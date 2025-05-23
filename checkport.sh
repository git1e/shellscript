#!/bin/bash

#通过nc命令探测AD的端口是否存在,并在异常时通过钉钉告警。

# nc 命令可以测试端口连通性和端口扫描，安装yum install nc -y
# 参数
# -w<超时秒数> 设置等待连线的时间
# -z 使用0输入/输出模式，只在扫描通信端口时使用。

Date=`date +%Y%m%d%H%M`
SERVER=server_address
PORT=389

`nc -z -w5 $SERVER $PORT`
result1=$?
json="date:$Date server:$SERVER port:$PORT ad 域 is error"
TOKEN="'https://oapi.dingtalk.com/robot/send?access_token=xxxx'"
DING_MSG="curl ${TOKEN} -H 'Content-Type: application/json'  -d '{\"msgtype\": \"text\", \"text\": {\"content\": \"${json}\"}}'"

if [  "$result1" != 0 ]; then
  echo  $json|tee -a /tmp/adCheck.log
  eval $DING_MSG
else
  echo  "date:$Date server:${SERVER},port:${PORT} is ok" |tee -a /tmp/adCheck.log
fi
