# Manual Maven Installation Script
param([string]$InstallDir = "C:\Apache\Maven")

Write-Host "Manual Maven Installation" -ForegroundColor Cyan
Write-Host "Installing to: $InstallDir" -ForegroundColor Yellow
Write-Host ""

# Maven download URL (latest 3.9.x)
$mavenVersion = "3.9.9"
$mavenUrl = "https://archive.apache.org/dist/maven/maven-3/$mavenVersion/binaries/apache-maven-$mavenVersion-bin.zip"
$downloadPath = "$env:TEMP\maven.zip"

try {
    # Download Maven
    Write-Host "Downloading Maven $mavenVersion..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $mavenUrl -OutFile $downloadPath -UseBasicParsing
    Write-Host "✓ Downloaded successfully" -ForegroundColor Green

    # Extract Maven
    Write-Host "Extracting Maven..." -ForegroundColor Yellow
    if (Test-Path $InstallDir) { Remove-Item $InstallDir -Recurse -Force }
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    
    Expand-Archive -Path $downloadPath -DestinationPath $InstallDir -Force
    
    # Move files from nested directory
    $extractedDir = Join-Path $InstallDir "apache-maven-$mavenVersion"
    if (Test-Path $extractedDir) {
        Get-ChildItem $extractedDir | Move-Item -Destination $InstallDir -Force
        Remove-Item $extractedDir -Force
    }
    
    Write-Host "✓ Extracted successfully" -ForegroundColor Green

    # Set environment variables
    Write-Host "Setting environment variables..." -ForegroundColor Yellow
    $mavenHome = $InstallDir
    $mavenBin = "$InstallDir\bin"
    
    # Set MAVEN_HOME
    [System.Environment]::SetEnvironmentVariable("MAVEN_HOME", $mavenHome, "Machine")
    
    # Add to PATH
    $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -notlike "*$mavenBin*") {
        $newPath = "$currentPath;$mavenBin"
        [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
    }
    
    Write-Host "✓ Environment variables set" -ForegroundColor Green

    # Test installation
    Write-Host "Testing Maven installation..." -ForegroundColor Yellow
    $env:PATH += ";$mavenBin"
    
    $testResult = & "$mavenBin\mvn.cmd" --version 2>&1
    if ($testResult -match "Apache Maven") {
        Write-Host "✓ Maven installed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Maven Version:" -ForegroundColor Cyan
        Write-Host $testResult -ForegroundColor White
        Write-Host ""
        Write-Host "You can now run SETUP.bat again!" -ForegroundColor Green
    } else {
        throw "Maven test failed"
    }

} catch {
    Write-Host "✗ Installation failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Manual steps:" -ForegroundColor Yellow
    Write-Host "1. Download: $mavenUrl" -ForegroundColor Gray
    Write-Host "2. Extract to: $InstallDir" -ForegroundColor Gray
    Write-Host "3. Add to PATH: $InstallDir\bin" -ForegroundColor Gray
} finally {
    # Cleanup
    if (Test-Path $downloadPath) { Remove-Item $downloadPath -Force }
}

Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")