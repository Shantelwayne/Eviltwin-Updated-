# Quick PostgreSQL Detection Script
Write-Host "Checking for PostgreSQL installation..." -ForegroundColor Cyan
Write-Host ""

# Check if psql is on PATH
$psqlOnPath = Get-Command psql -ErrorAction SilentlyContinue
if ($psqlOnPath) {
    Write-Host "[FOUND] PostgreSQL on PATH: $($psqlOnPath.Source)" -ForegroundColor Green
    $pgBin = Split-Path $psqlOnPath.Source
    Write-Host "        Bin directory: $pgBin" -ForegroundColor Green
    exit 0
}

# Check common installation locations
$candidates = @(
    "C:\Program Files\PostgreSQL\16\bin",
    "C:\Program Files\PostgreSQL\15\bin", 
    "C:\Program Files\PostgreSQL\14\bin",
    "C:\Program Files\PostgreSQL\13\bin",
    "C:\Program Files\PostgreSQL\12\bin",
    "C:\Program Files (x86)\PostgreSQL\16\bin",
    "C:\Program Files (x86)\PostgreSQL\15\bin"
)

Write-Host "Checking common installation paths:" -ForegroundColor Yellow
foreach ($candidate in $candidates) {
    if (Test-Path "$candidate\psql.exe") {
        Write-Host "[FOUND] PostgreSQL at: $candidate" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "[----] Not found: $candidate" -ForegroundColor DarkGray
    }
}

# Check registry
Write-Host ""
Write-Host "Checking Windows registry for PostgreSQL..." -ForegroundColor Yellow
$regPaths = @(
    "HKLM:\SOFTWARE\PostgreSQL\Installations",
    "HKLM:\SOFTWARE\Wow6432Node\PostgreSQL\Installations"
)

foreach ($regPath in $regPaths) {
    if (Test-Path $regPath) {
        Write-Host "[CHECKING] Registry path: $regPath" -ForegroundColor Yellow
        try {
            Get-ChildItem $regPath -ErrorAction SilentlyContinue | ForEach-Object {
                $base = (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).Base
                if ($base -and (Test-Path "$base\bin\psql.exe")) {
                    Write-Host "[FOUND] PostgreSQL at: $base\bin" -ForegroundColor Green
                    exit 0
                }
            }
        } catch {
            Write-Host "[ERROR] Could not read registry: $_" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "PostgreSQL NOT FOUND on this system." -ForegroundColor Red
Write-Host ""
Write-Host "To install PostgreSQL:" -ForegroundColor Yellow
Write-Host "1. Download from: https://www.postgresql.org/download/windows/" -ForegroundColor Cyan
Write-Host "2. Or try: winget install PostgreSQL.PostgreSQL.16" -ForegroundColor Cyan
Write-Host ""
Write-Host "Make sure to remember the superuser password you set during installation!" -ForegroundColor Yellow