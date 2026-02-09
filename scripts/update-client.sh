#!/bin/bash

# Tunnel 客户端自动更新脚本

set -e

REPO="xiaqijun/tunnel"
INSTALL_DIR="."
GITHUB_API="https://api.github.com/repos/$REPO/releases/latest"

echo "================================"
echo "Tunnel 客户端自动更新"
echo "================================"

# 获取当前版本
CURRENT_VERSION=""
if [ -f "./tunnel-client" ]; then
    CURRENT_VERSION=$(./tunnel-client -version 2>&1 | grep -oP 'Tunnel \K[0-9.]+' || echo "unknown")
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

# 检查客户端是否在运行
if pgrep -x "tunnel-client" > /dev/null; then
    echo "⏸️  检测到客户端正在运行，需要手动停止后再运行此脚本"
    echo "   kill \$(pgrep tunnel-client)"
    rm -rf "$TMP_DIR"
    exit 1
fi

# 备份旧版本
if [ -f "$INSTALL_DIR/tunnel-client" ]; then
    echo "💾 备份旧版本..."
    mv "$INSTALL_DIR/tunnel-client" "$INSTALL_DIR/tunnel-client.backup.$(date +%Y%m%d%H%M%S)"
fi

# 安装新版本
echo "📦 安装新版本..."
cp tunnel-client "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/tunnel-client"

# 清理临时文件
cd - > /dev/null
rm -rf "$TMP_DIR"

# 显示新版本
NEW_VERSION=$($INSTALL_DIR/tunnel-client -version 2>&1 | grep -oP 'Tunnel \K[0-9.]+' || echo "unknown")
echo ""
echo "================================"
echo "✅ 更新完成！"
echo "   $CURRENT_VERSION → $NEW_VERSION"
echo "================================"
echo ""
echo "💡 提示: 现在可以运行客户端"
echo "   ./tunnel-client -config client-config.yaml"
