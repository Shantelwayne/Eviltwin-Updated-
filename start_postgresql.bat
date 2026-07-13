@echo off
echo Starting PostgreSQL service...
echo.

REM Try common PostgreSQL service names
net start postgresql-x64-16 2>nul
if %errorlevel% == 0 (
    echo PostgreSQL-x64-16 service started successfully!
    goto :success
)

net start postgresql-x64-15 2>nul
if %errorlevel% == 0 (
    echo PostgreSQL-x64-15 service started successfully!
    goto :success
)

net start postgresql-x64-14 2>nul
if %errorlevel% == 0 (
    echo PostgreSQL-x64-14 service started successfully!
    goto :success
)

net start "PostgreSQL Database Server 16" 2>nul
if %errorlevel% == 0 (
    echo PostgreSQL Database Server 16 started successfully!
    goto :success
)

echo.
echo Could not start PostgreSQL service automatically.
echo Please try manually:
echo 1. Open Services (services.msc)
echo 2. Find PostgreSQL service
echo 3. Right-click and select "Start"
echo.
echo Or try these commands:
echo   sc query ^| findstr postgres
echo   net start [service-name]
echo.
pause
goto :end

:success
echo.
echo Waiting 3 seconds for service to initialize...
timeout /t 3 /nobreak >nul
echo.
echo You can now run SETUP.bat again!
echo.
pause

:end