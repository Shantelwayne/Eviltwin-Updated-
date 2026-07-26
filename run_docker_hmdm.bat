@echo off
echo ========================================
echo      HMDM Docker Installation
echo ========================================
echo.
echo This will:
echo 1. Stop local Tomcat
echo 2. Download and run HMDM via Docker
echo 3. Open HMDM in browser (takes 2-3 minutes)
echo.
pause

echo Stopping local Tomcat...
cd C:\tomcat9\bin
call shutdown.bat

echo.
echo Starting HMDM via Docker...
echo (This will download ~500MB the first time)
echo.

docker run -d -p 8080:8080 --name hmdm headwindmdm/hmdm

echo.
echo Waiting for HMDM to initialize...
echo This takes 2-3 minutes for database setup.
echo.

for /L %%i in (180,-1,1) do (
    echo Initializing... %%i seconds remaining
    timeout /t 1 /nobreak >nul
)

echo.
echo ========================================
echo   HMDM Docker should be ready!
echo   Opening browser...
echo ========================================
echo.

start http://localhost:8080

echo.
echo If you see HMDM login page:
echo   Login: admin
echo   Password: admin
echo.
echo If still loading, wait another minute.
echo.
pause