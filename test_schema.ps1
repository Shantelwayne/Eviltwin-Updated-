# Test Database Schema
$PG_BIN = "C:\Program Files\PostgreSQL\18\bin"
$PG_USER = "hmdm"
$PG_PASS = "hmdm"
$PG_HOST = "localhost"
$PG_PORT = "5432"
$PG_DB = "hmdm"

Write-Host "Testing database connection and checking for schema..." -ForegroundColor Yellow
$env:PGPASSWORD = $PG_PASS

# Check if userroles table exists
Write-Host "Checking for 'userroles' table..." -ForegroundColor Cyan
$result = & "$PG_BIN\psql.exe" -U $PG_USER -h $PG_HOST -p $PG_PORT -d $PG_DB -t -c "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'userroles');" 2>&1

if ($LASTEXITCODE -eq 0 -and $result.Trim() -eq "t") {
    Write-Host "✓ userroles table exists! Schema is ready." -ForegroundColor Green
    exit 0
} else {
    Write-Host "✗ userroles table not found. Application may still be initializing..." -ForegroundColor Red
    Write-Host "Result: $result" -ForegroundColor Gray
    exit 1
}