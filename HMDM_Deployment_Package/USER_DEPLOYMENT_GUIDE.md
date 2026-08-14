# 🚀 HMDM Deployment Guide for New Machines

## 📋 What You Received
You should have received: **`HMDM_Deployment_Package.zip`** file

## 🎯 Quick Start (5 Steps)

### **Step 1: Download and Extract** 📁
1. **Download** the `HMDM_Deployment_Package.zip` file to your Windows machine
2. **Create a folder** on your Desktop called `HMDM_Install`
3. **Extract** the ZIP file contents into this folder
4. You should now see these files:
   ```
   HMDM_Install/
   ├── INSTALL_HMDM.bat          ← START HERE
   ├── README.md
   ├── installers/
   ├── scripts/
   ├── config/
   └── docs/
   ```

### **Step 2: Check System Requirements** ✅
- **Operating System:** Windows 10 or Windows 11
- **RAM:** 4GB minimum (8GB recommended)
- **Disk Space:** 10GB free space
- **Internet:** Required for downloads
- **Admin Rights:** You must be able to "Run as administrator"

### **Step 3: Run the Installer** 🏃‍♂️
1. **Right-click** on `INSTALL_HMDM.bat`
2. **Select** "Run as administrator"
3. **Choose Option 1** (Docker Installation) - **RECOMMENDED** ⭐
   - Fastest and most reliable
   - Ready in 10-15 minutes
   - No complex setup required

### **Step 4: Wait for Installation** ⏱️
- The installer will:
  - Download and install Docker (if needed)
  - Download HMDM container (~500MB)
  - Set up the database automatically
  - Configure everything for you
- **Total time:** 10-15 minutes on first run

### **Step 5: Access HMDM** 🌐
1. When installation completes, your browser will open automatically
2. **Navigate to:** http://localhost:8080
3. **Login with:**
   - **Username:** `admin`
   - **Password:** `admin`
4. **Success!** 🎉 You now have HMDM running

---

## 📖 Detailed Instructions

### **Option A: Docker Installation (Recommended)** 🐳

**Best for:** Most users, quickest setup, least problems

1. Extract the package
2. Right-click `INSTALL_HMDM.bat` → "Run as administrator"
3. Choose **Option 1**
4. Wait 15 minutes
5. Access http://localhost:8080

**Advantages:**
- ✅ Everything included in one container
- ✅ No complex configuration needed
- ✅ Easy to update and backup
- ✅ Works the same on every machine

### **Option B: Full Installation** ⚙️

**Best for:** Advanced users who want full control

1. Extract the package
2. Right-click `INSTALL_HMDM.bat` → "Run as administrator"  
3. Choose **Option 2**
4. Wait 30-45 minutes (downloads Java, PostgreSQL, Tomcat, etc.)
5. Access http://localhost:8080

**Advantages:**
- ✅ Full control over all components
- ✅ Can customize configurations
- ✅ Direct access to database and files

---

## 🛠️ After Installation

### **Daily Usage:**
- **Start HMDM:** Double-click `scripts/start-hmdm-docker.bat`
- **Access Web:** http://localhost:8080
- **Login:** admin / admin (change this!)

### **Management:**
- **Stop HMDM:** `docker stop hmdm`
- **Start HMDM:** `docker start hmdm`
- **View Logs:** `docker logs hmdm`
- **Update HMDM:** Re-run the installer

### **Change Default Password:**
1. Login as admin/admin
2. Go to Settings → Users
3. Edit admin user and set new password

---

## ❓ Troubleshooting

### **Common Issues:**

**🔴 "This script must be run as Administrator"**
- **Fix:** Right-click the BAT file and select "Run as administrator"

**🔴 "Port 8080 is already in use"**
- **Fix:** Stop other programs using port 8080, or restart your computer

**🔴 "Docker failed to start"**
- **Fix:** Restart your computer and try again
- **Or:** Go to Start Menu → Docker Desktop → Start manually

**🔴 "White page" or "Loading..." at http://localhost:8080**
- **Fix:** Wait 2-3 more minutes, HMDM is still starting up
- **Or:** Refresh the page

**🔴 "Can't connect" to http://localhost:8080**
- **Check:** Is Docker running? Open Docker Desktop from Start Menu
- **Check:** Run `docker ps` in Command Prompt - should show "hmdm" container

### **Getting Help:**
1. Check `docs/INSTALLATION.md` for detailed troubleshooting
2. View logs in `C:\hmdm\logs\` (full installation)
3. Run `docker logs hmdm` (Docker installation)

---

## 🔐 Security Notes

### **After Installation:**
1. **Change default password** immediately (admin/admin)
2. **Set up HTTPS** for production use
3. **Configure firewall** if accessing from other computers
4. **Regular backups** of your device data

### **Network Access:**
- **Local only:** http://localhost:8080 (default)
- **Network access:** Replace `localhost` with your computer's IP address
- **Internet access:** Requires additional firewall and security configuration

---

## 📞 Support Information

### **What is HMDM?**
HMDM (Headwind Mobile Device Management) is an open-source system for managing Android devices remotely. You can:
- Install/uninstall apps on devices
- Configure device settings
- Track device location
- Send messages to devices  
- Create device groups and policies

### **System Requirements:**
- **Minimum:** Windows 10, 4GB RAM, 10GB disk space
- **Recommended:** Windows 11, 8GB RAM, 20GB disk space  
- **Network:** Internet connection for downloads and updates

### **File Locations:**
- **Docker:** All data in Docker container
- **Full Install:** 
  - HMDM files: `C:\hmdm\`
  - Tomcat: `C:\tomcat9\`
  - Database: PostgreSQL service

---

**🎯 Remember:** Choose **Option 1 (Docker)** for the easiest experience!