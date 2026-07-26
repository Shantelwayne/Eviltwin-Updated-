@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

:: ========================================
::    HMDM Deployment Package Creator
:: ========================================
:: Creates a complete deployment package for other machines

echo.
echo ========================================
echo    HMDM Deployment Package Creator
echo ========================================
echo.
echo This will create a complete HMDM deployment package containing:
echo - Automated installer scripts
echo - Pre-built WAR file (if available)
echo - Configuration templates
echo - Setup documentation
echo.
pause

:: Create package directory
set PACKAGE_DIR=HMDM_Deployment_Package
if exist "%PACKAGE_DIR%" rmdir /s /q "%PACKAGE_DIR%"
mkdir "%PACKAGE_DIR%"

echo [INFO] Creating deployment package structure...

:: Create directory structure
mkdir "%PACKAGE_DIR%\installers"
mkdir "%PACKAGE_DIR%\config"
mkdir "%PACKAGE_DIR%\war"
mkdir "%PACKAGE_DIR%\docs"
mkdir "%PACKAGE_DIR%\scripts"

:: Copy installer scripts
echo [INFO] Copying installer scripts and guides...
copy "HMDM_Auto_Installer.bat" "%PACKAGE_DIR%\installers\" >nul 2>&1
copy "HMDM_Docker_Installer.bat" "%PACKAGE_DIR%\installers\" >nul 2>&1
copy "USER_DEPLOYMENT_GUIDE.md" "%PACKAGE_DIR%\" >nul 2>&1
copy "QUICK_START.bat" "%PACKAGE_DIR%\" >nul 2>&1

:: Copy WAR file if it exists
echo [INFO] Checking for built WAR file...
if exist "hmdm-server-master\hmdm-server-master\server\target\launcher.war" (
    echo [OK] Found built WAR file, copying...
    copy "hmdm-server-master\hmdm-server-master\server\target\launcher.war" "%PACKAGE_DIR%\war\hmdm.war" >nul
) else (
    echo [INFO] No WAR file found, will download during installation
)

:: Create configuration templates
echo [INFO] Creating configuration templates...

:: Tomcat context template
echo ^<?xml version="1.0" encoding="UTF-8"?^>> "%PACKAGE_DIR%\config\tomcat-context.xml"
echo ^<Context^>>> "%PACKAGE_DIR%\config\tomcat-context.xml"
echo     ^<Parameter name="db.jdbcUrl" value="jdbc:postgresql://localhost:5432/hmdm" type="java.lang.String" /^>>> "%PACKAGE_DIR%\config\tomcat-context.xml"
echo     ^<Parameter name="db.username" value="hmdm" type="java.lang.String" /^>>> "%PACKAGE_DIR%\config\tomcat-context.xml"
echo     ^<Parameter name="db.password" value="CHANGE_THIS_PASSWORD" type="java.lang.String" /^>>> "%PACKAGE_DIR%\config\tomcat-context.xml"
echo     ^<Parameter name="files.directory" value="C:/hmdm/files" type="java.lang.String" /^>>> "%PACKAGE_DIR%\config\tomcat-context.xml"
echo     ^<Parameter name="base.url" value="http://localhost:8080" type="java.lang.String" /^>>> "%PACKAGE_DIR%\config\tomcat-context.xml"
echo     ^<Parameter name="mobile.url" value="http://localhost:8080" type="java.lang.String" /^>>> "%PACKAGE_DIR%\config\tomcat-context.xml"
echo     ^<Parameter name="log4j.configuration" value="C:/hmdm/log4j-hmdm.xml" type="java.lang.String" /^>>> "%PACKAGE_DIR%\config\tomcat-context.xml"
echo ^</Context^>>> "%PACKAGE_DIR%\config\tomcat-context.xml"

:: Database setup script
echo -- HMDM Database Setup Script> "%PACKAGE_DIR%\config\setup-database.sql"
echo -- Run this script as PostgreSQL superuser>> "%PACKAGE_DIR%\config\setup-database.sql"
echo.>> "%PACKAGE_DIR%\config\setup-database.sql"
echo DROP DATABASE IF EXISTS hmdm;>> "%PACKAGE_DIR%\config\setup-database.sql"
echo DROP USER IF EXISTS hmdm;>> "%PACKAGE_DIR%\config\setup-database.sql"
echo.>> "%PACKAGE_DIR%\config\setup-database.sql"
echo CREATE USER hmdm WITH PASSWORD 'CHANGE_THIS_PASSWORD';>> "%PACKAGE_DIR%\config\setup-database.sql"
echo CREATE DATABASE hmdm WITH OWNER=hmdm ENCODING='UTF8';>> "%PACKAGE_DIR%\config\setup-database.sql"
echo GRANT ALL PRIVILEGES ON DATABASE hmdm TO hmdm;>> "%PACKAGE_DIR%\config\setup-database.sql"

:: Log4j configuration
echo ^<?xml version="1.0" encoding="UTF-8"?^>> "%PACKAGE_DIR%\config\log4j-hmdm.xml"
echo ^<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd"^>>> "%PACKAGE_DIR%\config\log4j-hmdm.xml"
echo ^<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/"^>>> "%PACKAGE_DIR%\config\log4j-hmdm.xml"
echo     ^<appender name="FILE" class="org.apache.log4j.FileAppender"^>>> "%PACKAGE_DIR%\config\log4j-hmdm.xml"
echo         ^<param name="File" value="C:/hmdm/logs/hmdm.log" /^>>> "%PACKAGE_DIR%\config\log4j-hmdm.xml"
echo         ^<layout class="org.apache.log4j.PatternLayout"^>>> "%PACKAGE_DIR%\config\log4j-hmdm.xml"
echo             ^<param name="ConversionPattern" value="%%d{yyyy-MM-dd HH:mm:ss} %%p %%c: %%m%%n" /^>>> "%PACKAGE_DIR%\config\log4j-hmdm.xml"
echo         ^</layout^>>> "%PACKAGE_DIR%\config\log4j-hmdm.xml"
echo     ^</appender^>>> "%PACKAGE_DIR%\config\log4j-hmdm.xml"
echo     ^<root^>>> "%PACKAGE_DIR%\config\log4j-hmdm.xml"
echo         ^<level value="INFO" /^>>> "%PACKAGE_DIR%\config\log4j-hmdm.xml"
echo         ^<appender-ref ref="FILE" /^>>> "%PACKAGE_DIR%\config\log4j-hmdm.xml"
echo     ^</root^>>> "%PACKAGE_DIR%\config\log4j-hmdm.xml"
echo ^</log4j:configuration^>>> "%PACKAGE_DIR%\config\log4j-hmdm.xml"

:: Create utility scripts
echo [INFO] Creating utility scripts...

:: Start HMDM script
echo @echo off> "%PACKAGE_DIR%\scripts\start-hmdm.bat"
echo echo Starting HMDM services...>> "%PACKAGE_DIR%\scripts\start-hmdm.bat"
echo net start postgresql>> "%PACKAGE_DIR%\scripts\start-hmdm.bat"
echo C:\tomcat9\bin\startup.bat>> "%PACKAGE_DIR%\scripts\start-hmdm.bat"
echo echo HMDM started. Access: http://localhost:8080>> "%PACKAGE_DIR%\scripts\start-hmdm.bat"
echo pause>> "%PACKAGE_DIR%\scripts\start-hmdm.bat"

:: Stop HMDM script
echo @echo off> "%PACKAGE_DIR%\scripts\stop-hmdm.bat"
echo echo Stopping HMDM services...>> "%PACKAGE_DIR%\scripts\stop-hmdm.bat"
echo C:\tomcat9\bin\shutdown.bat>> "%PACKAGE_DIR%\scripts\stop-hmdm.bat"
echo net stop postgresql>> "%PACKAGE_DIR%\scripts\stop-hmdm.bat"
echo echo HMDM stopped.>> "%PACKAGE_DIR%\scripts\stop-hmdm.bat"
echo pause>> "%PACKAGE_DIR%\scripts\stop-hmdm.bat"

:: Docker start script
echo @echo off> "%PACKAGE_DIR%\scripts\start-hmdm-docker.bat"
echo echo Starting HMDM Docker container...>> "%PACKAGE_DIR%\scripts\start-hmdm-docker.bat"
echo docker start hmdm>> "%PACKAGE_DIR%\scripts\start-hmdm-docker.bat"
echo echo HMDM Docker started. Access: http://localhost:8080>> "%PACKAGE_DIR%\scripts\start-hmdm-docker.bat"
echo pause>> "%PACKAGE_DIR%\scripts\start-hmdm-docker.bat"

:: Create documentation
echo [INFO] Creating documentation...

:: README file
echo # HMDM Deployment Package> "%PACKAGE_DIR%\README.md"
echo.>> "%PACKAGE_DIR%\README.md"
echo This package contains everything needed to deploy HMDM ^(Headwind Mobile Device Management^) on Windows machines.>> "%PACKAGE_DIR%\README.md"
echo.>> "%PACKAGE_DIR%\README.md"
echo ## Installation Options>> "%PACKAGE_DIR%\README.md"
echo.>> "%PACKAGE_DIR%\README.md"
echo ### Option 1: Docker Installation ^(Recommended^)>> "%PACKAGE_DIR%\README.md"
echo - **File:** `installers\HMDM_Docker_Installer.bat`>> "%PACKAGE_DIR%\README.md"
echo - **Requirements:** Windows 10+ with Administrator rights>> "%PACKAGE_DIR%\README.md"
echo - **Time:** 15 minutes>> "%PACKAGE_DIR%\README.md"
echo - **Advantages:** No complex setup, works consistently>> "%PACKAGE_DIR%\README.md"
echo.>> "%PACKAGE_DIR%\README.md"
echo ### Option 2: Full Installation>> "%PACKAGE_DIR%\README.md"
echo - **File:** `installers\HMDM_Auto_Installer.bat`>> "%PACKAGE_DIR%\README.md"
echo - **Requirements:** Windows 10+ with Administrator rights>> "%PACKAGE_DIR%\README.md"
echo - **Time:** 30-45 minutes>> "%PACKAGE_DIR%\README.md"
echo - **Advantages:** Full control, customizable>> "%PACKAGE_DIR%\README.md"
echo.>> "%PACKAGE_DIR%\README.md"
echo ## Usage>> "%PACKAGE_DIR%\README.md"
echo.>> "%PACKAGE_DIR%\README.md"
echo 1. Extract this package to a folder>> "%PACKAGE_DIR%\README.md"
echo 2. Right-click your chosen installer and "Run as administrator">> "%PACKAGE_DIR%\README.md"
echo 3. Follow the prompts>> "%PACKAGE_DIR%\README.md"
echo 4. Access HMDM at http://localhost:8080 ^(admin/admin^)>> "%PACKAGE_DIR%\README.md"
echo.>> "%PACKAGE_DIR%\README.md"
echo ## Management Scripts>> "%PACKAGE_DIR%\README.md"
echo.>> "%PACKAGE_DIR%\README.md"
echo - `scripts\start-hmdm.bat` - Start HMDM services>> "%PACKAGE_DIR%\README.md"
echo - `scripts\stop-hmdm.bat` - Stop HMDM services>> "%PACKAGE_DIR%\README.md"
echo - `scripts\start-hmdm-docker.bat` - Start Docker version>> "%PACKAGE_DIR%\README.md"
echo.>> "%PACKAGE_DIR%\README.md"
echo ## Configuration Files>> "%PACKAGE_DIR%\README.md"
echo.>> "%PACKAGE_DIR%\README.md"
echo - `config\tomcat-context.xml` - Tomcat configuration template>> "%PACKAGE_DIR%\README.md"
echo - `config\setup-database.sql` - PostgreSQL database setup>> "%PACKAGE_DIR%\README.md"
echo - `config\log4j-hmdm.xml` - Logging configuration>> "%PACKAGE_DIR%\README.md"

:: Installation instructions
echo # HMDM Installation Instructions> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo.>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo ## System Requirements>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo.>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo - Windows 10 or later>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo - 4GB RAM minimum ^(8GB recommended^)>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo - 10GB free disk space>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo - Administrator privileges>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo - Internet connection ^(for downloads^)>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo.>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo ## Quick Start ^(Docker^)>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo.>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo 1. Right-click `installers\HMDM_Docker_Installer.bat`>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo 2. Select "Run as administrator">> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo 3. Wait for installation to complete>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo 4. Open http://localhost:8080>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo 5. Login with admin/admin>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo.>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo ## Troubleshooting>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo.>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo - **Port 8080 in use:** Stop other web servers or change HMDM port>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo - **Docker issues:** Restart Docker Desktop and try again>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo - **Database errors:** Check PostgreSQL service is running>> "%PACKAGE_DIR%\docs\INSTALLATION.md"
echo - **White page:** Wait 2-3 minutes for full initialization>> "%PACKAGE_DIR%\docs\INSTALLATION.md"

:: Create main installer launcher
echo @echo off> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo setlocal EnableDelayedExpansion>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo cd /d "%%~dp0">> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo.>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo ========================================>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo        HMDM Installation Launcher>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo ========================================>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo.>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo Choose your installation method:>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo.>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo 1. Docker Installation ^(Recommended^)>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo    - Fastest and most reliable>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo    - No complex configuration>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo    - Ready in 15 minutes>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo.>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo 2. Full Installation>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo    - Complete control over components>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo    - Customizable configuration>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo    - Takes 30-45 minutes>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo.>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo 3. View Documentation>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo.>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo 4. Exit>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo echo.>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo set /p choice="Enter your choice (1-4): ">> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo.>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo if "%%choice%%"=="1" (>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo     echo Starting Docker installation...>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo     call installers\HMDM_Docker_Installer.bat>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo ^) else if "%%choice%%"=="2" (>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo     echo Starting full installation...>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo     call installers\HMDM_Auto_Installer.bat>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo ^) else if "%%choice%%"=="3" (>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo     start README.md>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo     goto :menu>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo ^) else if "%%choice%%"=="4" (>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo     exit /b 0>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo ^) else (>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo     echo Invalid choice. Please enter 1-4.>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo     pause>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo     goto :menu>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"
echo ^)>> "%PACKAGE_DIR%\INSTALL_HMDM.bat"

:: Package everything into a ZIP file
echo [INFO] Creating ZIP package...
powershell -Command "Compress-Archive -Path '%PACKAGE_DIR%\*' -DestinationPath 'HMDM_Deployment_Package.zip' -Force"

if exist "HMDM_Deployment_Package.zip" (
    echo [OK] Package created successfully ✓
    
    :: Get package size
    for %%A in ("HMDM_Deployment_Package.zip") do set size=%%~zA
    set /a sizeKB=!size!/1024
    
    echo.
    echo ========================================
    echo     Package Creation Complete!
    echo ========================================
    echo.
    echo Package file: HMDM_Deployment_Package.zip
    echo Package size: !sizeKB! KB
    echo.
    echo Package contents:
    echo - 2 automated installer scripts
    echo - Configuration templates
    echo - Management scripts  
    echo - Complete documentation
    if exist "%PACKAGE_DIR%\war\hmdm.war" echo - Pre-built WAR file ✓
    echo.
    echo To deploy on another machine:
    echo 1. Copy HMDM_Deployment_Package.zip to target machine
    echo 2. Extract the ZIP file
    echo 3. Run INSTALL_HMDM.bat as Administrator
    echo.
    echo The package is ready for distribution!
    
) else (
    echo [ERROR] Failed to create ZIP package
)

echo.
pause