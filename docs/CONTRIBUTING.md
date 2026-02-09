# 贡献指南

感谢你考虑为 Tunnel 项目做出贡献！

## 如何贡献

### 报告 Bug

如果你发现了 bug，请创建一个 Issue 并包含:

- **清晰的标题**描述问题
- **详细的步骤**重现问题
- **预期行为**和**实际行为**
- **环境信息** (操作系统、Go 版本等)
- **日志输出** (如果有)

### 提出新功能

如果你有新功能的想法:

1. 先创建一个 Issue 讨论
2. 说明功能的用途和价值
3. 提供使用示例
4. 等待维护者反馈

### 提交代码

1. **Fork 项目**

2. **创建功能分支**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **编写代码**
   - 遵循现有代码风格
   - 添加必要的注释
   - 编写单元测试
   - 更新文档

4. **提交更改**
   ```bash
   git add .
   git commit -m "Add amazing feature"
   ```

5. **推送到 Fork**
   ```bash
   git push origin feature/amazing-feature
   ```

6. **创建 Pull Request**
   - 清晰描述更改内容
   - 关联相关 Issue
   - 等待代码审查

## 代码规范

### Go 代码风格

遵循标准的 Go 代码规范:

```bash
# 格式化代码
go fmt ./...

# 代码检查
go vet ./...

# 静态分析 (可选)
golangci-lint run
```

### 命名规范

- **包名**: 小写，简短，有意义
- **导出函数**: PascalCase
- **私有函数**: camelCase
- **常量**: UPPER_SNAKE_CASE
- **接口**: 以 -er 结尾

### 注释规范

```go
// NewServer 创建一个新的服务器实例
// 参数:
//   - config: 服务器配置
// 返回值:
//   - *Server: 服务器实例
func NewServer(config *ServerConfig) *Server {
    // ...
}
```

### 错误处理

```go
// ✅ 好的做法
if err != nil {
    return fmt.Errorf("failed to connect: %w", err)
}

// ❌ 不好的做法
if err != nil {
    panic(err)
}
```

## 测试要求

### 单元测试

所有新功能必须包含单元测试:

```go
func TestNewServer(t *testing.T) {
    config := &ServerConfig{
        BindPort: 7000,
    }
    
    server := NewServer(config)
    
    if server == nil {
        t.Fatal("Expected server, got nil")
    }
}
```

### 运行测试

```bash
# 运行所有测试
go test ./...

# 带覆盖率
go test -cover ./...

# 生成覆盖率报告
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### 基准测试

性能相关的更改需要提供基准测试:

```go
func BenchmarkDataTransfer(b *testing.B) {
    for i := 0; i < b.N; i++ {
        // 测试代码
    }
}
```

## 提交信息规范

使用清晰的提交信息:

```
类型(范围): 简短描述

详细描述 (可选)

相关 Issue: #123
```

**类型**:
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建/工具变动

**示例**:

```
feat(server): 添加 TLS 支持

- 实现 TLS 配置
- 添加证书管理
- 更新文档

Closes #45
```

## Pull Request 检查清单

在提交 PR 前，确保:

- [ ] 代码通过所有测试
- [ ] 添加了必要的测试
- [ ] 更新了相关文档
- [ ] 遵循代码规范
- [ ] 提交信息清晰
- [ ] 无合并冲突
- [ ] 功能完整可用

## 文档贡献

文档同样重要！你可以:

- 修正拼写/语法错误
- 改进现有文档
- 添加使用示例
- 翻译文档到其他语言

## 社区准则

### 行为准则

- 尊重他人
- 欢迎新手
- 建设性反馈
- 开放讨论
- 包容多样性

### 沟通渠道

- **Issues**: Bug 报告和功能请求
- **Discussions**: 一般讨论和问答
- **Pull Requests**: 代码贡献

## 开发环境设置

### 依赖安装

```bash
# 克隆项目
git clone https://github.com/yourusername/tunnel.git
cd tunnel

# 安装依赖
go mod download

# 安装开发工具 (可选)
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

### 本地运行

```bash
# 终端 1: 运行服务器
go run cmd/server/main.go -config config.yaml

# 终端 2: 运行客户端
go run cmd/client/main.go -config client-config.yaml
```

### 调试

使用 VS Code 调试配置 `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug Server",
            "type": "go",
            "request": "launch",
            "mode": "debug",
            "program": "${workspaceFolder}/cmd/server",
            "args": ["-config", "config.yaml"]
        },
        {
            "name": "Debug Client",
            "type": "go",
            "request": "launch",
            "mode": "debug",
            "program": "${workspaceFolder}/cmd/client",
            "args": ["-config", "client-config.yaml"]
        }
    ]
}
```

## 发布流程

维护者发布新版本:

1. 更新 `CHANGELOG.md`
2. 更新版本号
3. 创建 Git tag
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```
4. 创建 GitHub Release
5. 构建并发布二进制文件

## 获得帮助

如果你有任何问题:

1. 查看现有文档
2. 搜索已有 Issues
3. 创建新 Issue 提问
4. 参与 Discussions

## 致谢

感谢所有贡献者！

你的贡献让这个项目变得更好！🎉
