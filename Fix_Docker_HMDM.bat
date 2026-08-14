@echo off
echo ========================================
echo    Docker HMDM Container Fix
echo ========================================
echo.
echo This will fix the stuck HMDM container by:
echo 1. Removing the problematic container
echo 2. Starting with proper configuration
echo 3. Bypassing key initialization issues
echo.
pause

echo [INFO] Stopping and removing stuck container...
docker stop hmdm 2>nul
docker rm -f hmdm 2>nul

echo [INFO] Cleaning up any orphaned containers...
docker container prune -f

echo [INFO] Starting HMDM with fixed configuration...
echo Method 1: Try with specific version...
docker run -d -p 8080:8080 --name hmdm --restart=unless-stopped headwindmdm/hmdm:5.39

timeout /t 30 /nobreak >nul

echo [INFO] Checking container status...
docker ps --filter "name=hmdm"

echo [INFO] Checking logs...
docker logs hmdm --tail 20

echo.
echo If still stuck with "Keys not found", trying alternative method...
echo.

docker logs hmdm --tail 5 | findstr "Keys not found" >nul
if %ERRORLEVEL% equ 0 (
    echo [INFO] Trying method 2: Force key bypass...
    docker stop hmdm
    docker rm -f hmdm
    
    docker run -d -p 8080:8080 --name hmdm ^
        -e HMDM_ENCRYPT_PASSWORD="admin123" ^
        -e HMDM_DATABASE_PASSWORD="admin123" ^
        -e CATALINA_OPTS="-Xms512m -Xmx1024m" ^
        headwindmdm/hmdm:latest
    
    timeout /t 30 /nobreak >nul
    docker logs hmdm --tail 10
)

echo.
echo [INFO] Final check - attempting to connect...
timeout /t 60 /nobreak

curl -I http://localhost:8080 2>nul && (
    echo [SUCCESS] HMDM is responding!
    start http://localhost:8080
) || (
    echo [INFO] Still initializing, check again in 2 minutes
    echo Manual check: docker logs hmdm
)

echo.
echo Container management commands:
echo - View logs: docker logs hmdm -f
echo - Stop: docker stop hmdm  
echo - Restart: docker restart hmdm
echo - Remove: docker rm -f hmdm
echo.
pause