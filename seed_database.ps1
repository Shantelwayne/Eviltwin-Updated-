# HMDM Database Seeding Script
Write-Host "Starting HMDM database seeding..." -ForegroundColor Cyan

# Configuration
$PG_BIN = "C:\Program Files\PostgreSQL\18\bin"
$PG_USER = "hmdm"
$PG_PASS = "hmdm"
$PG_HOST = "localhost"
$PG_PORT = "5432"
$PG_DB = "hmdm"
$HMDM_DATA_DIR = "C:\hmdm"
$cleanServerDir = "C:\Users\migwi\Desktop\Spywares\hmdm-server-master\hmdm-server-master"

# Check if SQL init file exists
$sqlInit = Join-Path $cleanServerDir "install\sql\hmdm_init.en.sql"
Write-Host "Looking for SQL init file: $sqlInit" -ForegroundColor Yellow

if (Test-Path -LiteralPath $sqlInit) {
    Write-Host "✓ Found SQL init file" -ForegroundColor Green
    
    # Set environment variables
    $env:PGPASSWORD = $PG_PASS
    $env:Path += ";$PG_BIN"
    
    Write-Host "Processing SQL content..." -ForegroundColor Yellow
    $sqlContent = (Get-Content $sqlInit -Raw) `
        -replace '_HMDM_BASE_',    ($HMDM_DATA_DIR -replace '\\','/') `
        -replace '_HMDM_VERSION_', '5.19' `
        -replace '_HMDM_APK_',     'hmdm-5.19-os.apk' `
        -replace '_ADMIN_EMAIL_',  ''
    
    $tempSql = "$env:TEMP\hmdm_init_retry.sql"
    Write-Host "Writing processed SQL to: $tempSql" -ForegroundColor Yellow
    $sqlContent | Set-Content $tempSql -Encoding UTF8
    
    Write-Host "Executing SQL seeding..." -ForegroundColor Yellow
    $psqlResult = & "$PG_BIN\psql.exe" -U $PG_USER -h $PG_HOST -p $PG_PORT -d $PG_DB -f $tempSql 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Database seeded successfully!" -ForegroundColor Green
        Remove-Item $tempSql -Force -ErrorAction SilentlyContinue
        exit 0
    } else {
        Write-Host "✗ Database seeding failed:" -ForegroundColor Red
        Write-Host $psqlResult -ForegroundColor Red
        Write-Host "Temp SQL file left for inspection: $tempSql" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "✗ SQL init file not found: $sqlInit" -ForegroundColor Red
    exit 2
}