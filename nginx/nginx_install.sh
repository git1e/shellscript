#!/bin/bash

set -exo pipefail
SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)
# nginx version,default 2.4.1
NGINX_VERSION='2.4.1'; [ -n "$1" ] && NGINX_VERSION="${1}"
PACKAGE_PATH="/tmp/nginx_install"

CONFIG_OPTIONS="--prefix=/usr/local/nginx \
--pid-path=/run/nginx.pid \
--user=nginx \
--group=nginx \
--with-file-aio \
--with-ipv6 \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_realip_module \
--with-stream_ssl_preread_module \
--with-http_addition_module \
--with-http_xslt_module=dynamic \
--with-http_image_filter_module=dynamic \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_degradation_module \
--with-http_slice_module \
--with-http_stub_status_module \
--with-http_perl_module=dynamic \
--with-http_auth_request_module \
--with-mail=dynamic \
--with-mail_ssl_module \
--with-pcre \
--with-pcre-jit \
--with-stream=dynamic \
--with-stream_ssl_module \
--with-google_perftools_module \
--with-debug \
--add-module=../ngx_dynamic_upstream \
--add-dynamic-module=../echo-nginx-module"





if [ -d "${PACKAGE_PATH}" ]; then
    echo "nginx package dir exists. delete..."
    rm -rf ${PACKAGE_PATH}
    mkdir ${PACKAGE_PATH}
else
    echo "nginx package dir does not exist. create..."
    mkdir ${PACKAGE_PATH}
fi



function yum_repo() {
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
    curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
    sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
    yum clean all && yum makecache
}

function install_tools() {
    yum_repo
    yum -y install git
}


function download_package() {
    install_tools
    echo "download nginx  package"
    cd ${PACKAGE_PATH}
    curl -O  https://tengine.taobao.org/download/tengine-${NGINX_VERSION}.tar.gz && tar zxf tengine-${NGINX_VERSION}.tar.gz
    echo "git clone echo-nginx-module"
    git clone -b v0.63 --depth 1 https://gitee.com/mirrors/echo-nginx-module.git
    git clone  --depth 1 https://github.com/cubicdaiya/ngx_dynamic_upstream.git
}


function install_dependency() {
    yum install -y gcc pcre pcre-devel openssl openssl-devel libxml2 libxml2-devel libxslt-devel gd-devel perl-devel perl-ExtUtils-Embed GeoIP GeoIP-devel GeoIP-data gperftools
}

function install_nginx() {
    useradd -M -s /sbin/nologin nginx 
    cd ${PACKAGE_PATH}/tengine-${NGINX_VERSION} && \
    ./configure  ${CONFIG_OPTIONS}  && \ 
    make  && \
    make install 

    ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx
    ln -s /usr/local/nginx/conf /etc/nginx

    # config nginx
    mkdir /data/logs/nginx /data/www/html -p
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
    cd ${SCRIPT_PATH}
    cp nginx.service /etc/systemd/system/nginx.service
    cp -a conf/* /etc/nginx/
    systemctl  daemon-reload && systemctl enable nginx

    # nginx logrotate
    cp nginx_logrotate /etc/logrotate.d/
}

download_package
install_dependency
install_nginx