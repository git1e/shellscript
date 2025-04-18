#!/bin/bash
set -e
npm_mirror(){
    npm config set registry https://registry.npmmirror.com
    echo "查看npm配置:"
    npm config list
}

pypi_mirror(){
    # 指定 pip 安装包时使用的全局默认源
    pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
    # 指定信任的主机地址
    pip config set install.trusted-host mirrors.aliyun.com
    echo "查看pip配置:"
    pip config list
}   

if [ `command -v npm` ];then
    echo "command npm exists on system"
    npm_mirror
fi

if [ "$(command -v pip)" ]; then
    echo "command pip exists on system"
    pypi_mirror
fi
