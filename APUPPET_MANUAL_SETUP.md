# aPuppet Server - Manual Setup Guide

## 🚀 Complete Setup for New Machines

### Prerequisites Installation

#### 1. Install Docker Desktop
- **Download:** https://docker.com/products/docker-desktop/
- **Install:** Run installer as Administrator
- **Verify:** After installation, Docker should show in system tray
- **Test:** Open PowerShell/CMD and run: `docker --version`

#### 2. Install Git (Optional - for cloning)
- **Download:** https://git-scm.com/downloads
- **Alternative:** Download ZIP from GitHub directly

### Method 1: Using Our Automation Scripts

#### Windows (Recommended)
```powershell
# 1. Download the project files
git clone https://github.com/Shantelwayne/Eviltwin-Updated-.git
cd Eviltwin-Updated-

# 2. Use our automated scripts
# Double-click: CHECK_APUPPET_REQUIREMENTS.bat
# Then: START_APUPPET_SERVER.bat
```

### Method 2: Manual Docker Commands

#### Step 1: Prepare Files
```bash
# Clone or download the project
git clone https://github.com/Shantelwayne/Eviltwin-Updated-.git
cd Eviltwin-Updated-/apuppet-server
```

#### Step 2: Configure Server
```bash
# Edit config.yaml (required)
notepad config.yaml

# Set these values:
hostname: "localhost"              # For local testing
email: "admin@localhost.com"       # Admin email
```

#### Step 3: Start Services
```bash
# Start in foreground (see logs)
docker-compose up

# OR start in background (detached)
docker-compose up -d
```

#### Step 4: Verify Services
```bash
# Check running containers
docker-compose ps

# Check logs
docker-compose logs

# Test connectivity
curl http://localhost/web-admin/
```

### Method 3: Individual Container Setup

If docker-compose fails, you can run containers individually:

```bash
# 1. Create network
docker network create apuppet-network

# 2. Start Janus WebRTC server
docker run -d \
  --name apuppet-janus \
  --network apuppet-network \
  -p 8088:8088 \
  -p 8089:8089 \
  -p 8989:8989 \
  -p 10000-10500:10000-10500/udp \
  canyan/janus-gateway:latest

# 3. Start Nginx web server
docker run -d \
  --name apuppet-nginx \
  --network apuppet-network \
  -p 80:80 \
  -p 443:443 \
  -v "./web-admin:/usr/share/nginx/html" \
  nginx:alpine

# 4. Start Python dev server (optional)
docker run -d \
  --name apuppet-web \
  --network apuppet-network \
  -p 8080:8080 \
  -v "./web-admin:/app" \
  -w /app \
  python:3.9-alpine \
  python -m http.server 8080
```

## 🔄 Docker Desktop Behavior

### Automatic Startup
- **NO** - Docker Desktop does NOT automatically start your aPuppet containers
- **Containers stop** when Docker Desktop closes
- **Containers stop** when computer restarts
- **You must manually restart** containers after reboot

### Making Containers Auto-Start

#### Option 1: Restart Policy (Recommended)
```yaml
# In docker-compose.yml, add restart policy:
services:
  janus:
    restart: unless-stopped
  nginx:
    restart: unless-stopped
  web-server:
    restart: unless-stopped
```

#### Option 2: Docker Desktop Settings
- Open Docker Desktop → Settings → General
- Enable "Start Docker Desktop when you log in"
- Enable "Use Docker Compose V2"

#### Option 3: Windows Service (Advanced)
```bash
# Install Docker Desktop as Windows service
# This runs Docker even when not logged in
```

## 📊 Service Management Commands

### Starting Services
```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d janus

# Force recreate containers
docker-compose up -d --force-recreate
```

### Stopping Services
```bash
# Stop all services
docker-compose down

# Stop but keep data
docker-compose stop

# Stop specific service
docker-compose stop nginx
```

### Monitoring Services
```bash
# View all container status
docker-compose ps

# View logs (all services)
docker-compose logs

# View logs (specific service)
docker-compose logs janus

# Follow logs in real-time
docker-compose logs -f

# View resource usage
docker stats
```

### Updating Services
```bash
# Pull latest images
docker-compose pull

# Restart with new images
docker-compose down && docker-compose up -d

# Update specific service
docker-compose pull janus
docker-compose up -d janus
```

## 🌐 Network Access

### Local Access (Same Machine)
- **Web Interface:** http://localhost/web-admin/
- **Janus API:** http://localhost:8088
- **Dev Server:** http://localhost:8080

### Network Access (Other Devices)
- **Find your IP:** `ipconfig` (Windows) or `ifconfig` (Linux/Mac)
- **Access from other devices:** http://YOUR_IP_ADDRESS/web-admin/
- **Example:** http://192.168.1.100/web-admin/

### Firewall Configuration
```bash
# Windows Firewall (Run as Administrator)
netsh advfirewall firewall add rule name="aPuppet Web" dir=in action=allow protocol=TCP localport=80
netsh advfirewall firewall add rule name="aPuppet Janus" dir=in action=allow protocol=TCP localport=8088
netsh advfirewall firewall add rule name="aPuppet WebSocket" dir=in action=allow protocol=TCP localport=8989
netsh advfirewall firewall add rule name="aPuppet RTP" dir=in action=allow protocol=UDP localport=10000-10500
```

## 🛠️ Troubleshooting

### Common Issues

#### Port Conflicts
```bash
# Check what's using port 80
netstat -ano | findstr :80

# Kill process using port (Windows)
taskkill /PID <PID_NUMBER> /F

# Use different port
# Edit docker-compose.yml: "8080:80" instead of "80:80"
```

#### Docker Not Starting
```bash
# Restart Docker Desktop service
# Method 1: Restart Docker Desktop app
# Method 2: Services → Docker Desktop Service → Restart
# Method 3: Reboot computer
```

#### Containers Failing
```bash
# Check detailed logs
docker-compose logs

# Remove and recreate
docker-compose down
docker system prune -f
docker-compose up -d
```

#### Can't Access Web Interface
```bash
# Check container status
docker-compose ps

# Check if nginx is running
curl -I http://localhost

# Check firewall
# Temporarily disable Windows Defender Firewall for testing
```

## 📁 File Structure Required

```
apuppet-server/
├── docker-compose.yml          # Main orchestration file
├── config.yaml                 # Server configuration
├── web-admin/                  # Web interface files
│   ├── index.html             # Main interface
│   ├── js/                    # JavaScript files
│   ├── css/                   # Stylesheets
│   └── static/                # Images, icons
├── janus-config/              # Janus WebRTC config (optional)
└── nginx-config/              # Nginx config (optional)
```

## 🚀 Production Deployment

### Linux Server (Recommended)
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install docker.io docker-compose git
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Clone and start
git clone https://github.com/Shantelwayne/Eviltwin-Updated-.git
cd Eviltwin-Updated-/apuppet-server
sudo ./install.sh  # For production setup with SSL
```

### Windows Server
```powershell
# Install Docker Desktop for Windows Server
# Or use Docker Engine in server mode
# Same commands as desktop version
```

## 🔐 Security Considerations

### Development (localhost)
- ✅ Safe for local testing
- ✅ No external access by default
- ✅ No SSL required

### Production (internet access)
- ❗ **HTTPS required** (use SSL certificates)
- ❗ **Strong passwords** for sessions
- ❗ **Firewall rules** to restrict access
- ❗ **VPN access** recommended for corporate use

---

## 📞 Quick Help

**If you have issues:**
1. Check Docker Desktop is running
2. Run `CHECK_APUPPET_REQUIREMENTS.bat`
3. Check Windows Firewall settings
4. Verify port availability
5. Review container logs: `docker-compose logs`

**Need to restart everything:**
```bash
docker-compose down
docker system prune -f
docker-compose up -d
```

**Emergency reset:**
```bash
# This removes EVERYTHING Docker-related
docker system prune -a --volumes -f
# Then re-run setup
```