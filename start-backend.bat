@echo off
setlocal EnableDelayedExpansion

title Campus Backend
chcp 65001 >nul 2>&1

set "BASE_DIR=%~dp0"
set "BACKEND_DIR=%BASE_DIR%backend"
set "DB_HOST=%DB_HOST%"
set "DB_PORT=%DB_PORT%"
set "DB_NAME=%DB_NAME%"
set "DB_USERNAME=%DB_USERNAME%"
set "DB_PASSWORD=%DB_PASSWORD%"

if "%DB_HOST%"=="" set "DB_HOST=localhost"
if "%DB_PORT%"=="" set "DB_PORT=3306"
if "%DB_NAME%"=="" set "DB_NAME=campus_lostfound"
if "%DB_USERNAME%"=="" set "DB_USERNAME=root"

echo ============================================
echo   Starting Campus Backend
echo ============================================
echo.

cd /d "%BACKEND_DIR%"

echo [INFO] Starting Spring Boot application...
echo [INFO] Database: jdbc:mysql://%DB_HOST%:%DB_PORT%/%DB_NAME%
echo.

mvn spring-boot:run

if errorlevel 1 (
    echo.
    echo [ERROR] Backend startup failed
    pause
    exit /b 1
)