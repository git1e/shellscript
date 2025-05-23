#!/bin/bash
set -euxo pipefail

# 安装目录
install_dir="/data/redis"

# redis version
redis_version="6.2.9"

# 下载地址,http://download.redis.io/releases/redis-6.2.9.tar.gz   
redis_package_url="http://download.redis.io/releases/redis-${redis_version}.tar.gz"

download_redis() {
    # 安装依赖 
    yum -y install gcc

    # 
    mkdir -p ${install_dir}
    cd ${install_dir}
    # 如果不存在则下载
    if [ ! -f redis-${redis_version}.tar.gz ]; then
        echo "redis-${redis_version}.tar.gz not exist"
        curl -LO ${redis_package_url}
    fi
    
    if [ ! -d redis-${redis_version} ]; then 
        tar -zxvf redis-${redis_version}.tar.gz
    fi
    
    cd redis-${redis_version}
    make 
}

install_redis() {
    # 创建目录
    for i in $(seq 6370 6375); do
        mkdir -p ${install_dir}/redis-cluster-${i}/{data,logs}
        
        cat <<EOF > ${install_dir}/redis-cluster-${i}/redis.conf
bind 0.0.0.0
daemonize yes
protected-mode no
port ${i}
# 最大内存2G
#maxmemory 2147483648
# 代表Redis内存达到最大限制时，Redis不会自动清理或删除任何键来释放内存，新的写入请求将会被拒绝
#maxmemory-policy noeviction
# 开启集群
cluster-enabled yes
# redis登录密码，默认admin123456
requirepass admin123456
# redis认证密码,默认admin123456
masterauth admin123456
# 集群的配置，配置文件首次启动自动生成、
cluster-config-file ${install_dir}/redis-cluster-${i}/nodes.conf
cluster-node-timeout 5000
appendonly yes
#redis dump落盘文件
dbfilename dump.rdb
#redis aof落盘文件
appendfilename appendonly.aof
#redis日志文件
dir ${install_dir}/redis-cluster-${i}/data
logfile ${install_dir}/redis-cluster-${i}/logs/redis.log
EOF
    done

}

init_redis() {
    for i in $(seq 6370 6375); do
        ${install_dir}/redis-${redis_version}/src/redis-server ${install_dir}/redis-cluster-${i}/redis.conf
        redis_cluster_ips_ports+="127.0.0.1:$i "
    done
    # init cluster
    ${install_dir}/redis-${redis_version}/src/redis-cli --auth admin123456 --cluster create --cluster-replicas 1 ${redis_cluster_ips_ports} 

}

main() {
    download_redis
    install_redis
    init_redis

}
main