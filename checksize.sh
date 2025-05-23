#!/bin/bash
#检测指定目录大小，当超过了磁盘规定大小，删除指定文件
#
Date=`date +%Y%m%d%H%M`
dir_path="/var/log/test"
volume_path="/"

disk_used=`df -hP $volume_path|sed -n '2p'|awk '{print int($5)}'`
if [ "$disk_used" -ge "70" ] ;then
       echo "$Date -- $volume_path size is greater than 80% will delete $dir_path files">>$0.log
       du -s $dir_path/*>file_size.txt
       awk '{if($1 >102500){print $2}}' file_size.txt|xargs rm -rf
fi
