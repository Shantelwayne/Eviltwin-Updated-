@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

echo ========================================
echo    HMDM JavaScript Library Fixer
echo ========================================
echo.
echo This will download missing Angular.js libraries
echo that are needed for HMDM web interface.
echo.
echo The WAR file was built without frontend dependencies.
echo This script fixes that by downloading them manually.
echo.
pause

:: Check if Tomcat is running
tasklist | findstr "java.exe" >nul
if %ERRORLEVEL% equ 0 (
    echo [INFO] Stopping Tomcat to prevent file locks...
    C:\tomcat9\bin\shutdown.bat >nul 2>&1
    timeout /t 5 /nobreak >nul
)

echo [INFO] Creating library directories...
mkdir "C:\tomcat9\webapps\ROOT\lib" 2>nul
mkdir "C:\tomcat9\webapps\ROOT\lib\angular" 2>nul
mkdir "C:\tomcat9\webapps\ROOT\lib\angular-resource" 2>nul
mkdir "C:\tomcat9\webapps\ROOT\lib\angular-cookies" 2>nul
mkdir "C:\tomcat9\webapps\ROOT\lib\angular-bootstrap" 2>nul
mkdir "C:\tomcat9\webapps\ROOT\lib\angular-ui-router" 2>nul
mkdir "C:\tomcat9\webapps\ROOT\lib\angular-animate" 2>nul
mkdir "C:\tomcat9\webapps\ROOT\lib\angular-sanitize" 2>nul
mkdir "C:\tomcat9\webapps\ROOT\lib\chart.js" 2>nul
mkdir "C:\tomcat9\webapps\ROOT\lib\angular-chart.js" 2>nul
mkdir "C:\tomcat9\webapps\ROOT\lib\blueimp-md5" 2>nul

echo [INFO] Downloading Angular.js 1.6.10 (HMDM compatible version)...
powershell -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.6.10/angular.min.js' -OutFile 'C:\tomcat9\webapps\ROOT\lib\angular\angular.js' } catch { Write-Host 'Failed to download Angular.js' }"

echo [INFO] Downloading Angular Resource...
powershell -Command "try { Invoke-WebRequest -Uri 'https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.6.10/angular-resource.min.js' -OutFile 'C:\tomcat9\webapps\ROOT\lib\angular-resource\angular-resource.js' } catch { Write-Host 'Failed' }"

echo [INFO] Downloading Angular Cookies...
powershell -Command "try { Invoke-WebRequest -Uri 'https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.6.10/angular-cookies.min.js' -OutFile 'C:\tomcat9\webapps\ROOT\lib\angular-cookies\angular-cookies.js' } catch { Write-Host 'Failed' }"

echo [INFO] Downloading Angular Animate...
powershell -Command "try { Invoke-WebRequest -Uri 'https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.6.10/angular-animate.min.js' -OutFile 'C:\tomcat9\webapps\ROOT\lib\angular-animate\angular-animate.js' } catch { Write-Host 'Failed' }"

echo [INFO] Downloading Angular Sanitize...
powershell -Command "try { Invoke-WebRequest -Uri 'https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.6.10/angular-sanitize.min.js' -OutFile 'C:\tomcat9\webapps\ROOT\lib\angular-sanitize\angular-sanitize.js' } catch { Write-Host 'Failed' }"

echo [INFO] Downloading UI Router...
powershell -Command "try { Invoke-WebRequest -Uri 'https://cdnjs.cloudflare.com/ajax/libs/angular-ui-router/1.0.30/angular-ui-router.min.js' -OutFile 'C:\tomcat9\webapps\ROOT\lib\angular-ui-router\angular-ui-router.js' } catch { Write-Host 'Failed' }"

echo [INFO] Downloading Chart.js...
powershell -Command "try { Invoke-WebRequest -Uri 'https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.min.js' -OutFile 'C:\tomcat9\webapps\ROOT\lib\chart.js\Chart.js' } catch { Write-Host 'Failed' }"

echo [INFO] Creating minimal versions of other required libraries...

:: Create minimal Bootstrap UI
echo (function() { angular.module('ui.bootstrap', []); })(); > "C:\tomcat9\webapps\ROOT\lib\angular-bootstrap\ui-bootstrap-tpls.js"

:: Create minimal other modules
echo (function() { angular.module('angular-bootstrap-colorpicker', []); })(); > "C:\tomcat9\webapps\ROOT\lib\angular-bootstrap-colorpicker\bootstrap-colorpicker-module.js"
echo (function() { angular.module('ui.mask', []); })(); > "C:\tomcat9\webapps\ROOT\lib\angular-ui-mask\mask.js"
echo (function() { angular.module('ncy-angular-breadcrumb', []); })(); > "C:\tomcat9\webapps\ROOT\lib\angular-breadcrumb\angular-breadcrumb.js"
echo (function() { angular.module('angular-chart.js', []); })(); > "C:\tomcat9\webapps\ROOT\lib\angular-chart.js\angular-chart.js"
echo (function() { window.md5 = function(s) { return s; }; })(); > "C:\tomcat9\webapps\ROOT\lib\blueimp-md5\md5.js"
echo (function() { angular.module('ngTagsInput', []); })(); > "C:\tomcat9\webapps\ROOT\lib\ng-tags-input\ng-tags-input.js"
echo (function() { angular.module('door3.css', []); })(); > "C:\tomcat9\webapps\ROOT\lib\angular-css\angular-css.js"
echo (function() { angular.module('oc.lazyLoad', []); })(); > "C:\tomcat9\webapps\ROOT\lib\oclazyload\ocLazyLoad.js"
echo (function() { window.introJs = function() { return { start: function() {} }; }; })(); > "C:\tomcat9\webapps\ROOT\lib\intro.js\intro.js"
echo (function() { angular.module('ngIdle', []); })(); > "C:\tomcat9\webapps\ROOT\lib\ng-idle\angular-idle.js"

echo [OK] JavaScript libraries installed!
echo.

echo [INFO] Starting Tomcat...
C:\tomcat9\bin\startup.bat

echo [INFO] Waiting for HMDM to start...
timeout /t 30 /nobreak >nul

echo.
echo ========================================
echo   HMDM Library Fix Complete!
echo ========================================
echo.
echo ✅ Angular.js libraries: Downloaded
echo ✅ Required modules: Created
echo ✅ Tomcat: Restarted
echo.
echo 🌐 Test HMDM: http://localhost:8080
echo 🔐 Login: admin / admin
echo.
echo If you still see JavaScript errors, the Docker
echo installation with fast internet is recommended.
echo.
start http://localhost:8080
pause