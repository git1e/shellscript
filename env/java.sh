#!/bin/bash
# 判断java是否安装
JAVA_HOME=/usr/local/java
JAVA_FILE=jdk-8u301-linux-x64

yum install -y wget
install_java(){
    echo '开始安装'
    mkdir $JAVA_HOME
    tar zxf $JAVA_FILE.tar.gz -C $JAVA_HOME --strip-components 1 && \
    #jdk env
    echo "export JAVA_HOME=$JAVA_HOME" >>/etc/profile && \
    echo "export JRE_HOME=$JAVA_HOME/jre" >>/etc/profile && \
    echo "export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >>/etc/profile && \
    echo "export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH" >>/etc/profile && \
    source /etc/profile
}

if [ `command -v java` ];then
    echo 'java 已经安装'
    exit 0
elif [ -d "$JAVA_HOME" ];then
    echo '$JAVA_HOME 已经存在，请检查java环境是否正常'
    exit 0
elif [ -f "$JAVA_FILE.tar.gz" ];then
    echo 'java 安装包已经存在'
    install_java
else
    echo '开始下载java安装包'
    wget https://d6.injdk.cn/oraclejdk/8/$JAVA_FILE.tar.gz
    install_java
    if [ $? -eq "0" ]; then
     echo "jdk已经安装完成"
     java -version
   else
     echo "jdk 安装失败"
     
   fi
fi
