# 配置文件说明

本目录包含 Tunnel 项目的配置文件示例。

## 📁 文件说明

- `config.example.yaml` - 服务器端配置示例
- `client-config.example.yaml` - 客户端配置示例

## 🚀 使用方法

### 1. 复制示例配置

```bash
# 服务器配置
cp configs/config.example.yaml config.yaml

# 客户端配置
cp configs/client-config.example.yaml client-config.yaml
```

### 2. 修改配置

编辑配置文件，**必须修改以下内容：**

#### 服务器配置 (config.yaml)

```yaml
auth:
  token: "your-secret-token"  # ⚠️ 改为强密码（至少20位）
```

#### 客户端配置 (client-config.yaml)

```yaml
server:
  addr: "your-server-ip:7000"  # ⚠️ 改为实际服务器地址
  token: "your-secret-token"   # ⚠️ 与服务器token一致
```

### 3. 运行程序

```bash
# 服务器端
./bin/tunnel-server -config config.yaml

# 客户端
./bin/tunnel-client -config client-config.yaml
```

## 📝 配置项说明

### 服务器配置详解

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `server.bind_addr` | 服务器监听地址 | `0.0.0.0` |
| `server.bind_port` | 隧道服务端口 | `7000` |
| `web.bind_addr` | Web管理界面地址 | `0.0.0.0` |
| `web.bind_port` | Web管理界面端口 | `8080` |
| `auth.token` | 认证令牌 | **必须修改** |
| `performance.max_connections` | 最大连接数 | `10000` |
| `performance.pool_size` | 连接池大小 | `1000` |

### 客户端配置详解

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `server.addr` | 服务器地址 | **必须修改** |
| `server.token` | 认证令牌 | **必须修改** |
| `client.name` | 客户端名称 | `my-client` |
| `client.reconnect_interval` | 重连间隔（秒） | `5` |
| `client.heartbeat_interval` | 心跳间隔（秒） | `30` |
| `tunnels[].local_port` | 本地服务端口 | - |
| `tunnels[].remote_port` | 远程暴露端口 | - |

## ⚠️ 安全提示

1. **不要提交实际配置文件到 Git**
   - `.gitignore` 已配置忽略 `config.yaml` 和 `client-config.yaml`
   - 仅提交 `.example.yaml` 示例文件

2. **Token 安全**
   - 使用强密码（建议 20+ 字符）
   - 定期更换 Token
   - 不要在公开场合分享 Token

3. **生成随机 Token**
   ```bash
   # Linux/Mac
   openssl rand -hex 16
   
   # Windows PowerShell
   -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
   ```

## 🔗 相关文档

- [部署指南](../docs/DEPLOY.md) - 生产环境配置
- [客户端快速入门](../docs/CLIENT-QUICK-START.md) - 客户端安装
- [安全指南](../docs/SECURITY.md) - 安全最佳实践
