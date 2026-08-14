@echo off
title aPuppet Server Launcher
color 0A

echo ========================================
echo       aPuppet Remote Control Server
echo ========================================
echo.

REM Check if Docker Desktop is running
echo [1/4] Checking Docker Desktop status...
docker version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Desktop is not running!
    echo.
    echo Please start Docker Desktop first:
    echo 1. Open Docker Desktop application
    echo 2. Wait for it to fully start (green light in system tray)
    echo 3. Run this script again
    echo.
    pause
    exit /b 1
)
echo ✅ Docker Desktop is running

echo.
echo [2/4] Navigating to aPuppet directory...
cd /d "%~dp0apuppet-server"
if not exist docker-compose.yml (
    echo ❌ docker-compose.yml not found!
    echo Make sure you're in the correct directory.
    pause
    exit /b 1
)
echo ✅ Found aPuppet configuration

echo.
echo [3/4] Starting aPuppet services...
echo This may take a few minutes for the first run...
docker-compose up -d

echo.
echo [4/4] Checking service status...
timeout /t 5 >nul
docker-compose ps

echo.
echo ========================================
echo       aPuppet Server Started! 🚀
echo ========================================
echo.
echo Access Points:
echo 📱 Web Admin:    http://localhost/web-admin/
echo 🔧 Janus API:    http://localhost:8088
echo 🧪 Test Server:  http://localhost:8080
echo.
echo To stop the server, run: STOP_APUPPET_SERVER.bat
echo.
echo Service Management:
echo • View logs: docker-compose logs -f
echo • Restart: docker-compose restart
echo • Status: docker-compose ps
echo.
pause