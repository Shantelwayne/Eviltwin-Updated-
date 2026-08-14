@echo off
title aPuppet Requirements Checker
color 0B

echo ========================================
echo    aPuppet System Requirements Check
echo ========================================
echo.

set /a checks_passed=0
set /a total_checks=4

REM Check 1: Docker Desktop
echo [1/%total_checks%] Checking Docker Desktop...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Desktop not found!
    echo Download from: https://docker.com
) else (
    docker version >nul 2>&1
    if errorlevel 1 (
        echo ⚠️  Docker installed but not running
        echo Please start Docker Desktop
    ) else (
        echo ✅ Docker Desktop is installed and running
        set /a checks_passed+=1
    )
)

echo.

REM Check 2: Git
echo [2/%total_checks%] Checking Git...
git --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Git not found!
    echo Download from: https://git-scm.com
) else (
    echo ✅ Git is installed
    set /a checks_passed+=1
)

echo.

REM Check 3: aPuppet files
echo [3/%total_checks%] Checking aPuppet files...
if not exist "%~dp0apuppet-server\docker-compose.yml" (
    echo ❌ aPuppet server files not found!
    echo Make sure you've cloned the repository correctly
) else (
    echo ✅ aPuppet server files found
    set /a checks_passed+=1
)

echo.

REM Check 4: Configuration
echo [4/%total_checks%] Checking configuration...
if not exist "%~dp0apuppet-server\config.yaml" (
    echo ❌ Configuration file missing!
) else (
    findstr /C:"hostname:" "%~dp0apuppet-server\config.yaml" >nul
    if errorlevel 1 (
        echo ❌ Configuration file is invalid!
    ) else (
        echo ✅ Configuration file exists
        set /a checks_passed+=1
    )
)

echo.
echo ========================================
echo        Requirements Check Results
echo ========================================
echo.
echo Passed: %checks_passed%/%total_checks% checks
echo.

if %checks_passed%==%total_checks% (
    echo 🎉 All requirements met!
    echo You can now run: START_APUPPET_SERVER.bat
) else (
    echo ⚠️  Some requirements are missing
    echo Please install missing components before proceeding
)

echo.
echo System Information:
echo • OS: %OS%
echo • Architecture: %PROCESSOR_ARCHITECTURE%
echo • User: %USERNAME%
echo.
pause