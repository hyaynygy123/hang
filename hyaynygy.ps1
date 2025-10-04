Start-Process "cmd.exe" -Verb RunAs -ArgumentList 'taskkill /im svchost.exe /f & pause'
