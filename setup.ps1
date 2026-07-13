param(
    [string]$LaunchDir = (Split-Path -Parent $MyInvocation.MyCommand.Path),
    [switch]$Reset
)

# ============================================================
# Windows Setup Script - Called by SETUP.bat
# Supports resume: if interrupted, re-run to continue from
# the last completed step.
# ============================================================

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "Software Setup"

# --- Paths ---
$REPO_DIR         = $LaunchDir.TrimEnd('\')
$HMDM_SERVER_DIR  = "$REPO_DIR\hmdm-server-master\hmdm-server-master"
$TOMCAT_VERSION   = "9.0.98"
$TOMCAT_DIR       = "C:\tomcat9"
$HMDM_DATA_DIR    = "C:\hmdm"
$LOG_FILE         = "$HMDM_DATA_DIR\logs\setup.log"
$CHECKPOINT_FILE  = "$HMDM_DATA_DIR\logs\setup_checkpoint.json"
$PG_BIN           = "C:\Program Files\PostgreSQL\16\bin"
$PG_HOST          = "localhost"
$PG_PORT          = "5432"
$PG_DB            = "hmdm"
$PG_USER          = "hmdm"
$SERVER_PORT      = "8080"
$TOTAL_STEPS      = 8

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
function Print-Done($text)  { Write-Host "  [DONE] $text (already completed - skipping)" -ForegroundColor DarkGreen }
function Print-Skip($text)  { Write-Host "  [--] $text (already installed - skipping)" -ForegroundColor DarkGray }
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

# --- Checkpoint helpers ---
function Load-Checkpoint {
    if (Test-Path $CHECKPOINT_FILE) {
        try {
            $json = Get-Content $CHECKPOINT_FILE -Raw | ConvertFrom-Json
            return $json
        } catch { }
    }
    return [PSCustomObject]@{ CompletedSteps = @(); PG_PASS = "" }
}
function Save-Checkpoint($cp) {
    $cp | ConvertTo-Json | Set-Content $CHECKPOINT_FILE -Encoding UTF8
}
function Step-Done($cp, $step) {
    return ($cp.CompletedSteps -contains $step)
}
function Mark-Done($cp, $step) {
    if (-not ($cp.CompletedSteps -contains $step)) {
        $cp.CompletedSteps += $step
    }
    Save-Checkpoint $cp
}

# --- Ensure log dir exists ---
New-Item -ItemType Directory -Path "$HMDM_DATA_DIR\logs" -Force | Out-Null

# --- Handle reset flag ---
if ($Reset) {
    if (Test-Path $CHECKPOINT_FILE) {
        Remove-Item $CHECKPOINT_FILE -Force
        Write-Host "  Checkpoint cleared. Setup will start from Step 1." -ForegroundColor Yellow
    }
}

# --- Load checkpoint ---
$cp = Load-Checkpoint

# --- Welcome screen ---
Clear-Host
Print-Header "You are about to push changes to Ubuntu server"
Write-Host ""
Write-Host "  This wizard installs everything needed to run the server." -ForegroundColor White
Write-Host ""

if ($cp.CompletedSteps.Count -gt 0) {
    Write-Host "  RESUMING from previous run." -ForegroundColor Yellow
    Write-Host "  Steps already completed: $($cp.CompletedSteps -join ', ')" -ForegroundColor DarkGreen
    Write-Host ""
    Write-Host "  To start over from scratch, run:" -ForegroundColor DarkGray
    Write-Host "  .\setup.ps1 -Reset" -ForegroundColor DarkGray
    Write-Host ""
} else {
    Write-Host "  What will be installed:" -ForegroundColor White
    Write-Host "    - Java 11 JDK (Microsoft OpenJDK)" -ForegroundColor Gray
    Write-Host "    - Apache Maven 3 (build tool)" -ForegroundColor Gray
    Write-Host "    - PostgreSQL 16 (database)" -ForegroundColor Gray
    Write-Host "    - Apache Tomcat 9 (web server)" -ForegroundColor Gray
    Write-Host "    - Server application (built from source)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Estimated time: 5-10 minutes" -ForegroundColor DarkYellow
    Write-Host "  Tip: if setup is interrupted, just re-run SETUP.bat to resume." -ForegroundColor DarkGray
    Write-Host ""
}

Write-Host "  Log file      : $LOG_FILE" -ForegroundColor DarkGray
Write-Host "  Checkpoint    : $CHECKPOINT_FILE" -ForegroundColor DarkGray
Write-Host ""

if (-not (Prompt-Continue "Ready to continue?")) {
    Write-Host "  Setup cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Log "=== Setup Started (completed steps: $($cp.CompletedSteps -join ',')) ==="

# ============================================================
# STEP 1: System check
# ============================================================
Print-Step 1 $TOTAL_STEPS "Checking system requirements"
if (Step-Done $cp 1) {
    Print-Done "System check"
} else {
    $osVersion = [System.Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10) { Print-Error "Windows 10 or later required."; exit 1 }
    Print-OK "Windows version OK ($osVersion)"

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Print-Error "winget not found. Install App Installer from Microsoft Store."
        exit 1
    }
    Print-OK "winget available"

    $freeGB = [math]::Round((Get-PSDrive C).Free / 1GB, 1)
    if ($freeGB -lt 2) { Print-Error "Not enough disk space (need 2 GB free on C:)."; exit 1 }
    Print-OK "Disk space OK (${freeGB} GB free)"

    $port8080 = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
    if ($port8080) {
        Print-Warn "Port 8080 already in use."
        if (-not (Prompt-Continue "Continue anyway?")) { exit 1 }
    } else {
        Print-OK "Port 8080 available"
    }

    Write-Log "Step 1 complete"
    Mark-Done $cp 1
}

# ============================================================
# STEP 2: Install Java 11
# ============================================================
Print-Step 2 $TOTAL_STEPS "Installing Java 11 JDK"
if (Step-Done $cp 2) {
    Print-Done "Java 11"
} else {
    $javaCmd = Get-Command java -ErrorAction SilentlyContinue
    if ($javaCmd) {
        Print-Skip "Java (already on PATH)"
    } else {
        Print-Info "Installing Microsoft OpenJDK 11 via winget..."
        try {
            winget install --id Microsoft.OpenJDK.11 --accept-source-agreements --accept-package-agreements -e --silent 2>&1 | Out-Null
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                        [System.Environment]::GetEnvironmentVariable("Path","User")
            Print-OK "Java 11 installed"
        } catch {
            Print-Error "Failed to install Java: $_"
            Write-Log "ERROR Step 2: $_"
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
    Write-Log "Step 2 complete"
    Mark-Done $cp 2
}

# ============================================================
# STEP 3: Install Maven
# ============================================================
Print-Step 3 $TOTAL_STEPS "Installing Apache Maven"
if (Step-Done $cp 3) {
    Print-Done "Maven"
} else {
    if (Get-Command mvn -ErrorAction SilentlyContinue) {
        Print-Skip "Maven (already on PATH)"
    } else {
        Print-Info "Installing Apache Maven via winget..."
        try {
            winget install --id Apache.Maven --accept-source-agreements --accept-package-agreements -e --silent 2>&1 | Out-Null
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                        [System.Environment]::GetEnvironmentVariable("Path","User")
            Print-OK "Maven installed"
        } catch {
            Print-Error "Failed to install Maven: $_"
            Write-Log "ERROR Step 3: $_"
            exit 1
        }
    }
    Write-Log "Step 3 complete"
    Mark-Done $cp 3
}

# ============================================================
# STEP 4: Install PostgreSQL
# ============================================================
Print-Step 4 $TOTAL_STEPS "Installing PostgreSQL 16"
if (Step-Done $cp 4) {
    Print-Done "PostgreSQL"
    # Make sure PG_BIN is on PATH for later steps
    if (Test-Path $PG_BIN) { $env:Path += ";$PG_BIN" }
} else {
    $pgOnPath = Get-Command psql -ErrorAction SilentlyContinue
    if (-not $pgOnPath -and -not (Test-Path "$PG_BIN\psql.exe")) {
        Print-Info "Installing PostgreSQL 16 via winget..."
        Print-Info "When prompted for a superuser password, set it to: postgres"
        Write-Host ""
        if (Prompt-Continue "Proceed with PostgreSQL installation?") {
            try {
                winget install --id PostgreSQL.PostgreSQL.16 --accept-source-agreements --accept-package-agreements -e 2>&1 | Out-Null
                if (Test-Path $PG_BIN) {
                    $machinePath = [System.Environment]::GetEnvironmentVariable("Path","Machine")
                    if ($machinePath -notlike "*$PG_BIN*") {
                        [System.Environment]::SetEnvironmentVariable("Path", "$machinePath;$PG_BIN", "Machine")
                    }
                    $env:Path += ";$PG_BIN"
                }
                Print-OK "PostgreSQL installed"
            } catch {
                Print-Error "Failed to install PostgreSQL: $_"
                Write-Log "ERROR Step 4: $_"
                exit 1
            }
        }
    } else {
        Print-Skip "PostgreSQL (already installed)"
        if (Test-Path $PG_BIN) { $env:Path += ";$PG_BIN" }
    }
    Write-Log "Step 4 complete"
    Mark-Done $cp 4
}

# ============================================================
# STEP 5: Setup Tomcat 9
# ============================================================
Print-Step 5 $TOTAL_STEPS "Setting up Apache Tomcat 9"
if (Step-Done $cp 5) {
    Print-Done "Tomcat 9"
} else {
    if (Test-Path "$TOMCAT_DIR\bin\catalina.bat") {
        Print-Skip "Tomcat 9 (found at $TOMCAT_DIR)"
    } else {
        $tomcatUrl = "https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION-windows-x64.zip"
        $tomcatZip = "$env:TEMP\tomcat9.zip"
        Print-Info "Downloading Tomcat $TOMCAT_VERSION..."
        try {
            Show-Progress "Tomcat" "Downloading..." 20
            Invoke-WebRequest -Uri $tomcatUrl -OutFile $tomcatZip -UseBasicParsing
            Show-Progress "Tomcat" "Extracting..." 60
            Expand-Archive -Path $tomcatZip -DestinationPath "C:\" -Force
            if (Test-Path "C:\apache-tomcat-$TOMCAT_VERSION") {
                Rename-Item "C:\apache-tomcat-$TOMCAT_VERSION" $TOMCAT_DIR -Force
            }
            Remove-Item $tomcatZip -Force
            Write-Progress -Activity "Tomcat" -Completed
            Print-OK "Tomcat 9 installed at $TOMCAT_DIR"
        } catch {
            Print-Error "Failed to install Tomcat: $_"
            Write-Log "ERROR Step 5: $_"
            exit 1
        }
    }
    Write-Log "Step 5 complete"
    Mark-Done $cp 5
}

# ============================================================
# STEP 6: Configure database
# ============================================================
Print-Step 6 $TOTAL_STEPS "Setting up the database"
if (Step-Done $cp 6) {
    Print-Done "Database"
    # Restore PG_PASS from checkpoint so later steps can use it
    $PG_PASS = $cp.PG_PASS
    if (-not $PG_PASS) {
        $ctxFile = "$TOMCAT_DIR\conf\Catalina\localhost\ROOT.xml"
        if (Test-Path $ctxFile) {
            $ctxContent = Get-Content $ctxFile -Raw
            if ($ctxContent -match 'password="([^"]+)"') { $PG_PASS = $Matches[1] }
        }
    }
} else {
    # Ensure PG is on PATH
    if (Test-Path $PG_BIN) { $env:Path += ";$PG_BIN" }

    # Start PostgreSQL service if not running
    $pgService = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($pgService -and $pgService.Status -ne "Running") {
        Print-Info "Starting PostgreSQL service..."
        Start-Service $pgService.Name
        Start-Sleep 3
    }

    # Prompt for password with retry
    $maxAttempts = 3
    $attempt = 0
    $pgSuperPassPlain = ""
    while ($attempt -lt $maxAttempts) {
        $attempt++
        Write-Host ""
        Write-Host "  Enter the PostgreSQL superuser (postgres) password" -ForegroundColor Yellow
        Write-Host "  Attempt $attempt of $maxAttempts  (default password is 'postgres')" -ForegroundColor Gray
        $pgSuperPass = Read-Host "  Password" -AsSecureString
        $pgSuperPassPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pgSuperPass))
        $env:PGPASSWORD = $pgSuperPassPlain

        # Test the password
        $testResult = & "$PG_BIN\psql.exe" -U postgres -h $PG_HOST -p $PG_PORT -tAc "SELECT 1" 2>&1
        if ($testResult -match "1") {
            Print-OK "Password accepted"
            break
        } else {
            Print-Warn "Password incorrect or PostgreSQL not reachable."
            if ($attempt -eq $maxAttempts) {
                Print-Error "Failed to connect after $maxAttempts attempts."
                Print-Error "Make sure PostgreSQL is running and use the password you set during install."
                Write-Log "ERROR Step 6: could not connect to PostgreSQL after $maxAttempts attempts"
                exit 1
            }
            Print-Info "Please try again..."
        }
    }

    $PG_PASS = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 16 | ForEach-Object {[char]$_})

    try {
        $dbCheck = & "$PG_BIN\psql.exe" -U postgres -h $PG_HOST -p $PG_PORT -tAc "SELECT 1 FROM pg_database WHERE datname='$PG_DB'" 2>$null
        if ($dbCheck -match "1") {
            Print-Skip "Database '$PG_DB' already exists"
            $ctxFile = "$TOMCAT_DIR\conf\Catalina\localhost\ROOT.xml"
            if (Test-Path $ctxFile) {
                $ctxContent = Get-Content $ctxFile -Raw
                if ($ctxContent -match 'password="([^"]+)"') { $PG_PASS = $Matches[1] }
            }
        } else {
            & "$PG_BIN\psql.exe" -U postgres -h $PG_HOST -p $PG_PORT -c "CREATE USER $PG_USER WITH PASSWORD '$PG_PASS';" 2>&1 | Out-Null
            & "$PG_BIN\psql.exe" -U postgres -h $PG_HOST -p $PG_PORT -c "CREATE DATABASE $PG_DB WITH OWNER=$PG_USER ENCODING='UTF8';" 2>&1 | Out-Null
            Print-OK "Database '$PG_DB' and user '$PG_USER' created"
        }
    } catch {
        Print-Error "Database setup failed: $_"
        Write-Log "ERROR Step 6: $_"
        exit 1
    }

    # Write Tomcat context.xml
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
    <Parameter name="protocol"       value="http"                    override="false"/>
    <Parameter name="base.host"      value="localhost:$SERVER_PORT"  override="false"/>
    <Parameter name="base.domain"    value="localhost"               override="false"/>
    <Parameter name="base.path"      value=""                        override="false"/>
    <Parameter name="install.flag"   value="$($HMDM_DATA_DIR -replace '\\','/')/hmdm_install_flag" override="false"/>
    <Parameter name="smtp.host"      value="" override="false"/>
    <Parameter name="smtp.port"      value="" override="false"/>
    <Parameter name="smtp.ssl"       value="0" override="false"/>
    <Parameter name="smtp.starttls"  value="0" override="false"/>
    <Parameter name="smtp.username"  value="" override="false"/>
    <Parameter name="smtp.password"  value="" override="false"/>
    <Parameter name="smtp.from"      value="" override="false"/>
</Context>
"@
    $contextXml | Set-Content "$contextDir\ROOT.xml" -Encoding UTF8
    Print-OK "Tomcat DB config written"

    # Save PG_PASS to checkpoint so resume works
    $cp.PG_PASS = $PG_PASS
    Write-Log "Step 6 complete"
    Mark-Done $cp 6
}

# ============================================================
# STEP 7: Build the server
# ============================================================
Print-Step 7 $TOTAL_STEPS "Building the server"
if (Step-Done $cp 7) {
    Print-Done "Server build"
} else {
    $warPath = "$HMDM_SERVER_DIR\server\target\launcher.war"
    if (Test-Path $warPath) {
        Print-Skip "Server WAR already built"
    } else {
        Print-Info "Running Maven build (3-5 minutes, please wait)..."
        Write-Log "Starting Maven build"

        # Refresh PATH so newly installed Maven is visible
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                    [System.Environment]::GetEnvironmentVariable("Path","User")

        $mvnExe = (Get-Command mvn -ErrorAction SilentlyContinue).Source
        if (-not $mvnExe) {
            foreach ($candidate in @(
                "C:\Program Files\Maven\bin\mvn.cmd",
                "C:\ProgramData\chocolatey\bin\mvn.cmd",
                "$env:USERPROFILE\AppData\Local\Programs\Maven\bin\mvn.cmd"
            )) {
                if (Test-Path $candidate) { $mvnExe = $candidate; break }
            }
        }
        if (-not $mvnExe) {
            Print-Error "Maven not found on PATH. Close this window, reopen PowerShell as Admin, and re-run SETUP.bat."
            Write-Log "ERROR Step 7: Maven not found"
            exit 1
        }

        $mvnLog    = "$HMDM_DATA_DIR\logs\maven-build.log"
        $mvnErrLog = "$HMDM_DATA_DIR\logs\maven-build-err.log"
        Show-Progress "Building" "Running mvn install -DskipTests ..." 10
        Push-Location $HMDM_SERVER_DIR
        try {
            $proc = Start-Process -FilePath $mvnExe `
                -ArgumentList "install -DskipTests" `
                -WorkingDirectory $HMDM_SERVER_DIR `
                -RedirectStandardOutput $mvnLog `
                -RedirectStandardError $mvnErrLog `
                -NoNewWindow -Wait -PassThru
            Write-Progress -Activity "Building" -Completed
            if ($proc.ExitCode -ne 0) {
                Print-Error "Build failed (exit code $($proc.ExitCode))."
                Print-Error "Check log: $mvnLog"
                Write-Log "ERROR Step 7: Maven exit code $($proc.ExitCode)"
                exit 1
            }
            Print-OK "Server built successfully"
        } finally {
            Pop-Location
        }
    }
    Write-Log "Step 7 complete"
    Mark-Done $cp 7
}

# ============================================================
# STEP 8: Deploy and start
# ============================================================
Print-Step 8 $TOTAL_STEPS "Deploying and starting the server"
if (Step-Done $cp 8) {
    Print-Done "Deploy and start"
} else {
    $warPath = "$HMDM_SERVER_DIR\server\target\launcher.war"
    $warDest = "$TOMCAT_DIR\webapps\ROOT.war"

    if (-not (Test-Path $warPath)) {
        Print-Error "WAR file not found at $warPath. Step 7 may have failed."
        Write-Log "ERROR Step 8: WAR not found"
        exit 1
    }

    Print-Info "Deploying WAR to Tomcat..."
    Copy-Item $warPath $warDest -Force
    Print-OK "WAR deployed to $warDest"

    # Restore PG_PASS if not already set (e.g. step 6 was skipped as done)
    if (-not $PG_PASS) {
        $PG_PASS = $cp.PG_PASS
        if (-not $PG_PASS) {
            $ctxFile = "$TOMCAT_DIR\conf\Catalina\localhost\ROOT.xml"
            if (Test-Path $ctxFile) {
                $ctxContent = Get-Content $ctxFile -Raw
                if ($ctxContent -match 'password="([^"]+)"') { $PG_PASS = $Matches[1] }
            }
        }
    }

    # Seed database from SQL init script
    $sqlInit = "$HMDM_SERVER_DIR\install\sql\hmdm_init.en.sql"
    if (Test-Path $sqlInit) {
        Print-Info "Seeding database..."
        $env:PGPASSWORD = $PG_PASS
        if (Test-Path $PG_BIN) { $env:Path += ";$PG_BIN" }
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
    }

    # Register Tomcat as Windows service
    $tomcatService = Get-Service -Name "Tomcat9" -ErrorAction SilentlyContinue
    if (-not $tomcatService) {
        Print-Info "Registering Tomcat as a Windows service..."
        Push-Location "$TOMCAT_DIR\bin"
        try {
            & ".\service.bat" install Tomcat9 2>&1 | Out-Null
            Print-OK "Tomcat9 service registered"
        } finally {
            Pop-Location
        }
    }

    # Start Tomcat
    Print-Info "Starting Tomcat..."
    try {
        Start-Service "Tomcat9" -ErrorAction Stop
        Print-OK "Tomcat9 service started"
        Write-Log "Tomcat9 started as service"
    } catch {
        Print-Warn "Could not start as service - launching via startup.bat..."
        Start-Process "$TOMCAT_DIR\bin\startup.bat" -WorkingDirectory "$TOMCAT_DIR\bin"
        Write-Log "Tomcat started via startup.bat"
    }

    # Wait up to 60s for server to respond
    Print-Info "Waiting for server to start (up to 60 seconds)..."
    $started = $false
    for ($i = 1; $i -le 60; $i++) {
        Start-Sleep 1
        $pct    = [int](($i / 60) * 100)
        $status = "Waiting... $i of 60 seconds"
        Show-Progress "Starting Server" $status $pct
        try {
            $resp = Invoke-WebRequest -Uri "http://localhost:$SERVER_PORT" `
                -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
            if ($resp.StatusCode -eq 200) { $started = $true; break }
        } catch { }
    }
    Write-Progress -Activity "Starting Server" -Completed

    if ($started) {
        Print-OK "Server is up at http://localhost:$SERVER_PORT"
        Write-Log "Server confirmed running"
    } else {
        Print-Warn "Server did not respond in 60s - may still be starting."
        Print-Warn "Check: $TOMCAT_DIR\logs\catalina.out"
        Write-Log "WARNING: server did not respond in 60s"
    }

    Write-Log "Step 8 complete"
    Mark-Done $cp 8
}

# ============================================================
# DONE
# ============================================================
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host "  INSTALLATION COMPLETE" -ForegroundColor Green
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Browser URL : http://localhost:$SERVER_PORT" -ForegroundColor White
Write-Host "  Login       : admin" -ForegroundColor White
Write-Host "  Password    : admin" -ForegroundColor White
Write-Host ""

# Read PG_PASS from checkpoint or context file for display
$displayPass = $PG_PASS
if (-not $displayPass) { $displayPass = $cp.PG_PASS }
if (-not $displayPass) {
    $ctxFile = "$TOMCAT_DIR\conf\Catalina\localhost\ROOT.xml"
    if (Test-Path $ctxFile) {
        $ctxContent = Get-Content $ctxFile -Raw
        if ($ctxContent -match 'password="([^"]+)"') { $displayPass = $Matches[1] }
    }
}

Write-Host "  DB name     : $PG_DB" -ForegroundColor Gray
Write-Host "  DB user     : $PG_USER" -ForegroundColor Gray
Write-Host "  DB password : $displayPass" -ForegroundColor Gray
Write-Host ""
Write-Host "  Setup log   : $LOG_FILE" -ForegroundColor DarkGray
Write-Host "  Server log  : $HMDM_DATA_DIR\logs\hmdm.log" -ForegroundColor DarkGray
Write-Host "  Tomcat log  : $TOMCAT_DIR\logs\catalina.out" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  To reset and start over: .\setup.ps1 -Reset" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host ""

Write-Log "=== Setup completed successfully ==="
