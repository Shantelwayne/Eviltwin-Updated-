@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

:: ========================================
::   HMDM Docker Automated Installer
:: ========================================
:: Simplest way to install HMDM on any Windows machine

echo.
echo ========================================
echo    HMDM Docker Automated Installer
echo ========================================
echo.
echo This will install:
echo - Docker Desktop (if not present)
echo - HMDM via Docker container
echo.
echo Advantages:
echo - No complex setup (Java, PostgreSQL, Tomcat)
echo - Works consistently on any Windows 10+ machine
echo - Easy updates and backups
echo - Complete setup in under 15 minutes
echo.
pause

:: Check if running as Administrator
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: This script must be run as Administrator
    echo Right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo [INFO] Running with Administrator privileges ✓
echo.

:: ========================================
:: STEP 1: Check and Install Docker Desktop
:: ========================================
echo ========================================
echo STEP 1: Checking Docker Installation
echo ========================================

:: Check if Docker is already installed and running
docker --version >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [OK] Docker is already installed ✓
    docker --version
    goto :docker_ready
)

echo [INFO] Docker not found, checking Docker Desktop...

:: Check if Docker Desktop is installed but not running
if exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
    echo [INFO] Docker Desktop found but not running, starting...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    goto :wait_docker
)

:: Install Docker Desktop
echo [INFO] Installing Docker Desktop...

:: Try winget first
winget --version >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [INFO] Installing Docker Desktop via winget...
    winget install Docker.DockerDesktop --silent --accept-source-agreements --accept-package-agreements
    if %ERRORLEVEL% equ 0 goto :start_docker
)

:: Manual download and install
echo [INFO] Downloading Docker Desktop manually...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://desktop.docker.com/win/main/amd64/Docker%%20Desktop%%20Installer.exe' -OutFile 'DockerDesktopInstaller.exe'}"

echo [INFO] Installing Docker Desktop (this may take several minutes)...
echo Please wait for the installation to complete...
DockerDesktopInstaller.exe install --quiet
del DockerDesktopInstaller.exe

:start_docker
echo [INFO] Starting Docker Desktop...
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

:wait_docker
echo [INFO] Waiting for Docker to start (this can take 2-3 minutes)...
echo.

:: Wait for Docker to be ready
set /a counter=0
:docker_check_loop
timeout /t 10 /nobreak >nul
set /a counter+=1

docker --version >nul 2>&1
if %ERRORLEVEL% equ 0 goto :docker_ready

if %counter% geq 30 (
    echo [ERROR] Docker failed to start after 5 minutes
    echo Please restart Docker Desktop manually and run this script again
    pause
    exit /b 1
)

echo Waiting for Docker... (%counter%/30 attempts^)
goto :docker_check_loop

:docker_ready
echo [OK] Docker is ready ✓
docker --version
echo.

:: ========================================
:: STEP 2: Stop any existing HMDM containers
:: ========================================
echo ========================================
echo STEP 2: Preparing HMDM Container
echo ========================================

echo [INFO] Stopping any existing HMDM containers...
docker stop hmdm >nul 2>&1
docker rm hmdm >nul 2>&1

echo [INFO] Stopping conflicting services on port 8080...
:: Stop Tomcat if running
taskkill /f /im java.exe >nul 2>&1
net stop tomcat9 >nul 2>&1

echo [OK] Ready for HMDM deployment ✓
echo.

:: ========================================
:: STEP 3: Deploy HMDM via Docker
:: ========================================
echo ========================================
echo STEP 3: Deploying HMDM Server
echo ========================================

echo [INFO] Pulling HMDM Docker image (this may take a few minutes)...
docker pull headwindmdm/hmdm

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to pull HMDM Docker image
    echo Please check your internet connection
    pause
    exit /b 1
)

echo [INFO] Starting HMDM container...
docker run -d -p 8080:8080 --name hmdm --restart=unless-stopped headwindmdm/hmdm

if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to start HMDM container
    pause
    exit /b 1
)

echo [OK] HMDM container started ✓
echo.

:: ========================================
:: STEP 4: Wait for HMDM to Initialize
:: ========================================
echo ========================================
echo STEP 4: Waiting for HMDM to Initialize
echo ========================================

echo [INFO] HMDM is initializing database and web interface...
echo This takes about 2-3 minutes on first startup.
echo.

:: Wait with countdown
for /L %%i in (180,-1,1) do (
    echo Initializing HMDM... %%i seconds remaining
    timeout /t 1 /nobreak >nul
)

echo.

:: ========================================
:: STEP 5: Test HMDM Access
:: ========================================
echo ========================================
echo STEP 5: Testing HMDM Access
echo ========================================

echo [INFO] Testing HMDM web interface...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080' -TimeoutSec 10; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"

if %ERRORLEVEL% equ 0 (
    echo [OK] HMDM web interface is responding ✓
) else (
    echo [WARNING] HMDM may still be starting up...
)

echo.

:: ========================================
:: STEP 6: Installation Complete
:: ========================================
echo ========================================
echo      HMDM Installation Complete!
echo ========================================
echo.
echo Docker Container Status:
docker ps --filter "name=hmdm" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.
echo HMDM Access Information:
echo - Web Interface: http://localhost:8080
echo - Default Login: admin
echo - Default Password: admin
echo.
echo Container Management:
echo - Start HMDM:  docker start hmdm
echo - Stop HMDM:   docker stop hmdm
echo - View logs:   docker logs hmdm
echo - Update:      docker pull headwindmdm/hmdm ^&^& docker stop hmdm ^&^& docker rm hmdm ^&^& docker run -d -p 8080:8080 --name hmdm headwindmdm/hmdm
echo.

:: Save installation info
echo Docker HMDM installation completed on: %date% %time%> hmdm_docker_info.txt
echo Container name: hmdm>> hmdm_docker_info.txt
echo Web interface: http://localhost:8080>> hmdm_docker_info.txt
echo Default credentials: admin/admin>> hmdm_docker_info.txt
docker --version >> hmdm_docker_info.txt

echo Installation details saved to: hmdm_docker_info.txt
echo.
echo [INFO] Opening HMDM in browser...
start http://localhost:8080

echo.
echo If you see the HMDM login page, installation was successful!
echo If still loading, wait another minute and refresh the page.
echo.
pause