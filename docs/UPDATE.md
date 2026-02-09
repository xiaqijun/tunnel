# Tunnel 自动更新功能

## 功能概述

Tunnel 现已支持自动检查和更新功能，无需手动下载和安装新版本。

## 1. 查看当前版本

### 服务器
```bash
./tunnel-server -version
# 输出: Tunnel 1.0.1 (linux/amd64)
```

### 客户端
```bash
./tunnel-client -version
# 输出: Tunnel 1.0.1 (linux/amd64)
```

## 2. 检查更新

### 通过 Web API 检查
```bash
# 检查是否有新版本
curl http://47.243.104.165:8080/api/update/check

# 返回示例:
{
  "success": true,
  "has_update": true,
  "current_version": "1.0.1",
  "latest_version": "v1.0.2",
  "release_notes": "## 更新内容\n- 新增功能A\n- 修复Bug B",
  "published_at": "2026-02-05T10:00:00Z"
}
```

### 获取详细更新信息
```bash
# 获取更新信息和下载链接
curl http://47.243.104.165:8080/api/update/info

# 返回包含:
# - 版本信息
# - 下载链接
# - 更新说明
# - 更新命令
```

### 获取版本信息
```bash
curl http://47.243.104.165:8080/api/version

# 返回:
{
  "success": true,
  "data": {
    "version": "1.0.1",
    "go_version": "go1.21.6",
    "os": "linux",
    "arch": "amd64"
  }
}
```

## 3. 自动更新

### 服务器更新 (Linux)

#### 方法1: 一键更新脚本
```bash
# 使用 sudo 运行自动更新脚本
curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/update-server.sh | sudo bash
```

#### 方法2: 手动更新
```bash
# 1. 下载最新版本
LATEST_VERSION=$(curl -s https://api.github.com/repos/xiaqijun/tunnel/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
wget https://github.com/xiaqijun/tunnel/releases/download/$LATEST_VERSION/tunnel-$LATEST_VERSION-linux-amd64.tar.gz

# 2. 停止服务
sudo systemctl stop tunnel-server

# 3. 备份旧版本
sudo mv /usr/local/bin/tunnel-server /usr/local/bin/tunnel-server.backup

# 4. 解压并安装
tar -xzf tunnel-$LATEST_VERSION-linux-amd64.tar.gz
sudo mv tunnel-server /usr/local/bin/
sudo chmod +x /usr/local/bin/tunnel-server

# 5. 启动服务
sudo systemctl start tunnel-server

# 6. 验证
tunnel-server -version
systemctl status tunnel-server
```

### 服务器更新 (Windows)

#### 方法1: PowerShell 一键更新
```powershell
# 以管理员权限运行 PowerShell
irm https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/update-server.ps1 | iex
```

#### 方法2: 手动更新
```powershell
# 1. 获取最新版本
$latest = (Invoke-RestMethod "https://api.github.com/repos/xiaqijun/tunnel/releases/latest").tag_name

# 2. 下载
Invoke-WebRequest "https://github.com/xiaqijun/tunnel/releases/download/$latest/tunnel-$latest-windows-amd64.zip" -OutFile "tunnel.zip"

# 3. 停止服务/进程
Stop-Process -Name "tunnel-server" -Force -ErrorAction SilentlyContinue

# 4. 备份
Move-Item tunnel-server.exe tunnel-server.exe.backup -Force

# 5. 解压安装
Expand-Archive tunnel.zip -DestinationPath . -Force

# 6. 启动
.\tunnel-server.exe -config config.yaml
```

### 客户端更新 (Linux)

#### 一键更新脚本
```bash
curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/update-client.sh | bash
```

#### 手动更新
```bash
# 1. 停止客户端
pkill tunnel-client

# 2. 下载最新版本
LATEST_VERSION=$(curl -s https://api.github.com/repos/xiaqijun/tunnel/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
curl -fsSL https://github.com/xiaqijun/tunnel/releases/download/$LATEST_VERSION/tunnel-$LATEST_VERSION-linux-amd64.tar.gz -o tunnel.tar.gz

# 3. 备份并安装
mv tunnel-client tunnel-client.backup
tar -xzf tunnel.tar.gz
chmod +x tunnel-client

# 4. 重启客户端
./tunnel-client -config client-config.yaml &
```

## 4. 自动更新脚本说明

### update-server.sh 功能
- ✅ 自动检测最新版本
- ✅ 自动下载对应架构的版本 (amd64/arm64)
- ✅ 自动停止服务
- ✅ 备份旧版本（带时间戳）
- ✅ 安装新版本
- ✅ 自动启动服务
- ✅ 验证更新结果

### update-client.sh 功能
- ✅ 自动检测最新版本
- ✅ 自动下载对应架构的版本
- ✅ 检测运行状态（避免覆盖运行中的进程）
- ✅ 备份旧版本
- ✅ 安装新版本

## 5. 更新流程

```
1. 检查更新
   ↓
2. 发现新版本
   ↓
3. 下载新版本包
   ↓
4. 停止当前运行的服务/进程
   ↓
5. 备份当前版本
   ↓
6. 安装新版本
   ↓
7. 启动服务/进程
   ↓
8. 验证版本
```

## 6. 版本命名规范

- 格式: `v主版本.次版本.修订版本`
- 示例: `v1.0.1`, `v1.1.0`, `v2.0.0`
- GitHub Tag: 必须以 `v` 开头才会触发发布

## 7. 回滚到旧版本

### 如果更新后出现问题

#### Linux
```bash
# 停止服务
sudo systemctl stop tunnel-server

# 恢复备份（替换为实际的备份文件名）
sudo mv /usr/local/bin/tunnel-server.backup.20260205123456 /usr/local/bin/tunnel-server

# 启动服务
sudo systemctl start tunnel-server
```

#### Windows
```powershell
# 停止进程
Stop-Process -Name "tunnel-server" -Force

# 恢复备份
Move-Item tunnel-server.exe.backup tunnel-server.exe -Force

# 启动
.\tunnel-server.exe -config config.yaml
```

## 8. 更新频率建议

- 🔔 **重要安全更新**: 立即更新
- 🔧 **Bug修复**: 建议更新
- ✨ **新功能**: 可选更新
- 📊 **性能优化**: 推荐更新

## 9. 注意事项

1. **备份配置**: 更新前确保配置文件已备份
2. **测试环境**: 建议先在测试环境验证
3. **查看日志**: 更新后检查服务日志
4. **保留备份**: 至少保留一个旧版本备份
5. **网络连接**: 确保能访问 GitHub
6. **权限要求**: Linux 服务器更新需要 sudo 权限

## 10. 故障排查

### 更新失败
```bash
# 检查网络连接
curl -I https://github.com

# 检查 GitHub API
curl https://api.github.com/repos/xiaqijun/tunnel/releases/latest

# 查看错误日志
journalctl -u tunnel-server -n 50
```

### 服务启动失败
```bash
# 检查服务状态
systemctl status tunnel-server

# 查看详细日志
journalctl -u tunnel-server -f

# 手动运行测试
/usr/local/bin/tunnel-server -config /etc/tunnel/config.yaml
```

### 版本不一致
```bash
# 确认实际运行的版本
ps aux | grep tunnel-server
lsof -i :7000  # 查看占用端口的进程

# 重新安装
sudo systemctl stop tunnel-server
sudo rm /usr/local/bin/tunnel-server
# 重新下载安装
```

## 11. API 端点总结

| 端点 | 方法 | 说明 |
|------|------|------|
| `/api/version` | GET | 获取当前版本信息 |
| `/api/update/check` | GET | 检查是否有新版本 |
| `/api/update/info` | GET | 获取更新详情和命令 |

## 12. 开发者：发布新版本

```bash
# 1. 更新版本号
vi pkg/version/version.go  # 修改 Version 常量

# 2. 提交代码
git add .
git commit -m "Release v1.0.2"
git push

# 3. 创建标签
git tag v1.0.2 -m "Release v1.0.2: 新增XXX功能"
git push origin v1.0.2

# 4. GitHub Actions 会自动构建并发布
# 等待几分钟后，新版本将在 Releases 页面可用
```

---

**更新愉快！如有问题，请查看 [GitHub Issues](https://github.com/xiaqijun/tunnel/issues)**
