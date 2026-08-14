# Direct Database Seeding for HMDM
Write-Host "Attempting direct database seeding..." -ForegroundColor Cyan

$PG_BIN = "C:\Program Files\PostgreSQL\18\bin"
$PG_USER = "hmdm"
$PG_PASS = "e30bDL6doiy7zFkP"
$PG_HOST = "localhost"
$PG_PORT = "5432"
$PG_DB = "hmdm"
$HMDM_DATA_DIR = "C:\hmdm"
$SERVER_DIR = "C:\Users\migwi\Desktop\Spywares\hmdm-server-master\hmdm-server-master"

$env:PGPASSWORD = $PG_PASS

# Read and process the SQL init script
$sqlInit = "$SERVER_DIR\install\sql\hmdm_init.en.sql"

if (Test-Path $sqlInit) {
    Write-Host "Processing SQL init file: $sqlInit" -ForegroundColor Yellow
    
    $sqlContent = (Get-Content $sqlInit -Raw) `
        -replace '_HMDM_BASE_', ($HMDM_DATA_DIR -replace '\\','/') `
        -replace '_HMDM_VERSION_', '5.19' `
        -replace '_HMDM_APK_', 'hmdm-5.19-os.apk' `
        -replace '_ADMIN_EMAIL_', 'admin@localhost.com'
        
    $tempSql = "$env:TEMP\hmdm_seed_final.sql"
    $sqlContent | Set-Content $tempSql -Encoding UTF8
    
    Write-Host "Executing database seeding..." -ForegroundColor Yellow
    Write-Host "SQL content preview:" -ForegroundColor Gray
    Get-Content $tempSql | Select-Object -First 5 | Write-Host -ForegroundColor Gray
    
    $result = & "$PG_BIN\psql.exe" -U $PG_USER -h $PG_HOST -p $PG_PORT -d $PG_DB -f $tempSql 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Database seeded successfully!" -ForegroundColor Green
        Remove-Item $tempSql -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "Database seeding error:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        Write-Host "Temp SQL file saved at: $tempSql" -ForegroundColor Yellow
        Write-Host "Exit code: $LASTEXITCODE" -ForegroundColor Red
    }
} else {
    Write-Host "✗ SQL init file not found: $sqlInit" -ForegroundColor Red
}