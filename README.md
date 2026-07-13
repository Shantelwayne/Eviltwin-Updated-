# Headwind MDM — Research Fork

A hardened, security-improved fork of [Headwind MDM](https://h-mdm.com) — an open-source Mobile Device Management platform for Android devices.

This fork was created for **research and testing purposes on regulated, owned devices only**. It contains a series of security and code quality fixes applied on top of the upstream codebase.

---

## Repository Structure

```
├── hmdm-android-master/   # Android MDM client (launcher/agent)
└── hmdm-server-master/    # Java web server (command & control backend)
```

---

## What is Headwind MDM?

Headwind MDM is a full-featured open-source MDM system consisting of two components:

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Android Client | Java / Android SDK | Runs on managed devices as the home launcher. Syncs policy, installs/uninstalls apps, enforces restrictions, reports telemetry. |
| Web Server | Java EE / Tomcat / PostgreSQL | Administration panel. Pushes configuration, commands, and app updates to enrolled devices. |

---

## Security & Code Fixes Applied (This Fork)

The following issues from the upstream codebase have been resolved:

### Critical Security
| # | File | Fix |
|---|------|-----|
| 1 | `UnsafeOkHttpClient.java` | Added hard runtime guard — throws `IllegalStateException` if called in a release build. SSL protocol updated from deprecated `SSL` to `TLS`. |
| 2 | `PushNotificationProcessor.java` | Remote shell execution now validates against a two-layer security check: injection pattern blocklist (`;`, `&&`, `\|`, backtick, `$(`, etc.) and a command prefix allowlist (`am`, `pm`, `settings`, `chmod`, etc.). |
| 3 | `AndroidManifest.xml` + `network_security_config.xml` | Removed global `usesCleartextTraffic=true`. Network security config updated to disable cleartext globally and remove user-installed CA trust. |

### Crash Fixes
| # | File | Fix |
|---|------|-----|
| 4 | `PushNotificationProcessor.java` | `File.listFiles()` can return `null` — added null checks in `deleteRecursive()` and `purgeDir()` to prevent `NullPointerException`. |

### Memory & Lifecycle
| # | File | Fix |
|---|------|-----|
| 5 | `SettingsHelper.java` | Singleton now stores `applicationContext` instead of whatever context was passed in, eliminating Activity/Service memory leaks. |

### Deprecated API Replacements
| # | File | Fix |
|---|------|-----|
| 6 | `ConfigUpdater.java` | All 6 deprecated `AsyncTask` usages replaced with `ExecutorService` + `Handler`. |
| 7 | `ConfigUpdater.java` | Both `getActiveNetworkInfo()` calls replaced with `NetworkCapabilities` API (API 23+ with pre-23 fallback). |

### Build & Dependencies
| # | File | Fix |
|---|------|-----|
| 8 | `app/build.gradle` (root + app) | Replaced shutdown `jcenter()` repository with `google()` + `mavenCentral()`. |
| 9 | `app/build.gradle` | Updated `appcompat` → `1.7.0`, `recyclerview` → `1.3.2`, `material` → `1.12.0`, `localbroadcastmanager` → `1.1.0`, `picasso` → `2.8`. |
| 10 | `app/build.gradle` + `proguard-rules.pro` | Enabled R8 shrinking (`minifyEnabled true`, `shrinkResources true`) for release builds. Added comprehensive ProGuard keep rules for Jackson, Retrofit, AIDL, WorkManager, Paho MQTT, ZXing, DataBinding, JAXB. |

### Server-side
| # | File | Fix |
|---|------|-----|
| 11 | `cpu_monitor.sh` | Fixed missing `$` on variable `LAST_RESTART_TIME` — restart throttle was always broken. |

---

## Requirements

### Android Client
- Android Studio (Hedgehog or later recommended)
- Android SDK API 26+ (minSdk), API 34 (targetSdk)
- Java 8

### Web Server
- Ubuntu 22.04 LTS (recommended) — **or** Docker Desktop on Windows
- Java 8 JDK
- Apache Tomcat 9
- PostgreSQL 12+
- Maven 3.6+
- `aapt` (Android Asset Packaging Tool)

---

## Building & Running

### Android Client

1. Open `hmdm-android-master/hmdm-android-master` in Android Studio
2. Configure your server URL in `app/build.gradle`:
   ```gradle
   buildConfigField("String", "BASE_URL", "\"https://your-server.com\"")
   ```
3. Build the APK:
   ```bash
   ./gradlew assembleOpensourceRelease
   ```
4. Find the output at `app/build/outputs/apk/opensource/release/`

To set device owner (required for silent install/uninstall):
```bash
adb shell dpm set-device-owner com.hmdm.launcher/.AdminReceiver
```

### Web Server (Linux / WSL2 / Ubuntu)

```bash
# 1. Install dependencies
sudo apt install git aapt tomcat9 maven postgresql

# 2. Build
cd hmdm-server-master/hmdm-server-master
mvn install

# 3. Run interactive installer (as root)
sudo ./hmdm_install.sh
```

### Web Server (Windows via Docker)

```bash
docker run -p 8080:8080 headwindmdm/hmdm
```

Then open `http://localhost:8080` — default credentials: `admin` / `admin`.

---

## Configuration Reference (Android Client)

Key `build.gradle` fields:

| Field | Default | Description |
|-------|---------|-------------|
| `BASE_URL` | `https://app.h-mdm.com` | MDM server URL |
| `SECONDARY_BASE_URL` | same | Fallback server URL |
| `DEVICE_ID_CHOICE` | `user` | How device ID is set: `user`, `imei`, `serial`, `mac` |
| `ENABLE_PUSH` | `true` | Enable MQTT/long-polling push notifications |
| `MQTT_PORT` | `31000` | MQTT port for push |
| `REQUEST_SIGNATURE` | `changeme-...` | **Change this** — shared secret for request signing |
| `CHECK_SIGNATURE` | `false` | Enable server signature verification (MITM protection) |
| `TRUST_ANY_CERTIFICATE` | `false` | Trust self-signed certs — **debug only**, blocked in release builds |
| `SYSTEM_PRIVILEGES` | `false` | Enable if app is signed with system keys |

---

## Remote Command Security (Shell Allowlist)

Remote shell commands sent via push messages are validated before execution. Only these command prefixes are permitted:

```
am, pm, settings, setprop, input, svc, chmod, wm, dumpsys, logcat
```

The following injection patterns are always blocked regardless of prefix:

```
;  &&  ||  |  `  $(  ${  >  <  \n  \r
```

To modify the allowlist, edit `SHELL_COMMAND_ALLOWLIST` and `SHELL_INJECTION_PATTERNS` in `Const.java`.

---

## License

Licensed under the [Apache License 2.0](LICENSE).

Original project: [Headwind MDM](https://github.com/h-mdm/hmdm-server) by Headwind Solutions LLC.

This fork contains modifications for research and security hardening purposes. All modifications are released under the same Apache 2.0 license.

---

## Disclaimer

This software is intended for use on **devices you own or have explicit written authorization to manage**. Deploying MDM software on devices without the knowledge and consent of the device owner may be illegal in your jurisdiction. The authors of this fork accept no liability for misuse.
