# 📚 项目导航

欢迎来到 Tunnel 项目！这里是完整的文档导航。

## 🚀 快速开始

| 文档 | 描述 | 适合人群 |
|------|------|----------|
| [README.md](README.md) | 项目概述和功能介绍 | 所有人 |
| [QUICKSTART.md](QUICKSTART.md) | 5分钟快速上手指南 | 新手 ⭐ |
| [start.bat](start.bat) | Windows 一键启动脚本 | Windows 用户 |
| [Makefile](Makefile) | Linux/Mac 构建脚本 | Linux/Mac 用户 |

## 📖 核心文档

### 部署相关

| 文档 | 描述 | 难度 |
|------|------|------|
| [DEPLOY.md](DEPLOY.md) | 生产环境部署指南 | ⭐⭐ |
| [DOCKER.md](DOCKER.md) | Docker 容器化部署 | ⭐⭐ |
| [docker-compose.yml](docker-compose.yml) | Docker Compose 配置 | ⭐ |

### 开发相关

| 文档 | 描述 | 难度 |
|------|------|------|
| [CONTRIBUTING.md](CONTRIBUTING.md) | 贡献指南 | ⭐⭐ |
| [API.md](API.md) | RESTful API 文档 | ⭐⭐ |
| [PERFORMANCE.md](PERFORMANCE.md) | 性能测试和优化 | ⭐⭐⭐ |

### 其他

| 文档 | 描述 |
|------|------|
| [CHANGELOG.md](CHANGELOG.md) | 版本更新日志 |
| [LICENSE](LICENSE) | MIT 开源协议 |
| [SECURITY.md](SECURITY.md) | 安全策略 |

## 🗂️ 项目结构

```
tunnel/
├── cmd/                    # 主程序入口
│   ├── server/            # 服务器端
│   │   └── main.go
│   └── client/            # 客户端
│       └── main.go
│
├── internal/              # 内部包
│   ├── server/           # 服务器实现
│   │   ├── server.go    # 核心服务器逻辑
│   │   └── web.go       # Web API
│   └── client/          # 客户端实现
│       └── client.go    # 核心客户端逻辑
│
├── pkg/                  # 公共包
│   ├── config/          # 配置管理
│   ├── protocol/        # 通信协议
│   └── pool/           # 连接池/协程池
│
├── web/                 # Web 管理界面
│   ├── index.html      # 主页面
│   ├── style.css       # 样式
│   └── app.js         # JavaScript
│
├── docs/               # 文档目录 (本导航页)
│
├── .github/           # GitHub 配置
│   └── workflows/    # CI/CD 工作流
│
├── config.yaml        # 服务器配置示例
├── client-config.yaml # 客户端配置示例
├── go.mod            # Go 模块文件
├── Dockerfile        # 服务器 Docker 镜像
├── Dockerfile.client # 客户端 Docker 镜像
├── docker-compose.yml # Docker Compose 配置
├── Makefile         # 构建脚本
├── build.bat        # Windows 构建脚本
└── start.bat        # Windows 启动脚本
```

## 🎯 按场景查找

### 我想...

#### 🏁 快速试用
1. 阅读 [QUICKSTART.md](QUICKSTART.md)
2. 运行 `start.bat` (Windows) 或 `make build && make run-server` (Linux/Mac)
3. 访问 http://localhost:8080

#### 🚀 部署到生产环境
1. 阅读 [DEPLOY.md](DEPLOY.md)
2. 配置 `config.yaml`
3. 参考部署章节

#### 🐳 使用 Docker
1. 阅读 [DOCKER.md](DOCKER.md)
2. 运行 `docker-compose up -d`
3. 访问 http://localhost:8080

#### 🔧 开发和贡献
1. 阅读 [CONTRIBUTING.md](CONTRIBUTING.md)
2. Fork 项目
3. 提交 Pull Request

#### 📊 性能测试
1. 阅读 [PERFORMANCE.md](PERFORMANCE.md)
2. 运行 `go test -bench=. ./...`
3. 查看测试结果

#### 🔌 集成 API
1. 阅读 [API.md](API.md)
2. 查看 API 端点
3. 实现客户端

#### 🐛 报告问题
1. 搜索现有 [Issues](https://github.com/yourusername/tunnel/issues)
2. 创建新 Issue
3. 提供详细信息

#### 💡 提出建议
1. 访问 [Discussions](https://github.com/yourusername/tunnel/discussions)
2. 描述你的想法
3. 等待反馈

## 📝 配置文件说明

### 服务器配置文件

| 文件 | 用途 |
|------|------|
| [config.yaml](config.yaml) | 服务器配置示例 |

关键配置项：
- `server.bind_port`: 客户端连接端口 (默认: 7000)
- `web.bind_port`: Web 管理端口 (默认: 8080)
- `auth.token`: 认证令牌 ⚠️ 务必修改

### 客户端配置文件

| 文件 | 用途 |
|------|------|
| [client-config.yaml](client-config.yaml) | 客户端配置示例 |

关键配置项：
- `server.addr`: 服务器地址
- `server.token`: 认证令牌 (与服务器一致)
- `tunnels`: 隧道列表

## 🔍 代码导航

### 服务器端核心代码

| 文件 | 功能 |
|------|------|
| [internal/server/server.go](internal/server/server.go) | TCP 服务器, 连接管理 |
| [internal/server/web.go](internal/server/web.go) | Web API, WebSocket |

### 客户端核心代码

| 文件 | 功能 |
|------|------|
| [internal/client/client.go](internal/client/client.go) | 客户端连接, 端口转发 |

### 公共包

| 文件 | 功能 |
|------|------|
| [pkg/protocol/message.go](pkg/protocol/message.go) | 消息协议定义 |
| [pkg/pool/pool.go](pkg/pool/pool.go) | 连接池, 协程池 |
| [pkg/config/config.go](pkg/config/config.go) | 配置加载 |

### Web 界面

| 文件 | 功能 |
|------|------|
| [web/index.html](web/index.html) | 主页面结构 |
| [web/style.css](web/style.css) | 样式设计 |
| [web/app.js](web/app.js) | 交互逻辑 |

## 🧪 测试文件

| 文件 | 功能 |
|------|------|
| [pkg/pool/pool_test.go](pkg/pool/pool_test.go) | 连接池测试 |
| [pkg/protocol/message_test.go](pkg/protocol/message_test.go) | 协议测试 |

## 📞 获取帮助

### 文档没有解答我的问题？

1. **搜索 Issues**: 也许别人已经问过
2. **查看 Discussions**: 社区讨论
3. **创建 Issue**: 描述你的问题
4. **发送邮件**: your-email@example.com

### 常见问题快速链接

- ❓ [如何安装](QUICKSTART.md#-前置要求)
- ❓ [如何配置](QUICKSTART.md#️-基础配置)
- ❓ [如何部署](DEPLOY.md)
- ❓ [如何贡献](CONTRIBUTING.md)
- ❓ [性能如何](PERFORMANCE.md)
- ❓ [API 文档](API.md)

## 🎓 学习路径

### 初学者路径

1. 阅读 [README.md](README.md) 了解项目
2. 跟随 [QUICKSTART.md](QUICKSTART.md) 快速开始
3. 查看 Web 管理界面
4. 尝试配置自己的隧道

### 进阶路径

1. 阅读 [DEPLOY.md](DEPLOY.md) 学习生产部署
2. 研究 [PERFORMANCE.md](PERFORMANCE.md) 优化性能
3. 查看 [API.md](API.md) 集成到系统
4. 尝试 Docker 部署

### 开发者路径

1. 阅读 [CONTRIBUTING.md](CONTRIBUTING.md)
2. 了解项目结构
3. 运行测试
4. 提交 Pull Request

## 🌟 推荐阅读顺序

### 第一天
- [ ] README.md
- [ ] QUICKSTART.md
- [ ] 运行项目

### 第二天
- [ ] DEPLOY.md
- [ ] 配置生产环境
- [ ] 测试隧道

### 第三天
- [ ] API.md
- [ ] 集成测试
- [ ] 性能测试

### 之后
- [ ] CONTRIBUTING.md
- [ ] 参与贡献
- [ ] 分享经验

## 📌 重要提示

⚠️ **安全性**: 请务必阅读 [SECURITY.md](SECURITY.md)

⚠️ **配置**: 修改默认 token！

⚠️ **更新**: 定期检查更新

---

<p align="center">
  <i>找不到你需要的文档？<a href="https://github.com/yourusername/tunnel/issues">告诉我们</a></i>
</p>

<p align="center">
  <a href="README.md">回到主页</a> •
  <a href="QUICKSTART.md">快速开始</a> •
  <a href="https://github.com/yourusername/tunnel/issues">报告问题</a>
</p>
