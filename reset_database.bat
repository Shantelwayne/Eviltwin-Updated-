@echo off
echo Resetting HMDM database...

cd "C:\Program Files\PostgreSQL\18\bin"

echo Dropping existing hmdm database...
psql -h localhost -U postgres -d postgres -c "DROP DATABASE IF EXISTS hmdm;"

echo Creating fresh hmdm database...
psql -h localhost -U postgres -d postgres -c "CREATE DATABASE hmdm WITH OWNER=hmdm;"

if %errorlevel% neq 0 (
    echo Failed to create database
    echo Make sure PostgreSQL is running and pg_hba.conf is set to 'trust'
    pause
    exit /b 1
)

echo Database reset successful!
echo Starting Tomcat...

cd C:\tomcat9\bin
startup.bat

echo.
echo Wait 2-3 minutes for HMDM to initialize, then open:
echo http://localhost:8080
echo Login: admin / admin
echo.
pause