#!/bin/bash
# 从 GitHub Releases 下载预编译的二进制文件并安装
# 适用于 Linux 服务器快速部署

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=================================="
echo "  Tunnel 快速安装脚本"
echo "  (使用预编译二进制)"
echo "=================================="
echo ""

# 配置
GITHUB_REPO="xiaqijun/tunnel"
INSTALL_DIR="/opt/tunnel"
VERSION="${1:-latest}"  # 默认使用最新版本

# 检测系统架构
ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    PLATFORM="linux-amd64"
elif [ "$ARCH" == "aarch64" ] || [ "$ARCH" == "arm64" ]; then
    PLATFORM="linux-arm64"
else
    echo -e "${RED}不支持的架构: $ARCH${NC}"
    exit 1
fi

echo -e "${YELLOW}检测到系统架构: $PLATFORM${NC}"
echo ""

# 创建临时目录
TMP_DIR=$(mktemp -d)
cd $TMP_DIR

echo -e "${YELLOW}步骤 1/6: 下载预编译二进制文件${NC}"

if [ "$VERSION" == "latest" ]; then
    DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/download/latest/tunnel-${PLATFORM}.tar.gz"
    echo "下载最新版本..."
else
    DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/download/${VERSION}/tunnel-${PLATFORM}.tar.gz"
    echo "下载版本 $VERSION..."
fi

echo "下载地址: $DOWNLOAD_URL"

if command -v wget &> /dev/null; then
    wget -q --show-progress "$DOWNLOAD_URL" -O tunnel.tar.gz
elif command -v curl &> /dev/null; then
    curl -L "$DOWNLOAD_URL" -o tunnel.tar.gz
else
    echo -e "${RED}错误: 需要 wget 或 curl${NC}"
    exit 1
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 下载完成${NC}"
else
    echo -e "${RED}✗ 下载失败${NC}"
    echo "请检查："
    echo "  1. 网络连接是否正常"
    echo "  2. GitHub 是否可访问"
    echo "  3. Release 版本是否存在"
    exit 1
fi

echo ""
echo -e "${YELLOW}步骤 2/6: 解压文件${NC}"
tar -xzf tunnel.tar.gz
echo -e "${GREEN}✓ 解压完成${NC}"

echo ""
echo -e "${YELLOW}步骤 3/6: 安装到系统${NC}"
# 创建安装目录
mkdir -p $INSTALL_DIR/bin
mkdir -p $INSTALL_DIR/logs

# 复制二进制文件
cp tunnel-server-${PLATFORM} $INSTALL_DIR/bin/tunnel-server
cp tunnel-client-${PLATFORM} $INSTALL_DIR/bin/tunnel-client

# 设置执行权限
chmod +x $INSTALL_DIR/bin/tunnel-server
chmod +x $INSTALL_DIR/bin/tunnel-client

echo -e "${GREEN}✓ 二进制文件已安装到 $INSTALL_DIR/bin/${NC}"

echo ""
echo -e "${YELLOW}步骤 4/6: 下载配置文件${NC}"
# 如果配置文件不存在，下载默认配置
if [ ! -f "$INSTALL_DIR/config.yaml" ]; then
    echo "下载默认配置文件..."
    wget -q https://raw.githubusercontent.com/${GITHUB_REPO}/main/config.yaml -O $INSTALL_DIR/config.yaml
    wget -q https://raw.githubusercontent.com/${GITHUB_REPO}/main/client-config.yaml -O $INSTALL_DIR/client-config.yaml
    
    # 生成随机 token
    RANDOM_TOKEN=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    sed -i "s/token:.*/token: \"$RANDOM_TOKEN\"/" $INSTALL_DIR/config.yaml
    
    echo -e "${GREEN}✓ 配置文件已创建${NC}"
    echo -e "${YELLOW}  Token: $RANDOM_TOKEN${NC}"
    echo -e "${YELLOW}  请记录此 Token！${NC}"
else
    echo -e "${YELLOW}配置文件已存在，跳过${NC}"
fi

echo ""
echo -e "${YELLOW}步骤 5/6: 下载 Web 界面${NC}"
if [ ! -d "$INSTALL_DIR/web" ]; then
    mkdir -p $INSTALL_DIR/web
    wget -q https://raw.githubusercontent.com/${GITHUB_REPO}/main/web/index.html -O $INSTALL_DIR/web/index.html
    wget -q https://raw.githubusercontent.com/${GITHUB_REPO}/main/web/app.js -O $INSTALL_DIR/web/app.js
    wget -q https://raw.githubusercontent.com/${GITHUB_REPO}/main/web/style.css -O $INSTALL_DIR/web/style.css
    echo -e "${GREEN}✓ Web 界面已下载${NC}"
else
    echo -e "${YELLOW}Web 目录已存在，跳过${NC}"
fi

echo ""
echo -e "${YELLOW}步骤 6/6: 安装 systemd 服务${NC}"

# 创建 systemd 服务文件
cat > /etc/systemd/system/tunnel-server.service << EOF
[Unit]
Description=Tunnel Server - High Performance NAT Traversal Service
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/bin/tunnel-server -config $INSTALL_DIR/config.yaml
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=tunnel-server

# 安全设置
NoNewPrivileges=true
PrivateTmp=true

# 资源限制
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

# 重载 systemd
systemctl daemon-reload
echo -e "${GREEN}✓ systemd 服务已安装${NC}"

# 清理临时文件
cd /
rm -rf $TMP_DIR

echo ""
echo "=================================="
echo -e "${GREEN}  安装完成！${NC}"
echo "=================================="
echo ""
echo "安装位置："
echo "  $INSTALL_DIR"
echo ""
echo "可执行文件："
echo "  服务器: $INSTALL_DIR/bin/tunnel-server"
echo "  客户端: $INSTALL_DIR/bin/tunnel-client"
echo ""
echo "配置文件："
echo "  $INSTALL_DIR/config.yaml"
echo "  $INSTALL_DIR/client-config.yaml"
echo ""
echo "下一步操作："
echo ""
echo "1. 配置防火墙（开放端口 7000 和 8080）："
echo "   ufw allow 7000/tcp"
echo "   ufw allow 8080/tcp"
echo ""
echo "2. 启动服务："
echo "   systemctl start tunnel-server"
echo ""
echo "3. 设置开机自启："
echo "   systemctl enable tunnel-server"
echo ""
echo "4. 查看状态："
echo "   systemctl status tunnel-server"
echo ""
echo "5. 查看日志："
echo "   journalctl -u tunnel-server -f"
echo ""
