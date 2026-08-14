@echo off
echo Seeding HMDM database with correct credentials...
set PGPASSWORD=e30bDL6doiy7zFkP
set PG_BIN=C:\Program Files\PostgreSQL\18\bin
set PG_USER=hmdm
set PG_HOST=localhost
set PG_PORT=5432
set PG_DB=hmdm

echo Testing database connection...
"%PG_BIN%\psql.exe" -U %PG_USER% -h %PG_HOST% -p %PG_PORT% -d %PG_DB% -c "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Cannot connect to database
    exit /b 1
)

echo Connection successful. Checking for tables...
"%PG_BIN%\psql.exe" -U %PG_USER% -h %PG_HOST% -p %PG_PORT% -d %PG_DB% -c "\dt" >nul 2>&1
if errorlevel 1 (
    echo Tables don't exist yet. Seeding will likely fail.
) else (
    echo Tables exist. Proceeding with seeding...
)

echo Processing SQL file...
powershell -Command "$sqlContent = (Get-Content 'C:\Users\migwi\Desktop\Spywares\hmdm-server-master\hmdm-server-master\install\sql\hmdm_init.en.sql' -Raw) -replace '_HMDM_BASE_', 'C:/hmdm' -replace '_HMDM_VERSION_', '5.19' -replace '_HMDM_APK_', 'hmdm-5.19-os.apk' -replace '_ADMIN_EMAIL_', 'admin@localhost.com'; $sqlContent | Set-Content '%TEMP%\hmdm_final_seed.sql' -Encoding UTF8"

echo Executing database seeding...
"%PG_BIN%\psql.exe" -U %PG_USER% -h %PG_HOST% -p %PG_PORT% -d %PG_DB% -f "%TEMP%\hmdm_final_seed.sql"

if errorlevel 1 (
    echo Database seeding failed!
    echo Check the error messages above.
) else (
    echo Database seeded successfully!
    del "%TEMP%\hmdm_final_seed.sql" >nul 2>&1
)
pause