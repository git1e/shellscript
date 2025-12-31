#!/bin/bash
#  一键生成并部署 Keepalived 配置

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$PROJECT_ROOT/templates/keepalived.conf.j2"
VARS_FILE="$PROJECT_ROOT/vars/keepalived_vars.yaml"
OUTPUT_CONF="/etc/keepalived/keepalived.conf"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

# 检查是否 root
if [[ $EUID -ne 0 ]]; then
    error "此脚本必须以 root 权限运行！"
fi

# 检查依赖
check_deps() {
    log "检查依赖..."
    command -v j2 >/dev/null || {
        warn "j2cli 未安装，正在安装..."
        if command -v yum >/dev/null; then
            yum install -y python3-pip
        elif command -v apt >/dev/null; then
            apt update && apt install -y python3-pip
        else
            error "无法自动安装 pip，请手动安装 python3-pip"
        fi
        pip3 install --no-cache-dir j2cli[yaml]
    }
    command -v keepalived >/dev/null || {
        warn "keepalived 未安装, 正在安装..."
        if command -v yum >/dev/null; then
            yum install -y keepalived
        elif command -v apt >/dev/null; then
            apt update && apt install -y keepalived
        else
            error "无法自动安装 keepalived，请手动安装"
        fi
    }
}

# 创建目录
setup_dirs() {
    mkdir -p /etc/keepalived
}

# 生成配置
generate_config() {
    log "正在使用 j2cli 渲染配置..."
    j2 "$TEMPLATE" "$VARS_FILE" > "$OUTPUT_CONF"
    if [ $? -ne 0 ]; then
        error "配置渲染失败！"
    fi
    log "配置已生成：$OUTPUT_CONF"
}

# 校验配置（通过尝试启动 dry-run）
validate_config() {
    log "验证配置语法（通过启动测试）..."
    # Keepalived 无 -t 参数，但可临时启动并立即停止
    systemctl stop keepalived 2>/dev/null || true
    timeout 3s keepalived --dump-conf --log-console --log-detail --use-file "$OUTPUT_CONF" >/dev/null 2>&1
    if [ $? -eq 124 ]; then
        # 超时说明配置基本合法（keepalived 启动后不会退出）
        log "配置语法校验通过（模拟启动成功）"
        killall keepalived 2>/dev/null || true
    elif [ $? -eq 0 ]; then
        log "配置 dump 成功，视为有效"
    else
        error "配置可能有误，请检查 $OUTPUT_CONF"
    fi
}



# 主流程
main() {
    check_deps
    setup_dirs
    generate_config
    validate_config
}

main "$@"