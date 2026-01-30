#!/bin/bash

# ==================== 脚本说明 ===================
# 自动 Git 提交流程
# 功能：监听指定目录的文件变化，并自动执行 Git 提交
# 用途：适用于需要自动记录文件变更的场景
#
# 用法：
# 1. 修改配置区中的 WATCH_DIR 为你想要监听的 Git 仓库路径
# 2. 确保 LOG_FILE 路径可写
# 3. 运行此脚本：./watch.sh
# 4. 脚本将持续运行并监听文件变化
#
# 注意事项：
# - 需要安装 inotify-tools
# - 确保 Git 已配置用户名和邮箱
# - 脚本将持续运行直到手动停止 (Ctrl+C)
# ================================================

# ==================== 配置区 ====================
WATCH_DIR="/root/ansible-keepalived"        # 替换为你的 Git 仓库路径
LOG_FILE="/var/log/auto_git.log"      # 日志文件路径（确保脚本有写权限）
MAX_FILES_IN_COMMIT_MSG=10            # 提交信息中最多列出的文件数
# ================================================

# 创建日志目录（如果不存在）
mkdir -p "$(dirname "$LOG_FILE")"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# 进入监控目录
cd "$WATCH_DIR" || { log "ERROR: 无法进入目录 $WATCH_DIR"; exit 1; }

# 确保 Git 配置
# git config --get user.name >/dev/null || git config user.name "Auto Commit Bot"
# git config --get user.email >/dev/null || git config user.email "bot@example.com"

log "INFO: 开始监控目录 $WATCH_DIR"

while true; do
  # 监听文件系统事件（输出完整路径）
  event_file=$(inotifywait -r -e modify,create,delete,move,moved_to --format '%w%f' "$WATCH_DIR")
  log "INFO: 检测到文件变更: $event_file"

  sleep 2  # 防抖：等待可能的批量写入完成

  # 暂存所有变更
  if ! git add . 2>>"$LOG_FILE"; then
    log "WARN: git add 失败，跳过本次提交"
    continue
  fi

  # 检查是否有实际暂存内容
  if git diff --cached --quiet; then
    log "INFO: 无实际变更，跳过提交"
    continue
  fi

  # 获取变更文件列表（格式：状态 + 文件名）
  changed_files=$(git diff --cached --name-status)
  file_count=$(echo "$changed_files" | wc -l)

  # 构建提交信息
  commit_msg="Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')\n\n"
  
  # 重置 action_files 变量，避免累积之前的数据
  action_files=""
  while IFS=$'\t' read -r status file; do
	  case "$status" in
		A) action="Added" ;;
		M) action="Modified" ;;
		D) action="Deleted" ;;
		R*) action="Renamed" ;;
		C*) action="Copied" ;;
		*) action="Changed ($status)" ;;
	  esac
	  action_files+="- $action: $file\n"
  done <<< "$(echo -e "$changed_files")"

  if [ "$file_count" -le "$MAX_FILES_IN_COMMIT_MSG" ]; then
    commit_msg+="Changed files:\n"
	commit_msg+="$action_files"

  else
    commit_msg+="Too many files changed ($file_count files). Showing summary only.\n"
    commit_msg+="Example files:\n"
    # 提取前N个文件
    example_files=$(echo -e "$action_files" | head -n $MAX_FILES_IN_COMMIT_MSG)
    commit_msg+="$example_files"
    commit_msg+="\n... and $((file_count - MAX_FILES_IN_COMMIT_MSG)) more files."
  fi

  commit_msg+="\n[Auto-committed by inotify script]"

  # 写入临时提交信息文件
  temp_msg=$(mktemp) || { log "ERROR: 无法创建临时文件"; continue; }
  echo -e "$commit_msg" > "$temp_msg"

  # 执行提交
  if git commit -F "$temp_msg" >>"$LOG_FILE" 2>&1; then
    commit_hash=$(git rev-parse HEAD)
    log "SUCCESS: 提交成功 - $commit_hash (共 $file_count 个文件)"
  else
    log "ERROR: git commit 失败"
  fi

  rm -f "$temp_msg"

  # 可选：自动推送（取消注释并配置好 SSH/Git 凭据）
  # if git push origin main >>"$LOG_FILE" 2>&1; then
  #   log "INFO: 推送成功"
  # else
  #   log "WARN: 推送失败"
  # fi
done
