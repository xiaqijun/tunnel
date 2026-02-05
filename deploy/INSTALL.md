# Linux 服务器部署指南

## 📋 前置要求

- Linux 服务器（Ubuntu 18.04+, Debian 10+, CentOS 7+）
- SSH 访问权限
- Root 或 sudo 权限
- 至少 512MB 内存
- 开放端口：7000（隧道）、8080（Web管理）

## 🚀 快速部署（推荐）

### 步骤 1：上传项目到服务器

将整个项目文件夹上传到服务器（可使用 scp、sftp、git clone 等方式）

```bash
# 方式 1：使用 scp 上传（在本地执行）
scp -r e:\github\Tunnel root@your-server-ip:/root/

# 方式 2：在服务器上 git clone
ssh root@your-server-ip
git clone https://github.com/your-repo/Tunnel.git
cd Tunnel
```

### 步骤 2：执行部署脚本

```bash
cd Tunnel
chmod +x deploy/*.sh

# 编译程序
bash deploy/linux-deploy.sh
```

### 步骤 3：修改配置文件

```bash
# 编辑服务器配置
nano config.yaml
```

**重要：** 必须修改以下配置：
- `auth.token`: 改为您自己的强密码（至少 20 位随机字符）

```yaml
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
```

### 步骤 4：配置防火墙

```bash
# 自动配置防火墙
sudo bash deploy/firewall-setup.sh
```

### 步骤 5：安装为系统服务（推荐）

```bash
# 安装 systemd 服务
sudo bash deploy/install-service.sh

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

```bash
# 停止服务
sudo systemctl stop tunnel-server

# 拉取最新代码或上传新文件
git pull  # 或重新上传

# 重新编译
bash deploy/linux-deploy.sh

# 重新安装服务
sudo bash deploy/install-service.sh

# 启动服务
sudo systemctl start tunnel-server
```

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
