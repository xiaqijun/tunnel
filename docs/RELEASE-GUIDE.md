# 📦 Release 下载和安装指南

## 下载地址

从 GitHub Releases 下载预编译的二进制文件：
https://github.com/xiaqijun/tunnel/releases/latest

## 📥 可用的发布包

每个 Release 包含以下平台的完整包：

| 平台 | 文件名 | 内容 |
|------|--------|------|
| Linux AMD64 | `tunnel-vX.X.X-linux-amd64.tar.gz` | 服务器端 + 客户端 + Web UI + 配置示例 |
| Linux ARM64 | `tunnel-vX.X.X-linux-arm64.tar.gz` | 服务器端 + 客户端 + Web UI + 配置示例 |
| Windows AMD64 | `tunnel-vX.X.X-windows-amd64.zip` | 服务器端 + 客户端 + Web UI + 配置示例 |
| macOS AMD64 | `tunnel-vX.X.X-darwin-amd64.tar.gz` | 服务器端 + 客户端 + Web UI + 配置示例 |
| macOS ARM64 | `tunnel-vX.X.X-darwin-arm64.tar.gz` | 服务器端 + 客户端 + Web UI + 配置示例 |

## 📂 压缩包结构

解压后的目录结构：

```
linux-amd64/              # 或 windows-amd64/ darwin-amd64/ 等
├── tunnel-server         # 服务器端程序
├── tunnel-client         # 客户端程序
├── web/                  # Web管理界面
│   ├── index.html
│   ├── app.js
│   └── style.css
├── config.example.yaml           # 服务器配置示例
├── client-config.example.yaml    # 客户端配置示例
├── README.md             # 项目说明
└── LICENSE               # 开源协议
```

## 🚀 快速安装

### Linux / macOS

```bash
# 1. 下载最新版本
wget https://github.com/xiaqijun/tunnel/releases/latest/download/tunnel-vX.X.X-linux-amd64.tar.gz

# 2. 解压
tar -xzf tunnel-vX.X.X-linux-amd64.tar.gz

# 3. 进入目录
cd linux-amd64

# 4. 复制配置文件
cp config.example.yaml config.yaml
cp client-config.example.yaml client-config.yaml

# 5. 编辑配置（修改token和地址）
nano config.yaml

# 6. 运行服务器
./tunnel-server -config config.yaml

# 或运行客户端
./tunnel-client -config client-config.yaml
```

### Windows

```powershell
# 1. 下载 tunnel-vX.X.X-windows-amd64.zip

# 2. 解压到任意目录

# 3. 进入 windows-amd64 目录

# 4. 复制配置文件
copy config.example.yaml config.yaml
copy client-config.example.yaml client-config.yaml

# 5. 编辑配置文件（用记事本或其他编辑器）

# 6. 运行服务器
.\tunnel-server.exe -config config.yaml

# 或运行客户端
.\tunnel-client.exe -config client-config.yaml
```

## 📦 部署到服务器

### 方式一：一键自动部署（推荐）

使用自动部署脚本，自动下载最新版本并配置：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/deploy-to-server.sh)
```

### 方式二：手动部署

```bash
# 1. 下载并解压
wget https://github.com/xiaqijun/tunnel/releases/latest/download/tunnel-vX.X.X-linux-amd64.tar.gz
tar -xzf tunnel-vX.X.X-linux-amd64.tar.gz

# 2. 安装到系统目录
sudo mkdir -p /opt/tunnel
sudo cp -r linux-amd64/* /opt/tunnel/

# 3. 配置
cd /opt/tunnel
sudo cp config.example.yaml config.yaml
sudo nano config.yaml  # 修改token

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
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 5. 启动服务
sudo systemctl daemon-reload
sudo systemctl enable tunnel-server
sudo systemctl start tunnel-server
```

## 🔄 更新到新版本

### 自动更新（推荐）

服务器端：
```bash
curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/update-server.sh | sudo bash
```

客户端：
```bash
curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/update-client.sh | bash
```

### 手动更新

```bash
# 1. 下载新版本
wget https://github.com/xiaqijun/tunnel/releases/latest/download/tunnel-vX.X.X-linux-amd64.tar.gz

# 2. 停止服务
sudo systemctl stop tunnel-server

# 3. 备份旧版本
sudo mv /opt/tunnel/tunnel-server /opt/tunnel/tunnel-server.backup

# 4. 解压并安装
tar -xzf tunnel-vX.X.X-linux-amd64.tar.gz
sudo cp linux-amd64/tunnel-server /opt/tunnel/
sudo cp linux-amd64/tunnel-client /opt/tunnel/
sudo cp -r linux-amd64/web /opt/tunnel/

# 5. 重启服务
sudo systemctl start tunnel-server
```

## 📋 版本说明

### 版本号格式

`vX.Y.Z`

- X: 主版本号（重大更新）
- Y: 次版本号（功能更新）
- Z: 修订号（bug修复）

### 查看当前版本

```bash
./tunnel-server -version
./tunnel-client -version
```

## ❓ 常见问题

### Q: 如何选择正确的平台？

| 系统 | 架构检查命令 | 下载包 |
|------|-------------|--------|
| Linux | `uname -m` 显示 `x86_64` | linux-amd64 |
| Linux | `uname -m` 显示 `aarch64` | linux-arm64 |
| Windows | 64位系统 | windows-amd64 |
| macOS | Intel 芯片 | darwin-amd64 |
| macOS | M1/M2/M3 芯片 | darwin-arm64 |

### Q: 解压后找不到可执行文件？

确保解压完整，压缩包包含一层目录：
```bash
# 正确的解压方式
tar -xzf tunnel-vX.X.X-linux-amd64.tar.gz
cd linux-amd64
ls  # 应该能看到 tunnel-server 和 tunnel-client
```

### Q: 如何验证下载的文件？

```bash
# 检查文件大小（应该在几MB到几十MB之间）
ls -lh tunnel-*.tar.gz

# 解压测试
tar -tzf tunnel-*.tar.gz | head
```

### Q: Web文件在哪里？

Web管理界面文件在压缩包的 `web/` 目录中，包含：
- `index.html` - 主页面
- `app.js` - JavaScript逻辑
- `style.css` - 样式文件

服务器启动时会自动加载这些文件。

## 🔗 相关链接

- [项目主页](https://github.com/xiaqijun/tunnel)
- [发布页面](https://github.com/xiaqijun/tunnel/releases)
- [部署文档](docs/DEPLOY.md)
- [客户端快速入门](docs/CLIENT-QUICK-START.md)
- [配置说明](configs/README.md)
