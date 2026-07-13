@echo off
:: ============================================================
::  Headwind MDM - Windows Setup Launcher
::  Double-click this file after cloning the repo.
::  It will guide you through the full installation.
:: ============================================================
title Headwind MDM Setup

:: Check if already running as Administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :run_setup
)

:: Not admin - re-launch elevated
echo.
echo  =========================================================
echo   Headwind MDM Setup needs Administrator privileges.
echo   A UAC prompt will appear - please click "Yes" to allow.
echo  =========================================================
echo.
pause

:: Re-launch this script elevated
powershell -Command "Start-Process '%~f0' -Verb RunAs"
exit /b

:run_setup
cls
echo.
echo  =========================================================
echo.
echo      Welcome to Headwind MDM Windows Setup
echo.
echo  =========================================================
echo.
echo  This installer will:
echo.
echo    [1] Check your system requirements
echo    [2] Install Java 11 JDK
echo    [3] Install Apache Maven
echo    [4] Install PostgreSQL 16
echo    [5] Download and configure Apache Tomcat 9
echo    [6] Build the Headwind MDM server
echo    [7] Set up the database
echo    [8] Deploy and start the server
echo.
echo  ---------------------------------------------------------
echo  After setup, open your browser to: http://localhost:8080
echo  Default login: admin / admin
echo  ---------------------------------------------------------
echo.
echo  Press any key to begin installation...
pause >nul

:: Run the PowerShell setup script
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" -LaunchDir "%~dp0"

if %errorLevel% neq 0 (
    echo.
    echo  =========================================================
    echo   Setup encountered an error. See details above.
    echo   Check C:\hmdm\logs\setup.log for more information.
    echo  =========================================================
    echo.
    pause
    exit /b 1
)

echo.
echo  =========================================================
echo   Setup Complete!
echo.
echo   Open your browser and go to: http://localhost:8080
echo   Login: admin    Password: admin
echo  =========================================================
echo.
echo  Press any key to open the browser...
pause >nul
start http://localhost:8080
exit /b 0
