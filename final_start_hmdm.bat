@echo off
echo ========================================
echo      HMDM Final Startup Script
echo ========================================
echo.
echo This script will:
echo 1. Stop Tomcat (if running)
echo 2. Start Tomcat with fresh HMDM
echo 3. Wait for initialization
echo 4. Open HMDM in browser
echo.
echo Make sure you've reset the database first!
echo.
pause

echo Stopping Tomcat...
cd C:\tomcat9\bin
call shutdown.bat
timeout /t 5 /nobreak >nul

echo Starting Tomcat...
call startup.bat

echo.
echo Waiting 90 seconds for HMDM to initialize database...
echo (This only takes time on first run with empty database)
echo.

for /L %%i in (90,-1,1) do (
    echo Initializing... %%i seconds remaining
    timeout /t 1 /nobreak >nul
)

echo.
echo ========================================
echo   HMDM should be ready!
echo   Opening browser...
echo ========================================
echo.
echo URL: http://localhost:8080
echo Login: admin
echo Password: admin
echo.

start http://localhost:8080

echo Browser opened. If you see HMDM login page, SUCCESS!
echo If you see Tomcat error page, check the logs.
pause