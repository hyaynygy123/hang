# 恢复任务栏显示（含多显示器），必要时重启 Explorer 兜底
Add-Type -Language CSharp @"
using System;
using System.Runtime.InteropServices;
using System.Text;

public static class TaskbarRestore {
    const int SW_SHOW = 5;

    [DllImport("user32.dll", SetLastError=true)]
    static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll", SetLastError=true)]
    static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll", CharSet=CharSet.Unicode)]
    static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);

    public static void ShowAll(){
        // 主任务栏
        var primary = FindWindow("Shell_TrayWnd", null);
        if(primary != IntPtr.Zero) ShowWindow(primary, SW_SHOW);

        // 副任务栏（多显示器）
        EnumWindows((h, l) => {
            var sb = new StringBuilder(256);
            GetClassName(h, sb, sb.Capacity);
            if(sb.ToString() == "Shell_SecondaryTrayWnd")
                ShowWindow(h, SW_SHOW);
            return true;
        }, IntPtr.Zero);
    }
}
"@

# 1) 尝试直接显示
[TaskbarRestore]::ShowAll()

Start-Sleep -Milliseconds 300

# 2) 可选：如果你之前打开了“自动隐藏”，一起恢复为不自动隐藏（主屏）
try {
    $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
    if (Test-Path $key) {
        $v = (Get-ItemProperty -Path $key).Settings
        if ($v -and $v.Length -ge 9) {
            $v[8] = $v[8] -band (-bnot 0x08)   # 清除自动隐藏位
            Set-ItemProperty -Path $key -Name Settings -Value $v | Out-Null
        }
    }
} catch {}

# 3) 兜底：如果任务栏还是没出现，就温和重启一下 Explorer
$tray = Get-Process -Name explorer -ErrorAction SilentlyContinue
if ($tray) {
    # 通知资源管理器刷新任务栏（更温和方式）
    & rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True | Out-Null
}
# 如果仍不出现，可以解除下面两行注释，做一次重启（会刷新桌面图标/任务栏）
# Stop-Process -Name explorer -Force
# Start-Process explorer

Write-Host "✅ 任务栏恢复完成（如仍未显示，可取消脚本末尾两行注释再运行一次）"
