# 📂 项目结构

Tunnel 项目的目录结构说明。

```
tunnel/
├── README.md                   # 项目主文档
├── LICENSE                     # MIT 开源协议
├── Makefile                    # Linux/Mac 构建脚本
├── go.mod                      # Go 模块依赖
├── go.sum                      # Go 依赖校验
│
├── .github/                    # GitHub 配置
│   └── workflows/              # GitHub Actions 工作流
│
├── bin/                        # 编译输出目录
│   ├── tunnel-server.exe       # Windows 服务器端
│   ├── tunnel-client.exe       # Windows 客户端
│   ├── tunnel-server           # Linux 服务器端
│   └── tunnel-client           # Linux 客户端
│
├── cmd/                        # 程序入口
│   ├── server/                 # 服务器端入口
│   │   └── main.go
│   └── client/                 # 客户端入口
│       └── main.go
│
├── configs/                    # 配置文件示例 ⭐ 新增
│   ├── README.md               # 配置说明文档
│   ├── config.example.yaml     # 服务器配置示例
│   └── client-config.example.yaml  # 客户端配置示例
│
├── demo-html/                  # 演示页面
│   └── index.html              # 测试用HTML页面
│
├── deploy/                     # 部署相关
│   ├── INSTALL.md              # Linux 服务器部署指南
│   └── tunnel-server.service  # systemd 服务配置
│
├── docker/                     # Docker 相关 ⭐ 新增
│   ├── Dockerfile              # 服务器端镜像
│   ├── Dockerfile.client       # 客户端镜像
│   └── docker-compose.yml      # Docker Compose 配置
│
├── docs/                       # 文档目录 ⭐ 新增
│   ├── API.md                  # API 接口文档
│   ├── CHANGELOG.md            # 版本更新日志
│   ├── CLIENT-QUICK-START.md   # 客户端快速入门
│   ├── CONTRIBUTING.md         # 贡献指南
│   ├── DEPLOY.md               # 部署指南
│   ├── PERFORMANCE.md          # 性能测试
│   ├── SECURITY.md             # 安全指南
│   └── UPDATE.md               # 自动更新文档
│
├── internal/                   # 内部实现（不导出）
│   ├── client/                 # 客户端逻辑
│   │   └── client.go
│   └── server/                 # 服务器端逻辑
│       ├── server.go           # 核心服务
│       └── web.go              # Web API
│
├── pkg/                        # 公共包（可导出）
│   ├── config/                 # 配置管理
│   │   └── config.go
│   ├── pool/                   # 连接池/对象池
│   │   ├── pool.go
│   │   └── pool_test.go
│   ├── protocol/               # 通信协议
│   │   ├── message.go
│   │   └── message_test.go
│   └── version/                # 版本信息
│       └── version.go
│
├── scripts/                    # 脚本集合 ⭐ 整理
│   ├── auto-deploy.ps1         # Windows 自动部署
│   ├── build.bat               # Windows 构建脚本
│   ├── start.bat               # Windows 启动脚本
│   ├── deploy-to-server.sh     # Linux 服务器部署
│   ├── update-server.sh        # Linux 服务器更新
│   ├── update-server.ps1       # Windows 服务器更新
│   └── update-client.sh        # Linux 客户端更新
│
└── web/                        # Web 管理界面
    ├── index.html              # 主页面
    ├── app.js                  # JavaScript 逻辑
    └── style.css               # 样式文件
```

## 🎯 核心目录说明

### 源代码结构

```
代码组织遵循 Go 项目标准布局：
- cmd/      - 程序入口，main 包
- internal/ - 内部实现，不对外暴露
- pkg/      - 公共包，可被外部项目引用
```

### 配置管理

```
configs/    - 配置文件示例（提交到 Git）
根目录/     - 实际配置文件（不提交，在 .gitignore 中）
```

### 文档结构

```
README.md   - 项目主文档（根目录）
LICENSE     - 开源协议（根目录）
docs/       - 详细文档（统一管理）
```

### 部署资源

```
scripts/    - 所有脚本（构建、部署、更新）
docker/     - Docker 相关文件
deploy/     - 服务配置和部署文档
```

## 📝 文件命名规范

### Markdown 文档

- 全大写：`README.md`, `LICENSE`, `CHANGELOG.md`
- 描述性：`CLIENT-QUICK-START.md`, `DEPLOY.md`

### 配置文件

- 示例文件：`*.example.yaml`
- 实际配置：`*.yaml`（不提交）

### 脚本文件

- Shell 脚本：`*.sh`（Linux/Mac）
- PowerShell：`*.ps1`（Windows）
- 批处理：`*.bat`（Windows）

## 🔧 开发工作流

### 1. 克隆项目

```bash
git clone https://github.com/xiaqijun/tunnel.git
cd tunnel
```

### 2. 配置环境

```bash
# 复制配置示例
cp configs/config.example.yaml config.yaml
cp configs/client-config.example.yaml client-config.yaml

# 修改配置
# 编辑 config.yaml 和 client-config.yaml
```

### 3. 构建项目

```bash
# Linux/Mac
make build

# Windows
.\scripts\build.bat
```

### 4. 运行测试

```bash
go test ./...
```

### 5. 运行程序

```bash
# 服务器端
./bin/tunnel-server -config config.yaml

# 客户端
./bin/tunnel-client -config client-config.yaml
```

## 📦 发布流程

### 1. 更新版本

编辑 `pkg/version/version.go`

### 2. 更新日志

更新 `docs/CHANGELOG.md`

### 3. 构建发布

```bash
# 构建所有平台
make build-all

# 或使用脚本
./scripts/build-release.sh
```

### 4. 创建 Release

在 GitHub 创建新的 Release，上传编译好的二进制文件。

## 🔗 相关文档

- [README.md](README.md) - 项目介绍
- [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) - 贡献指南
- [docs/DEPLOY.md](docs/DEPLOY.md) - 部署指南
- [configs/README.md](configs/README.md) - 配置说明
