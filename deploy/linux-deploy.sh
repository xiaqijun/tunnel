#!/bin/bash
# Tunnel Server Linux 部署脚本

set -e

echo "================================"
echo "  Tunnel Server 自动部署脚本"
echo "================================"
echo ""

# 检查 Go 是否安装
if ! command -v go &> /dev/null; then
    echo "❌ 未检测到 Go 环境，开始安装 Go 1.21+"
    
    # 下载并安装 Go（根据架构选择）
    ARCH=$(uname -m)
    if [ "$ARCH" == "x86_64" ]; then
        GO_ARCH="amd64"
    elif [ "$ARCH" == "aarch64" ]; then
        GO_ARCH="arm64"
    else
        echo "不支持的架构: $ARCH"
        exit 1
    fi
    
    GO_VERSION="1.21.6"
    wget https://golang.org/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
    rm go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
    
    # 设置环境变量
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    export PATH=$PATH:/usr/local/go/bin
    
    echo "✅ Go 安装完成"
else
    echo "✅ Go 已安装: $(go version)"
fi

echo ""
echo "开始编译服务器端..."

# 创建 bin 目录
mkdir -p bin

# 编译服务器端
go build -ldflags="-s -w" -o bin/tunnel-server ./cmd/server
if [ $? -eq 0 ]; then
    echo "✅ 服务器端编译成功"
else
    echo "❌ 服务器端编译失败"
    exit 1
fi

# 编译客户端
go build -ldflags="-s -w" -o bin/tunnel-client ./cmd/client
if [ $? -eq 0 ]; then
    echo "✅ 客户端编译成功"
else
    echo "❌ 客户端编译失败"
    exit 1
fi

echo ""
echo "设置权限..."
chmod +x bin/tunnel-server
chmod +x bin/tunnel-client

echo ""
echo "================================"
echo "  编译完成！"
echo "================================"
echo ""
echo "可执行文件位置："
echo "  - 服务器端: $(pwd)/bin/tunnel-server"
echo "  - 客户端:   $(pwd)/bin/tunnel-client"
echo ""
echo "配置文件："
echo "  - 服务器配置: $(pwd)/config.yaml"
echo "  - 客户端配置: $(pwd)/client-config.yaml"
echo ""
echo "运行服务器："
echo "  ./bin/tunnel-server -config config.yaml"
echo ""
