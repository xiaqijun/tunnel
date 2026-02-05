# 📦 客户端快速安装指南

## 概述

Tunnel 服务器提供了一键安装客户端的便捷方式，用户只需复制命令到终端即可完成安装和运行。

## 使用方法

### 1. 访问 Web 管理界面

打开浏览器访问服务器地址（默认 `http://localhost:8080`）

### 2. 查看快速安装区域

在管理界面的"📦 快速安装客户端"区域，选择您的操作系统：

- **Windows** - 支持 PowerShell 和 CMD
- **Linux** - 支持 Bash 和 Wget
- **macOS** - 支持 Bash

### 3. 复制安装命令

点击"📋 复制"按钮，命令会自动复制到剪贴板。

### 4. 创建配置文件

在运行命令前，需要先创建 `client-config.yaml` 配置文件：

```yaml
server:
  addr: "SERVER_ADDRESS:7000"  # 替换为实际服务器地址
  token: "YOUR_TOKEN"          # 替换为实际 token
  
client:
  name: "my-client"            # 客户端名称
  reconnect_interval: 5
  heartbeat_interval: 30
  
tunnels:
  - name: "web-service"
    local_addr: "127.0.0.1"
    local_port: 8080           # 本地服务端口
    remote_port: 8080          # 远程暴露端口
```

### 5. 运行安装命令

在有 `client-config.yaml` 的目录中运行复制的命令。

## 各平台示例

### Windows PowerShell

```powershell
irm http://localhost:8080/api/download/client/windows/amd64 -OutFile tunnel-client.exe; .\tunnel-client.exe -config client-config.yaml
```

### Windows CMD

```cmd
curl -o tunnel-client.exe http://localhost:8080/api/download/client/windows/amd64 && tunnel-client.exe -config client-config.yaml
```

### Linux / macOS

```bash
curl -fsSL http://localhost:8080/api/download/client/linux/amd64 -o tunnel-client && chmod +x tunnel-client && ./tunnel-client -config client-config.yaml
```

## API 端点

服务器提供了以下 API 端点：

### 获取安装命令

```
GET /api/install
```

返回所有平台的安装命令和配置模板。

**响应示例：**

```json
{
  "success": true,
  "data": {
    "windows": {
      "powershell": "irm http://...",
      "cmd": "curl -o ..."
    },
    "linux": {
      "bash": "curl -fsSL ...",
      "wget": "wget ..."
    },
    "darwin": {
      "bash": "curl -fsSL ..."
    },
    "config_template": {
      "server": "SERVER_ADDRESS:7000",
      "token": "YOUR_TOKEN",
      ...
    }
  }
}
```

### 下载客户端

```
GET /api/download/client/{os}/{arch}
```

**参数：**
- `os`: 操作系统 (windows, linux, darwin)
- `arch`: 架构 (amd64, arm64)

**示例：**
```
GET /api/download/client/windows/amd64
GET /api/download/client/linux/amd64
GET /api/download/client/darwin/amd64
```

## 注意事项

1. **配置文件必填**：运行前必须创建 `client-config.yaml` 文件
2. **服务器地址**：将 `localhost` 替换为实际的服务器地址
3. **Token 认证**：确保使用正确的 token，与服务器配置一致
4. **端口配置**：根据需要配置 `local_port` 和 `remote_port`
5. **防火墙**：确保远程端口在服务器防火墙中已开放

## 高级用法

### 后台运行（Linux/macOS）

```bash
# 使用 nohup
nohup ./tunnel-client -config client-config.yaml > tunnel.log 2>&1 &

# 使用 systemd (推荐)
# 创建 /etc/systemd/system/tunnel-client.service
```

### 后台运行（Windows）

```powershell
# 使用 Start-Process
Start-Process -FilePath ".\tunnel-client.exe" -ArgumentList "-config client-config.yaml" -WindowStyle Hidden
```

## 故障排除

### 1. 下载失败

- 检查服务器地址是否正确
- 确认服务器正在运行
- 检查网络连接

### 2. 连接失败

- 验证 `server.addr` 配置
- 检查 `token` 是否正确
- 确认服务器端口 7000 可访问

### 3. 权限问题（Linux/macOS）

```bash
chmod +x tunnel-client
```

## 相关文档

- [快速开始](../QUICKSTART.md)
- [配置说明](../README.md#配置)
- [部署指南](../DEPLOY.md)
- [API 文档](../API.md)
