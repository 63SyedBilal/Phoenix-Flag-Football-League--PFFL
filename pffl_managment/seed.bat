@echo off
setlocal

REM PFFL Backend Seeding Script Runner for Windows
REM This script provides an easy way to run the seeding operations

echo 🌱 PFFL Backend Database Seeding Tool
echo ======================================

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js is not installed. Please install Node.js first.
    pause
    exit /b 1
)

REM Check if package.json exists
if not exist "package.json" (
    echo ❌ package.json not found. Please run this script from the correct directory.
    pause
    exit /b 1
)

REM Install dependencies if node_modules doesn't exist
if not exist "node_modules" (
    echo 📦 Installing dependencies...
    npm install
    if errorlevel 1 (
        echo ❌ Failed to install dependencies.
        pause
        exit /b 1
    )
)

REM Show menu
echo.
echo Select an option:
echo 1) Seed database with test users
echo 2) Cleanup test users
echo 3) Show help
echo 4) Exit
echo.

set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    echo 🌱 Seeding database with test users...
    npm run seed
) else if "%choice%"=="2" (
    echo 🧹 Cleaning up test users...
    set /p confirm="Are you sure you want to remove all test users? (y/N): "
    if /i "%confirm%"=="y" (
        npm run cleanup
    ) else if /i "%confirm%"=="yes" (
        npm run cleanup
    ) else (
        echo Cleanup cancelled.
    )
) else if "%choice%"=="3" (
    npm run help
) else if "%choice%"=="4" (
    echo 👋 Goodbye!
    exit /b 0
) else (
    echo ❌ Invalid option. Please choose 1-4.
    pause
    exit /b 1
)

echo.
echo ✅ Operation completed!
pause