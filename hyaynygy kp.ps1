$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).
  IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
  $my = $MyInvocation.MyCommand.Definition
  $args = @('-ExecutionPolicy','Bypass','-File',"`"$my`"") -join ' '
  Start-Process powershell.exe -Verb RunAs -ArgumentList $args
  exit
}
$sysDrive = ($env:SystemDrive).TrimEnd('\')   # e.g. C:
$targets = Get-CimInstance Win32_Volume |
  Where-Object {
    $_.DriveLetter -and
    $_.DriveLetter -ne $sysDrive -and
    -not $_.BootVolume -and
    -not $_.SystemVolume -and
    $_.DriveType -eq 3   
  } |
  Sort-Object DriveLetter

if (-not $targets) {
  Write-Host "qwqqwq"
  exit
}

foreach ($v in $targets) {
  $dl = $v.DriveLetter.TrimEnd('\')  # e.g. D:
  Write-Host "qwq"
  cmd /c "mountvol $dl /D" | Out-Null
}

Write-Host "awa"
