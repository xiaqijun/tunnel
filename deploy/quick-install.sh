#!/bin/bash
# 服务器 47.243.104.165 一键安装脚本（使用预编译版本）

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=================================="
echo "  Tunnel 一键安装部署"
echo "  服务器: 47.243.104.165"
echo "  使用预编译二进制 - 无需编译"
echo "=================================="
echo ""

# 检测架构
ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    PLATFORM="linux-amd64"
elif [ "$ARCH" == "aarch64" ]; then
    PLATFORM="linux-arm64"
else
    echo -e "${RED}不支持的架构: $ARCH${NC}"
    exit 1
fi

echo -e "${GREEN}系统架构: $PLATFORM${NC}"
echo ""

# 下载安装脚本并执行
echo -e "${YELLOW}下载并执行安装脚本...${NC}"
bash <(wget -qO- https://raw.githubusercontent.com/xiaqijun/tunnel/main/deploy/install-from-release.sh)

# 配置防火墙
echo ""
echo -e "${YELLOW}配置防火墙...${NC}"

if command -v ufw &> /dev/null; then
    ufw allow 7000/tcp
    ufw allow 8080/tcp
    echo -e "${GREEN}✓ UFW 规则已添加${NC}"
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=7000/tcp
    firewall-cmd --permanent --add-port=8080/tcp
    firewall-cmd --reload
    echo -e "${GREEN}✓ firewalld 规则已添加${NC}"
fi

# 启动服务
echo ""
echo -e "${YELLOW}启动服务...${NC}"
systemctl start tunnel-server
systemctl enable tunnel-server

# 等待服务启动
sleep 2

# 检查状态
if systemctl is-active --quiet tunnel-server; then
    echo -e "${GREEN}✓ 服务启动成功！${NC}"
else
    echo -e "${RED}✗ 服务启动失败${NC}"
    journalctl -u tunnel-server -n 20
    exit 1
fi

# 获取 Token
TOKEN=$(grep "token:" /opt/tunnel/config.yaml | awk '{print $2}' | tr -d '"')

echo ""
echo "=================================="
echo -e "${GREEN}  部署完成！${NC}"
echo "=================================="
echo ""
echo "服务器信息："
echo "  IP: 47.243.104.165"
echo "  隧道端口: 7000"
echo "  Web 管理: 8080"
echo ""
echo "认证 Token："
echo -e "  ${YELLOW}$TOKEN${NC}"
echo ""
echo "Web 管理界面："
echo "  http://47.243.104.165:8080"
echo ""
echo "服务管理："
echo "  查看状态: systemctl status tunnel-server"
echo "  查看日志: journalctl -u tunnel-server -f"
echo "  重启服务: systemctl restart tunnel-server"
echo ""
echo -e "${GREEN}请保存好 Token！${NC}"
echo ""
