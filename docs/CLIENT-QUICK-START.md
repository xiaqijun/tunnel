# 📦 客户端快速安装指南

## 自动安装（推荐）

### Linux / macOS

从服务器下载配置文件和客户端程序并直接运行：

```bash
# 下载配置文件
sudo curl -fsSL "http://YOUR_SERVER_IP:8080/api/download/config?name=my-linux" -o client-config.yaml

# 下载客户端程序
curl -fsSL "http://YOUR_SERVER_IP:8080/api/download/client/linux/amd64" -o tunnel-client

# 设置执行权限
chmod +x tunnel-client

# 运行客户端
./tunnel-client -config client-config.yaml
```

**一条命令完成：**
```bash
sudo curl -fsSL "http://YOUR_SERVER_IP:8080/api/download/config?name=my-linux" -o client-config.yaml && \
curl -fsSL "http://YOUR_SERVER_IP:8080/api/download/client/linux/amd64" -o tunnel-client && \
chmod +x tunnel-client && \
./tunnel-client -config client-config.yaml
```

### Windows PowerShell

```powershell
# 下载配置文件
Invoke-WebRequest -Uri "http://YOUR_SERVER_IP:8080/api/download/config?name=my-windows" -OutFile client-config.yaml

# 下载客户端程序
Invoke-WebRequest -Uri "http://YOUR_SERVER_IP:8080/api/download/client/windows/amd64" -OutFile tunnel-client.exe

# 运行客户端
.\tunnel-client.exe -config client-config.yaml
```

**一条命令完成：**
```powershell
irm "http://YOUR_SERVER_IP:8080/api/download/config?name=my-windows" -OutFile client-config.yaml; irm "http://YOUR_SERVER_IP:8080/api/download/client/windows/amd64" -OutFile tunnel-client.exe; .\tunnel-client.exe -config client-config.yaml
```

## 手动安装

### 1. 编译客户端

```bash
# 克隆项目
git clone https://github.com/xiaqijun/tunnel.git
cd tunnel

# 编译客户端
# Linux/Mac
go build -o tunnel-client ./cmd/client

# Windows
go build -o tunnel-client.exe ./cmd/client
```

### 2. 创建配置文件

创建 `client-config.yaml` 文件：

```yaml
server:
  addr: "YOUR_SERVER_IP:7000"
  token: "YOUR_SECRET_TOKEN"

client:
  name: "my-client"
  reconnect_interval: 5
  heartbeat_interval: 30

tunnels:
  - name: "web"
    local_addr: "127.0.0.1"
    local_port: 8080      # 本地服务端口
    remote_port: 8000     # 远程访问端口
```

### 3. 运行客户端

```bash
# Linux/Mac
./tunnel-client -config client-config.yaml

# Windows
.\tunnel-client.exe -config client-config.yaml
```

## API 端点说明

### 下载配置文件

```
GET /api/download/config?name=<client-name>
```

**参数：**
- `name`: 客户端名称（可选，默认为 `my-client`）

**示例：**
```bash
curl -O "http://YOUR_SERVER:8080/api/download/config?name=my-linux"
```

### 下载客户端程序

```
GET /api/download/client/{os}/{arch}
```

**参数：**
- `os`: 操作系统，支持 `linux`, `windows`, `darwin`
- `arch`: 架构，支持 `amd64`, `arm64`

**示例：**
```bash
# Linux AMD64
curl -O "http://YOUR_SERVER:8080/api/download/client/linux/amd64"

# Windows AMD64
curl -O "http://YOUR_SERVER:8080/api/download/client/windows/amd64"

# macOS ARM64
curl -O "http://YOUR_SERVER:8080/api/download/client/darwin/arm64"
```

## 常见问题

### Q: 下载客户端时出现"transfer closed"错误？

**A:** 这通常是因为：
1. 服务器端没有编译好的客户端二进制文件
2. 网络连接不稳定

**解决方案：**
- 确保服务器端的 `bin/tunnel-client` 或 `bin/tunnel-client.exe` 文件存在
- 在服务器上重新编译：
  ```bash
  cd /opt/tunnel
  go build -o bin/tunnel-client ./cmd/client
  ```
- 或者从 GitHub Release 下载预编译版本

### Q: 如何验证客户端版本？

```bash
./tunnel-client -version
```

### Q: 配置文件在哪里？

- 通过 API 下载的配置文件会保存为 `client-config.yaml`
- 手动创建的配置文件可以放在任何位置，运行时通过 `-config` 参数指定

### Q: 如何后台运行客户端？

**Linux:**
```bash
# 使用 nohup
nohup ./tunnel-client -config client-config.yaml > tunnel.log 2>&1 &

# 使用 screen
screen -S tunnel
./tunnel-client -config client-config.yaml
# 按 Ctrl+A+D 退出 screen

# 使用 systemd（推荐）
sudo tee /etc/systemd/system/tunnel-client.service > /dev/null << 'EOF'
[Unit]
Description=Tunnel Client
After=network.target

[Service]
Type=simple
User=youruser
WorkingDirectory=/home/youruser
ExecStart=/home/youruser/tunnel-client -config /home/youruser/client-config.yaml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable tunnel-client
sudo systemctl start tunnel-client
```

**Windows:**
```powershell
# 使用 Start-Process
Start-Process -FilePath ".\tunnel-client.exe" -ArgumentList "-config client-config.yaml" -WindowStyle Hidden

# 或注册为 Windows 服务（需要第三方工具如 NSSM）
```

## 更新客户端

使用自动更新脚本（推荐）：

```bash
# Linux
curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/update-client.sh | bash
```

## 卸载客户端

```bash
# 停止客户端进程
pkill tunnel-client

# 删除文件
rm tunnel-client client-config.yaml

# 如果使用了 systemd
sudo systemctl stop tunnel-client
sudo systemctl disable tunnel-client
sudo rm /etc/systemd/system/tunnel-client.service
sudo systemctl daemon-reload
```

## 技术支持

- 📖 [完整文档](README.md)
- 🐛 [问题反馈](https://github.com/xiaqijun/tunnel/issues)
- 💬 [讨论区](https://github.com/xiaqijun/tunnel/discussions)
