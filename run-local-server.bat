@echo off
echo Starting HMDM Server locally from project folder...
echo.
echo This will run the server on: http://localhost:9090
echo Press Ctrl+C to stop the server
echo.

cd /d "%~dp0hmdm-server-master\hmdm-server-master\server"

echo Checking Maven...
where mvn >nul 2>nul
if errorlevel 1 (
    echo Maven not found on PATH. Adding Maven to PATH...
    set "PATH=%PATH%;C:\Apache\Maven\bin"
)

echo.
echo Starting embedded Tomcat server...
echo This may take a few moments to start...
echo.

mvn tomcat7:run -Dskip.frontend=true

pause