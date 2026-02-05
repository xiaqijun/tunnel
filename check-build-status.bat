@echo off
REM GitHub Actions 构建状态监控脚本

echo ================================
echo   监控 GitHub Actions 构建
echo ================================
echo.
echo 项目: xiaqijun/tunnel
echo Tag: v1.0.0
echo.

REM 打开 GitHub Actions 页面
echo 正在打开 Actions 页面...
start https://github.com/xiaqijun/tunnel/actions

timeout /t 2 /nobreak >nul

REM 打开 Releases 页面
echo 正在打开 Releases 页面...
start https://github.com/xiaqijun/tunnel/releases

timeout /t 2 /nobreak >nul

REM 打开具体的 Release
echo 正在打开 v1.0.0 Release 页面...
start https://github.com/xiaqijun/tunnel/releases/tag/v1.0.0

echo.
echo ================================
echo   页面已在浏览器中打开
echo ================================
echo.
echo 请在浏览器中查看：
echo   1. Actions 页面 - 查看构建进度
echo   2. Releases 页面 - 查看已发布的版本
echo   3. v1.0.0 Release - 查看构建结果
echo.

REM 使用 PowerShell 调用 GitHub API 检查状态
echo 正在检查构建状态...
echo.

powershell -Command "& { try { $response = Invoke-RestMethod -Uri 'https://api.github.com/repos/xiaqijun/tunnel/actions/runs?per_page=1' -Headers @{'Accept'='application/vnd.github.v3+json'} -ErrorAction Stop; $run = $response.workflows_runs[0]; if ($run) { Write-Host '最新构建:' -ForegroundColor Yellow; Write-Host '  工作流: ' -NoNewline; Write-Host $run.name -ForegroundColor Cyan; Write-Host '  状态: ' -NoNewline; if ($run.status -eq 'completed') { if ($run.conclusion -eq 'success') { Write-Host 'SUCCESS' -ForegroundColor Green } else { Write-Host $run.conclusion.ToUpper() -ForegroundColor Red } } else { Write-Host $run.status.ToUpper() -ForegroundColor Yellow }; Write-Host '  创建时间: ' -NoNewline; Write-Host $run.created_at -ForegroundColor Gray; Write-Host '  链接: ' -NoNewline; Write-Host $run.html_url -ForegroundColor Blue } else { Write-Host '未找到构建记录' -ForegroundColor Red } } catch { Write-Host '无法获取构建状态，请在浏览器中查看' -ForegroundColor Red; Write-Host $_.Exception.Message -ForegroundColor Gray } }"

echo.
echo 提示: 
echo   - Release workflow 通常需要 2-3 分钟完成
echo   - 构建成功后会在 Releases 页面看到预编译文件
echo   - 刷新浏览器页面查看最新状态
echo.
pause
