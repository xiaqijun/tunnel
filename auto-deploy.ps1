# Tunnel Auto Deploy Script
param([string]$Password = "LSxqj1002>")

Write-Host "================================" -ForegroundColor Blue
Write-Host "  Tunnel Auto Deploy" -ForegroundColor Blue
Write-Host "  Server: 47.243.104.165" -ForegroundColor Blue
Write-Host "================================" -ForegroundColor Blue
Write-Host ""

if (!(Get-Module -ListAvailable -Name Posh-SSH)) {
    Write-Host "Installing Posh-SSH module..." -ForegroundColor Yellow
    try {
        Install-Module -Name Posh-SSH -Force -Scope CurrentUser -AllowClobber -ErrorAction Stop
        Write-Host "Posh-SSH installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to install Posh-SSH: $_" -ForegroundColor Red
        exit 1
    }
}

Import-Module Posh-SSH -ErrorAction SilentlyContinue

$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ("root", $secpasswd)

try {
    Write-Host "Connecting to server..." -ForegroundColor Cyan
    $session = New-SSHSession -ComputerName "47.243.104.165" -Credential $credential -AcceptKey -ErrorAction Stop
    Write-Host "SSH connected successfully" -ForegroundColor Green
    Write-Host "Executing deployment script..." -ForegroundColor Cyan
    
    $result = Invoke-SSHCommand -SSHSession $session -Command "curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/deploy-to-server.sh | sudo -S bash" -TimeOut 120
    
    Write-Host ""
    Write-Host $result.Output
    if ($result.Error) { Write-Host $result.Error -ForegroundColor Red }
    
    Remove-SSHSession -SSHSession $session | Out-Null
    
    if ($result.ExitStatus -eq 0) {
        Write-Host ""
        Write-Host "Deployment completed successfully!" -ForegroundColor Green
    }
} catch {
    Write-Host "Deployment failed: $_" -ForegroundColor Red
}
