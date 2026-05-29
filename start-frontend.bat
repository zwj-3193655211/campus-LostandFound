@echo off
setlocal EnableExtensions
chcp 65001 >nul 2>&1

set "BASE_DIR=%~dp0"
set "FRONTEND_DIR=%BASE_DIR%frontend"
set "NPM_EXE="

for %%I in (npm.cmd) do if not "%%~$PATH:I"=="" set "NPM_EXE=%%~$PATH:I"

if not defined NPM_EXE (
    echo [ERROR] npm not found. Please install Node.js 16+
    pause
    exit /b 1
)

pushd "%FRONTEND_DIR%"
if not exist "%FRONTEND_DIR%\node_modules" (
    echo [INFO] First run detected. Installing frontend dependencies...
    call "%NPM_EXE%" install
    if errorlevel 1 (
        popd
        echo [ERROR] Frontend dependency installation failed
        pause
        exit /b 1
    )
)

echo [INFO] Starting frontend dev server: http://localhost:3000
call "%NPM_EXE%" run dev -- --host 0.0.0.0
popd
