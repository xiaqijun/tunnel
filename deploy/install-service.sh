#!/bin/bash
# 安装 Tunnel Server 为系统服务

set -e

echo "================================"
echo "  安装 Tunnel Server 系统服务"
echo "================================"
echo ""

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ 请使用 root 权限运行此脚本"
    echo "   使用: sudo bash install-service.sh"
    exit 1
fi

# 部署目录
DEPLOY_DIR="/opt/tunnel"
SERVICE_FILE="/etc/systemd/system/tunnel-server.service"

echo "创建部署目录: $DEPLOY_DIR"
mkdir -p $DEPLOY_DIR
mkdir -p $DEPLOY_DIR/bin
mkdir -p $DEPLOY_DIR/logs

# 复制文件
echo "复制可执行文件和配置..."
cp -f bin/tunnel-server $DEPLOY_DIR/bin/
cp -f config.yaml $DEPLOY_DIR/
cp -rf web $DEPLOY_DIR/

# 设置权限
chmod +x $DEPLOY_DIR/bin/tunnel-server

# 复制 systemd 服务文件
echo "安装 systemd 服务..."
cp -f deploy/tunnel-server.service $SERVICE_FILE

# 重载 systemd
systemctl daemon-reload

echo ""
echo "✅ 安装完成！"
echo ""
echo "================================"
echo "  使用以下命令管理服务"
echo "================================"
echo ""
echo "启动服务:"
echo "  sudo systemctl start tunnel-server"
echo ""
echo "停止服务:"
echo "  sudo systemctl stop tunnel-server"
echo ""
echo "重启服务:"
echo "  sudo systemctl restart tunnel-server"
echo ""
echo "查看状态:"
echo "  sudo systemctl status tunnel-server"
echo ""
echo "开机自启:"
echo "  sudo systemctl enable tunnel-server"
echo ""
echo "查看日志:"
echo "  sudo journalctl -u tunnel-server -f"
echo ""
echo "================================"
echo "  重要提示"
echo "================================"
echo ""
echo "1. 请编辑配置文件: $DEPLOY_DIR/config.yaml"
echo "   修改 token 为强密码"
echo ""
echo "2. 确保防火墙开放以下端口:"
echo "   - 7000 (隧道服务)"
echo "   - 8080 (Web管理)"
echo ""
echo "3. 首次启动前请编辑配置文件"
echo ""
