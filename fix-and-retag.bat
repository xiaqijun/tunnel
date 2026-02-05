@echo off
REM 自动修复并重新标记

echo ================================
echo   修复 GitHub Actions 权限错误
echo ================================
echo.

echo 步骤 1: 删除本地 tag
git tag -d v1.0.0
if %ERRORLEVEL% EQU 0 (
    echo [OK] 本地 tag 已删除
) else (
    echo [WARN] 本地 tag 不存在或已删除
)
echo.

echo 步骤 2: 删除远程 tag
git push origin :refs/tags/v1.0.0
if %ERRORLEVEL% EQU 0 (
    echo [OK] 远程 tag 已删除
) else (
    echo [WARN] 远程 tag 不存在或已删除
)
echo.

echo 步骤 3: 等待 GitHub 处理...
timeout /t 3 /nobreak >nul
echo.

echo 步骤 4: 创建新的 tag
git tag -a v1.0.0 -m "Release v1.0.0 - 高性能内网穿透服务器"
if %ERRORLEVEL% EQU 0 (
    echo [OK] 新 tag 已创建
) else (
    echo [ERROR] 创建 tag 失败
    pause
    exit /b 1
)
echo.

echo 步骤 5: 推送 tag 到 GitHub
git push origin v1.0.0
if %ERRORLEVEL% EQU 0 (
    echo [OK] Tag 已推送
) else (
    echo [ERROR] 推送失败
    pause
    exit /b 1
)
echo.

echo ================================
echo   操作完成！
echo ================================
echo.
echo 下一步：
echo   1. 访问 GitHub 仓库设置页面
echo   2. Settings - Actions - General
echo   3. 选择 "Read and write permissions"
echo   4. 保存设置
echo.
echo 快速访问：
echo   设置: https://github.com/xiaqijun/tunnel/settings/actions
echo   Actions: https://github.com/xiaqijun/tunnel/actions
echo.

echo 是否在浏览器中打开设置页面？
choice /C YN /M "按 Y 打开，N 跳过"

if errorlevel 2 goto :end
if errorlevel 1 (
    start https://github.com/xiaqijun/tunnel/settings/actions
    timeout /t 2 /nobreak >nul
    start https://github.com/xiaqijun/tunnel/actions
    echo.
    echo [OK] 已在浏览器中打开
)

:end
echo.
echo 构建将在 2-3 分钟内完成
echo 请在 Actions 页面查看进度
echo.
pause
