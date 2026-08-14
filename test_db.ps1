# Test Database Connection and Schema
Write-Host "Testing database connection and schema..." -ForegroundColor Cyan

$PG_BIN = "C:\Program Files\PostgreSQL\18\bin"
$PG_USER = "hmdm"
$PG_PASS = "hmdm"
$PG_HOST = "localhost"  
$PG_PORT = "5432"
$PG_DB = "hmdm"

$env:PGPASSWORD = $PG_PASS

Write-Host "Checking if database exists..." -ForegroundColor Yellow
& "$PG_BIN\psql.exe" -U $PG_USER -h $PG_HOST -p $PG_PORT -d $PG_DB -c "\dt" 2>&1 | Write-Host

Write-Host "Checking specific tables..." -ForegroundColor Yellow
& "$PG_BIN\psql.exe" -U $PG_USER -h $PG_HOST -p $PG_PORT -d $PG_DB -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;" 2>&1 | Write-Host