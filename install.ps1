$u="https://cdn.jsdelivr.net/gh/hyaynygy123/hang@main/install.ps1"
$u2="https://raw.githubusercontent.com/hyaynygy123/hang/main/install.ps1"

try {
    Write-Host "🌐 正在尝试从 jsDelivr 获取脚本..." -ForegroundColor Cyan
    $r = Invoke-WebRequest -Uri $u -UseBasicParsing -ErrorAction Stop
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($r.Content)
    $script = [System.Text.Encoding]::UTF8.GetString($bytes)
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    Write-Host "⚙️  正在执行 jsDelivr 脚本..." -ForegroundColor Yellow
    Invoke-Expression $script
}
catch {
    Write-Host "⚠️  jsDelivr 访问失败，切换到 GitHub 原始链接..." -ForegroundColor Yellow
    try {
        $r2 = Invoke-WebRequest -Uri $u2 -UseBasicParsing -ErrorAction Stop
        $bytes2 = [System.Text.Encoding]::UTF8.GetBytes($r2.Content)
        $script2 = [System.Text.Encoding]::UTF8.GetString($bytes2)
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        Write-Host "⚙️  正在执行 GitHub Raw 脚本..." -ForegroundColor Yellow
        Invoke-Expression $script2
    }
    catch {
        Write-Host "❌ 两个源都访问失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}
finally {
    Write-Host "`n✅ 执行完毕。按任意键退出..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
