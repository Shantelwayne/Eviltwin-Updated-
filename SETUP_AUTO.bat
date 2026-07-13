@echo off
:: ============================================================
::  Automated Setup - No prompts, runs straight through
:: ============================================================
title Software Setup (Automated)

:: Check if already running as Administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :run_setup
)

:: Not admin - re-launch elevated
echo.
echo  =========================================================
echo   Launching setup with Administrator privileges...
echo  =========================================================
echo.

:: Re-launch this script elevated
powershell -Command "Start-Process '%~f0' -Verb RunAs"
exit /b

:run_setup
cls
echo.
echo  =========================================================
echo   Automated Software Setup (No Prompts)
echo  =========================================================
echo.
echo  Starting installation automatically...
echo.

:: Run the PowerShell setup script with automation flag
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" -LaunchDir "%~dp0" -Automated

if %errorLevel% neq 0 (
    echo.
    echo  =========================================================
    echo   Setup encountered an error. See details above.
    echo   Check C:\hmdm\logs\setup.log for more information.
    echo  =========================================================
    echo.
    echo  Press any key to exit...
    pause >nul
    exit /b 1
)

echo.
echo  =========================================================
echo   Setup Complete! Server should be starting...
echo.
echo   URL: http://localhost:8080
echo   Login: admin / admin
echo  =========================================================
echo.
echo  Opening browser in 10 seconds...
timeout /t 10 /nobreak >nul
start http://localhost:8080
exit /b 0