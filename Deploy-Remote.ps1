# Tunnel 远程一键部署脚本
# PowerShell 版本

Write-Host "================================" -ForegroundColor Blue
Write-Host "  Tunnel 远程一键部署" -ForegroundColor Blue
Write-Host "  服务器: 47.243.104.165" -ForegroundColor Blue
Write-Host "================================" -ForegroundColor Blue
Write-Host ""

Write-Host "正在连接服务器并执行部署..." -ForegroundColor Yellow
Write-Host ""
Write-Host "提示：执行过程中可能需要输入服务器 root 密码" -ForegroundColor Cyan
Write-Host ""

# 执行远程部署命令
ssh root@47.243.104.165 "curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/deploy-to-server.sh | sudo bash"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================" -ForegroundColor Green
    Write-Host "   部署完成！" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "请查看上方输出获取 Token 和访问信息" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "================================" -ForegroundColor Red
    Write-Host "   部署失败" -ForegroundColor Red
    Write-Host "================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "可能的原因：" -ForegroundColor Yellow
    Write-Host "  1. SSH 连接失败（密码错误或网络问题）" -ForegroundColor Yellow
    Write-Host "  2. 服务器无法访问 GitHub" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "建议：检查网络连接和服务器状态" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
