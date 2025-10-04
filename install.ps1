# install.ps1
<#
  测试脚本 — 用于验证 irm | iex 是否正常工作
  运行后会输出一些系统信息，不会修改任何配置
#>

Write-Host "✅ GitHub PowerShell 脚本执行成功！" -ForegroundColor Green
Write-Host "当前用户: $env:USERNAME"
Write-Host "当前计算机: $env:COMPUTERNAME"
Write-Host "PowerShell 版本: $($PSVersionTable.PSVersion)"
Write-Host "当前时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "脚本运行目录: $PWD"
Write-Host "网络连通测试 (bing.com):"
try {
    if (Test-Connection -ComputerName "bing.com" -Count 1 -Quiet) {
        Write-Host "🌐 网络连接正常" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️ 无法访问网络" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ 网络测试出错: $_" -ForegroundColor Red
}

Write-Host "`n🎯 测试结束，一切运行良好！" -ForegroundColor Green
