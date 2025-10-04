@ECHO OFF
REM  QBFC Project Options Begin
REM  HasVersionInfo: No
REM Companyname: 
REM Productname: 
REM Filedescription: 
REM Copyrights: 
REM Trademarks: 
REM Originalname: 
REM Comments: 
REM Productversion:  0. 0. 0. 0
REM Fileversion:  0. 0. 0. 0
REM Internalname: 
REM ExeType: console
REM Architecture: x64
REM Appicon: 
REM AdministratorManifest: No
REM  QBFC Project Options End
@ECHO ON
@echo off
setlocal

:: 检查是否已有管理员权限
>nul 2>&1 net session
if %errorlevel% neq 0 (
    :: 如果已经带了 --elevated 参数，则直接进入主流程，避免循环
    if "%~1"=="--elevated" goto ADMIN_MAIN

    echo [i] 当前非管理员，尝试用 PowerShell 请求提升...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "Start-Process -FilePath '%COMSPEC%' -ArgumentList '/c','\"%~f0\" --elevated' -Verb RunAs"
    exit /b
)

:ADMIN_MAIN
echo [OK] 已是管理员，执行管理员操作...
:: -------------------------
:: -------------------------

echo 完成。
pause
exit /b
