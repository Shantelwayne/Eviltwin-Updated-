# HMDM Deployment Package

This package contains everything needed to deploy HMDM (Headwind Mobile Device Management) on Windows machines.

## Installation Options

### Option 1: Docker Installation (Recommended)
- **File:** `installers\HMDM_Docker_Installer.bat`
- **Requirements:** Windows 10+ with Administrator rights
- **Time:** 15 minutes
- **Advantages:** No complex setup, works consistently

### Option 2: Full Installation
- **File:** `installers\HMDM_Auto_Installer.bat`
- **Requirements:** Windows 10+ with Administrator rights
- **Time:** 30-45 minutes
- **Advantages:** Full control, customizable

## Usage

1. Extract this package to a folder
2. Right-click your chosen installer and "Run as administrator"
3. Follow the prompts
4. Access HMDM at http://localhost:8080 (admin/admin)

## Management Scripts

- `scripts\start-hmdm.bat` - Start HMDM services
- `scripts\stop-hmdm.bat` - Stop HMDM services
- `scripts\start-hmdm-docker.bat` - Start Docker version

## Configuration Files

- `config\tomcat-context.xml` - Tomcat configuration template
- `config\setup-database.sql` - PostgreSQL database setup
- `config\log4j-hmdm.xml` - Logging configuration
