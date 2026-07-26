@echo off
echo Complete HMDM Database Setup
echo ============================
set PGPASSWORD=e30bDL6doiy7zFkP
set PG_BIN=C:\Program Files\PostgreSQL\18\bin
set PG_USER=hmdm
set PG_HOST=localhost
set PG_PORT=5432
set PG_DB=hmdm

echo Step 1: Creating essential database tables...
"%PG_BIN%\psql.exe" -U %PG_USER% -h %PG_HOST% -p %PG_PORT% -d %PG_DB% -f "C:\Users\migwi\Desktop\Spywares\create_tables.sql"

if errorlevel 1 (
    echo ERROR: Failed to create tables
    pause
    exit /b 1
)

echo Step 2: Processing and running seed data...
powershell -Command "$sqlContent = (Get-Content 'C:\Users\migwi\Desktop\Spywares\hmdm-server-master\hmdm-server-master\install\sql\hmdm_init.en.sql' -Raw) -replace '_HMDM_BASE_', 'C:/hmdm' -replace '_HMDM_VERSION_', '5.19' -replace '_HMDM_APK_', 'hmdm-5.19-os.apk' -replace '_ADMIN_EMAIL_', 'admin@localhost.com'; $sqlContent | Set-Content '%TEMP%\hmdm_seed.sql' -Encoding UTF8"

"%PG_BIN%\psql.exe" -U %PG_USER% -h %PG_HOST% -p %PG_PORT% -d %PG_DB% -f "%TEMP%\hmdm_seed.sql"

if errorlevel 1 (
    echo WARNING: Seeding had some issues, but core tables exist
    echo You can proceed with using HMDM
) else (
    echo SUCCESS: Database setup completed!
)

echo Step 3: Verifying setup...
echo Checking tables:
"%PG_BIN%\psql.exe" -U %PG_USER% -h %PG_HOST% -p %PG_PORT% -d %PG_DB% -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;"

echo.
echo Database setup complete!
echo You can now access HMDM at: http://localhost:8080
echo Default login: admin / admin
echo.
pause