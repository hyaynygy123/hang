# install.ps1
<#
  测试脚本 — 用于验证 irm | iex 是否正常工作
  运行后会输出一些系统信息，不会修改任何配置
#>

Write-Host "GitHub PowerShell ok！" -ForegroundColor Green
Write-Host "user: $env:USERNAME"
Write-Host "computer: $env:COMPUTERNAME"
Write-Host "PowerShell: $($PSVersionTable.PSVersion)"
Write-Host "time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "jiao ben: $PWD"
Write-Host "by hang"
try {
    if (Test-Connection -ComputerName "bing.com" -Count 1 -Quiet) {
        Write-Host "🌐 ok" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️ no" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ no: $_" -ForegroundColor Red
}

Write-Host "`n🎯 yes good！" -ForegroundColor Green
