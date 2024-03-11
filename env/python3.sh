#!/bin/bash
#Description: Centos7下python2升级成Python3

download(){ 
    yum install wget zlib* gcc* openssl openssl-devel  libffi libffi-devel  -y
    wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz
    xz -d Python-3.7.3.tar.xz
    tar -xvf Python-3.7.3.tar
}

compile(){
    cd Python-3.7.3
    ./configure --prefix=/usr/local/python3 --with-ssl --enable-shared
    make && make install
}

create_link(){
    ln -s /usr/local/python3/bin/python3.7 /usr/bin/python3
    ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
    echo "/usr/local/python3/lib" >/etc/ld.so.conf.d/python3.conf
    ldconfig
    pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/
    python3 --version
}
#安装virtualenv
install_virtualenv(){
    echo "安装virtualenv"
    pip3 install virtualenv
    ln -fs /usr/local/python3/bin/virtualenv /usr/bin/virtualenv 
}

main(){
    download
    compile
    create_link
    install_virtualenv
}

main