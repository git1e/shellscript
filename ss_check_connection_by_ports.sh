#!/bin/bash

# 
PORTS=("22" "80" "443")
EXCLUDE_IPS=("127.0.0.1" "localhost" "192.168.1.2" "192.168.1.10")

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "正在检查与本地端口 ${GREEN}${PORTS[*]}${NC} 的连接, 已排除IP: ${GREEN}${EXCLUDE_IPS[*]}${NC}"
echo -e "========================================\n"

# 生成排除模式，用于grep -vE
generate_exclude_pattern() {
    local pattern=""
    for ip in "${EXCLUDE_IPS[@]}"; do
        pattern+="$ip|"
    done
    pattern+="127\\.0\\.0\\.1|localhost|^::"
    
    # 移除末尾可能存在的 |
    echo "$pattern" | sed 's/|$//'
}

EXCLUDE_PATTERN=$(generate_exclude_pattern)

# 函数：检查单个端口
check_port() {
    local port=$1
    
    echo -e "${GREEN}本地端口 $port 连接分析:${NC}"
    
    # 直接通过管道处理，避免中间变量
    local connection_count=$(ss -tn state connected sport = :"$port" 2>/dev/null | awk 'END{if(NR>1) print NR-1; else print 0}')
    
    if [ "$connection_count" -eq 0 ]; then
        echo -e "  暂无连接\n"
        return
    fi
    
    
    # 使用更高效的方式
    ip_list=$(ss -tn state connected sport = :"$port" 2>/dev/null | \
              awk 'NR>1 {print $5}' | \
              cut -d: -f1 | \
              grep -vE "$EXCLUDE_PATTERN" | \
              sort)
    
    if [ -z "$ip_list" ]; then
        echo "  所有连接均在排除列表中"
    else
        # 直接使用 sort 和 uniq 统计并排序
        echo "$ip_list" | \
            sort | \
            uniq -c | \
            sort -k1 -nr | \
            while read count ip; do
                echo "  $ip: $count 个连接"
            done
    fi
    echo -e "\n----------------------------------------\n"
}

# 主循环
for port in "${PORTS[@]}"; do
    check_port "$port"
done

echo -e "${GREEN}检查完成！${NC}"
