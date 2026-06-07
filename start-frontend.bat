@echo off
setlocal EnableDelayedExpansion

title Campus Frontend
chcp 65001 >nul 2>&1

set "SCRIPT_DIR=%~dp0"
set "FRONTEND_DIR=%SCRIPT_DIR%frontend"

echo ============================================
echo   Starting Campus Frontend
echo ============================================
echo.

echo [INFO] Script directory: %SCRIPT_DIR%
echo [INFO] Frontend directory: %FRONTEND_DIR%
echo.

if not exist "%FRONTEND_DIR%\package.json" (
    echo [ERROR] package.json not found in frontend directory
    pause
    exit /b 1
)

echo [INFO] Installing dependencies...
call npm install --prefix "%FRONTEND_DIR%"
if errorlevel 1 (
    echo [ERROR] npm install failed
    pause
    exit /b 1
)

echo.
echo [INFO] Starting Vite dev server...
echo.

npm run dev --prefix "%FRONTEND_DIR%"

if errorlevel 1 (
    echo.
    echo [ERROR] Frontend startup failed
    pause
    exit /b 1
)