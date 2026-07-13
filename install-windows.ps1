#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Headwind MDM — Windows prerequisites installer + server setup
.DESCRIPTION
    Installs Java 11, Maven, PostgreSQL, Tomcat 9, creates the HMDM
    database, builds the server WAR, deploys it, and starts Tomcat.
    Run this script ONCE from an elevated (Administrator) PowerShell.
.USAGE
    Right-click PowerShell -> "Run as Administrator", then:
    cd "C:\Users\migwi\Desktop\Spywares"
    Set-ExecutionPolicy Bypass -Scope Process -Force
    .\install-windows.ps1
#>

$ErrorActionPreference = "Stop"

# ─── Configuration ────────────────────────────────────────────────────────────
$HMDM_SERVER_DIR  = "C:\Users\migwi\Desktop\Spywares\hmdm-server-master\hmdm-server-master"
$TOMCAT_VERSION   = "9.0.98"
$TOMCAT_DIR       = "C:\tomcat9"
$HMDM_DATA_DIR    = "C:\hmdm"
$PG_HOST          = "localhost"
$PG_PORT          = "5432"
$PG_DB            = "hmdm"
$PG_USER          = "hmdm"
$PG_PASS          = "hmdm_secure_2024"
$SERVER_PROTOCOL  = "http"
$SERVER_HOST      = "localhost"
$SERVER_PORT      = "8080"
$SERVER_PATH      = ""          # leave empty for ROOT deployment
# ──────────────────────────────────────────────────────────────────────────────

function Write-Step($msg) {
    Write-Host "`n===> $msg" -ForegroundColor Cyan
}

function Write-OK($msg) {
    Write-Host "  [OK] $msg" -ForegroundColor Green
}

function Write-Warn($msg) {
    Write-Host "  [!!] $msg" -ForegroundColor Yellow
}

# ─── 1. Install Java 11 JDK ───────────────────────────────────────────────────
Write-Step "Installing Java 11 JDK (Microsoft OpenJDK)"
$javaCheck = Get-Command java -ErrorAction SilentlyContinue
if ($javaCheck) {
    Write-OK "Java already installed: $(java -version 2>&1 | Select-Object -First 1)"
} else {
    winget install --id Microsoft.OpenJDK.11 --accept-source-agreements --accept-package-agreements -e
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-OK "Java 11 installed"
}

# ─── 2. Install Maven ─────────────────────────────────────────────────────────
Write-Step "Installing Apache Maven"
$mvnCheck = Get-Command mvn -ErrorAction SilentlyContinue
if ($mvnCheck) {
    Write-OK "Maven already installed"
} else {
    winget install --id Apache.Maven --accept-source-agreements --accept-package-agreements -e
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-OK "Maven installed"
}

# ─── 3. Install PostgreSQL ────────────────────────────────────────────────────
Write-Step "Installing PostgreSQL 16"
$pgCheck = Get-Command psql -ErrorAction SilentlyContinue
if ($pgCheck) {
    Write-OK "PostgreSQL already installed"
} else {
    winget install --id PostgreSQL.PostgreSQL.16 --accept-source-agreements --accept-package-agreements -e
    # Add psql to PATH
    $pgBin = "C:\Program Files\PostgreSQL\16\bin"
    if (Test-Path $pgBin) {
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
        if ($currentPath -notlike "*$pgBin*") {
            [System.Environment]::SetEnvironmentVariable("Path", "$currentPath;$pgBin", "Machine")
        }
        $env:Path += ";$pgBin"
    }
    Write-OK "PostgreSQL installed"
}

# ─── 4. Download and install Tomcat 9 ────────────────────────────────────────
Write-Step "Setting up Apache Tomcat 9"
if (Test-Path "$TOMCAT_DIR\bin\catalina.bat") {
    Write-OK "Tomcat already present at $TOMCAT_DIR"
} else {
    $tomcatUrl = "https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION-windows-x64.zip"
    $tomcatZip = "$env:TEMP\tomcat9.zip"
    Write-Host "  Downloading Tomcat $TOMCAT_VERSION..."
    Invoke-WebRequest -Uri $tomcatUrl -OutFile $tomcatZip -UseBasicParsing
    Write-Host "  Extracting..."
    Expand-Archive -Path $tomcatZip -DestinationPath "C:\" -Force
    Rename-Item "C:\apache-tomcat-$TOMCAT_VERSION" $TOMCAT_DIR -ErrorAction SilentlyContinue
    Remove-Item $tomcatZip -Force
    Write-OK "Tomcat installed at $TOMCAT_DIR"
}

# ─── 5. Set JAVA_HOME for Tomcat ─────────────────────────────────────────────
Write-Step "Configuring JAVA_HOME"
$javaHome = [System.Environment]::GetEnvironmentVariable("JAVA_HOME","Machine")
if (-not $javaHome) {
    # Try to auto-detect
    $javaExe = (Get-Command java -ErrorAction SilentlyContinue).Source
    if ($javaExe) {
        $javaHome = (Split-Path (Split-Path $javaExe))
        [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $javaHome, "Machine")
        $env:JAVA_HOME = $javaHome
        Write-OK "JAVA_HOME set to $javaHome"
    } else {
        Write-Warn "Could not auto-detect JAVA_HOME. Please set it manually."
    }
} else {
    $env:JAVA_HOME = $javaHome
    Write-OK "JAVA_HOME already set: $javaHome"
}

# ─── 6. Create HMDM data directories ─────────────────────────────────────────
Write-Step "Creating HMDM data directories"
foreach ($dir in @($HMDM_DATA_DIR, "$HMDM_DATA_DIR\files", "$HMDM_DATA_DIR\plugins", "$HMDM_DATA_DIR\logs")) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
Write-OK "Directories created under $HMDM_DATA_DIR"

# ─── 7. Create PostgreSQL database and user ───────────────────────────────────
Write-Step "Setting up PostgreSQL database"
$env:PGPASSWORD = "postgres"   # default superuser password during fresh install
$pgBin = "C:\Program Files\PostgreSQL\16\bin"

# Check if DB already exists
$dbExists = & "$pgBin\psql.exe" -U postgres -h $PG_HOST -p $PG_PORT -tAc "SELECT 1 FROM pg_database WHERE datname='$PG_DB'" 2>$null
if ($dbExists -eq "1") {
    Write-OK "Database '$PG_DB' already exists"
} else {
    Write-Host "  Creating user and database..."
    & "$pgBin\psql.exe" -U postgres -h $PG_HOST -p $PG_PORT -c "CREATE USER $PG_USER WITH PASSWORD '$PG_PASS';" 2>&1 | Out-Null
    & "$pgBin\psql.exe" -U postgres -h $PG_HOST -p $PG_PORT -c "CREATE DATABASE $PG_DB WITH OWNER=$PG_USER;" 2>&1 | Out-Null
    Write-OK "Database '$PG_DB' and user '$PG_USER' created"
}

# ─── 8. Write Tomcat context.xml (database + HMDM config) ────────────────────
Write-Step "Writing Tomcat context configuration"
$contextDir = "$TOMCAT_DIR\conf\Catalina\localhost"
if (-not (Test-Path $contextDir)) {
    New-Item -ItemType Directory -Path $contextDir -Force | Out-Null
}

$baseUrl = "${SERVER_PROTOCOL}://${SERVER_HOST}:${SERVER_PORT}${SERVER_PATH}"

$contextXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<Context path="$SERVER_PATH" docBase="ROOT">

    <!-- PostgreSQL connection pool -->
    <Resource name="jdbc/hmdm"
              auth="Container"
              type="javax.sql.DataSource"
              driverClassName="org.postgresql.Driver"
              url="jdbc:postgresql://${PG_HOST}:${PG_PORT}/${PG_DB}"
              username="${PG_USER}"
              password="${PG_PASS}"
              maxTotal="20"
              maxIdle="10"
              maxWaitMillis="-1"/>

    <!-- HMDM application parameters -->
    <Parameter name="base.directory"     value="$($HMDM_DATA_DIR -replace '\\', '/')" override="false"/>
    <Parameter name="protocol"           value="$SERVER_PROTOCOL"     override="false"/>
    <Parameter name="base.host"          value="${SERVER_HOST}:${SERVER_PORT}" override="false"/>
    <Parameter name="base.domain"        value="$SERVER_HOST"          override="false"/>
    <Parameter name="base.path"          value="$SERVER_PATH"          override="false"/>
    <Parameter name="install.flag"       value="$($HMDM_DATA_DIR -replace '\\', '/')/hmdm_install_flag" override="false"/>
    <Parameter name="smtp.host"          value=""          override="false"/>
    <Parameter name="smtp.port"          value=""          override="false"/>
    <Parameter name="smtp.ssl"           value="0"         override="false"/>
    <Parameter name="smtp.starttls"      value="0"         override="false"/>
    <Parameter name="smtp.username"      value=""          override="false"/>
    <Parameter name="smtp.password"      value=""          override="false"/>
    <Parameter name="smtp.from"          value=""          override="false"/>
</Context>
"@

$contextXml | Set-Content "$contextDir\ROOT.xml" -Encoding UTF8
Write-OK "Context config written to $contextDir\ROOT.xml"

# ─── 9. Write log4j config ────────────────────────────────────────────────────
Write-Step "Writing log4j configuration"
$log4jXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">
<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/">
    <appender name="FILE" class="org.apache.log4j.RollingFileAppender">
        <param name="File"            value="$($HMDM_DATA_DIR -replace '\\', '/')/logs/hmdm.log"/>
        <param name="MaxFileSize"     value="10MB"/>
        <param name="MaxBackupIndex"  value="5"/>
        <layout class="org.apache.log4j.PatternLayout">
            <param name="ConversionPattern" value="%d{yyyy-MM-dd HH:mm:ss} %-5p %c{1}:%L - %m%n"/>
        </layout>
    </appender>
    <root>
        <priority value="INFO"/>
        <appender-ref ref="FILE"/>
    </root>
</log4j:configuration>
"@
$log4jXml | Set-Content "$HMDM_DATA_DIR\log4j-hmdm.xml" -Encoding UTF8
Write-OK "log4j config written"

# ─── 10. Build the WAR ───────────────────────────────────────────────────────
Write-Step "Building Headwind MDM server WAR (this takes 2-5 minutes)"
$warSource = "$HMDM_SERVER_DIR\server\target\launcher.war"
if (Test-Path $warSource) {
    Write-OK "WAR already built, skipping Maven build"
} else {
    Push-Location $HMDM_SERVER_DIR
    try {
        & mvn install -DskipTests 2>&1 | Tee-Object -FilePath "$HMDM_DATA_DIR\logs\maven-build.log"
        if ($LASTEXITCODE -ne 0) {
            throw "Maven build failed. Check $HMDM_DATA_DIR\logs\maven-build.log"
        }
        Write-OK "WAR built successfully"
    } finally {
        Pop-Location
    }
}

# ─── 11. Deploy WAR to Tomcat ─────────────────────────────────────────────────
Write-Step "Deploying WAR to Tomcat"
$warDest = "$TOMCAT_DIR\webapps\ROOT.war"
Copy-Item $warSource $warDest -Force
Write-OK "WAR deployed to $warDest"

# ─── 12. Run SQL init script ──────────────────────────────────────────────────
Write-Step "Initialising database schema"
$sqlInit = "$HMDM_SERVER_DIR\install\sql\hmdm_init.en.sql"
if (Test-Path $sqlInit) {
    $sqlContent = Get-Content $sqlInit -Raw
    $sqlContent = $sqlContent `
        -replace '_HMDM_BASE_',    ($HMDM_DATA_DIR -replace '\\', '/') `
        -replace '_HMDM_VERSION_', '5.19' `
        -replace '_HMDM_APK_',     'hmdm-5.19-os.apk' `
        -replace '_ADMIN_EMAIL_',  'admin@localhost'
    $tempSql = "$env:TEMP\hmdm_init_win.sql"
    $sqlContent | Set-Content $tempSql -Encoding UTF8

    $env:PGPASSWORD = $PG_PASS
    & "$pgBin\psql.exe" -U $PG_USER -h $PG_HOST -p $PG_PORT -d $PG_DB -f $tempSql 2>&1
    Remove-Item $tempSql -Force
    Write-OK "Database schema initialised"
} else {
    Write-Warn "SQL init file not found at $sqlInit — skipping (Liquibase will handle it on first start)"
}

# ─── 13. Install Tomcat as a Windows service ─────────────────────────────────
Write-Step "Installing Tomcat as a Windows service"
$serviceExists = Get-Service -Name "Tomcat9" -ErrorAction SilentlyContinue
if ($serviceExists) {
    Write-OK "Tomcat9 service already installed"
} else {
    $serviceBat = "$TOMCAT_DIR\bin\service.bat"
    if (Test-Path $serviceBat) {
        Set-Location "$TOMCAT_DIR\bin"
        & ".\service.bat" install Tomcat9
        Write-OK "Tomcat9 service installed"
    } else {
        Write-Warn "service.bat not found — you will need to start Tomcat manually"
    }
}

# ─── 14. Start Tomcat ─────────────────────────────────────────────────────────
Write-Step "Starting Tomcat"
try {
    Start-Service -Name "Tomcat9" -ErrorAction Stop
    Write-OK "Tomcat9 service started"
} catch {
    Write-Warn "Could not start service — trying startup.bat instead"
    Start-Process "$TOMCAT_DIR\bin\startup.bat" -WorkingDirectory "$TOMCAT_DIR\bin"
}

# ─── Done ─────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "======================================================" -ForegroundColor Green
Write-Host "  Headwind MDM server setup complete!" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  URL:      http://localhost:8080"
Write-Host "  Login:    admin"
Write-Host "  Password: admin"
Write-Host ""
Write-Host "  Logs:     $HMDM_DATA_DIR\logs\hmdm.log"
Write-Host "  Tomcat:   $TOMCAT_DIR\logs\catalina.out"
Write-Host ""
Write-Host "  Wait ~30 seconds for Tomcat to fully start, then open:"
Write-Host "  http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
