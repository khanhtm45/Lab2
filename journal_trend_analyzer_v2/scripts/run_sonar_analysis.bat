@echo off
REM ========================================
REM SonarQube Analysis Script for Windows
REM ========================================

echo [1/5] Cleaning previous builds...
call flutter clean

echo.
echo [2/5] Getting Flutter dependencies...
call flutter pub get

echo.
echo [3/5] Running Flutter analyze...
call flutter analyze

echo.
echo [4/5] Running tests with coverage (optional)...
call flutter test --coverage || echo Tests failed or no tests found, continuing...

echo.
echo [5/5] Running SonarQube Scanner...
echo.
echo NOTE: Make sure SonarQube server is running at http://localhost:9000
echo       or set SONAR_HOST_URL and SONAR_TOKEN environment variables
echo.

REM Check if sonar-scanner is in PATH
where sonar-scanner >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: sonar-scanner not found in PATH
    echo Please install SonarQube Scanner or add it to PATH
    echo Download from: https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/
    pause
    exit /b 1
)

REM Run SonarQube Scanner
sonar-scanner

echo.
echo ========================================
echo Analysis complete!
echo View results at: http://localhost:9000/dashboard?id=journal_trend_analyzer_v2
echo ========================================
pause
