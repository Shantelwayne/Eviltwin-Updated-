@echo off
color 0A
title HMDM Quick Start Guide

:main_menu
cls
echo.
echo     ╔═══════════════════════════════════════╗
echo     ║        HMDM QUICK START GUIDE         ║
echo     ╚═══════════════════════════════════════╝
echo.
echo     📦 You have received: HMDM_Deployment_Package.zip
echo.
echo     🚀 QUICK START (5 STEPS):
echo.
echo     1️⃣  Extract the ZIP file to a folder
echo     2️⃣  Right-click INSTALL_HMDM.bat 
echo     3️⃣  Select "Run as administrator"
echo     4️⃣  Choose Option 1 (Docker - Recommended)
echo     5️⃣  Wait 15 minutes, then go to http://localhost:8080
echo.
echo     🔐 Default Login: admin / admin
echo.
echo     ═══════════════════════════════════════
echo.
echo     What do you want to do?
echo.
echo     [1] 🐳 Start Docker Installation (Recommended)
echo     [2] ⚙️  Start Full Installation (Advanced)  
echo     [3] 📖 View Detailed Instructions
echo     [4] ❓ Troubleshooting Help
echo     [5] ℹ️  System Requirements  
echo     [6] 🚪 Exit
echo.
set /p choice="     Enter your choice (1-6): "

if "%choice%"=="1" goto docker_install
if "%choice%"=="2" goto full_install  
if "%choice%"=="3" goto instructions
if "%choice%"=="4" goto troubleshoot
if "%choice%"=="5" goto requirements
if "%choice%"=="6" goto exit
echo     ❌ Invalid choice. Please enter 1-6.
pause
goto main_menu

:docker_install
cls
echo.
echo     ╔═══════════════════════════════════════╗
echo     ║         DOCKER INSTALLATION           ║
echo     ╚═══════════════════════════════════════╝
echo.
echo     🐳 Docker Installation is the RECOMMENDED option
echo.
echo     ✅ Advantages:
echo        • Fastest setup (15 minutes)
echo        • Most reliable 
echo        • No complex configuration
echo        • Easy updates
echo.
echo     📋 What will happen:
echo        1. Install Docker Desktop (if needed)
echo        2. Download HMDM container (~500MB)
echo        3. Start HMDM automatically
echo        4. Open http://localhost:8080
echo.
echo     ⚠️  You MUST run as Administrator!
echo.
echo     [1] Start Docker Installation Now
echo     [2] Back to Main Menu
echo.
set /p choice="     Enter your choice (1-2): "

if "%choice%"=="1" (
    echo.
    echo     🚀 Starting Docker installation...
    echo     Looking for INSTALL_HMDM.bat...
    if exist "INSTALL_HMDM.bat" (
        echo     ✅ Found installer, launching...
        start "HMDM Installer" cmd /c "INSTALL_HMDM.bat"
    ) else if exist "installers\HMDM_Docker_Installer.bat" (
        echo     ✅ Found Docker installer, launching...
        start "HMDM Docker Installer" cmd /c "installers\HMDM_Docker_Installer.bat"
    ) else (
        echo     ❌ Installer not found!
        echo     Make sure you extracted the ZIP file correctly.
        echo     The installer should be in the same folder as this file.
    )
    pause
)
goto main_menu

:full_install
cls
echo.
echo     ╔═══════════════════════════════════════╗
echo     ║          FULL INSTALLATION            ║
echo     ╚═══════════════════════════════════════╝
echo.
echo     ⚙️  Full Installation - For Advanced Users
echo.
echo     📋 This will install:
echo        • Java 11 JDK
echo        • PostgreSQL Database  
echo        • Apache Tomcat Web Server
echo        • Apache Maven Build Tool
echo        • HMDM Server Application
echo.
echo     ⏱️  Time Required: 30-45 minutes
echo     💾 Disk Space: ~2GB downloads
echo     🌐 Internet: Required throughout installation
echo.
echo     ✅ Advantages:
echo        • Full control over components
echo        • Can customize configurations
echo        • Direct database access
echo.
echo     ⚠️  You MUST run as Administrator!
echo.
echo     [1] Start Full Installation Now
echo     [2] Back to Main Menu  
echo.
set /p choice="     Enter your choice (1-2): "

if "%choice%"=="1" (
    echo.
    echo     🚀 Starting full installation...
    if exist "installers\HMDM_Auto_Installer.bat" (
        echo     ✅ Found full installer, launching...
        start "HMDM Full Installer" cmd /c "installers\HMDM_Auto_Installer.bat"
    ) else (
        echo     ❌ Full installer not found!
        echo     Make sure you extracted the complete ZIP package.
    )
    pause
)
goto main_menu

:instructions
cls
echo.
echo     ╔═══════════════════════════════════════╗
echo     ║        DETAILED INSTRUCTIONS          ║
echo     ╚═══════════════════════════════════════╝
echo.
echo     📖 Step-by-Step Installation:
echo.
echo     BEFORE YOU START:
echo     ✅ Extract HMDM_Deployment_Package.zip
echo     ✅ Ensure you have Administrator rights
echo     ✅ Close other programs using port 8080
echo     ✅ Have stable internet connection
echo.
echo     INSTALLATION STEPS:
echo     1️⃣  Right-click on INSTALL_HMDM.bat
echo     2️⃣  Select "Run as administrator"
echo     3️⃣  Choose installation type:
echo         • Option 1: Docker (Recommended for most users)
echo         • Option 2: Full (Advanced users only)
echo     4️⃣  Wait for installation to complete
echo     5️⃣  Browser will open automatically to http://localhost:8080
echo.
echo     FIRST LOGIN:
echo     🔐 Username: admin
echo     🔐 Password: admin
echo     ⚠️  CHANGE THIS PASSWORD IMMEDIATELY!
echo.
echo     DAILY USE:
echo     🌐 Web Interface: http://localhost:8080
echo     🚀 Start HMDM: Use scripts in the 'scripts' folder
echo     🛑 Stop HMDM: docker stop hmdm (Docker) or shutdown scripts
echo.
echo     Press any key to return to main menu...
pause >nul
goto main_menu

:troubleshoot
cls
echo.
echo     ╔═══════════════════════════════════════╗
echo     ║           TROUBLESHOOTING             ║
echo     ╚═══════════════════════════════════════╝
echo.
echo     🔴 COMMON PROBLEMS AND SOLUTIONS:
echo.
echo     PROBLEM: "This script must be run as Administrator"
echo     💡 SOLUTION: Right-click BAT file → "Run as administrator"
echo.
echo     PROBLEM: "Port 8080 is already in use"  
echo     💡 SOLUTION: Restart computer or stop other web servers
echo.
echo     PROBLEM: "Docker failed to start"
echo     💡 SOLUTION: 
echo        • Restart computer
echo        • Start Docker Desktop manually from Start Menu
echo        • Try installation again
echo.
echo     PROBLEM: White page at http://localhost:8080
echo     💡 SOLUTION: 
echo        • Wait 2-3 more minutes (HMDM is still loading)
echo        • Refresh the browser page
echo        • Check Docker container is running: docker ps
echo.
echo     PROBLEM: "Can't connect" to localhost:8080
echo     💡 SOLUTION:
echo        • Check Docker Desktop is running
echo        • Run: docker start hmdm
echo        • Check Windows Firewall settings
echo.
echo     PROBLEM: Installation fails or hangs
echo     💡 SOLUTION:
echo        • Check internet connection
echo        • Temporarily disable antivirus
echo        • Run Windows Updates first
echo        • Try different installation option
echo.
echo     🆘 Still having problems?
echo        • Check logs in C:\hmdm\logs\ (full installation)
echo        • Run: docker logs hmdm (Docker installation)  
echo        • Review README.md for detailed troubleshooting
echo.
echo     Press any key to return to main menu...
pause >nul
goto main_menu

:requirements
cls
echo.
echo     ╔═══════════════════════════════════════╗
echo     ║         SYSTEM REQUIREMENTS           ║
echo     ╚═══════════════════════════════════════╝
echo.
echo     🖥️  OPERATING SYSTEM:
echo        • Windows 10 (version 1809 or later)
echo        • Windows 11 (any version)
echo        • Windows Server 2019 or 2022
echo.
echo     💾 MEMORY (RAM):
echo        • Minimum: 4GB RAM
echo        • Recommended: 8GB RAM  
echo        • Heavy usage: 16GB RAM
echo.
echo     💿 DISK SPACE:
echo        • Installation: 10GB free space
echo        • Docker images: ~2GB
echo        • Device data: 5GB+ (depends on usage)
echo        • Total recommended: 20GB free space
echo.
echo     🌐 NETWORK:
echo        • Internet connection (required for installation)
echo        • Port 8080 available (for web interface)
echo        • Port 5432 available (for database - full install only)
echo.
echo     👤 USER PERMISSIONS:
echo        • Administrator rights REQUIRED
echo        • Must be able to install software
echo        • Must be able to modify Windows services
echo.
echo     🔧 ADDITIONAL REQUIREMENTS:
echo        • Microsoft Visual C++ Redistributable (usually installed)
echo        • .NET Framework 4.8 or later (usually installed)
echo        • Windows Defender exclusions may be needed
echo.
echo     ⚡ PERFORMANCE NOTES:
echo        • SSD storage recommended for better performance
echo        • Multiple CPU cores help with device management
echo        • More RAM allows managing more devices
echo.
echo     Press any key to return to main menu...
pause >nul
goto main_menu

:exit
cls
echo.
echo     ╔═══════════════════════════════════════╗
echo     ║              THANK YOU!               ║
echo     ╚═══════════════════════════════════════╝
echo.
echo     🎯 QUICK REMINDER:
echo.
echo     TO START INSTALLATION:
echo     1. Right-click INSTALL_HMDM.bat
echo     2. "Run as administrator" 
echo     3. Choose Option 1 (Docker)
echo     4. Wait 15 minutes
echo     5. Go to http://localhost:8080
echo.
echo     🔐 Login: admin / admin
echo.
echo     Good luck with your HMDM deployment! 🚀
echo.
pause
exit

:end