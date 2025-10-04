<#
.SYNOPSIS
  以管理员权限重新运行当前脚本（如果尚未拥有管理员权限）。

.USAGE
  双击脚本或在 PowerShell 中运行:
    pwsh -ExecutionPolicy Bypass -File .\Run-AsAdmin.ps1
  或（Windows PowerShell）:
    powershell -ExecutionPolicy Bypass -File .\Run-AsAdmin.ps1

.NOTES
  - 兼容 PowerShell 5+ / PowerShell Core
  - 保留并传递原始命令行参数
#>

# ----- 判定是否为管理员 -----
function Test-IsAdmin {
    try {
        $current = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($current)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

# ----- 如果不是管理员则以管理员身份重启脚本 -----
if (-not (Test-IsAdmin)) {
    # 获取当前 PowerShell 可执行文件（兼容 pwsh / powershell）
    $pwshPath = (Get-Command -Name pwsh -ErrorAction SilentlyContinue)?.Source
    if (-not $pwshPath) {
        # 回退到 windows powershell
        $pwshPath = (Get-Command -Name powershell -ErrorAction SilentlyContinue).Source
    }

    # 如果仍然找不到，则使用 "powershell.exe" 作为默认
    if (-not $pwshPath) { $pwshPath = "powershell.exe" }

    # 当前脚本路径（兼容交互/模块/剪贴等）
    $scriptPath = $MyInvocation.MyCommand.Definition
    if ([string]::IsNullOrEmpty($scriptPath)) {
        Write-Error "无法确定脚本路径，无法以管理员身份重新启动。"
        exit 1
    }

    # 收集脚本接收到的参数并构造参数字符串（转义双引号）
    $argList = @()
    foreach ($a in $args) {
        # 用双引号包裹并对内部双引号转义
        $escaped = $a -replace '"','\"'
        $argList += "`"$escaped`""
    }
    $argString = if ($argList.Count -gt 0) { " " + ($argList -join " ") } else { "" }

    # 构造要传给 PowerShell 的 -File 参数（注意对路径加引号）
    $psArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"$argString"

    Write-Host "[i] 当前非管理员，正在弹出 UAC 请求提升权限..." -ForegroundColor Yellow

    # 启动新的提升进程
    try {
        Start-Process -FilePath $pwshPath -ArgumentList $psArgs -Verb RunAs -WindowStyle Normal
    } catch {
        Write-Error "启动提升进程失败：$($_.Exception.Message)"
        exit 1
    }

    # 当前（非管理员）实例退出，让提升后的实例接管
    exit 0
}

# ----- 已经是管理员，从这里开始写你的管理员级操作 -----
Write-Host "[OK] 当前已是管理员，开始执行管理员任务..." -ForegroundColor Green

try {
    # ===== 在这里替换成你的实际逻辑 =====
    # 示例：显示一些系统信息（管理员可见）
    Write-Host "当前用户: $([Environment]::UserName)"
    Write-Host "计算机名: $env:COMPUTERNAME"
    Write-Host "PowerShell 可执行路径: $($PSHOME)"
    Write-Host ""

    # TODO: 在这里放你需要管理员权限执行的命令，例如修改 DNS、安装服务、改系统设置等
    # 示例（仅演示，不主动修改任何系统设置）：
    Write-Host "示例：此处可以放置需要管理员权限的脚本操作..." 

    # =====================================
}
catch {
    Write-Error "执行时出错：$($_.Exception.Message)"
}

# ----- 保持窗口以便查看输出（双击运行时很有用） -----
Write-Host ""
Write-Host "执行完毕。按 Enter 退出..." -ForegroundColor Cyan
Read-Host | Out-Null
