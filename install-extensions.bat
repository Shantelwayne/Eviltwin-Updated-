@echo off
echo Installing Android Development Extensions for VS Code...
echo.

REM Core Android Development
code --install-extension vscjava.vscode-java-pack
code --install-extension richardwillis.vscode-gradle
code --install-extension adelphes.android-dev-ext
code --install-extension mathiasfrohlich.kotlin
code --install-extension redhat.java

REM Build Tools
code --install-extension ms-vscode.gradle-tasks
code --install-extension vscjava.vscode-gradle

REM APK Management
code --install-extension DiemasMichiels.emulate
code --install-extension adelphes.android-dev-ext

REM Required for Java/Kotlin
code --install-extension vscjava.vscode-java-dependency
code --install-extension vscjava.vscode-java-test
code --install-extension vscjava.vscode-maven
code --install-extension vscjava.vscode-java-debug

echo.
echo ✅ Extensions installed! 
echo.
echo Next steps:
echo 1. Install Android SDK
echo 2. Set ANDROID_HOME environment variable
echo 3. Install Gradle
echo.
pause