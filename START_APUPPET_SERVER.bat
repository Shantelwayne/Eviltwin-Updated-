@echo off
title aPuppet Server Launcher
color 0A

echo ========================================
echo       aPuppet Remote Control Server
echo ========================================
echo.

REM Check if Docker Desktop is running
echo [1/5] Checking Docker Desktop status...
docker version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Desktop is not running!
    echo.
    echo Please start Docker Desktop first:
    echo 1. Open Docker Desktop application
    echo 2. Wait for it to fully start (green light in system tray)
    echo 3. Run this script again
    echo.
    echo TIP: You can set Docker Desktop to start automatically:
    echo Docker Desktop → Settings → General → "Start Docker Desktop when you log in"
    echo.
    pause
    exit /b 1
)
echo ✅ Docker Desktop is running

echo.
echo [2/5] Navigating to aPuppet directory...
cd /d "%~dp0apuppet-server"
if not exist docker-compose.yml (
    echo ❌ docker-compose.yml not found!
    echo Make sure you're in the correct directory.
    echo Expected: %~dp0apuppet-server\docker-compose.yml
    pause
    exit /b 1
)
echo ✅ Found aPuppet configuration

echo.
echo [3/5] Checking configuration...
if not exist config.yaml (
    echo ⚠️  Creating default configuration...
    echo ---> config.yaml
    echo hostname: "localhost">> config.yaml
    echo email: "admin@localhost.com">> config.yaml
    echo ✅ Created default config.yaml
) else (
    echo ✅ Configuration file exists
)

echo.
echo [4/5] Starting aPuppet services...
echo This may take a few minutes for the first run...
echo.
docker-compose up -d

echo.
echo [5/5] Checking service status...
timeout /t 5 >nul
docker-compose ps

echo.
echo ========================================
echo       aPuppet Server Started! 🚀
echo ========================================
echo.
echo 📡 Server Status:
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
echo.
echo 🌐 Access Points:
echo • Web Admin:    http://localhost/web-admin/
echo • Janus API:    http://localhost:8088
echo • Dev Server:   http://localhost:8080
echo.
echo 📱 For Network Access (other devices):
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr "IPv4"') do (
    for /f "tokens=1" %%j in ("%%i") do echo • Network:      http://%%j/web-admin/
)
echo.
echo 🔧 Management Commands:
echo • View logs:     docker-compose logs -f
echo • Restart:       docker-compose restart
echo • Stop server:   STOP_APUPPET_SERVER.bat
echo.
echo ⚠️  IMPORTANT: Docker Desktop must be running for the server to work!
echo    Containers will stop when Docker Desktop closes or computer restarts.
echo.
pause