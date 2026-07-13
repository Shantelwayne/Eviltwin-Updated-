# Test script to verify path cleaning
param([string]$LaunchDir = (Split-Path -Parent $MyInvocation.MyCommand.Path))

Write-Host "Testing path construction..." -ForegroundColor Cyan
Write-Host ""

# Show original path
Write-Host "Original LaunchDir: [$LaunchDir]" -ForegroundColor Yellow

# Apply cleaning
$REPO_DIR = $LaunchDir.TrimEnd('\').TrimEnd('"').Trim()
Write-Host "Cleaned REPO_DIR: [$REPO_DIR]" -ForegroundColor Green

# Build server dir
$HMDM_SERVER_DIR = "$REPO_DIR\hmdm-server-master\hmdm-server-master"
Write-Host "HMDM_SERVER_DIR: [$HMDM_SERVER_DIR]" -ForegroundColor Green

# Clean server dir
$cleanServerDir = $HMDM_SERVER_DIR.Trim().TrimStart('"').TrimEnd('"')
Write-Host "Clean server dir: [$cleanServerDir]" -ForegroundColor Green

# Test if it exists
if (Test-Path -LiteralPath $cleanServerDir) {
    Write-Host "✓ Server directory exists!" -ForegroundColor Green
} else {
    Write-Host "✗ Server directory NOT found!" -ForegroundColor Red
}

# Test WAR path
$warPath = Join-Path $cleanServerDir "server\target\launcher.war"
Write-Host "WAR path: [$warPath]" -ForegroundColor Cyan

if (Test-Path -LiteralPath $warPath) {
    Write-Host "✓ WAR file exists!" -ForegroundColor Green
} else {
    Write-Host "✗ WAR file not found (this is normal if not built yet)" -ForegroundColor Yellow
}