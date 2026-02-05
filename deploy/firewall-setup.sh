#!/bin/bash
# 配置防火墙规则

echo "================================"
echo "  配置防火墙"
echo "================================"
echo ""

# 检测防火墙类型
if command -v ufw &> /dev/null; then
    echo "检测到 UFW 防火墙"
    echo "开放端口 7000 (TCP)..."
    sudo ufw allow 7000/tcp
    echo "开放端口 8080 (TCP)..."
    sudo ufw allow 8080/tcp
    echo "✅ UFW 规则已添加"
    
elif command -v firewall-cmd &> /dev/null; then
    echo "检测到 firewalld 防火墙"
    echo "开放端口 7000 (TCP)..."
    sudo firewall-cmd --permanent --add-port=7000/tcp
    echo "开放端口 8080 (TCP)..."
    sudo firewall-cmd --permanent --add-port=8080/tcp
    sudo firewall-cmd --reload
    echo "✅ firewalld 规则已添加"
    
elif command -v iptables &> /dev/null; then
    echo "使用 iptables 配置防火墙"
    sudo iptables -A INPUT -p tcp --dport 7000 -j ACCEPT
    sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
    
    # 保存规则
    if [ -f /etc/debian_version ]; then
        sudo iptables-save | sudo tee /etc/iptables/rules.v4
    elif [ -f /etc/redhat-release ]; then
        sudo service iptables save
    fi
    echo "✅ iptables 规则已添加"
    
else
    echo "⚠️  未检测到防火墙，请手动配置以下端口："
    echo "   - 7000/tcp (隧道服务)"
    echo "   - 8080/tcp (Web管理)"
fi

echo ""
echo "端口配置完成！"
