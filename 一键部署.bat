@echo off
chcp 65001 >nul
echo ================================
echo   Tunnel 一键部署到服务器
echo   服务器: 47.243.104.165
echo ================================
echo.

echo [1/2] 上传部署脚本到服务器...
scp deploy-to-server.sh root@47.243.104.165:/tmp/

if errorlevel 1 (
    echo ❌ 上传失败，请检查 SSH 连接
    pause
    exit /b 1
)

echo ✓ 上传成功
echo.
echo [2/2] 在服务器上执行部署...
ssh root@47.243.104.165 "chmod +x /tmp/deploy-to-server.sh && sudo bash /tmp/deploy-to-server.sh"

echo.
echo ================================
echo   部署脚本执行完成
echo ================================
pause
