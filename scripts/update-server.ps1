# Tunnel 服务器自动更新脚本 (Windows PowerShell)
# 用法: irm http://YOUR_SERVER:8080/api/update/script/windows | iex

$ErrorActionPreference = "Stop"

$REPO = "xiaqijun/tunnel"
$GITHUB_API = "https://api.github.com/repos/$REPO/releases/latest"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Tunnel 服务器自动更新" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# 获取当前版本
$CURRENT_VERSION = "unknown"
if (Test-Path ".\tunnel-server.exe") {
    try {
        $versionOutput = & .\tunnel-server.exe -version 2>&1
        if ($versionOutput -match "Tunnel ([\d.]+)") {
            $CURRENT_VERSION = $matches[1]
        }
    } catch {
        $CURRENT_VERSION = "unknown"
    }
    Write-Host "📌 当前版本: $CURRENT_VERSION" -ForegroundColor Yellow
} else {
    Write-Host "⚠️  未检测到已安装的版本" -ForegroundColor Yellow
}

# 获取最新版本信息
Write-Host "🔍 检查最新版本..." -ForegroundColor Cyan
try {
    $latestInfo = Invoke-RestMethod -Uri $GITHUB_API
    $LATEST_VERSION = $latestInfo.tag_name
    $LATEST_VERSION_NUM = $LATEST_VERSION -replace "^v", ""
} catch {
    Write-Host "❌ 无法获取最新版本信息: $_" -ForegroundColor Red
    exit 1
}

Write-Host "📦 最新版本: $LATEST_VERSION_NUM" -ForegroundColor Green

# 检查是否需要更新
if ($CURRENT_VERSION -eq $LATEST_VERSION_NUM) {
    Write-Host "✅ 已是最新版本，无需更新" -ForegroundColor Green
    exit 0
}

# 构建下载URL
$DOWNLOAD_FILE = "tunnel-$LATEST_VERSION-windows-amd64.zip"
$DOWNLOAD_URL = "https://github.com/$REPO/releases/download/$LATEST_VERSION/$DOWNLOAD_FILE"

Write-Host "📥 下载地址: $DOWNLOAD_URL" -ForegroundColor Cyan

# 创建临时目录
$TMP_DIR = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $TMP_DIR | Out-Null

try {
    # 下载文件
    Write-Host "⬇️  正在下载..." -ForegroundColor Cyan
    $downloadPath = Join-Path $TMP_DIR $DOWNLOAD_FILE
    Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile $downloadPath
    
    # 解压文件
    Write-Host "📦 正在解压..." -ForegroundColor Cyan
    Expand-Archive -Path $downloadPath -DestinationPath $TMP_DIR -Force
    
    # 停止服务（如果作为服务运行）
    $serviceName = "tunnel-server"
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    $serviceWasRunning = $false
    
    if ($service -and $service.Status -eq "Running") {
        Write-Host "⏸️  停止服务..." -ForegroundColor Yellow
        Stop-Service -Name $serviceName -Force
        $serviceWasRunning = $true
    }
    
    # 停止正在运行的进程
    $processes = Get-Process -Name "tunnel-server" -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Host "⏸️  停止进程..." -ForegroundColor Yellow
        $processes | Stop-Process -Force
        Start-Sleep -Seconds 2
    }
    
    # 备份旧版本
    if (Test-Path ".\tunnel-server.exe") {
        Write-Host "💾 备份旧版本..." -ForegroundColor Cyan
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        Move-Item ".\tunnel-server.exe" ".\tunnel-server.exe.backup.$timestamp" -Force
    }
    
    # 安装新版本
    Write-Host "📦 安装新版本..." -ForegroundColor Cyan
    $newExe = Get-ChildItem -Path $TMP_DIR -Filter "tunnel-server.exe" -Recurse | Select-Object -First 1
    if ($newExe) {
        Copy-Item $newExe.FullName -Destination ".\tunnel-server.exe" -Force
    } else {
        throw "未找到 tunnel-server.exe"
    }
    
    # 启动服务
    if ($serviceWasRunning) {
        Write-Host "▶️  启动服务..." -ForegroundColor Green
        Start-Service -Name $serviceName
        
        Start-Sleep -Seconds 2
        
        $service = Get-Service -Name $serviceName
        if ($service.Status -eq "Running") {
            Write-Host "✅ 服务已成功启动" -ForegroundColor Green
        } else {
            Write-Host "⚠️  服务启动失败，请检查日志" -ForegroundColor Yellow
        }
    }
    
    # 显示新版本
    $NEW_VERSION = "unknown"
    try {
        $versionOutput = & .\tunnel-server.exe -version 2>&1
        if ($versionOutput -match "Tunnel ([\d.]+)") {
            $NEW_VERSION = $matches[1]
        }
    } catch {}
    
    Write-Host ""
    Write-Host "================================" -ForegroundColor Green
    Write-Host "✅ 更新完成！" -ForegroundColor Green
    Write-Host "   $CURRENT_VERSION → $NEW_VERSION" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    
} finally {
    # 清理临时文件
    if (Test-Path $TMP_DIR) {
        Remove-Item -Path $TMP_DIR -Recurse -Force
    }
}
