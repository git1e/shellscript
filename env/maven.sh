#!/bin/bash

# 定义变量
MAVEN_VERSION="3.6.3"
MAVEN_URL="https://mirrors.huaweicloud.com/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
INSTALL_DIR="/usr/local"
MAVEN_DIR="${INSTALL_DIR}/apache-maven-${MAVEN_VERSION}"

# 检查是否以 root 用户运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 用户或通过 sudo 运行此脚本"
    exit 1
fi

# 检查是否已安装 Java
if ! command -v java &> /dev/null; then
    echo "Java 未安装，请先安装 Java"
    exit 1
fi

# 检查 Maven 是否已安装
if command -v mvn &> /dev/null; then
    echo "Maven 已安装，版本信息如下："
    mvn --version
    exit 0
fi



# 下载 Maven
echo "正在下载 Apache Maven ${MAVEN_VERSION}..."
wget -q ${MAVEN_URL} -O /tmp/apache-maven.tar.gz

# 解压 Maven
echo "正在解压 Maven..."
tar -xzf /tmp/apache-maven.tar.gz -C ${INSTALL_DIR}



# 设置环境变量
echo "设置环境变量..."
cat <<EOF >> /etc/profile
export MAVEN_HOME=${MAVEN_DIR}
export PATH=\${MAVEN_HOME}/bin:\${PATH}
EOF

# 使环境变量生效
source /etc/profile

# 验证安装
echo "验证 Maven 安装..."
mvn --version

# 清理下载的文件
rm /tmp/apache-maven.tar.gz

echo "Apache Maven ${MAVEN_VERSION} 已成功安装到 ${MAVEN_DIR}"