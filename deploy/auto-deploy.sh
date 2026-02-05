#!/bin/bash
# Tunnel 服务器一键部署脚本
# 服务器: 47.243.104.165
# 生成时间: 2026年2月5日

set -e

echo "=================================="
echo "  Tunnel 服务器一键部署"
echo "=================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 部署目录
DEPLOY_DIR="/opt/tunnel"
REPO_URL="https://github.com/xiaqijun/tunnel.git"

echo -e "${YELLOW}步骤 1/7: 检查必要工具${NC}"
# 检查 git
if ! command -v git &> /dev/null; then
    echo "安装 git..."
    if [ -f /etc/debian_version ]; then
        apt-get update && apt-get install -y git
    elif [ -f /etc/redhat-release ]; then
        yum install -y git
    fi
fi
echo -e "${GREEN}✓ Git 已安装${NC}"

# 检查 Go
if ! command -v go &> /dev/null; then
    echo -e "${YELLOW}安装 Go 1.21...${NC}"
    
    ARCH=$(uname -m)
    if [ "$ARCH" == "x86_64" ]; then
        GO_ARCH="amd64"
    elif [ "$ARCH" == "aarch64" ]; then
        GO_ARCH="arm64"
    else
        echo -e "${RED}不支持的架构: $ARCH${NC}"
        exit 1
    fi
    
    GO_VERSION="1.21.6"
    cd /tmp
    wget -q https://golang.org/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
    rm -rf /usr/local/go
    tar -C /usr/local -xzf go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
    rm go${GO_VERSION}.linux-${GO_ARCH}.tar.gz
    
    export PATH=$PATH:/usr/local/go/bin
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
fi
echo -e "${GREEN}✓ Go 已安装: $(go version)${NC}"

echo ""
echo -e "${YELLOW}步骤 2/7: 克隆项目${NC}"
# 创建部署目录
mkdir -p $DEPLOY_DIR
cd $DEPLOY_DIR

# 克隆或更新仓库
if [ -d ".git" ]; then
    echo "更新现有仓库..."
    git pull
else
    echo "克隆仓库..."
    cd /opt
    rm -rf tunnel
    git clone $REPO_URL
    cd tunnel
fi
echo -e "${GREEN}✓ 项目已克隆到 $DEPLOY_DIR${NC}"

echo ""
echo -e "${YELLOW}步骤 3/7: 编译程序${NC}"
cd $DEPLOY_DIR
export PATH=$PATH:/usr/local/go/bin

# 创建 bin 目录
mkdir -p bin

# 编译服务器端
go build -ldflags="-s -w" -o bin/tunnel-server ./cmd/server
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 服务器端编译成功${NC}"
else
    echo -e "${RED}✗ 服务器端编译失败${NC}"
    exit 1
fi

# 编译客户端
go build -ldflags="-s -w" -o bin/tunnel-client ./cmd/client
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 客户端编译成功${NC}"
else
    echo -e "${RED}✗ 客户端编译失败${NC}"
    exit 1
fi

# 设置权限
chmod +x bin/tunnel-server
chmod +x bin/tunnel-client

echo ""
echo -e "${YELLOW}步骤 4/7: 配置服务器${NC}"
# 生成随机 token
RANDOM_TOKEN=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)

# 备份原配置
if [ -f config.yaml ]; then
    cp config.yaml config.yaml.bak
fi

# 更新 token
sed -i "s/token:.*/token: \"$RANDOM_TOKEN\"/" config.yaml

echo -e "${GREEN}✓ 配置文件已更新${NC}"
echo -e "${YELLOW}  Token: $RANDOM_TOKEN${NC}"
echo -e "${YELLOW}  请记录此 Token，客户端连接时需要使用！${NC}"

echo ""
echo -e "${YELLOW}步骤 5/7: 配置防火墙${NC}"

# 检测防火墙类型并配置
if command -v ufw &> /dev/null; then
    echo "配置 UFW 防火墙..."
    ufw allow 7000/tcp
    ufw allow 8080/tcp
    echo -e "${GREEN}✓ UFW 规则已添加${NC}"
    
elif command -v firewall-cmd &> /dev/null; then
    echo "配置 firewalld..."
    firewall-cmd --permanent --add-port=7000/tcp
    firewall-cmd --permanent --add-port=8080/tcp
    firewall-cmd --reload
    echo -e "${GREEN}✓ firewalld 规则已添加${NC}"
    
elif command -v iptables &> /dev/null; then
    echo "配置 iptables..."
    iptables -A INPUT -p tcp --dport 7000 -j ACCEPT
    iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
    
    # 保存规则
    if [ -f /etc/debian_version ]; then
        mkdir -p /etc/iptables
        iptables-save > /etc/iptables/rules.v4
    elif [ -f /etc/redhat-release ]; then
        service iptables save 2>/dev/null || true
    fi
    echo -e "${GREEN}✓ iptables 规则已添加${NC}"
else
    echo -e "${YELLOW}⚠ 未检测到防火墙，请手动开放端口 7000 和 8080${NC}"
fi

echo ""
echo -e "${YELLOW}步骤 6/7: 安装 systemd 服务${NC}"

# 复制服务文件
cp deploy/tunnel-server.service /etc/systemd/system/

# 重载 systemd
systemctl daemon-reload
echo -e "${GREEN}✓ systemd 服务已安装${NC}"

echo ""
echo -e "${YELLOW}步骤 7/7: 启动服务${NC}"

# 启动服务
systemctl start tunnel-server
systemctl enable tunnel-server

# 检查状态
sleep 2
if systemctl is-active --quiet tunnel-server; then
    echo -e "${GREEN}✓ 服务启动成功！${NC}"
else
    echo -e "${RED}✗ 服务启动失败，查看日志：${NC}"
    echo "  journalctl -u tunnel-server -n 50"
    exit 1
fi

echo ""
echo "=================================="
echo -e "${GREEN}  部署完成！${NC}"
echo "=================================="
echo ""
echo "服务器信息："
echo "  IP 地址: 47.243.104.165"
echo "  隧道端口: 7000"
echo "  Web 管理: 8080"
echo ""
echo "认证信息："
echo -e "  Token: ${YELLOW}$RANDOM_TOKEN${NC}"
echo ""
echo "Web 管理界面："
echo "  http://47.243.104.165:8080"
echo ""
echo "服务管理命令："
echo "  启动: systemctl start tunnel-server"
echo "  停止: systemctl stop tunnel-server"
echo "  重启: systemctl restart tunnel-server"
echo "  状态: systemctl status tunnel-server"
echo "  日志: journalctl -u tunnel-server -f"
echo ""
echo "客户端配置示例（client-config.yaml）："
echo "---"
echo "server:"
echo "  addr: \"47.243.104.165:7000\""
echo "  token: \"$RANDOM_TOKEN\""
echo ""
echo "client:"
echo "  name: \"client-1\""
echo ""
echo "tunnels:"
echo "  - name: \"web\""
echo "    local_addr: \"127.0.0.1\""
echo "    local_port: 8080"
echo "    remote_port: 8000"
echo "---"
echo ""
echo -e "${GREEN}请保存好 Token！${NC}"
echo ""
