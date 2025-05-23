#!/bin/bash

NGINX_LOG_DIR=/data/logs/nginx
DATE=`date +%Y%m%d-%H%M%S`
cd $NGINX_LOG_DIR

#删除3天前的日志。
find $NGINX_LOG_DIR -mtime +3 -type f -name '*.log'|xargs rm -f


# 日志切割
LOGS_FILE=`ls|grep log$`
for NGINX_LOG in $LOGS_FILE
do
    mv NGINX_LOG NGINX_LOG-$DATE
done
#重新打开日志文件
nginx -s reopen


#定时任务
##########
0 1 * * * /bin/sh /usr/local/script/nginx_cut_del.sh
##########