# 🚀 Tunnel - 高性能内网穿透服务器

[![Go Version](https://img.shields.io/badge/Go-1.21+-00ADD8?style=flat&logo=go)](https://golang.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

一个基于 Go 语言开发的**高性能内网穿透服务器**，支持精美的 Web 管理界面。让你的本地服务轻松暴露到公网！

<p align="center">
  <img src="https://img.shields.io/badge/性能-⭐⭐⭐⭐⭐-blue" alt="High Performance">
  <img src="https://img.shields.io/badge/易用性-⭐⭐⭐⭐⭐-green" alt="Easy to Use">
  <img src="https://img.shields.io/badge/稳定性-⭐⭐⭐⭐⭐-orange" alt="Stable">
</p>

---

## ✨ 功能特性

- 🚀 **高性能 TCP 转发** - 基于连接池和协程池优化，吞吐量可达 Gbps 级别
- 🌐 **精美 Web 管理界面** - 现代化设计，实时监控所有隧道状态
- 🔐 **安全认证机制** - Token 认证，保护你的服务安全
- 📊 **实时流量统计** - 查看每个客户端的流量使用情况
- ⚡ **多客户端并发** - 支持 10,000+ 并发连接
- 🔄 **自动重连** - 客户端断线自动重连，无需人工干预
- 💓 **心跳保活** - 保持连接活跃，及时发现异常
- 🎯 **零配置启动** - 一键启动脚本，5分钟即可运行
- 🔄 **自动更新功能** - 一键检查和更新到最新版本（v1.0.2+）
- ⚙️ **配置自动生成** - 服务器端自动生成客户端配置文件（v1.0.1+）

## 🎬 快速演示

### Windows 一键启动

```cmd
# 双击运行
scripts\start.bat
```

### Linux/Mac 快速启动

```bash
# 编译并运行
make build
make run-server  # 终端 1
make run-client  # 终端 2
```

### Docker 启动

```bash
cd docker
docker-compose up -d
```

打开浏览器访问 `http://localhost:8080` 查看管理界面！

## 📖 详细文档

| 文档 | 说明 |
|------|------|
| [📋 部署指南](docs/DEPLOY.md) | 生产环境部署（含Docker） |
| [📘 客户端快速入门](docs/CLIENT-QUICK-START.md) | 客户端安装和使用 |
| [📊 性能测试](docs/PERFORMANCE.md) | 性能优化和测试 |
| [🔌 API 文档](docs/API.md) | RESTful API 接口 |
| [🔄 更新指南](docs/UPDATE.md) | 自动更新使用文档 |
| [🔒 安全指南](docs/SECURITY.md) | 安全策略和最佳实践 |
| [🤝 贡献指南](docs/CONTRIBUTING.md) | 如何参与贡献 |
| [📝 更新日志](docs/CHANGELOG.md) | 版本更新历史 |
## 🚀 Linux 服务器快速安装

一条命令完成服务器部署（自动从 GitHub Release 获取最新版本）：

```bash
# 自动获取最新版本并安装
bash <(curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/deploy-to-server.sh)
```

**自动完成：**
- ✅ 从 GitHub Release 下载最新预编译版本
- ✅ 安装到 /opt/tunnel
- ✅ 配置防火墙
- ✅ 创建 systemd 服务
- ✅ 生成随机安全 Token
- ✅ 启动服务

📝 更多部署方式请查看 [部署指南](DEPLOY.md)

---
## 🏗️ 架构设计

### 服务器端
- **TCP 监听服务** - 接收客户端连接
- **HTTP/WebSocket API** - 提供管理接口
- **连接池管理** - 优化资源使用
- **实时流量统计** - 监控所有连接

### 客户端
- **长连接维护** - 与服务器保持连接
- **本地端口转发** - 转发到本地服务
- **自动重连机制** - 断线自动恢复
- **心跳保活** - 定时发送心跳

## 🎯 使用场景

- 🌐 **本地开发演示** - 临时展示本地项目给客户
- 🏠 **远程访问家庭设备** - 访问家里的 NAS、摄像头等
- 🔧 **微信公众号开发** - 本地调试微信接口
- 🎮 **游戏联机** - 搭建临时游戏服务器
- 📱 **IoT 设备接入** - 内网设备连接到云端

## 📚 快速开始

### 编译

```bash
# Windows
scripts\build.bat

# Linux/Mac
make build
```

### 运行服务器

```bash
# Windows
bin\tunnel-server.exe -config config.yaml

# Linux
./bin/tunnel-server -config config.yaml
```

默认端口:
- 🔌 隧道服务: `7000`
- 🌐 Web 管理: `8080`
- 🖥️ Web 界面: http://localhost:8080

### 运行客户端

```bash
# Windows
bin\tunnel-client.exe -config client-config.yaml

# Linux  
./bin/tunnel-client -config client-config.yaml
```

## ⚙️ 配置说明

> 📁 配置文件示例位于 [configs/](configs/) 目录，请复制到根目录并修改。
> 
> ```bash
> cp configs/config.example.yaml config.yaml
> cp configs/client-config.example.yaml client-config.yaml
> ```

### 服务器配置 (config.yaml)

```yaml
server:
  bind_addr: "0.0.0.0"
  bind_port: 7000
  
web:
  bind_addr: "0.0.0.0"
  bind_port: 8080
  
auth:
  token: "your-secret-token"  # ⚠️ 请修改为强密码
  
performance:
  max_connections: 10000      # 最大连接数
  pool_size: 1000            # 连接池大小
  read_buffer_size: 8192     # 读缓冲区大小
  write_buffer_size: 8192    # 写缓冲区大小
  worker_pool_size: 500      # 工作协程池大小
```

### 客户端配置 (client-config.yaml)

```yaml
server:
  addr: "your-server-ip:7000"
  token: "your-secret-token"  # 与服务器保持一致
  
client:
  name: "client-1"
  reconnect_interval: 5       # 重连间隔(秒)
  heartbeat_interval: 30      # 心跳间隔(秒)
  
tunnels:
  - name: "web-service"
    local_addr: "127.0.0.1"
    local_port: 8080          # 本地服务端口
    remote_port: 8000         # 远程访问端口
    
  - name: "ssh-service"
    local_addr: "127.0.0.1"
    local_port: 22
    remote_port: 2222
```

## 🌟 Web 管理界面功能

打开浏览器访问 `http://your-server:8080`

- ✅ **实时仪表盘** - 查看在线客户端、活动连接、流量统计
- 📊 **客户端管理** - 查看所有客户端详细信息
- 🔗 **隧道监控** - 实时监控每个隧道的状态
- 📈 **流量统计** - 查看发送/接收流量数据
- ⚡ **实时更新** - WebSocket 推送，无需刷新
- 📱 **响应式设计** - 完美支持手机、平板访问

## 🚀 性能优化

### 已实现的优化

1. **🔄 连接池复用** - 复用 TCP 连接，减少连接建立开销
2. **⚡ 协程池管理** - 限制协程数量，防止资源耗尽
3. **📦 零拷贝传输** - 使用 `io.Copy` 高效传输数据
4. **🎯 缓冲优化** - 可配置的读写缓冲区大小
5. **💾 内存池** - 使用 `sync.Pool` 减少内存分配

### 性能指标

在标准硬件上的测试结果：

| 指标 | 数值 |
|------|------|
| 吞吐量 | 1-10 Gbps |
| 并发连接 | 10,000+ |
| 延迟 | < 1ms (本地) |
| CPU 使用 | < 50% @ 1000 并发 |
| 内存使用 | < 200MB @ 1000 并发 |

详见 [性能测试文档](PERFORMANCE.md)

## 🐳 Docker 部署

### 使用 Docker Compose

```bash
# 进入 docker 目录
cd docker

# 启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

### 单独运行

```bash
# 构建服务器镜像
docker build -t tunnel-server .

# 运行服务器
docker run -d \
  -p 7000:7000 \
  -p 8080:8080 \
  --name tunnel-server \
  tunnel-server
```

更多 Docker 部署选项详见 [部署指南](DEPLOY.md)

## 📊 API 接口

提供 RESTful API 和 WebSocket 接口：

### HTTP API

```bash
# 获取所有客户端
GET /api/clients

# 获取单个客户端
GET /api/clients/{id}

# 获取统计信息
GET /api/stats
```

### WebSocket

```javascript
const ws = new WebSocket('ws://localhost:8080/api/ws');
ws.onmessage = (event) => {
  const clients = JSON.parse(event.data);
  console.log('实时客户端数据:', clients);
};
```

详见 [API 文档](API.md)

## 🔧 开发

### 环境要求

- Go 1.21+
- 支持的操作系统: Windows, Linux, macOS

### 克隆项目

```bash
git clone https://github.com/yourusername/tunnel.git
cd tunnel
```

### 安装依赖

```bash
go mod download
go mod tidy
```

### 运行测试

```bash
# 运行所有测试
go test ./...

# 带覆盖率
go test -cover ./...

# 运行基准测试
go test -bench=. ./pkg/pool
```

### 本地开发

```bash
# 终端 1: 运行服务器
go run ./cmd/server -config config.yaml

# 终端 2: 运行客户端
go run ./cmd/client -config client-config.yaml
```

## 🤝 贡献

欢迎贡献！请查看 [贡献指南](CONTRIBUTING.md)

### 快速步骤

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📝 更新日志

查看 [CHANGELOG.md](CHANGELOG.md) 了解版本历史

## � 版本更新

### 查看当前版本
```bash
./tunnel-server -version
./tunnel-client -version
```

### 检查更新
```bash
# 通过API检查
curl http://YOUR_SERVER:8080/api/update/check

# 通过API获取更新详情
curl http://YOUR_SERVER:8080/api/update/info
```

### 自动更新（推荐）

**Linux 服务器:**
```bash
curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/update-server.sh | sudo bash
```

**Linux 客户端:**
```bash
curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/update-client.sh | bash
```

**Windows 服务器:**
```powershell
irm https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/update-server.ps1 | iex
```

详细更新文档请查看 [UPDATE.md](UPDATE.md)

## �🛣️ 路线图

### v1.0.2 (已发布) ✅
- [x] 🔄 自动更新功能
- [x] 📝 版本管理系统
- [x] 🔌 更新检查API

### v1.0.1 (已发布) ✅
- [x] ⚙️ 配置自动生成
- [x] 📥 配置下载API

### v1.1.0 (计划中)
- [ ] UDP 协议支持
- [ ] TLS 加密传输
- [ ] API 认证机制
- [ ] 速率限制
- [ ] 连接复用优化

### v1.2.0 (愿景)
- [ ] 数据压缩
- [ ] 负载均衡
- [ ] 多服务器集群
- [ ] 完整的日志系统
- [ ] Prometheus 监控

### v2.0.0 (长期)
- [ ] HTTP/HTTPS 专用优化
- [ ] WebSocket 隧道
- [ ] 自定义域名
- [ ] Let's Encrypt 集成
- [ ] 插件系统

## 📜 许可证

本项目基于 [MIT 许可证](LICENSE) 开源

## 🙏 致谢

感谢所有贡献者和使用者！

## 📧 联系方式

- 💬 提出问题: [GitHub Issues](https://github.com/yourusername/tunnel/issues)
- 💡 功能建议: [GitHub Discussions](https://github.com/yourusername/tunnel/discussions)
- 📧 Email: your-email@example.com

## ⭐ Star 历史

如果这个项目对你有帮助，请给一个 ⭐️！

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/yourusername">Your Name</a>
</p>

<p align="center">
  <a href="#-tunnel---高性能内网穿透服务器">回到顶部 ⬆️</a>
</p>
