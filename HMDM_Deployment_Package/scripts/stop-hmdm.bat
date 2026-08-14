@echo off
echo Stopping HMDM services...
C:\tomcat9\bin\shutdown.bat
net stop postgresql
echo HMDM stopped.
pause
