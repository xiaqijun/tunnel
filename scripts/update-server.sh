#!/bin/bash

# Tunnel 服务器自动更新脚本
# 用法: curl -fsSL http://YOUR_SERVER:8080/api/update/script/linux | sudo bash

set -e

REPO="xiaqijun/tunnel"
INSTALL_DIR="/usr/local/bin"
SERVICE_NAME="tunnel-server"
GITHUB_API="https://api.github.com/repos/$REPO/releases/latest"

echo "================================"
echo "Tunnel 服务器自动更新"
echo "================================"

# 检查是否以root运行
if [ "$EUID" -ne 0 ]; then 
    echo "❌ 请使用 sudo 运行此脚本"
    exit 1
fi

# 获取当前版本
CURRENT_VERSION=""
if [ -f "$INSTALL_DIR/tunnel-server" ]; then
    CURRENT_VERSION=$($INSTALL_DIR/tunnel-server -version 2>&1 | grep -oP 'Tunnel \K[0-9.]+' || echo "unknown")
    echo "📌 当前版本: $CURRENT_VERSION"
else
    echo "⚠️  未检测到已安装的版本"
fi

# 获取最新版本信息
echo "🔍 检查最新版本..."
LATEST_INFO=$(curl -s "$GITHUB_API")
LATEST_VERSION=$(echo "$LATEST_INFO" | grep -oP '"tag_name": "\K[^"]+')
LATEST_VERSION_NUM=$(echo "$LATEST_VERSION" | sed 's/^v//')

if [ -z "$LATEST_VERSION" ]; then
    echo "❌ 无法获取最新版本信息"
    exit 1
fi

echo "📦 最新版本: $LATEST_VERSION_NUM"

# 检查是否需要更新
if [ "$CURRENT_VERSION" == "$LATEST_VERSION_NUM" ]; then
    echo "✅ 已是最新版本，无需更新"
    exit 0
fi

# 检测系统架构
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo "❌ 不支持的架构: $ARCH"
        exit 1
        ;;
esac

# 构建下载URL
DOWNLOAD_FILE="tunnel-$LATEST_VERSION-linux-$ARCH.tar.gz"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_VERSION/$DOWNLOAD_FILE"

echo "📥 下载地址: $DOWNLOAD_URL"

# 创建临时目录
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "⬇️  正在下载..."
if ! curl -fsSL -o "$DOWNLOAD_FILE" "$DOWNLOAD_URL"; then
    echo "❌ 下载失败"
    rm -rf "$TMP_DIR"
    exit 1
fi

echo "📦 正在解压..."
tar -xzf "$DOWNLOAD_FILE"

# 进入解压后的目录
cd linux-$ARCH

# 停止服务
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "⏸️  停止服务..."
    systemctl stop "$SERVICE_NAME"
    SERVICE_WAS_RUNNING=true
else
    SERVICE_WAS_RUNNING=false
fi

# 备份旧版本
if [ -f "$INSTALL_DIR/bin/tunnel-server" ]; then
    echo "💾 备份旧版本..."
    mv "$INSTALL_DIR/bin/tunnel-server" "$INSTALL_DIR/bin/tunnel-server.backup.$(date +%Y%m%d%H%M%S)"
fi

if [ -f "$INSTALL_DIR/bin/tunnel-client" ]; then
    mv "$INSTALL_DIR/bin/tunnel-client" "$INSTALL_DIR/bin/tunnel-client.backup.$(date +%Y%m%d%H%M%S)"
fi

# 安装新版本
echo "📦 安装新版本..."
mkdir -p "$INSTALL_DIR/bin"
mv tunnel-server "$INSTALL_DIR/bin/"
mv tunnel-client "$INSTALL_DIR/bin/"
chmod +x "$INSTALL_DIR/bin/tunnel-server"
chmod +x "$INSTALL_DIR/bin/tunnel-client"

# 更新web文件（如果存在）
if [ -d "web" ]; then
    echo "🌐 更新 Web 文件..."
    rm -rf "$INSTALL_DIR/web"
    cp -r web "$INSTALL_DIR/"
fi

# 启动服务
if [ "$SERVICE_WAS_RUNNING" = true ]; then
    echo "▶️  启动服务..."
    systemctl start "$SERVICE_NAME"
    
    # 等待服务启动
    sleep 2
    
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "✅ 服务已成功启动"
    else
        echo "⚠️  服务启动失败，请检查日志: journalctl -u $SERVICE_NAME"
    fi
fi

# 清理临时文件
cd /
rm -rf "$TMP_DIR"

# 显示新版本
NEW_VERSION=$($INSTALL_DIR/bin/tunnel-server -version 2>&1 | grep -oP 'Tunnel \K[0-9.]+' || echo "unknown")
echo ""
echo "================================"
echo "✅ 更新完成！"
echo "   $CURRENT_VERSION → $NEW_VERSION"
echo "================================"

# 显示服务状态
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "📊 服务状态: 运行中 ✓"
else
    echo "📊 服务状态: 已停止"
fi
