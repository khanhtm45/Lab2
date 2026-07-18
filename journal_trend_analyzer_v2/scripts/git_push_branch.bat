@echo off
REM ========================================
REM Git Push to New Branch Script
REM ========================================

echo.
echo ========================================
echo Git Push to New Branch
echo ========================================
echo.

REM Check if we're in a git repository
git rev-parse --git-dir >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Not a git repository
    echo Please run this script from the project root directory
    pause
    exit /b 1
)

REM Get current branch
for /f "tokens=*" %%i in ('git branch --show-current') do set CURRENT_BRANCH=%%i
echo Current branch: %CURRENT_BRANCH%
echo.

REM Ask for new branch name
set /p BRANCH_NAME="Enter new branch name (e.g., feature/sonarqube-setup): "

if "%BRANCH_NAME%"=="" (
    echo ERROR: Branch name cannot be empty
    pause
    exit /b 1
)

echo.
echo ========================================
echo Creating and switching to branch: %BRANCH_NAME%
echo ========================================
git checkout -b %BRANCH_NAME%

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to create branch
    pause
    exit /b 1
)

echo.
echo ========================================
echo Checking git status...
echo ========================================
git status

echo.
echo ========================================
echo Adding all changes...
echo ========================================
git add .

echo.
echo ========================================
echo Current changes to be committed:
echo ========================================
git status --short

echo.
set /p CONTINUE="Do you want to continue with commit? (y/n): "
if /i not "%CONTINUE%"=="y" (
    echo Aborted by user
    pause
    exit /b 0
)

echo.
set /p COMMIT_MESSAGE="Enter commit message (e.g., feat: Add SonarQube configuration): "

if "%COMMIT_MESSAGE%"=="" (
    set COMMIT_MESSAGE=feat: Update project files
    echo Using default message: %COMMIT_MESSAGE%
)

echo.
echo ========================================
echo Committing changes...
echo ========================================
git commit -m "%COMMIT_MESSAGE%"

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to commit
    pause
    exit /b 1
)

echo.
echo ========================================
echo Pushing to remote branch: %BRANCH_NAME%
echo ========================================
git push -u origin %BRANCH_NAME%

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to push to remote
    pause
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS!
echo ========================================
echo.
echo Branch created: %BRANCH_NAME%
echo Changes committed and pushed!
echo.
echo Next steps:
echo 1. Go to GitHub repository
echo 2. Click "Compare & pull request" button
echo 3. Review changes and create Pull Request
echo.
echo GitHub URL: https://github.com/your-username/your-repo
echo.
pause
