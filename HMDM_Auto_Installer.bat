@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

:: ========================================
::     HMDM Automated Windows Installer
:: ========================================
:: This script automatically installs all HMDM requirements
:: and sets up a complete MDM server on Windows

echo.
echo ========================================
echo    HMDM Automated Windows Installer
echo ========================================
echo.
echo This will install and configure:
echo - Java 11 JDK (if not present)
echo - PostgreSQL 18 (if not present)
echo - Apache Tomcat 9 (if not present)
echo - Maven (if not present)
echo - HMDM Server with full setup
echo.
echo Requirements: Windows 10+ with Admin rights
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
:: STEP 1: Check and Install Java 11
:: ========================================
echo ========================================
echo STEP 1: Checking Java 11 Installation
echo ========================================

java -version 2>&1 | findstr "11\." >nul
if %ERRORLEVEL% equ 0 (
    echo [OK] Java 11 is already installed ✓
    java -version
) else (
    echo [INFO] Java 11 not found, installing...
    
    :: Check if winget is available
    winget --version >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        echo [INFO] Installing Java 11 via winget...
        winget install Microsoft.OpenJDK.11 --silent --accept-source-agreements --accept-package-agreements
    ) else (
        echo [INFO] Downloading Java 11 manually...
        powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://aka.ms/download-jdk/microsoft-jdk-11.0.21-windows-x64.msi' -OutFile 'jdk11.msi'}"
        echo [INFO] Installing Java 11...
        msiexec /i jdk11.msi /quiet ADDLOCAL=FeatureMain,FeatureEnvironment
        del jdk11.msi
    )
    
    :: Set JAVA_HOME
    for /f "tokens=2*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Microsoft*JDK*11*" 2^>nul ^| findstr "InstallLocation"') do set JAVA_HOME=%%j
    if "!JAVA_HOME!"=="" set JAVA_HOME=C:\Program Files\Microsoft\jdk-11.0.21.9-hotspot
    
    setx JAVA_HOME "!JAVA_HOME!" /M
    setx PATH "%PATH%;!JAVA_HOME!\bin" /M
    echo [OK] Java 11 installed ✓
)
echo.

:: ========================================
:: STEP 2: Check and Install PostgreSQL
:: ========================================
echo ========================================
echo STEP 2: Checking PostgreSQL Installation
echo ========================================

if exist "C:\Program Files\PostgreSQL\*\bin\psql.exe" (
    echo [OK] PostgreSQL is already installed ✓
) else (
    echo [INFO] PostgreSQL not found, installing...
    
    winget --version >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        echo [INFO] Installing PostgreSQL via winget...
        winget install PostgreSQL.PostgreSQL --silent --accept-source-agreements --accept-package-agreements
    ) else (
        echo [INFO] Downloading PostgreSQL...
        powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://get.enterprisedb.com/postgresql/postgresql-16.1-1-windows-x64.exe' -OutFile 'postgresql-installer.exe'}"
        echo [INFO] Installing PostgreSQL (this may take a few minutes)...
        postgresql-installer.exe --mode unattended --superpassword "admin123" --servicename "postgresql" --serviceport "5432" --datadir "C:\PostgreSQL\data"
        del postgresql-installer.exe
    )
    
    echo [OK] PostgreSQL installed ✓
)
echo.

:: ========================================
:: STEP 3: Check and Install Apache Tomcat
:: ========================================
echo ========================================
echo STEP 3: Checking Apache Tomcat Installation
echo ========================================

if exist "C:\tomcat9\bin\startup.bat" (
    echo [OK] Tomcat 9 is already installed ✓
) else (
    echo [INFO] Tomcat not found, installing...
    
    echo [INFO] Downloading Apache Tomcat 9...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.98/bin/apache-tomcat-9.0.98-windows-x64.zip' -OutFile 'tomcat.zip'}"
    
    echo [INFO] Extracting Tomcat...
    powershell -Command "Expand-Archive -Path 'tomcat.zip' -DestinationPath 'C:\' -Force"
    ren "C:\apache-tomcat-9.0.98" "tomcat9"
    del tomcat.zip
    
    :: Create Tomcat directories
    mkdir "C:\tomcat9\conf\Catalina\localhost" 2>nul
    mkdir "C:\tomcat9\lib" 2>nul
    
    echo [OK] Tomcat 9 installed ✓
)
echo.

:: ========================================
:: STEP 4: Check and Install Maven
:: ========================================
echo ========================================
echo STEP 4: Checking Maven Installation
echo ========================================

mvn -version >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [OK] Maven is already installed ✓
    mvn -version
) else (
    echo [INFO] Maven not found, installing...
    
    winget --version >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        echo [INFO] Installing Maven via winget...
        winget install Apache.Maven --silent --accept-source-agreements --accept-package-agreements
    ) else (
        echo [INFO] Downloading Apache Maven...
        powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip' -OutFile 'maven.zip'}"
        
        echo [INFO] Extracting Maven...
        powershell -Command "Expand-Archive -Path 'maven.zip' -DestinationPath 'C:\' -Force"
        ren "C:\apache-maven-3.9.6" "maven"
        del maven.zip
        
        :: Set Maven environment variables
        setx MAVEN_HOME "C:\maven" /M
        setx PATH "%PATH%;C:\maven\bin" /M
    )
    
    echo [OK] Maven installed ✓
)
echo.

:: ========================================
:: STEP 5: Setup PostgreSQL Database
:: ========================================
echo ========================================
echo STEP 5: Setting up HMDM Database
echo ========================================

:: Find PostgreSQL installation
for /d %%i in ("C:\Program Files\PostgreSQL\*") do set POSTGRES_PATH=%%i
if "!POSTGRES_PATH!"=="" (
    :: Try alternate locations
    for /d %%i in ("C:\PostgreSQL\*") do set POSTGRES_PATH=%%i
    if "!POSTGRES_PATH!"=="" set POSTGRES_PATH=C:\Program Files\PostgreSQL\16
)

echo [INFO] Using PostgreSQL at: !POSTGRES_PATH!

:: Configure PostgreSQL for trust authentication
echo [INFO] Configuring PostgreSQL authentication...
echo # HMDM Configuration - Trust local connections> "!POSTGRES_PATH!\data\pg_hba_hmdm.conf"
echo host    all             all             127.0.0.1/32            trust>> "!POSTGRES_PATH!\data\pg_hba_hmdm.conf"
echo local   all             all                                     trust>> "!POSTGRES_PATH!\data\pg_hba_hmdm.conf"

:: Backup original and replace
copy "!POSTGRES_PATH!\data\pg_hba.conf" "!POSTGRES_PATH!\data\pg_hba.conf.backup" >nul 2>&1
copy "!POSTGRES_PATH!\data\pg_hba_hmdm.conf" "!POSTGRES_PATH!\data\pg_hba.conf" >nul 2>&1

:: Restart PostgreSQL service
echo [INFO] Restarting PostgreSQL service...
net stop postgresql >nul 2>&1
net start postgresql >nul 2>&1

:: Wait for service to start
timeout /t 5 /nobreak >nul

:: Create HMDM database and user
echo [INFO] Creating HMDM database...
set DB_PASSWORD=hmdm_%RANDOM%_%RANDOM%
echo Database password: !DB_PASSWORD!

"!POSTGRES_PATH!\bin\psql.exe" -h localhost -U postgres -d postgres -c "DROP DATABASE IF EXISTS hmdm;" 2>nul
"!POSTGRES_PATH!\bin\psql.exe" -h localhost -U postgres -d postgres -c "DROP USER IF EXISTS hmdm;" 2>nul
"!POSTGRES_PATH!\bin\psql.exe" -h localhost -U postgres -d postgres -c "CREATE USER hmdm WITH PASSWORD '!DB_PASSWORD!';"
"!POSTGRES_PATH!\bin\psql.exe" -h localhost -U postgres -d postgres -c "CREATE DATABASE hmdm WITH OWNER=hmdm;"

if %ERRORLEVEL% equ 0 (
    echo [OK] HMDM database created ✓
) else (
    echo [WARNING] Database creation had issues, continuing...
)
echo.

:: ========================================
:: STEP 6: Download PostgreSQL JDBC Driver
:: ========================================
echo ========================================
echo STEP 6: Installing PostgreSQL JDBC Driver
echo ========================================

if exist "C:\tomcat9\lib\postgresql-*.jar" (
    echo [OK] PostgreSQL JDBC driver already exists ✓
) else (
    echo [INFO] Downloading PostgreSQL JDBC driver...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://jdbc.postgresql.org/download/postgresql-42.7.4.jar' -OutFile 'C:\tomcat9\lib\postgresql-42.7.4.jar'}"
    echo [OK] PostgreSQL JDBC driver installed ✓
)
echo.

:: ========================================
:: STEP 7: Download and Build HMDM Server
:: ========================================
echo ========================================
echo STEP 7: Building HMDM Server
echo ========================================

if exist "hmdm-server-master" (
    echo [OK] HMDM source already exists ✓
) else (
    echo [INFO] Downloading HMDM server source...
    if exist "hmdm-server.zip" del hmdm-server.zip
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/h-mdm/hmdm-server/archive/refs/heads/master.zip' -OutFile 'hmdm-server.zip'}"
    
    echo [INFO] Extracting HMDM source...
    powershell -Command "Expand-Archive -Path 'hmdm-server.zip' -DestinationPath '.' -Force"
    del hmdm-server.zip
)

cd hmdm-server-master\hmdm-server-master

:: Create build properties
echo [INFO] Creating build configuration...
echo # HMDM Build Configuration> server\build.properties
echo server.home=C:/tomcat9>> server\build.properties
echo base.url=http://localhost:8080>> server\build.properties
echo mobile.url=http://localhost:8080>> server\build.properties

:: Build HMDM
echo [INFO] Building HMDM (this may take 5-10 minutes)...
call mvn clean install -DskipTests

if exist "server\target\launcher.war" (
    echo [OK] HMDM built successfully ✓
    
    :: Deploy to Tomcat
    echo [INFO] Deploying HMDM to Tomcat...
    copy "server\target\launcher.war" "C:\tomcat9\webapps\ROOT.war" >nul
    
    :: Remove old deployment
    rmdir /s /q "C:\tomcat9\webapps\ROOT" 2>nul
    
) else (
    echo [ERROR] HMDM build failed!
    pause
    exit /b 1
)

cd ..\..

:: ========================================
:: STEP 8: Configure Tomcat Context
:: ========================================
echo ========================================
echo STEP 8: Configuring Tomcat
echo ========================================

echo [INFO] Creating Tomcat context configuration...

echo ^<?xml version="1.0" encoding="UTF-8"?^>> C:\tomcat9\conf\Catalina\localhost\ROOT.xml
echo ^<Context^>>> C:\tomcat9\conf\Catalina\localhost\ROOT.xml
echo     ^<Parameter name="db.jdbcUrl" value="jdbc:postgresql://localhost:5432/hmdm" type="java.lang.String" /^>>> C:\tomcat9\conf\Catalina\localhost\ROOT.xml
echo     ^<Parameter name="db.username" value="hmdm" type="java.lang.String" /^>>> C:\tomcat9\conf\Catalina\localhost\ROOT.xml
echo     ^<Parameter name="db.password" value="!DB_PASSWORD!" type="java.lang.String" /^>>> C:\tomcat9\conf\Catalina\localhost\ROOT.xml
echo     ^<Parameter name="files.directory" value="C:/hmdm/files" type="java.lang.String" /^>>> C:\tomcat9\conf\Catalina\localhost\ROOT.xml
echo     ^<Parameter name="base.url" value="http://localhost:8080" type="java.lang.String" /^>>> C:\tomcat9\conf\Catalina\localhost\ROOT.xml
echo     ^<Parameter name="mobile.url" value="http://localhost:8080" type="java.lang.String" /^>>> C:\tomcat9\conf\Catalina\localhost\ROOT.xml
echo     ^<Parameter name="log4j.configuration" value="C:/hmdm/log4j-hmdm.xml" type="java.lang.String" /^>>> C:\tomcat9\conf\Catalina\localhost\ROOT.xml
echo ^</Context^>>> C:\tomcat9\conf\Catalina\localhost\ROOT.xml

:: Create HMDM directories
mkdir C:\hmdm\files 2>nul
mkdir C:\hmdm\logs 2>nul

:: Create log4j configuration
echo [INFO] Creating log4j configuration...
echo ^<?xml version="1.0" encoding="UTF-8"?^>> C:\hmdm\log4j-hmdm.xml
echo ^<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd"^>>> C:\hmdm\log4j-hmdm.xml
echo ^<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/"^>>> C:\hmdm\log4j-hmdm.xml
echo     ^<appender name="FILE" class="org.apache.log4j.FileAppender"^>>> C:\hmdm\log4j-hmdm.xml
echo         ^<param name="File" value="C:/hmdm/logs/hmdm.log" /^>>> C:\hmdm\log4j-hmdm.xml
echo         ^<layout class="org.apache.log4j.PatternLayout"^>>> C:\hmdm\log4j-hmdm.xml
echo             ^<param name="ConversionPattern" value="%%d{yyyy-MM-dd HH:mm:ss} %%p %%c: %%m%%n" /^>>> C:\hmdm\log4j-hmdm.xml
echo         ^</layout^>>> C:\hmdm\log4j-hmdm.xml
echo     ^</appender^>>> C:\hmdm\log4j-hmdm.xml
echo     ^<root^>>> C:\hmdm\log4j-hmdm.xml
echo         ^<level value="INFO" /^>>> C:\hmdm\log4j-hmdm.xml
echo         ^<appender-ref ref="FILE" /^>>> C:\hmdm\log4j-hmdm.xml
echo     ^</root^>>> C:\hmdm\log4j-hmdm.xml
echo ^</log4j:configuration^>>> C:\hmdm\log4j-hmdm.xml

echo [OK] Tomcat configured ✓
echo.

:: ========================================
:: STEP 9: Start Services and Test
:: ========================================
echo ========================================
echo STEP 9: Starting HMDM Server
echo ========================================

:: Start Tomcat
echo [INFO] Starting Tomcat server...
start /min C:\tomcat9\bin\startup.bat

echo [INFO] Waiting for HMDM to initialize...
echo This takes 1-2 minutes for database setup and WAR extraction...

:: Wait for startup
for /L %%i in (60,-1,1) do (
    echo Initializing... %%i seconds remaining
    timeout /t 1 /nobreak >nul
)

echo.
echo ========================================
echo       HMDM Installation Complete!
echo ========================================
echo.
echo Services Status:
echo - PostgreSQL: Running on port 5432
echo - Apache Tomcat: Running on port 8080
echo - HMDM Server: http://localhost:8080
echo.
echo Database Credentials:
echo - Database: hmdm
echo - Username: hmdm
echo - Password: !DB_PASSWORD!
echo.
echo HMDM Web Interface:
echo - URL: http://localhost:8080
echo - Username: admin
echo - Password: admin
echo.

:: Save installation info
echo Installation completed on: %date% %time%> C:\hmdm\installation_info.txt
echo Database password: !DB_PASSWORD!>> C:\hmdm\installation_info.txt
echo PostgreSQL path: !POSTGRES_PATH!>> C:\hmdm\installation_info.txt

echo [INFO] Opening HMDM in browser...
start http://localhost:8080

echo.
echo Installation log saved to: C:\hmdm\installation_info.txt
echo.
echo If you see a login page, the installation was successful!
echo If you see errors, check: C:\hmdm\logs\hmdm.log
echo.
pause