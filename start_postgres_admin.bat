@echo off
echo Starting PostgreSQL service...
echo You may need Administrator privileges for this.
echo.

net start postgresql-x64-18

if %errorlevel% equ 0 (
    echo SUCCESS: PostgreSQL started!
    echo Now you can use pgAdmin to reset the database.
) else (
    echo FAILED: Could not start PostgreSQL
    echo Try running this script as Administrator
    echo Or use Windows Services: Win+R, type services.msc
)

pause