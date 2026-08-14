# Run Liquibase manually to create HMDM database schema
Write-Host "Running Liquibase to create HMDM database schema..." -ForegroundColor Cyan

$PG_BIN = "C:\Program Files\PostgreSQL\18\bin"
$PG_USER = "hmdm"
$PG_PASS = "hmdm"
$PG_HOST = "localhost"
$PG_PORT = "5432"
$PG_DB = "hmdm"
$SERVER_DIR = "C:\Users\migwi\Desktop\Spywares\hmdm-server-master\hmdm-server-master\server"

# Check if Liquibase JAR exists in the server dependencies
$liquibaseJar = Get-ChildItem -Path "$SERVER_DIR\target\dependency" -Filter "liquibase*.jar" -ErrorAction SilentlyContinue | Select-Object -First 1

if ($liquibaseJar) {
    Write-Host "Found Liquibase JAR: $($liquibaseJar.FullName)" -ForegroundColor Green
    
    # Set classpath
    $classpath = "$($liquibaseJar.FullName);$SERVER_DIR\target\dependency\*"
    
    # Run Liquibase
    $env:PGPASSWORD = $PG_PASS
    
    Write-Host "Running Liquibase update..." -ForegroundColor Yellow
    & java -cp $classpath liquibase.integration.commandline.Main `
        --driver=org.postgresql.Driver `
        --url="jdbc:postgresql://${PG_HOST}:${PG_PORT}/${PG_DB}" `
        --username=$PG_USER `
        --password=$PG_PASS `
        --changeLogFile="$SERVER_DIR\src\main\resources\liquibase\db.changelog.xml" `
        --contexts="common,private" `
        update
        
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Database schema created successfully!" -ForegroundColor Green
    } else {
        Write-Host "✗ Liquibase failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Liquibase JAR not found in dependencies. Please run Maven build first." -ForegroundColor Red
}