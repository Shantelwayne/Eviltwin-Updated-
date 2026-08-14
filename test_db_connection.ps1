# Test database connection with found password
$env:PGPASSWORD = "e30bDL6doiy7zFkP"
$PG_BIN = "C:\Program Files\PostgreSQL\18\bin"

Write-Host "Testing connection with hmdm user..." -ForegroundColor Yellow
$result = & "$PG_BIN\psql.exe" -U hmdm -h localhost -p 5432 -d hmdm -c "SELECT 1;" 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Connected successfully to HMDM database!" -ForegroundColor Green
    Write-Host "Result: $result" -ForegroundColor Green
    
    # Check if tables exist
    Write-Host "Checking for tables..." -ForegroundColor Yellow
    & "$PG_BIN\psql.exe" -U hmdm -h localhost -p 5432 -d hmdm -c "\dt"
} else {
    Write-Host "✗ Connection failed: $result" -ForegroundColor Red
}