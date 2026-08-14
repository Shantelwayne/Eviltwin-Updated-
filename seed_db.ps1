# Database Seeding Script
$PG_BIN = "C:\Program Files\PostgreSQL\18\bin"
$PG_USER = "hmdm"
$PG_PASS = "hmdm"
$PG_HOST = "localhost"
$PG_PORT = "5432"
$PG_DB = "hmdm"
$HMDM_DATA_DIR = "C:\hmdm"

Write-Host "Starting database seeding..." -ForegroundColor Green

# Set password
$env:PGPASSWORD = $PG_PASS

# Check if schema exists
Write-Host "Checking database schema..." -ForegroundColor Yellow
& "$PG_BIN\psql.exe" -U $PG_USER -h $PG_HOST -p $PG_PORT -d $PG_DB -c "\dt" | Write-Host

# Seed database
$sqlInit = "C:\Users\migwi\Desktop\Spywares\hmdm-server-master\hmdm-server-master\install\sql\hmdm_init.en.sql"
if (Test-Path $sqlInit) {
    Write-Host "Seeding database from: $sqlInit" -ForegroundColor Green
    
    $sqlContent = (Get-Content $sqlInit -Raw) `
        -replace '_HMDM_BASE_',    ($HMDM_DATA_DIR -replace '\\','/') `
        -replace '_HMDM_VERSION_', '5.19' `
        -replace '_HMDM_APK_',     'hmdm-5.19-os.apk' `
        -replace '_ADMIN_EMAIL_',  ''
        
    $tempSql = "$env:TEMP\hmdm_init.sql"
    $sqlContent | Set-Content $tempSql -Encoding UTF8
    
    Write-Host "Executing SQL..." -ForegroundColor Yellow
    & "$PG_BIN\psql.exe" -U $PG_USER -h $PG_HOST -p $PG_PORT -d $PG_DB -f $tempSql
    
    Remove-Item $tempSql -Force -ErrorAction SilentlyContinue
    Write-Host "Database seeding completed!" -ForegroundColor Green
} else {
    Write-Host "SQL file not found: $sqlInit" -ForegroundColor Red
}