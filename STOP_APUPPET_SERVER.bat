@echo off
title aPuppet Server Stopper
color 0C

echo ========================================
echo      Stopping aPuppet Server...
echo ========================================
echo.

cd /d "%~dp0apuppet-server"

echo [1/2] Stopping all aPuppet services...
docker-compose down

echo.
echo [2/2] Cleaning up containers...
docker-compose ps

echo.
echo ========================================
echo       aPuppet Server Stopped! 🛑
echo ========================================
echo.
echo All services have been stopped and containers removed.
echo To start again, run: START_APUPPET_SERVER.bat
echo.
pause