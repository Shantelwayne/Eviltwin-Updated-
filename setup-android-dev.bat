@echo off
echo ===================================
echo    EvilTwin Android Setup
echo ===================================
echo.

echo [1/5] Checking Java installation...
java -version
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Java not found! 
    echo Please install Java JDK 8 or 11 from:
    echo https://adoptium.net/temurin/releases/
    pause
    exit /b 1
)
echo ✅ Java installed

echo.
echo [2/5] Checking Android SDK...
if exist "%ANDROID_HOME%\platform-tools\adb.exe" (
    echo ✅ Android SDK found at %ANDROID_HOME%
) else (
    echo ❌ Android SDK not found!
    echo.
    echo Please install Android Studio from:
    echo https://developer.android.com/studio
    echo.
    echo Or install SDK manually and set ANDROID_HOME environment variable
    pause
    exit /b 1
)

echo.
echo [3/5] Checking Gradle...
cd "%~dp0android-app"
if exist "gradlew.bat" (
    echo ✅ Gradle wrapper found
    gradlew.bat --version
) else (
    echo ❌ Gradle wrapper not found!
    exit /b 1
)

echo.
echo [4/5] Setting up Android project...
echo Configuring build.gradle for EvilTwin...

echo.
echo [5/5] Building APK...
echo This may take several minutes...
gradlew.bat assembleDebug

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ SUCCESS! APK built successfully!
    echo.
    echo 📱 APK Location: app\build\outputs\apk\debug\app-debug.apk
    echo 📧 Ready to distribute to target devices
    echo.
) else (
    echo.
    echo ❌ Build failed! Check errors above.
    echo.
)

echo ===================================
echo    Build Complete
echo ===================================
pause