# Linux 服务器部署指南

## 📋 前置要求

- Linux 服务器（Ubuntu 18.04+, Debian 10+, CentOS 7+）
- SSH 访问权限
- Root 或 sudo 权限
- 至少 512MB 内存
- 开放端口：7000（隧道）、8080（Web管理）

## 🚀 方式一：一键自动部署（最快，推荐）

在服务器上执行一条命令即可完成所有配置：

```bash
# 下载并执行一键部署脚本
bash <(curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/deploy-to-server.sh)

# 或使用 wget
bash <(wget -qO- https://raw.githubusercontent.com/xiaqijun/tunnel/main/deploy-to-server.sh)
```

**自动完成：**
- ✅ 自动检测最新版本
- ✅ 下载预编译的二进制文件
- ✅ 安装到 /opt/tunnel
- ✅ 配置防火墙（UFW/firewalld/iptables）
- ✅ 创建 systemd 服务
- ✅ 生成随机安全 Token
- ✅ 启动服务
- ✅ 显示访问信息和 Token

部署完成后会显示 Token 和访问地址，**请务必记录 Token**！

---

## 📦 方式二：手动部署

如果需要自定义配置或无法使用一键脚本，可以手动部署。

### 步骤 1：下载最新版本

访问 GitHub Releases 页面下载预编译的二进制文件：
https://github.com/xiaqijun/tunnel/releases/latest

或使用命令行下载：

```bash
# 检测系统架构
ARCH=$(uname -m)
case $ARCH in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
esac

# 获取最新版本号
LATEST_VERSION=$(curl -s https://api.github.com/repos/xiaqijun/tunnel/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

# 下载
wget https://github.com/xiaqijun/tunnel/releases/download/${LATEST_VERSION}/tunnel-${LATEST_VERSION}-linux-${ARCH}.tar.gz

# 解压
tar -xzf tunnel-${LATEST_VERSION}-linux-${ARCH}.tar.gz
```

### 步骤 2：安装文件

```bash
# 创建安装目录
sudo mkdir -p /opt/tunnel/bin
sudo mkdir -p /opt/tunnel/web

# 移动二进制文件
sudo mv tunnel-server /opt/tunnel/bin/
sudo chmod +x /opt/tunnel/bin/tunnel-server

# 如果压缩包包含web文件，也移动过去
# sudo mv web/* /opt/tunnel/web/
```

### 步骤 3：创建配置文件

```bash
# 创建配置文件
sudo tee /opt/tunnel/config.yaml > /dev/null << 'EOF'
server:
  bind_addr: "0.0.0.0"
  bind_port: 7000
  
web:
  bind_addr: "0.0.0.0"
  bind_port: 8080
  
auth:
  token: "YOUR-SECRET-TOKEN-HERE-CHANGE-ME"  # ⚠️ 必须修改
  
performance:
  max_connections: 10000
  pool_size: 1000
  read_buffer_size: 8192
  write_buffer_size: 8192
  worker_pool_size: 500
EOF

# 生成随机Token
RANDOM_TOKEN=$(openssl rand -hex 16)
sudo sed -i "s/YOUR-SECRET-TOKEN-HERE-CHANGE-ME/$RANDOM_TOKEN/g" /opt/tunnel/config.yaml

echo "✅ 配置文件已创建"
echo "📝 Token: $RANDOM_TOKEN"
echo "⚠️  请记录此Token，客户端连接时需要使用"
```

### 步骤 4：配置防火墙

根据您的防火墙类型执行相应命令：

```bash
# Ubuntu/Debian (UFW)
sudo ufw allow 7000/tcp
sudo ufw allow 8080/tcp

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-port=7000/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# 或使用 iptables
sudo iptables -A INPUT -p tcp --dport 7000 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
```

### 步骤 5：创建并启动 systemd 服务

创建服务文件：

```bash
sudo tee /etc/systemd/system/tunnel-server.service > /dev/null << 'EOF'
[Unit]
Description=Tunnel Server - High Performance NAT Traversal Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/tunnel
ExecStart=/opt/tunnel/bin/tunnel-server -config /opt/tunnel/config.yaml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 设置权限
sudo chmod 644 /etc/systemd/system/tunnel-server.service

# 重载 systemd
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start tunnel-server

# 查看状态
sudo systemctl status tunnel-server

# 设置开机自启
sudo systemctl enable tunnel-server
```

### 步骤 6：验证部署

1. **查看服务状态**
   ```bash
   sudo systemctl status tunnel-server
   ```

2. **查看日志**
   ```bash
   sudo journalctl -u tunnel-server -f
   ```

3. **访问 Web 管理界面**
   
   打开浏览器访问：`http://your-server-ip:8080`

4. **测试端口连接**
   ```bash
   # 在本地测试
   telnet your-server-ip 7000
   curl http://your-server-ip:8080
   ```

## 🛠️ 手动部署（不使用 systemd）

如果您不想使用 systemd 服务，可以手动运行：

```bash
# 前台运行（测试用）
./bin/tunnel-server -config config.yaml

# 后台运行（使用 nohup）
nohup ./bin/tunnel-server -config config.yaml > logs/server.log 2>&1 &

# 后台运行（使用 screen）
screen -S tunnel
./bin/tunnel-server -config config.yaml
# 按 Ctrl+A+D 退出 screen
```

## 📊 服务管理命令

### Systemd 服务管理

```bash
# 启动服务
sudo systemctl start tunnel-server

# 停止服务
sudo systemctl stop tunnel-server

# 重启服务
sudo systemctl restart tunnel-server

# 查看状态
sudo systemctl status tunnel-server

# 开机自启
sudo systemctl enable tunnel-server

# 禁用开机自启
sudo systemctl disable tunnel-server

# 查看日志
sudo journalctl -u tunnel-server -f

# 查看最近 100 行日志
sudo journalctl -u tunnel-server -n 100
```

### 手动进程管理

```bash
# 查找进程
ps aux | grep tunnel-server

# 停止进程
kill -9 <PID>

# 查看端口占用
netstat -tlnp | grep -E '7000|8080'
```

## 🔒 安全建议

1. **修改默认 Token**
   - 配置文件中的 `auth.token` 必须修改为强密码
   - 建议使用 20 位以上随机字符

2. **配置防火墙**
   - 仅开放必要端口（7000, 8080）
   - 如果不需要公网访问 Web 界面，可以仅允许特定 IP 访问 8080

3. **使用 HTTPS（可选）**
   - 在前端配置 Nginx 反向代理
   - 使用 Let's Encrypt 免费 SSL 证书

4. **限制访问**
   ```bash
   # 仅允许特定 IP 访问 Web 管理端口（使用 iptables）
   sudo iptables -A INPUT -p tcp -s YOUR_IP --dport 8080 -j ACCEPT
   sudo iptables -A INPUT -p tcp --dport 8080 -j DROP
   ```

## 🧪 测试部署

### 在客户端测试连接

1. **修改客户端配置** (`client-config.yaml`)
   ```yaml
   server:
     addr: "your-server-ip:7000"
     token: "YOUR-SECRET-TOKEN-HERE-CHANGE-ME"  # 与服务器一致
   
   client:
     name: "client-1"
     reconnect_interval: 5
     heartbeat_interval: 30
   
   tunnels:
     - name: "test-web"
       local_addr: "127.0.0.1"
       local_port: 8080
       remote_port: 8000
   ```

2. **运行客户端**（在本地 Windows 机器）
   ```cmd
   bin\tunnel-client.exe -config client-config.yaml
   ```

3. **测试隧道**
   - 访问 `http://your-server-ip:8000` 应该能访问到本地的服务

## ❓ 常见问题

### 1. 服务无法启动

检查日志：
```bash
sudo journalctl -u tunnel-server -n 50
```

常见原因：
- 端口被占用：检查 7000 和 8080 端口
- 权限问题：确保有执行权限
- 配置文件错误：检查 YAML 格式

### 2. 无法访问 Web 界面

```bash
# 检查服务是否运行
sudo systemctl status tunnel-server

# 检查端口监听
sudo netstat -tlnp | grep 8080

# 检查防火墙
sudo iptables -L -n | grep 8080
```

### 3. 客户端无法连接

- 检查服务器端口 7000 是否开放
- 确认 token 配置正确
- 检查服务器防火墙设置

## 📝 更新部署

### 使用自动更新脚本（推荐）

```bash
# 一键更新到最新版本
curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/update-server.sh | sudo bash
```

自动完成：
- ✅ 检测最新版本
- ✅ 下载对应架构的二进制文件
- ✅ 备份旧版本
- ✅ 停止服务
- ✅ 更新程序
- ✅ 重启服务

## 🗑️ 卸载服务

```bash
# 停止服务
sudo systemctl stop tunnel-server

# 禁用开机自启
sudo systemctl disable tunnel-server

# 删除服务文件
sudo rm /etc/systemd/system/tunnel-server.service

# 重载 systemd
sudo systemctl daemon-reload

# 删除部署文件（可选）
sudo rm -rf /opt/tunnel
```

## 📞 支持与反馈

如遇到问题，请：
1. 查看日志文件
2. 参考项目文档
3. 提交 GitHub Issue
