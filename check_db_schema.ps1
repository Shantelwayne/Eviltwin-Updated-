# Check if HMDM database schema has been created
Write-Host "Checking HMDM database schema..." -ForegroundColor Cyan

$env:PGPASSWORD = "hmdm"
$PG_BIN = "C:\Program Files\PostgreSQL\18\bin"

Write-Host "Connecting to database..." -ForegroundColor Yellow
$result = & "$PG_BIN\psql.exe" -U hmdm -h localhost -p 5432 -d hmdm -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>&1

if ($LASTEXITCODE -eq 0) {
    $tableCount = $result.Trim()
    Write-Host "Database connection successful. Found $tableCount tables." -ForegroundColor Green
    
    if ([int]$tableCount -gt 0) {
        Write-Host "Listing tables in public schema:" -ForegroundColor Yellow
        & "$PG_BIN\psql.exe" -U hmdm -h localhost -p 5432 -d hmdm -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;" 2>&1
        
        Write-Host "`nChecking for 'userroles' table specifically:" -ForegroundColor Yellow
        $userrolesCheck = & "$PG_BIN\psql.exe" -U hmdm -h localhost -p 5432 -d hmdm -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'userroles';" 2>&1
        
        if ($userrolesCheck.Trim() -eq "1") {
            Write-Host "✓ userroles table exists - schema is ready!" -ForegroundColor Green
            exit 0
        } else {
            Write-Host "✗ userroles table not found - schema not ready yet" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "✗ No tables found - application has not created schema yet" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✗ Database connection failed: $result" -ForegroundColor Red
    exit 2
}