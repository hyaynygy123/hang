$url  = "https://pic3.zhimg.com/v2-f7c45a855f5881818fe36e8c3ab5645e_r.jpg"
$path = "$env:TEMP\v2-f7c45a855f5881818fe36e8c3ab5645e_r.jpg"

# 下载图片
Invoke-WebRequest -Uri $url -OutFile $path

# 定义 WinAPI 函数（不需要类名，避免重复定义冲突）
$signature = @"
[DllImport("user32.dll", SetLastError=true)]
public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
"@

$User32 = Add-Type -MemberDefinition $signature -Name "User32" -Namespace WinAPI -PassThru

# 调用 API 设置壁纸
$result = $User32::SystemParametersInfo(20, 0, $path, 0x01 -bor 0x02)

if ($result) {
    Write-Host "✅ 壁纸已更换: $path"
} else {
    Write-Host "⚠️ 设置壁纸失败"
}

pause
