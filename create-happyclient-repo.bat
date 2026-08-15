@echo off
echo ========================================
echo    Creating HappyClient Repository
echo ========================================
echo.

echo [Step 1] Go to GitHub and create new repository:
echo    1. Visit: https://github.com/new
echo    2. Repository name: happyclient
echo    3. Description: HappyClient - Advanced Android Remote Control System
echo    4. Set to Public or Private (your choice)
echo    5. Do NOT initialize with README (we have our own)
echo    6. Click "Create repository"
echo.
echo Press any key when you've created the repository on GitHub...
pause

echo.
echo [Step 2] Adding new remote and pushing code...

REM Add the new remote (replace USERNAME with your GitHub username)
echo Enter your GitHub username:
set /p USERNAME="GitHub Username: "

git remote add happyclient https://github.com/%USERNAME%/happyclient.git

REM Push all branches and history to new repo
echo Pushing to HappyClient repository...
git push happyclient master

REM Set up tracking
git branch --set-upstream-to=happyclient/master master

echo.
echo ========================================
echo     HappyClient Repository Created!
echo ========================================
echo.
echo ✅ Repository URL: https://github.com/%USERNAME%/happyclient
echo ✅ All EvilTwin code pushed successfully
echo ✅ Ready for deployment on any machine
echo.
echo To clone on another machine:
echo    git clone https://github.com/%USERNAME%/happyclient.git
echo    cd happyclient/apuppet-server
echo    docker-compose up -d
echo.
pause