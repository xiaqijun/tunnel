@echo off
REM 打包项目用于上传到 Linux 服务器

echo ================================
echo   打包项目文件
echo ================================
echo.

REM 设置打包文件名
set PACKAGE_NAME=tunnel-deploy-%date:~0,4%%date:~5,2%%date:~8,2%.tar.gz

echo 正在打包项目文件...
echo.

REM 检查是否安装了 tar（Windows 10+ 自带）
where tar >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 未找到 tar 命令
    echo 请使用 WinRAR 或 7-Zip 手动打包以下文件：
    echo    - cmd/
    echo    - internal/
    echo    - pkg/
    echo    - web/
    echo    - deploy/
    echo    - config.yaml
    echo    - client-config.yaml
    echo    - go.mod
    echo    - go.sum
    pause
    exit /b 1
)

REM 创建临时目录
if exist tunnel-temp rd /s /q tunnel-temp
mkdir tunnel-temp

REM 复制需要的文件
echo 复制文件...
xcopy /E /I /Q cmd tunnel-temp\cmd\
xcopy /E /I /Q internal tunnel-temp\internal\
xcopy /E /I /Q pkg tunnel-temp\pkg\
xcopy /E /I /Q web tunnel-temp\web\
xcopy /E /I /Q deploy tunnel-temp\deploy\
copy config.yaml tunnel-temp\
copy client-config.yaml tunnel-temp\
copy go.mod tunnel-temp\
copy go.sum tunnel-temp\
copy README.md tunnel-temp\
copy DEPLOY.md tunnel-temp\

REM 打包
echo.
echo 创建压缩包...
cd tunnel-temp
tar -czf ..\%PACKAGE_NAME% *
cd ..

REM 清理
rd /s /q tunnel-temp

echo.
echo ================================
echo   打包完成！
echo ================================
echo.
echo 打包文件: %PACKAGE_NAME%
echo 大小: 
dir /-C %PACKAGE_NAME% | find ".tar.gz"
echo.
echo ================================
echo   上传到服务器
echo ================================
echo.
echo 使用以下命令上传到服务器：
echo.
echo   scp %PACKAGE_NAME% root@your-server-ip:/root/
echo.
echo 或者使用 WinSCP、FileZilla 等工具上传
echo.
echo 在服务器上解压：
echo   tar -xzf %PACKAGE_NAME%
echo   cd tunnel-temp
echo   bash deploy/linux-deploy.sh
echo.
pause
