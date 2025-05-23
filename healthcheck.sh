#!/bin/bash
#    -g<网关> 设置路由器跃程通信网关，最多可设置8个。
#    -G<指向器数目> 设置来源路由指向器，其数值为4的倍数。
#    -h 在线帮助。
#    -i<延迟秒数> 设置时间间隔，以便传送信息及扫描通信端口。
#    -l 使用监听模式，管控传入的资料。
#    -n 直接使用IP地址，而不通过域名服务器。
#    -o<输出文件> 指定文件名称，把往来传输的数据以16进制字码倾倒成该文件保存。
#    -p<通信端口> 设置本地主机使用的通信端口。
#    -r <端口>指定本地与远端主机的通信端口。
#    -s<来源位址> 设置本地主机送出数据包的IP地址。
#    -u 使用UDP传输协议。
#    -v 详细输出--用两个-v可得到更详细的内容
#    -w<超时秒数> 设置等待连线的时间。
#    -z 使用0输入/输出模式，只在扫描通信端口时使用。

#!/bin/bash

# -w<超时秒数> 设置等待连线的时间
# -z 使用0输入/输出模式，只在扫描通信端口时使用。

Date=`date +%Y%m%d%H%M`
SERVER=10.36.30.86
PORT=389

`nc -z -w5 $SERVER $PORT`
result1=$?
json="date:$Date server:$SERVER port:$PORT is error"
TOKEN="'https://oapi.dingtalk.com/robot/send?access_token=xxx'"
DING_MSG="curl ${TOKEN} -H 'Content-Type: application/json'  -d '{\"msgtype\": \"text\", \"text\": {\"content\": \"${json}\"}}'"

if [  "$result1" != 0 ]; then
  echo  $json|tee -a /tmp/adCheck.log
  eval $DING_MSG
else
  echo  "date:$Date server:${SERVER},port:${PORT} is ok" |tee -a /tmp/adCheck.log
fi




#################
cat>ip-ports.txt<<EOF
192.168.0.1 22
192.168.0.2 22
192.168.0.3 22
EOF

cat ip-ports.txt | while read line
do
Date=`date +%Y%m%d%H%M`

`nc -z -w5 $line`
result1=$?
json="date:$Date $line is error"
TOKEN="'https://oapi.dingtalk.com/robot/send?access_token=xxx'"
DING_MSG="curl ${TOKEN} -H 'Content-Type: application/json'  -d '{\"msgtype\": \"text\", \"text\": {\"content\": \"${json}\"}}'"

if [  "$result1" != 0 ]; then
  echo  $json|tee -a /tmp/adCheck.log
  eval $DING_MSG
else
  echo  "date:$Date $line is ok" |tee -a /tmp/adCheck.log
fi
done