@echo off
echo Starting HMDM services...
net start postgresql
C:\tomcat9\bin\startup.bat
echo HMDM started. Access: http://localhost:8080
pause
