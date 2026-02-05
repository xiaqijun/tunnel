@echo off
echo ================================================
echo   Tunnel 服务器部署 - 交互式安装
echo   服务器: 47.243.104.165
echo ================================================
echo.
echo 请按照提示操作：
echo.
echo 步骤 1: 连接到服务器（需要输入密码）
echo.
pause

ssh root@47.243.104.165

echo.
echo ================================================
echo   如果连接成功，请在服务器上执行以下命令：
echo ================================================
echo.
echo bash ^<(wget -qO- https://raw.githubusercontent.com/xiaqijun/tunnel/main/deploy-to-server.sh^)
echo.
echo 或者复制以下命令：
echo.
echo bash ^<(curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/deploy-to-server.sh^)
echo.
pause
