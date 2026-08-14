@echo off
echo Starting PostgreSQL service...
net start postgresql-x64-18
if %errorlevel% neq 0 (
    echo Failed to start PostgreSQL service
    echo You may need to run this as Administrator
    pause
    exit /b 1
)
echo PostgreSQL started successfully!
pause