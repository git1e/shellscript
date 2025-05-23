#!/bin/bash
#检测指定的url的连通性。
##############################################################
url="www.baidu.com"

num=`curl -I -m 5 -s -w "%{http_code}\n" -o /dev/null $url|grep 200|wc -l`
if [ $num -eq 1 ] #<==采用获取状态码，并转为数字的方式判断，如果301认为正确也可以加上egrep过滤。
then
     echo "$url is ok"
else
     echo "$url is fail"
fi
