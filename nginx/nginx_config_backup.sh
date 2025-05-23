#!/bin/bash

# 定义备份目录、源目录和日志文件
BACKUP_DIR="/data/backup"
SOURCE_DIR="/etc/nginx"
LOG_FILE="/var/log/nginx_config_backup.log"

# 创建备份目录（如果不存在）
mkdir -p $BACKUP_DIR

# 获取当前日期
DATE=$(date +%Y%m%d%H%M%S)

# 打包并备份Nginx配置文件
tar -czf $BACKUP_DIR/nginx_config_backup_$DATE.tar.gz -C /etc nginx

# 检查备份是否成功并将结果记录到日志文件
if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_DIR/nginx_config_backup_$DATE.tar.gz" | tee -a $LOG_FILE
else
    echo "Backup failed" | tee -a $LOG_FILE
fi