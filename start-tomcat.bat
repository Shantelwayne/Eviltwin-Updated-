@echo off
cd /d "C:\tomcat9\bin"
call startup.bat
echo Tomcat started. Waiting for application to initialize...
timeout /t 30 /nobreak > nul
echo Application should be initialized now.