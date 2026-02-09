# 部署指南

## 🚀 快速部署（推荐）

### Linux 服务器一键安装

使用自动部署脚本，从 GitHub Release 自动获取最新版本：

```bash
# 自动获取最新版本并安装
bash <(curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/deploy-to-server.sh)

# 或使用 wget
bash <(wget -qO- https://raw.githubusercontent.com/xiaqijun/tunnel/main/deploy-to-server.sh)
```

**脚本会自动完成：**
- ✅ 从 GitHub Release 获取最新版本
- ✅ 检测系统架构（amd64/arm64）
- ✅ 下载对应平台的预编译二进制文件
- ✅ 安装到 /opt/tunnel
- ✅ 配置防火墙（UFW/firewalld/iptables）
- ✅ 创建 systemd 服务
- ✅ 生成随机安全 Token
- ✅ 启动服务并设置开机自启

部署完成后会显示 Token 和访问地址，**请务必记录 Token**！

---

## 📦 手动部署

### 方式一：从 GitHub Release 下载

适合生产环境，无需编译：

```bash
# 1. 下载最新版本（自动检测架构）
LATEST_VERSION=$(curl -s https://api.github.com/repos/xiaqijun/tunnel/releases/latest | grep tag_name | cut -d '"' -f 4)
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; elif [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi
wget https://github.com/xiaqijun/tunnel/releases/download/$LATEST_VERSION/tunnel-$LATEST_VERSION-linux-$ARCH.tar.gz

# 2. 解压
tar -xzf tunnel-$LATEST_VERSION-linux-$ARCH.tar.gz

# 3. 移动到系统目录
sudo mv tunnel-server-linux-$ARCH /usr/local/bin/tunnel-server
sudo mv tunnel-client-linux-$ARCH /usr/local/bin/tunnel-client
sudo chmod +x /usr/local/bin/tunnel-server
sudo chmod +x /usr/local/bin/tunnel-client

# 4. 创建配置目录
sudo mkdir -p /opt/tunnel
cd /opt/tunnel

# 5. 下载配置文件
sudo wget https://raw.githubusercontent.com/xiaqijun/tunnel/main/config.yaml
sudo wget https://raw.githubusercontent.com/xiaqijun/tunnel/main/client-config.yaml

# 6. 修改配置（重要！）
sudo nano config.yaml  # 修改 auth.token 为强密码
```

### 方式二：从源码编译

适合开发环境或需要自定义编译：

## 服务器部署

### 1. 编译程序

```bash
# Windows
build.bat

# Linux/Mac
make build
```

### 2. 配置服务器

编辑 `config.yaml`:

```yaml
server:
  bind_addr: "0.0.0.0"
  bind_port: 7000
  
web:
  bind_addr: "0.0.0.0"
  bind_port: 8080
  
auth:
  token: "your-secret-token-here"  # 修改为强密码
  
performance:
  max_connections: 10000
  pool_size: 1000
  read_buffer_size: 8192
  write_buffer_size: 8192
  worker_pool_size: 500
```

### 3. 运行服务器

```bash
# Windows
bin\tunnel-server.exe -config config.yaml

# Linux
./bin/tunnel-server -config config.yaml
```

### 4. 配置防火墙

确保以下端口开放：
- 7000: 隧道服务端口
- 8080: Web管理端口
- 其他客户端配置的远程端口

## 客户端部署

### 1. 配置客户端

编辑 `client-config.yaml`:

```yaml
server:
  addr: "your-server-ip:7000"  # 服务器地址
  token: "your-secret-token-here"  # 与服务器一致
  
client:
  name: "client-1"  # 客户端名称
  reconnect_interval: 5
  heartbeat_interval: 30
  
tunnels:
  - name: "web-service"
    local_addr: "127.0.0.1"
    local_port: 8080
    remote_port: 8000
```

### 2. 运行客户端

```bash
# Windows
bin\tunnel-client.exe -config client-config.yaml

# Linux
./bin/tunnel-client -config client-config.yaml
```

## 作为服务运行

### Windows (NSSM)

1. 下载 NSSM: https://nssm.cc/download
2. 安装服务器服务:

```cmd
nssm install TunnelServer "C:\path\to\tunnel-server.exe" "-config C:\path\to\config.yaml"
nssm start TunnelServer
```

3. 安装客户端服务:

```cmd
nssm install TunnelClient "C:\path\to\tunnel-client.exe" "-config C:\path\to\client-config.yaml"
nssm start TunnelClient
```

### Linux (systemd)

1. 创建服务文件 `/etc/systemd/system/tunnel-server.service`:

```ini
[Unit]
Description=Tunnel Server
After=network.target

[Service]
Type=simple
User=tunnel
WorkingDirectory=/opt/tunnel
ExecStart=/opt/tunnel/tunnel-server -config /opt/tunnel/config.yaml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

2. 启动服务:

```bash
sudo systemctl daemon-reload
sudo systemctl enable tunnel-server
sudo systemctl start tunnel-server
```

## Docker 部署

### 服务器

```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o tunnel-server ./cmd/server

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/tunnel-server .
COPY config.yaml .
COPY web ./web
EXPOSE 7000 8080
CMD ["./tunnel-server", "-config", "config.yaml"]
```

构建和运行:

```bash
docker build -t tunnel-server .
docker run -d -p 7000:7000 -p 8080:8080 \
  -v $(pwd)/config.yaml:/app/config.yaml \
  --name tunnel-server \
  tunnel-server
```

## 性能优化建议

1. **调整系统参数**:

```bash
# Linux
# /etc/sysctl.conf
net.core.somaxconn = 32768
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.ip_local_port_range = 1024 65535
fs.file-max = 1000000

# 应用配置
sudo sysctl -p
```

2. **调整进程限制**:

```bash
# /etc/security/limits.conf
* soft nofile 1000000
* hard nofile 1000000
```

3. **配置优化**:
   - 增加 `worker_pool_size` 以处理更多并发连接
   - 调整 `read_buffer_size` 和 `write_buffer_size` 根据网络情况
   - 设置合适的 `max_connections`

## 监控和日志

### 查看日志

```bash
# 服务器日志
tail -f /var/log/tunnel-server.log

# 客户端日志
tail -f /var/log/tunnel-client.log
```

### Web管理界面

访问 `http://your-server-ip:8080` 查看：
- 在线客户端
- 活动连接数
- 流量统计
- 隧道状态

## 故障排查

### 客户端无法连接

1. 检查服务器地址和端口是否正确
2. 验证 token 是否匹配
3. 检查防火墙规则
4. 查看服务器日志

### 隧道无法工作

1. 确认远程端口未被占用
2. 检查本地服务是否正常运行
3. 查看客户端日志
4. 验证端口映射配置

### 性能问题

1. 检查系统资源使用情况
2. 调整性能参数
3. 增加 worker pool 大小
4. 优化缓冲区大小
