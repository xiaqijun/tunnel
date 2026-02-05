# GitHub Actions 构建状态监控
# PowerShell 版本

$owner = "xiaqijun"
$repo = "tunnel"
$tag = "v1.0.0"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "  GitHub Actions 构建监控" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "项目: $owner/$repo" -ForegroundColor Yellow
Write-Host "Tag:  $tag" -ForegroundColor Yellow
Write-Host ""

# 检查最新的 workflow runs
function Get-WorkflowStatus {
    try {
        $url = "https://api.github.com/repos/$owner/$repo/actions/runs?per_page=5"
        $headers = @{
            'Accept' = 'application/vnd.github.v3+json'
            'User-Agent' = 'PowerShell'
        }
        
        $response = Invoke-RestMethod -Uri $url -Headers $headers -ErrorAction Stop
        
        if ($response.workflow_runs -and $response.workflow_runs.Count -gt 0) {
            Write-Host "最近的构建:" -ForegroundColor Cyan
            Write-Host ""
            
            for ($i = 0; $i -lt [Math]::Min(5, $response.workflow_runs.Count); $i++) {
                $run = $response.workflow_runs[$i]
                
                Write-Host "  [$($i+1)] " -NoNewline -ForegroundColor Gray
                Write-Host "$($run.name)" -ForegroundColor White
                Write-Host "      状态: " -NoNewline
                
                if ($run.status -eq "completed") {
                    if ($run.conclusion -eq "success") {
                        Write-Host "✅ SUCCESS" -ForegroundColor Green
                    } elseif ($run.conclusion -eq "failure") {
                        Write-Host "❌ FAILED" -ForegroundColor Red
                    } else {
                        Write-Host "⚠️  $($run.conclusion.ToUpper())" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "⏳ $($run.status.ToUpper())" -ForegroundColor Yellow
                }
                
                Write-Host "      分支: $($run.head_branch)" -ForegroundColor Gray
                Write-Host "      时间: $($run.created_at)" -ForegroundColor Gray
                Write-Host "      链接: $($run.html_url)" -ForegroundColor Blue
                Write-Host ""
            }
        } else {
            Write-Host "未找到构建记录" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ 无法获取构建状态" -ForegroundColor Red
        Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Gray
    }
}

# 检查 Release 状态
function Get-ReleaseStatus {
    try {
        $url = "https://api.github.com/repos/$owner/$repo/releases/tags/$tag"
        $headers = @{
            'Accept' = 'application/vnd.github.v3+json'
            'User-Agent' = 'PowerShell'
        }
        
        $release = Invoke-RestMethod -Uri $url -Headers $headers -ErrorAction Stop
        
        Write-Host "Release 信息:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  名称: $($release.name)" -ForegroundColor White
        Write-Host "  标签: $($release.tag_name)" -ForegroundColor Yellow
        Write-Host "  发布时间: $($release.published_at)" -ForegroundColor Gray
        Write-Host "  链接: $($release.html_url)" -ForegroundColor Blue
        Write-Host ""
        
        if ($release.assets -and $release.assets.Count -gt 0) {
            Write-Host "  构建产物 ($($release.assets.Count) 个):" -ForegroundColor Green
            foreach ($asset in $release.assets) {
                $sizeInMB = [math]::Round($asset.size / 1MB, 2)
                Write-Host "    ✓ $($asset.name) " -NoNewline -ForegroundColor White
                Write-Host "($sizeInMB MB)" -ForegroundColor Gray
            }
            Write-Host ""
            Write-Host "  ✅ Release 构建完成！" -ForegroundColor Green
        } else {
            Write-Host "  ⏳ 等待构建产物..." -ForegroundColor Yellow
        }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "Release 信息:" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  ⏳ Release $tag 尚未创建或正在构建中..." -ForegroundColor Yellow
        } else {
            Write-Host "❌ 无法获取 Release 状态" -ForegroundColor Red
            Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Gray
        }
    }
}

# 执行检查
Get-WorkflowStatus
Write-Host ""
Write-Host "--------------------------------" -ForegroundColor Gray
Write-Host ""
Get-ReleaseStatus

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "  快速链接" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Actions 页面:" -ForegroundColor Yellow
Write-Host "  https://github.com/$owner/$repo/actions" -ForegroundColor Blue
Write-Host ""
Write-Host "Releases 页面:" -ForegroundColor Yellow
Write-Host "  https://github.com/$owner/$repo/releases" -ForegroundColor Blue
Write-Host ""
Write-Host "v1.0.0 Release:" -ForegroundColor Yellow
Write-Host "  https://github.com/$owner/$repo/releases/tag/$tag" -ForegroundColor Blue
Write-Host ""

# 询问是否在浏览器中打开
Write-Host ""
$open = Read-Host "是否在浏览器中打开这些页面? (y/n)"
if ($open -eq 'y' -or $open -eq 'Y') {
    Start-Process "https://github.com/$owner/$repo/actions"
    Start-Sleep -Seconds 1
    Start-Process "https://github.com/$owner/$repo/releases"
    Write-Host "✓ 已在浏览器中打开" -ForegroundColor Green
}

Write-Host ""
Write-Host "提示: 构建通常需要 2-3 分钟，请耐心等待" -ForegroundColor Gray
Write-Host ""
