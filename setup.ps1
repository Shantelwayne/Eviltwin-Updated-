param(
    [string]$LaunchDir = (Split-Path -Parent $MyInvocation.MyCommand.Path)
)

# ============================================================
# Windows Setup Script - Called by SETUP.bat
# ============================================================

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "Software Setup"

# --- Paths (auto-detected from repo location) ---
$REPO_DIR        = $LaunchDir.TrimEnd('\')
$HMDM_SERVER_DIR = "$REPO_DIR\hmdm-server-master\hmdm-server-master"
$TOMCAT_VERSION  = "9.0.98"
$TOMCAT_DIR      = "C:\tomcat9"
$HMDM_DATA_DIR   = "C:\hmdm"
$LOG_FILE        = "$HMDM_DATA_DIR\logs\setup.log"
$PG_BIN          = "C:\Program Files\PostgreSQL\16\bin"
$PG_HOST         = "localhost"
$PG_PORT         = "5432"
$PG_DB           = "hmdm"
$PG_USER         = "hmdm"
$SERVER_PORT     = "8080"

# --- Helper functions ---
function Print-Header($text) {
    Write-Host ""
    Write-Host "  ============================================================" -ForegroundColor DarkCyan
    Write-Host "   $text" -ForegroundColor White
    Write-Host "  ============================================================" -ForegroundColor DarkCyan
}

function Print-Step($num, $total, $text) {
    Write-Host ""
    Write-Host "  [Step $num/$total] $text" -ForegroundColor Cyan
    Write-Host "  ------------------------------------------------------------" -ForegroundColor DarkGray
}

function Print-OK($text)    { Write-Host "  [OK] $text" -ForegroundColor Green }
function Print-Skip($text)  { Write-Host "  [--] $text (already installed, skipping)" -ForegroundColor DarkGray }
function Print-Warn($text)  { Write-Host "  [!!] $text" -ForegroundColor Yellow }
function Print-Error($text) { Write-Host "  [XX] $text" -ForegroundColor Red }
function Print-Info($text)  { Write-Host "       $text" -ForegroundColor Gray }

function Write-Log($text) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LOG_FILE -Value "[$timestamp] $text" -ErrorAction SilentlyContinue
}

function Prompt-Continue($question) {
    Write-Host ""
    Write-Host "  $question [Y/n] " -ForegroundColor Yellow -NoNewline
    $response = Read-Host
    return ($response -eq "" -or $response -match "^[Yy]")
}

function Show-Progress($activity, $status, $pct) {
    Write-Progress -Activity $activity -Status $status -PercentComplete $pct
}

# --- Ensure log dir exists ---
New-Item -ItemType Directory -Path "$HMDM_DATA_DIR\logs" -Force | Out-Null

# --- Welcome screen ---
Clear-Host
Print-Header "You are about to push changes to Ubuntu server"
Write-Host ""
Write-Host "  This wizard installs everything needed to run the server." -ForegroundColor White
Write-Host ""
Write-Host "  What will be installed:" -ForegroundColor White
Write-Host "    - Java 11 JDK (Microsoft OpenJDK)" -ForegroundColor Gray
Write-Host "    - Apache Maven 3 (build tool)" -ForegroundColor Gray
Write-Host "    - PostgreSQL 16 (database)" -ForegroundColor Gray
Write-Host "    - Apache Tomcat 9 (web server)" -ForegroundColor Gray
Write-Host "    - Server application (built from source)" -ForegroundColor Gray
Write-Host ""
Write-Host "  Estimated time: 5-10 minutes" -ForegroundColor DarkYellow
Write-Host "  Log file: $LOG_FILE" -ForegroundColor DarkGray
Write-Host ""

if (-not (Prompt-Continue "Ready to start installation?")) {
    Write-Host "  Setup cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Log "=== Setup Started ==="
$TOTAL_STEPS = 8

# ============================================================
# STEP 1: System check
# ============================================================
Print-Step 1 $TOTAL_STEPS "Checking system requirements"

$osVersion = [System.Environment]::OSVersion.Version
Print-Info "Windows version: $osVersion"
if ($osVersion.Major -lt 10) {
    Print-Error "Windows 10 or later is required."
    exit 1
}
Print-OK "Windows version is compatible"

$winget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $winget) {
    Print-Error "winget not found. Please install App Installer from the Microsoft Store."
    exit 1
}
Print-OK "winget is available"

$drive = Get-PSDrive C
$freeGB = [math]::Round($drive.Free / 1GB, 1)
Print-Info "Free disk space on C: ${freeGB} GB"
if ($freeGB -lt 2) {
    Print-Error "Not enough disk space. At least 2 GB free required on C:"
    exit 1
}
Print-OK "Disk space OK (${freeGB} GB free)"

$port8080 = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($port8080) {
    Print-Warn "Port 8080 is already in use. Tomcat may not start."
    if (-not (Prompt-Continue "Continue anyway?")) { exit 1 }
} else {
    Print-OK "Port 8080 is available"
}

Write-Log "System check passed"

# ============================================================
# STEP 2: Install Java 11
# ============================================================
Print-Step 2 $TOTAL_STEPS "Installing Java 11 JDK"

$javaCmd = Get-Command java -ErrorAction SilentlyContinue
if ($javaCmd) {
    $javaVer = (java -version 2>&1)[0].ToString()
    Print-Skip "Java ($javaVer)"
    Write-Log "Java already installed: $javaVer"
} else {
    Print-Info "Downloading and installing Microsoft OpenJDK 11..."
    Write-Log "Installing Java 11"
    Show-Progress "Installing Java 11" "Downloading..." 10
    try {
        winget install --id Microsoft.OpenJDK.11 --accept-source-agreements --accept-package-agreements -e --silent 2>&1 | Out-Null
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                    [System.Environment]::GetEnvironmentVariable("Path","User")
        Write-Progress -Activity "Installing Java 11" -Completed
        Print-OK "Java 11 installed successfully"
        Write-Log "Java 11 installed"
    } catch {
        Print-Error "Failed to install Java: $_"
        Write-Log "ERROR installing Java: $_"
        exit 1
    }
}

$javaExe = (Get-Command java -ErrorAction SilentlyContinue).Source
if ($javaExe) {
    $javaHome = Split-Path (Split-Path $javaExe)
    [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $javaHome, "Machine")
    $env:JAVA_HOME = $javaHome
    Print-OK "JAVA_HOME set to $javaHome"
}

# ============================================================
# STEP 3: Install Maven
# ============================================================
Print-Step 3 $TOTAL_STEPS "Installing Apache Maven"

$mvnCmd = Get-Command mvn -ErrorAction SilentlyContinue
if ($mvnCmd) {
    Print-Skip "Maven"
    Write-Log "Maven already installed"
} else {
    Print-Info "Downloading and installing Apache Maven..."
    Write-Log "Installing Maven"
    Show-Progress "Installing Maven" "Downloading..." 10
    try {
        winget install --id Apache.Maven --accept-source-agreements --accept-package-agreements -e --silent 2>&1 | Out-Null
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                    [System.Environment]::GetEnvironmentVariable("Path","User")
        Write-Progress -Activity "Installing Maven" -Completed
        Print-OK "Maven installed successfully"
        Write-Log "Maven installed"
    } catch {
        Print-Error "Failed to install Maven: $_"
        Write-Log "ERROR installing Maven: $_"
        exit 1
    }
}

# ============================================================
# STEP 4: Install PostgreSQL
# ============================================================
Print-Step 4 $TOTAL_STEPS "Installing PostgreSQL 16"

$pgCmd = Get-Command psql -ErrorAction SilentlyContinue
if ($pgCmd) {
    Print-Skip "PostgreSQL"
    Write-Log "PostgreSQL already installed"
} else {
    Print-Info "Downloading and installing PostgreSQL 16..."
    Print-Info "When asked for a superuser password, use: postgres"
    Write-Host ""
    if (Prompt-Continue "Proceed with PostgreSQL installation?") {
        Write-Log "Installing PostgreSQL"
        Show-Progress "Installing PostgreSQL" "Downloading..." 10
        try {
            winget install --id PostgreSQL.PostgreSQL.16 --accept-source-agreements --accept-package-agreements -e 2>&1 | Out-Null
            if (Test-Path $PG_BIN) {
                $machinePath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
                if ($machinePath -notlike "*$PG_BIN*") {
                    [System.Environment]::SetEnvironmentVariable("Path", "$machinePath;$PG_BIN", "Machine")
                }
                $env:Path += ";$PG_BIN"
            }
            Write-Progress -Activity "Installing PostgreSQL" -Completed
            Print-OK "PostgreSQL installed successfully"
            Write-Log "PostgreSQL installed"
        } catch {
            Print-Error "Failed to install PostgreSQL: $_"
            Write-Log "ERROR installing PostgreSQL: $_"
            exit 1
        }
    }
}

# ============================================================
# STEP 5: Setup Tomcat 9
# ============================================================
Print-Step 5 $TOTAL_STEPS "Setting up Apache Tomcat 9"

if (Test-Path "$TOMCAT_DIR\bin\catalina.bat") {
    Print-Skip "Tomcat 9 (found at $TOMCAT_DIR)"
    Write-Log "Tomcat already present"
} else {
    $tomcatUrl = "https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION-windows-x64.zip"
    $tomcatZip = "$env:TEMP\tomcat9.zip"
    Print-Info "Downloading Tomcat $TOMCAT_VERSION..."
    Write-Log "Downloading Tomcat"
    Show-Progress "Setting up Tomcat" "Downloading..." 20
    try {
        Invoke-WebRequest -Uri $tomcatUrl -OutFile $tomcatZip -UseBasicParsing
        Show-Progress "Setting up Tomcat" "Extracting..." 60
        Expand-Archive -Path $tomcatZip -DestinationPath "C:\" -Force
        if (Test-Path "C:\apache-tomcat-$TOMCAT_VERSION") {
            Rename-Item "C:\apache-tomcat-$TOMCAT_VERSION" $TOMCAT_DIR -Force
        }
        Remove-Item $tomcatZip -Force
        Write-Progress -Activity "Setting up Tomcat" -Completed
        Print-OK "Tomcat 9 installed at $TOMCAT_DIR"
        Write-Log "Tomcat installed at $TOMCAT_DIR"
    } catch {
        Print-Error "Failed to install Tomcat: $_"
        Write-Log "ERROR installing Tomcat: $_"
        exit 1
    }
}

# ============================================================
# STEP 6: Configure database
# ============================================================
Print-Step 6 $TOTAL_STEPS "Setting up the database"

Write-Host ""
Write-Host "  Enter the PostgreSQL superuser password" -ForegroundColor Yellow
Write-Host "  (default is 'postgres' if you used that during install)" -ForegroundColor Gray
$pgSuperPass = Read-Host "  Password" -AsSecureString
$pgSuperPassPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pgSuperPass))
$env:PGPASSWORD = $pgSuperPassPlain

$PG_PASS = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 16 | ForEach-Object {[char]$_})

Print-Info "Creating database user and database..."
Write-Log "Setting up database"

$pgService = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($pgService -and $pgService.Status -ne "Running") {
    Start-Service $pgService.Name
    Start-Sleep 3
}

try {
    $dbCheck = & "$PG_BIN\psql.exe" -U postgres -h $PG_HOST -p $PG_PORT -tAc "SELECT 1 FROM pg_database WHERE datname='$PG_DB'" 2>$null
    if ($dbCheck -eq "1") {
        Print-Skip "Database '$PG_DB' already exists"
        $ctxFile = "$TOMCAT_DIR\conf\Catalina\localhost\ROOT.xml"
        if (Test-Path $ctxFile) {
            $ctxContent = Get-Content $ctxFile -Raw
            if ($ctxContent -match 'password="([^"]+)"') {
                $PG_PASS = $Matches[1]
            }
        }
    } else {
        & "$PG_BIN\psql.exe" -U postgres -h $PG_HOST -p $PG_PORT -c "CREATE USER $PG_USER WITH PASSWORD '$PG_PASS';" 2>&1 | Out-Null
        & "$PG_BIN\psql.exe" -U postgres -h $PG_HOST -p $PG_PORT -c "CREATE DATABASE $PG_DB WITH OWNER=$PG_USER ENCODING='UTF8';" 2>&1 | Out-Null
        Print-OK "Database '$PG_DB' and user '$PG_USER' created"
        Write-Log "Database created"
    }
} catch {
    Print-Error "Database setup failed: $_"
    Write-Log "ERROR in database setup: $_"
    exit 1
}

$contextDir = "$TOMCAT_DIR\conf\Catalina\localhost"
New-Item -ItemType Directory -Path $contextDir -Force | Out-Null

$contextXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<Context path="" docBase="ROOT">
    <Resource name="jdbc/hmdm" auth="Container" type="javax.sql.DataSource"
              driverClassName="org.postgresql.Driver"
              url="jdbc:postgresql://${PG_HOST}:${PG_PORT}/${PG_DB}"
              username="${PG_USER}" password="${PG_PASS}"
              maxTotal="20" maxIdle="10" maxWaitMillis="-1"/>
    <Parameter name="base.directory" value="$($HMDM_DATA_DIR -replace '\\','/')" override="false"/>
    <Parameter name="protocol"       value="http"           override="false"/>
    <Parameter name="base.host"      value="localhost:$SERVER_PORT" override="false"/>
    <Parameter name="base.domain"    value="localhost"      override="false"/>
    <Parameter name="base.path"      value=""               override="false"/>
    <Parameter name="install.flag"   value="$($HMDM_DATA_DIR -replace '\\','/')/hmdm_install_flag" override="false"/>
    <Parameter name="smtp.host"      value=""               override="false"/>
    <Parameter name="smtp.port"      value=""               override="false"/>
    <Parameter name="smtp.ssl"       value="0"              override="false"/>
    <Parameter name="smtp.starttls"  value="0"              override="false"/>
    <Parameter name="smtp.username"  value=""               override="false"/>
    <Parameter name="smtp.password"  value=""               override="false"/>
    <Parameter name="smtp.from"      value=""               override="false"/>
</Context>
"@
$contextXml | Set-Content "$contextDir\ROOT.xml" -Encoding UTF8
Print-OK "Tomcat configuration written"

# ============================================================
# STEP 7: Build the server
# ============================================================
Print-Step 7 $TOTAL_STEPS "Building the server"

$warPath = "$HMDM_SERVER_DIR\server\target\launcher.war"
if (Test-Path $warPath) {
    Print-Skip "Server already built"
    Write-Log "WAR already exists, skipping build"
} else {
    Print-Info "Running Maven build (this takes 3-5 minutes, please wait)..."
    Write-Log "Starting Maven build"
    Show-Progress "Building Server" "Running mvn install..." 10

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")

    $mvnExe = Get-Command mvn -ErrorAction SilentlyContinue
    if (-not $mvnExe) {
        $mvnCandidates = @(
            "C:\Program Files\Maven\bin\mvn.cmd",
            "C:\ProgramData\chocolatey\bin\mvn.cmd",
            "$env:USERPROFILE\AppData\Local\Programs\Maven\bin\mvn.cmd"
        )
        foreach ($candidate in $mvnCandidates) {
            if (Test-Path $candidate) { $mvnExe = $candidate; break }
        }
    }

    if (-not $mvnExe) {
        Print-Error "Maven not found. Please restart setup after installation completes."
        Write-Log "ERROR: Maven not found on PATH"
        exit 1
    }

    $mvnLog = "$HMDM_DATA_DIR\logs\maven-build.log"
    Push-Location $HMDM_SERVER_DIR
    try {
        $proc = Start-Process -FilePath "mvn" `
            -ArgumentList "install -DskipTests" `
            -WorkingDirectory $HMDM_SERVER_DIR `
            -RedirectStandardOutput $mvnLog `
            -RedirectStandardError "$HMDM_DATA_DIR\logs\maven-build-err.log" `
            -NoNewWindow -Wait -PassThru

        if ($proc.ExitCode -ne 0) {
            Write-Progress -Activity "Building Server" -Completed
            Print-Error "Build failed (exit code $($proc.ExitCode)). Check: $mvnLog"
            Write-Log "ERROR: Maven build failed with exit code $($proc.ExitCode)"
            exit 1
        }
        Write-Progress -Activity "Building Server" -Completed
        Print-OK "Server built successfully"
        Write-Log "Maven build completed"
    } finally {
        Pop-Location
    }
}

# ============================================================
# STEP 8: Deploy and start
# ============================================================
Print-Step 8 $TOTAL_STEPS "Deploying and starting the server"

$warDest = "$TOMCAT_DIR\webapps\ROOT.war"
Print-Info "Deploying to Tomcat..."
Copy-Item $warPath $warDest -Force
Print-OK "Deployed"
Write-Log "WAR deployed to $warDest"

$sqlInit = "$HMDM_SERVER_DIR\install\sql\hmdm_init.en.sql"
if (Test-Path $sqlInit) {
    $env:PGPASSWORD = $PG_PASS
    $sqlContent = (Get-Content $sqlInit -Raw) `
        -replace '_HMDM_BASE_',    ($HMDM_DATA_DIR -replace '\\','/') `
        -replace '_HMDM_VERSION_', '5.19' `
        -replace '_HMDM_APK_',     'hmdm-5.19-os.apk' `
        -replace '_ADMIN_EMAIL_',  ''
    $tempSql = "$env:TEMP\hmdm_init.sql"
    $sqlContent | Set-Content $tempSql -Encoding UTF8
    & "$PG_BIN\psql.exe" -U $PG_USER -h $PG_HOST -p $PG_PORT -d $PG_DB -f $tempSql 2>&1 | Out-Null
    Remove-Item $tempSql -Force -ErrorAction SilentlyContinue
    Print-OK "Database seeded"
    Write-Log "Database seeded"
}

$tomcatService = Get-Service -Name "Tomcat9" -ErrorAction SilentlyContinue
if (-not $tomcatService) {
    Print-Info "Registering Tomcat as a Windows service..."
    Set-Location "$TOMCAT_DIR\bin"
    & ".\service.bat" install Tomcat9 2>&1 | Out-Null
    Set-Location $REPO_DIR
    Print-OK "Tomcat9 service registered"
    Write-Log "Tomcat9 service installed"
}

Print-Info "Starting Tomcat..."
try {
    Start-Service "Tomcat9" -ErrorAction Stop
    Print-OK "Tomcat9 service started"
    Write-Log "Tomcat9 started"
} catch {
    Print-Warn "Could not start as service - launching directly..."
    Start-Process "$TOMCAT_DIR\bin\startup.bat" -WorkingDirectory "$TOMCAT_DIR\bin"
    Write-Log "Tomcat started via startup.bat"
}

Print-Info "Waiting for server to start (up to 60 seconds)..."
$started = $false
for ($i = 0; $i -lt 60; $i++) {
    Start-Sleep 1
    $pct = [int](($i / 60) * 100)
    $status = "Waiting... $i of 60 seconds elapsed"
    Show-Progress "Starting Server" $status $pct
    try {
        $resp = Invoke-WebRequest -Uri "http://localhost:$SERVER_PORT" -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
        if ($resp.StatusCode -eq 200) {
            $started = $true
            break
        }
    } catch { }
}
Write-Progress -Activity "Starting Server" -Completed

if ($started) {
    Print-OK "Server is up and running!"
    Write-Log "Server running at http://localhost:$SERVER_PORT"
} else {
    Print-Warn "Server did not respond in 60 seconds - it may still be starting."
    Print-Warn "Check: $TOMCAT_DIR\logs\catalina.out"
    Write-Log "WARNING: Server did not respond in 60s"
}

# --- Done ---
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host "  INSTALLATION COMPLETE" -ForegroundColor Green
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Browser URL : http://localhost:$SERVER_PORT" -ForegroundColor White
Write-Host "  Login       : admin" -ForegroundColor White
Write-Host "  Password    : admin" -ForegroundColor White
Write-Host ""
Write-Host "  DB name     : $PG_DB" -ForegroundColor Gray
Write-Host "  DB user     : $PG_USER" -ForegroundColor Gray
Write-Host "  DB password : $PG_PASS" -ForegroundColor Gray
Write-Host ""
Write-Host "  Setup log   : $LOG_FILE" -ForegroundColor DarkGray
Write-Host "  Server log  : $HMDM_DATA_DIR\logs\hmdm.log" -ForegroundColor DarkGray
Write-Host "  Tomcat log  : $TOMCAT_DIR\logs\catalina.out" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host ""

Write-Log "=== Setup completed successfully ==="
