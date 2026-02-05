#!/bin/bash
# Tunnel 自动部署到服务器 47.243.104.165
# 智能检测构建状态，自动下载并安装

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Tunnel 一键部署脚本${NC}"
echo -e "${BLUE}  服务器: 47.243.104.165${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# 配置
GITHUB_REPO="xiaqijun/tunnel"
TAG="v1.0.0"
INSTALL_DIR="/opt/tunnel"
ARCH=$(uname -m)

# 检测架构
if [ "$ARCH" == "x86_64" ]; then
    PLATFORM="linux-amd64"
elif [ "$ARCH" == "aarch64" ] || [ "$ARCH" == "arm64" ]; then
    PLATFORM="linux-arm64"
else
    echo -e "${RED}❌ 不支持的架构: $ARCH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 系统架构: $PLATFORM${NC}"
echo ""

# 函数：检查 release 是否存在
check_release() {
    echo -e "${YELLOW}检查 GitHub Release 状态...${NC}"
    
    DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/$TAG/tunnel-$PLATFORM.tar.gz"
    
    if curl --output /dev/null --silent --head --fail "$DOWNLOAD_URL"; then
        echo -e "${GREEN}✓ Release 文件已就绪${NC}"
        return 0
    else
        echo -e "${YELLOW}⏳ Release 文件尚未就绪，可能正在构建中...${NC}"
        return 1
    fi
}

# 等待 release 就绪（最多等待 5 分钟）
wait_for_release() {
    echo ""
    echo -e "${YELLOW}等待 GitHub Actions 构建完成...${NC}"
    
    MAX_ATTEMPTS=30  # 30次 x 10秒 = 5分钟
    ATTEMPT=0
    
    while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
        ATTEMPT=$((ATTEMPT + 1))
        echo -ne "\r${YELLOW}  尝试 $ATTEMPT/$MAX_ATTEMPTS ... ${NC}"
        
        if check_release >/dev/null 2>&1; then
            echo ""
            echo -e "${GREEN}✓ 构建完成！${NC}"
            return 0
        fi
        
        sleep 10
    done
    
    echo ""
    echo -e "${RED}❌ 等待超时。请检查：${NC}"
    echo "   https://github.com/$GITHUB_REPO/actions"
    echo "   https://github.com/$GITHUB_REPO/releases/tag/$TAG"
    exit 1
}

# 检查或等待 release
if ! check_release; then
    echo ""
    echo -e "${YELLOW}GitHub Actions 可能还在构建中...${NC}"
    echo -e "${YELLOW}正在等待构建完成（最多 5 分钟）${NC}"
    wait_for_release
fi

echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  开始安装${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# 步骤 1: 下载预编译文件
echo -e "${YELLOW}[1/8] 下载预编译二进制文件...${NC}"

TMP_DIR=$(mktemp -d)
cd $TMP_DIR

DOWNLOAD_URL="https://github.com/$GITHUB_REPO/releases/download/$TAG/tunnel-$PLATFORM.tar.gz"

if command -v wget &> /dev/null; then
    wget -q --show-progress "$DOWNLOAD_URL" -O tunnel.tar.gz
elif command -v curl &> /dev/null; then
    curl -L "$DOWNLOAD_URL" -o tunnel.tar.gz --progress-bar
else
    echo -e "${RED}❌ 需要 wget 或 curl${NC}"
    exit 1
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 下载完成${NC}"
else
    echo -e "${RED}❌ 下载失败${NC}"
    exit 1
fi

# 步骤 2: 解压
echo ""
echo -e "${YELLOW}[2/8] 解压文件...${NC}"
tar -xzf tunnel.tar.gz
echo -e "${GREEN}✓ 解压完成${NC}"

# 步骤 3: 停止旧服务（如果存在）
echo ""
echo -e "${YELLOW}[3/8] 检查并停止旧服务...${NC}"
if systemctl is-active --quiet tunnel-server 2>/dev/null; then
    systemctl stop tunnel-server
    echo -e "${GREEN}✓ 已停止旧服务${NC}"
else
    echo -e "${BLUE}  没有运行中的服务${NC}"
fi

# 步骤 4: 安装二进制文件
echo ""
echo -e "${YELLOW}[4/8] 安装二进制文件...${NC}"
mkdir -p $INSTALL_DIR/bin
mkdir -p $INSTALL_DIR/logs

cp tunnel-server-$PLATFORM $INSTALL_DIR/bin/tunnel-server
cp tunnel-client-$PLATFORM $INSTALL_DIR/bin/tunnel-client

chmod +x $INSTALL_DIR/bin/tunnel-server
chmod +x $INSTALL_DIR/bin/tunnel-client

echo -e "${GREEN}✓ 二进制文件已安装${NC}"

# 步骤 5: 配置文件
echo ""
echo -e "${YELLOW}[5/8] 配置服务器...${NC}"

if [ ! -f "$INSTALL_DIR/config.yaml" ]; then
    # 下载默认配置
    wget -q https://raw.githubusercontent.com/$GITHUB_REPO/main/config.yaml -O $INSTALL_DIR/config.yaml
    
    # 生成随机 token
    RANDOM_TOKEN=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
    sed -i "s/token:.*/token: \"$RANDOM_TOKEN\"/" $INSTALL_DIR/config.yaml
    
    echo -e "${GREEN}✓ 配置文件已创建${NC}"
    echo -e "${YELLOW}  Token: $RANDOM_TOKEN${NC}"
    echo -e "${RED}  请务必记录此 Token！${NC}"
    
    # 保存 token 到文件
    echo "$RANDOM_TOKEN" > $INSTALL_DIR/.token
    chmod 600 $INSTALL_DIR/.token
else
    echo -e "${BLUE}  配置文件已存在，保持不变${NC}"
fi

# 下载客户端配置模板
if [ ! -f "$INSTALL_DIR/client-config.yaml" ]; then
    wget -q https://raw.githubusercontent.com/$GITHUB_REPO/main/client-config.yaml -O $INSTALL_DIR/client-config.yaml
fi

# 步骤 6: Web 界面
echo ""
echo -e "${YELLOW}[6/8] 安装 Web 管理界面...${NC}"

mkdir -p $INSTALL_DIR/web
wget -q https://raw.githubusercontent.com/$GITHUB_REPO/main/web/index.html -O $INSTALL_DIR/web/index.html
wget -q https://raw.githubusercontent.com/$GITHUB_REPO/main/web/app.js -O $INSTALL_DIR/web/app.js
wget -q https://raw.githubusercontent.com/$GITHUB_REPO/main/web/style.css -O $INSTALL_DIR/web/style.css

echo -e "${GREEN}✓ Web 界面已安装${NC}"

# 步骤 7: 配置防火墙
echo ""
echo -e "${YELLOW}[7/8] 配置防火墙...${NC}"

if command -v ufw &> /dev/null; then
    ufw allow 7000/tcp >/dev/null 2>&1
    ufw allow 8080/tcp >/dev/null 2>&1
    echo -e "${GREEN}✓ UFW 规则已添加${NC}"
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=7000/tcp >/dev/null 2>&1
    firewall-cmd --permanent --add-port=8080/tcp >/dev/null 2>&1
    firewall-cmd --reload >/dev/null 2>&1
    echo -e "${GREEN}✓ firewalld 规则已添加${NC}"
elif command -v iptables &> /dev/null; then
    iptables -A INPUT -p tcp --dport 7000 -j ACCEPT >/dev/null 2>&1
    iptables -A INPUT -p tcp --dport 8080 -j ACCEPT >/dev/null 2>&1
    echo -e "${GREEN}✓ iptables 规则已添加${NC}"
else
    echo -e "${YELLOW}⚠️  未检测到防火墙${NC}"
    echo -e "${YELLOW}   请手动开放端口 7000 和 8080${NC}"
fi

# 步骤 8: 安装并启动 systemd 服务
echo ""
echo -e "${YELLOW}[8/8] 配置并启动服务...${NC}"

cat > /etc/systemd/system/tunnel-server.service << 'EOF'
[Unit]
Description=Tunnel Server - High Performance NAT Traversal Service
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/opt/tunnel
ExecStart=/opt/tunnel/bin/tunnel-server -config /opt/tunnel/config.yaml
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

systemctl daemon-reload
systemctl start tunnel-server
systemctl enable tunnel-server >/dev/null 2>&1

# 清理临时文件
cd /
rm -rf $TMP_DIR

# 等待服务启动
sleep 2

# 检查服务状态
if systemctl is-active --quiet tunnel-server; then
    echo -e "${GREEN}✓ 服务启动成功！${NC}"
else
    echo -e "${RED}❌ 服务启动失败${NC}"
    echo ""
    echo -e "${YELLOW}查看日志：${NC}"
    journalctl -u tunnel-server -n 20 --no-pager
    exit 1
fi

# 获取 Token
if [ -f "$INSTALL_DIR/.token" ]; then
    TOKEN=$(cat $INSTALL_DIR/.token)
elif [ -f "$INSTALL_DIR/config.yaml" ]; then
    TOKEN=$(grep "token:" $INSTALL_DIR/config.yaml | awk '{print $2}' | tr -d '"')
else
    TOKEN="请查看配置文件"
fi

# 完成信息
echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}  🎉 部署完成！${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo -e "${YELLOW}服务器信息：${NC}"
echo "  IP 地址: 47.243.104.165"
echo "  隧道端口: 7000"
echo "  Web 管理: 8080"
echo ""
echo -e "${YELLOW}认证信息：${NC}"
echo -e "  Token: ${GREEN}$TOKEN${NC}"
echo ""
echo -e "${YELLOW}访问地址：${NC}"
echo "  Web 管理: http://47.243.104.165:8080"
echo ""
echo -e "${YELLOW}服务管理命令：${NC}"
echo "  查看状态: systemctl status tunnel-server"
echo "  查看日志: journalctl -u tunnel-server -f"
echo "  重启服务: systemctl restart tunnel-server"
echo "  停止服务: systemctl stop tunnel-server"
echo ""
echo -e "${YELLOW}客户端配置示例：${NC}"
echo "---"
echo "server:"
echo "  addr: \"47.243.104.165:7000\""
echo "  token: \"$TOKEN\""
echo ""
echo "client:"
echo "  name: \"my-pc\""
echo ""
echo "tunnels:"
echo "  - name: \"local-web\""
echo "    local_addr: \"127.0.0.1\""
echo "    local_port: 8080"
echo "    remote_port: 8000"
echo "---"
echo ""
echo -e "${GREEN}✓ Token 已保存到: $INSTALL_DIR/.token${NC}"
echo -e "${RED}⚠️  请务必保存好 Token！${NC}"
echo ""
