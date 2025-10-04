# -*- coding: utf-8 -*-
# ===============================================
# PowerShell 批处理运行器：run-bat.ps1
# 功能：从远程下载 .bat 文件并运行（防乱码、防闪退）
# ===============================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Write-Host "🌐 正在下载批处理脚本..." -ForegroundColor Cyan

# 你要运行的 bat 脚本 URL（可以改成自己的）
$batUrl = "https://raw.githubusercontent.com/hyaynygy123/hang/refs/heads/main/install.bat"

# 保存到临时文件
$tmpBat = Join-Path $env:TEMP "remote_run_$(Get-Random).bat"

try {
    Invoke-WebRequest -Uri $batUrl -OutFile $tmpBat -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ 下载完成：$tmpBat" -ForegroundColor Green
}
catch {
    Write-Host "❌ 下载失败：" -ForegroundColor Red
    Write-Host $_
    Write-Host "`n按任意键退出..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# 执行批处理文件
Write-Host "⚙️ 正在执行批处理脚本..." -ForegroundColor Yellow
try {
    Start-Process "cmd.exe" -ArgumentList "/c `"$tmpBat`"" -Wait
    Write-Host "`n✅ 批处理执行完毕！" -ForegroundColor Green
}
catch {
    Write-Host "❌ 执行时出错：" -ForegroundColor Red
    Write-Host $_
}

# 删除临时文件（可选）
if (Test-Path $tmpBat) {
    Remove-Item $tmpBat -Force
    Write-Host "🧹 已清理临时文件。" -ForegroundColor DarkGray
}

# 防闪退停留
Write-Host "`n按任意键退出..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
