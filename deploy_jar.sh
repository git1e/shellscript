#!/bin/bash
#将脚本放在jar包同级目录。用法sh deploy_jar.sh jar_name [start|stop|restart|status|deployment]
Date=`date +%Y%m%d%H%M`
#存放要发布jar包路径
tmp_path="/var/tmp"
#生产jar包路径
svc_path=`cd $(dirname $0); pwd -P`
#创建备份路径
mkdir -p $svc_path/backup/$Date
#备份路径
backup_dir=$svc_path/backup/$Date
jar_name=$1


#使用说明，用来提示输入参数
usage() {
    echo "Usage: sh $0 $jar_name [start|stop|restart|status|deployment]"
    exit 1
}

#检查程序是否在运行
is_exist() { 
    pid=`ps -ef |grep java| grep $jar_name | grep -v grep | awk '{print $2}' `
    #如果不存在返回1，存在返回0
    if [ -z "${pid}" ]; then
      return 1
    else
      return 0
    fi
}

#启动方法
start() {
   is_exist
   if [ $? -eq "0" ]; then
     echo "$jar_name is already running. pid=${pid} ."
   else
     nohup java -jar $svc_path/$jar_name > /dev/null 2>&1 &
     echo "$jar_name is starting"
   fi
   
}

#停止方法
stop() {
   is_exist
   if [ $? -eq "0" ]; then
     kill -9 $pid
     echo "$jar_name is stoping"
   else
     echo "$jar_name is not running"
     
   fi
   
}

#输出运行状态
status() {
   is_exist
   if [ $? -eq "0" ]; then
     echo "$jar_name is running. Pid is ${pid}"
   else
     echo "$jar_name is not running."
   fi
}

#重启
restart() {
   stop
   start
}

#!备份、替换jar包
backup() {
   if  [ -f $jar_name ]; then 
	cp $svc_path/$jar_name $backup_dir/
	if [ $? -eq "0" ]; then
		echo "$jar_name is backup successed"
		cp -a $tmp_path/$jar_name $svc_path/
	fi
   else
	echo "$jar_name is not exist ! backup failed."
	cp -a $tmp_path/$jar_name $svc_path/
fi

}

#部署
deployment() {
stop
backup
start
echo "$jar_name deploymented"
}

#根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$2" in
   "start")
     start
     ;;
   "stop")
     stop
     ;;
   "status")
     status
     ;;
   "restart")
     restart
     ;;
   "deployment")
     deployment
     ;;
   *)
     usage
     ;;
esac
