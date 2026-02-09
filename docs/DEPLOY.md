# 部署和安装指南

> 包含服务器端和客户端的部署、安装、更新说明

## 🚀 服务器端快速部署

### 一键自动安装（推荐）

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/deploy-to-server.sh)
```

**自动完成：** 下载最新版本、配置防火墙、创建服务、生成Token

### 手动安装

```bash
# 1. 下载最新版本
wget https://github.com/xiaqijun/tunnel/releases/latest/download/tunnel-VERSION-linux-amd64.tar.gz

# 2. 解压并安装
tar -xzf tunnel-*.tar.gz && cd linux-amd64
sudo mkdir -p /opt/tunnel
sudo cp tunnel-server tunnel-client /opt/tunnel/
sudo cp -r web /opt/tunnel/
sudo cp config.example.yaml /opt/tunnel/config.yaml

# 3. 修改配置（必须修改token）
sudo nano /opt/tunnel/config.yaml

# 4. 创建systemd服务
sudo tee /etc/systemd/system/tunnel-server.service > /dev/null << 'EOF'
[Unit]
Description=Tunnel Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/tunnel
ExecStart=/opt/tunnel/tunnel-server -config /opt/tunnel/config.yaml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 5. 启动服务
sudo systemctl daemon-reload
sudo systemctl enable --now tunnel-server
```

### 配置说明

编辑 `/opt/tunnel/config.yaml`：

```yaml
server:
  bind_addr: "0.0.0.0"
  bind_port: 7000        # 客户端连接端口
  
web:
  bind_addr: "0.0.0.0"
  bind_port: 8080        # Web管理端口
  
auth:
  token: "CHANGE-ME"     # ⚠️ 必须修改为强密码
```

生成随机Token：`openssl rand -hex 16`

## 📱 客户端安装

### 从服务器下载（推荐）

服务器部署后，访问 Web 管理界面（http://YOUR_SERVER:8080）获取安装命令。

**Linux/macOS:**
```bash
curl -fsSL "http://YOUR_SERVER:8080/api/download/config?name=my-client" -o client-config.yaml && \
curl -fsSL "http://YOUR_SERVER:8080/api/download/client/linux/amd64" -o tunnel-client && \
chmod +x tunnel-client && ./tunnel-client -config client-config.yaml
```

**Windows:**
```powershell
irm "http://YOUR_SERVER:8080/api/download/config?name=my-client" -OutFile client-config.yaml
irm "http://YOUR_SERVER:8080/api/download/client/windows/amd64" -OutFile tunnel-client.exe
.\tunnel-client.exe -config client-config.yaml
```

### 从 GitHub Release 下载

```bash
wget https://github.com/xiaqijun/tunnel/releases/latest/download/tunnel-VERSION-linux-amd64.tar.gz
tar -xzf tunnel-*.tar.gz && cd linux-amd64
cp client-config.example.yaml client-config.yaml
nano client-config.yaml  # 修改服务器地址和token
./tunnel-client -config client-config.yaml
```

### 客户端配置

```yaml
server:
  addr: "YOUR_SERVER:7000"
  token: "YOUR_TOKEN"    # 与服务器token一致
  
client:
  name: "my-client"
  
tunnels:
  - name: "web"
    local_addr: "127.0.0.1"
    local_port: 8080     # 本地服务端口
    remote_port: 8000    # 服务器暴露端口
```

## 🔄 更新

**服务器端：**
```bash
curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/update-server.sh | sudo bash
```

**客户端：**
```bash
curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/update-client.sh | bash
```

## 🐳 Docker 部署

```bash
cd docker
docker-compose up -d
```

## 📦 下载

- **最新版本：** https://github.com/xiaqijun/tunnel/releases/latest
- **所有平台：** Linux/Windows/macOS (AMD64/ARM64)

## 🛠️ 服务管理

```bash
sudo systemctl start/stop/restart tunnel-server  # 启动/停止/重启
sudo systemctl status tunnel-server              # 状态
sudo journalctl -u tunnel-server -f              # 日志
```

## 🔒 安全建议

1. 修改默认Token（20位以上随机字符）
2. 配置防火墙（仅开放7000和8080端口）
3. 限制Web端口访问（生产环境）

## ❓ 常见问题

**客户端下载失败？** 检查服务器端 `/opt/tunnel/tunnel-client` 文件  
**无法访问Web？** 检查防火墙8080端口  
**客户端连接失败？** 确认token正确，检查7000端口  
**查看版本？** `./tunnel-server -version`
