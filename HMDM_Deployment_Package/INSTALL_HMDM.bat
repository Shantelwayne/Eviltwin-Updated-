@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

echo ========================================
echo        HMDM Installation Launcher
echo ========================================
echo.
echo Choose your installation method:
echo.
echo 1. Docker Installation (Recommended)
echo    - Fastest and most reliable
echo    - No complex configuration
echo    - Ready in 15 minutes
echo.
echo 2. Full Installation
echo    - Complete control over components
echo    - Customizable configuration
echo    - Takes 30-45 minutes
echo.
echo 3. View Documentation
echo.
echo 4. Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    echo Starting Docker installation...
    call installers\HMDM_Docker_Installer.bat
) else if "%choice%"=="2" (
    echo Starting full installation...
    call installers\HMDM_Auto_Installer.bat
) else if "%choice%"=="3" (
    start README.md
    goto :menu
) else if "%choice%"=="4" (
) else (
    echo Invalid choice. Please enter 1-4.
    pause
    goto :menu
)
