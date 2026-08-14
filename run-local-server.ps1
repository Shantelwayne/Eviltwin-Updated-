# Run HMDM Server Locally
param(
    [int]$Port = 9090
)

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  HMDM Local Development Server" -ForegroundColor Cyan  
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Server will run at: http://localhost:$Port" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Change to server directory
$serverDir = Join-Path $PSScriptRoot "hmdm-server-master\hmdm-server-master\server"
if (-not (Test-Path $serverDir)) {
    Write-Host "Error: Server directory not found at $serverDir" -ForegroundColor Red
    exit 1
}

Set-Location $serverDir
Write-Host "Working directory: $serverDir" -ForegroundColor Gray

# Check if Maven is available
$mvnCmd = Get-Command mvn -ErrorAction SilentlyContinue
if (-not $mvnCmd) {
    Write-Host "Maven not found on PATH. Adding Maven..." -ForegroundColor Yellow
    $env:Path += ";C:\Apache\Maven\bin"
    $mvnCmd = Get-Command mvn -ErrorAction SilentlyContinue
    if (-not $mvnCmd) {
        Write-Host "Error: Maven not found. Please install Maven first." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Maven found: $($mvnCmd.Source)" -ForegroundColor Green

# Start the embedded Tomcat server
Write-Host ""
Write-Host "Starting embedded Tomcat server..." -ForegroundColor Yellow
Write-Host "This may take a few moments to compile and start..." -ForegroundColor Gray
Write-Host ""

try {
    & mvn tomcat7:run "-Dskip.frontend=true" "-Dtomcat.port=$Port"
} catch {
    Write-Host "Error starting server: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Server stopped." -ForegroundColor Yellow