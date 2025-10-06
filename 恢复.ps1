# ---------------------------
# 自动恢复并分配盘符 (Auto Assign Drive Letters)
# ---------------------------

param([switch]$Force)

function Pause-Here { [void](Read-Host -Prompt '按回车退出') }

# ==== 自动提权 ====
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).
            IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    $myPath = $MyInvocation.MyCommand.Definition
    $args = "-ExecutionPolicy Bypass -File `"$myPath`""
    if ($Force) { $args += " -Force" }
    Start-Process powershell.exe -Verb RunAs -ArgumentList $args
    exit
}

Write-Host "🧩 已获取管理员权限"
Write-Host "🔍 正在扫描未分配盘符的卷..."

# ==== 获取候选卷 ====
$vols = Get-Volume |
    Where-Object {
        $_.DriveType -eq 'Fixed' -and
        $_.DriveLetter -eq $null -and
        $_.FileSystemType -in 'NTFS','ReFS' -and
        $_.Size -gt 10GB
    } |
    Sort-Object Size -Descending

if (-not $vols) {
    Write-Host "✅ 未检测到需要分配盘符的卷。"
    Pause-Here
    exit
}

# ==== 获取已占用的盘符 ====
$used = (Get-Volume | Where-Object { $_.DriveLetter }) | ForEach-Object { $_.DriveLetter }

# ==== 可用盘符列表 D..Z ====
$letters = @('D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z')
$idx = 0

foreach ($v in $vols) {
    # 跳过系统/引导/隐藏/只读分区
    $p = Get-Partition -Volume $v
    if ($p.IsSystem -or $p.IsBoot -or $p.IsHidden -or $p.IsReadOnly) {
        Write-Host "⚠️ 跳过系统或隐藏卷: $($v.Path)"
        continue
    }

    # 找到第一个可用的盘符
    while ($idx -lt $letters.Count -and ($letters[$idx] -in $used)) { $idx++ }
    if ($idx -ge $letters.Count) { Write-Warning "❌ 没有可用盘符"; break }

    $newLetter = $letters[$idx]
    try {
        # 如需强制“腾位置”，可以在这里判断 $Force 并把占用的新盘符挪到临时字母（此处默认不强制覆盖）
        $p | Set-Partition -NewDriveLetter $newLetter -ErrorAction Stop
        $label = if ($v.FileSystemLabel) { $v.FileSystemLabel } else { $v.UniqueId }
        Write-Host "✅ 已将卷 [$label] 分配为 $($newLetter):"
        $used += $newLetter
    }
    catch {
        Write-Warning "❌ 分配盘符 $($newLetter): 失败 -> $($_.Exception.Message)"
    }
    $idx++
}

Write-Host "🎉 盘符分配完成！"
Pause-Here
