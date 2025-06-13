#!/bin/bash
# 判断java是否安装
JAVA_DIR=/usr/local/java
# 支持的Java版本
SUPPORTED_VERSIONS=("17.0.2" "11.0.2" "21.0.2")
# 默认Java版本
DEFAULT_VERSION="17.0.2"

# 选择Java版本
select_java_version() {
    echo "请选择Java版本（默认为$DEFAULT_VERSION）:"
    select version in "${SUPPORTED_VERSIONS[@]}" "退出"; do
        case $version in
            "退出")
                echo "退出安装"
                exit 0
                ;;
            *)
                if [[ " ${SUPPORTED_VERSIONS[@]} " =~ " ${version} " ]]; then
                    JAVA_VERSION=$version
                    break
                else
                    echo "无效的选择，请重新输入"
                fi
                ;;
        esac
    done
}

JAVA_FILE=openjdk-${JAVA_VERSION}_linux-x64_bin.tar.gz  
JDK_URL=https://mirrors.huaweicloud.com/openjdk/${JAVA_VERSION}

# 创建环境变量配置文件
create_env_config() {
    cat <<EOF > /etc/profile.d/java.sh
export JAVA_HOME=$JAVA_DIR
export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH
EOF
    source /etc/profile.d/java.sh
}

install_java() {
    echo '开始安装'
    
    # 检查父目录是否存在
    if [ ! -d "/usr/local" ]; then
        echo "错误: /usr/local 目录不存在" >&2
        exit 1
    fi
    
    # 创建JAVA_DIR目录
    mkdir -p "$JAVA_DIR" || { echo "错误: 创建 $JAVA_DIR 失败" >&2; exit 1; }
    
    # 解压JDK文件
    tar zxf "$JAVA_FILE" -C "$JAVA_DIR" --strip-components 1 || { echo "错误: 解压 $JAVA_FILE 失败" >&2; exit 1; }
    
    # 创建环境变量配置
    create_env_config
    
    echo "JDK安装完成"
}

check_java() {
    if command -v java &>/dev/null; then
        echo 'java 已经安装'
        exit 0
    elif [ -d "$JAVA_HOME" ]; then
        echo "\$JAVA_HOME 已经存在，请检查java环境是否正常"
        exit 0
    fi
}

download_java() {
    if [ ! -f "$JAVA_FILE" ]; then
        echo '开始下载java安装包'
        curl -s -o "$JAVA_FILE" "$JDK_URL/$JAVA_FILE" || { echo "错误: 下载 $JAVA_FILE 失败" >&2; exit 1; }
    fi
}

main() {
    # 选择Java版本
    select_java_version
    
    check_java
    download_java
    install_java
    
    # 验证安装
    if java -version &>/dev/null; then
        echo "JDK安装成功"
        java -version
    else
        echo "错误: JDK安装失败" >&2
        exit 1
    fi
}

main