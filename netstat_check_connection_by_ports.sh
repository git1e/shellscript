#!/bin/bash
set -euo pipefail

# 
PORTS=("80" "443")
EXCLUDE_IPS=("127.0.0.1" "localhost" "192.168.1.2" "192.168.1.10")

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "正在检查与本地端口 ${GREEN}${PORTS[*]}${NC} 的连接, 已排除IP: ${GREEN}${EXCLUDE_IPS[*]}${NC}"

# 生成排除模式，用于grep -vE
generate_exclude_pattern() {
    local pattern=""
    for ip in "${EXCLUDE_IPS[@]}"; do
        pattern+="$ip|"
    done    
    # 移除末尾可能存在的 |
    echo "$pattern" | sed 's/|$//'
}

EXCLUDE_PATTERN=$(generate_exclude_pattern)


for port in "${PORTS[@]}"; do
    echo -e "\n端口 $port 连接分析:"
    echo "----------------------------"
    
    # 使用 netstat（输出格式更统一）
    netstat -tn 2>/dev/null | \
        awk -v port=":$port" '$4 ~ port  {print $5}' | \
        cut -d: -f1 | \
        grep -vE "$EXCLUDE_PATTERN" | \
        sort | uniq -c | sort -rn | \
        while read count ip; do
            echo "  $ip: $count 个连接"
        done
done

echo -e "\n检查完成！"
