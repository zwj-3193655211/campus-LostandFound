@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Campus LostFound - One Click Start
chcp 65001 >nul 2>&1

set "BASE_DIR=%~dp0"
set "BACKEND_DIR=%BASE_DIR%backend"
set "FRONTEND_DIR=%BASE_DIR%frontend"
set "SCHEMA_SQL=%BASE_DIR%docs\sql\schema.sql"
set "DATA_SQL=%BASE_DIR%docs\sql\data.sql"
set "MIGRATION_SQL=%BASE_DIR%docs\sql\phase9_migration.sql"
set "DB_HOST=%DB_HOST%"
set "DB_PORT=%DB_PORT%"
set "DB_NAME=%DB_NAME%"
set "DB_USERNAME=%DB_USERNAME%"
set "DB_PASSWORD=%DB_PASSWORD%"
set "MYSQL_EXE="
set "JAVA_EXE="
set "MAVEN_EXE="
set "NODE_EXE="
set "NPM_EXE="
set "BACKEND_JAR=%BACKEND_DIR%\target\backend-1.0.0-SNAPSHOT-runnable.jar"

if "%DB_HOST%"=="" set "DB_HOST=localhost"
if "%DB_PORT%"=="" set "DB_PORT=3306"
if "%DB_NAME%"=="" set "DB_NAME=campus_lostfound"
if "%DB_USERNAME%"=="" set "DB_USERNAME=root"

echo.
echo ============================================
echo   Campus Lost and Found Platform
echo   One Click Start Script v2.0
echo ============================================
echo.

call :find_mysql
if errorlevel 1 goto :fail

call :find_command JAVA_EXE java.exe "%JAVA_HOME%\bin\java.exe"
if errorlevel 1 goto :fail
call :find_command MAVEN_EXE mvn.cmd
if errorlevel 1 goto :fail
call :find_command NODE_EXE node.exe
if errorlevel 1 goto :fail
call :find_command NPM_EXE npm.cmd
if errorlevel 1 goto :fail

echo [1/6] Environment check passed
echo   MySQL: %MYSQL_EXE%
echo   Java:  %JAVA_EXE%
echo   Maven: %MAVEN_EXE%
echo   Node:  %NODE_EXE%
echo   npm:   %NPM_EXE%
echo.

if "%DB_PASSWORD%"=="" (
    set /p "DB_PASSWORD=Enter MySQL password for %DB_USERNAME%: "
)

echo [2/6] Testing database connection
"%MYSQL_EXE%" -h %DB_HOST% -P %DB_PORT% -u %DB_USERNAME% -p"%DB_PASSWORD%" -e "SELECT 1" >nul 2>&1
if errorlevel 1 (
    echo   [ERROR] MySQL connection failed. Check username, password, or service status.
    goto :fail
)
echo   [OK] MySQL connection successful
echo.

echo [3/6] Initializing or migrating database
"%MYSQL_EXE%" -h %DB_HOST% -P %DB_PORT% -u %DB_USERNAME% -p"%DB_PASSWORD%" -N -B -e "SHOW DATABASES LIKE '%DB_NAME%'" > "%TEMP%\campus_db_exists.txt" 2>nul
set /p "DB_EXISTS=" < "%TEMP%\campus_db_exists.txt"
del /q "%TEMP%\campus_db_exists.txt" >nul 2>&1

if /I "!DB_EXISTS!"=="%DB_NAME%" (
    if exist "%MIGRATION_SQL%" (
        echo   [INFO] Existing database detected. Running migration script
        "%MYSQL_EXE%" -h %DB_HOST% -P %DB_PORT% -u %DB_USERNAME% -p"%DB_PASSWORD%" %DB_NAME% < "%MIGRATION_SQL%"
        if errorlevel 1 (
            echo   [ERROR] Migration failed
            goto :fail
        )
    ) else (
        echo   [WARN] No migration script found, assuming database is up to date
    )
) else (
    if exist "%SCHEMA_SQL%" (
        echo   [INFO] Database not found. Creating schema with schema.sql
        "%MYSQL_EXE%" -h %DB_HOST% -P %DB_PORT% -u %DB_USERNAME% -p"%DB_PASSWORD%" < "%SCHEMA_SQL%"
        if errorlevel 1 (
            echo   [ERROR] schema.sql failed
            goto :fail
        )
    ) else (
        echo   [ERROR] Schema script not found: %SCHEMA_SQL%
        goto :fail
    )
    if exist "%DATA_SQL%" (
        echo   [INFO] Loading initial data with data.sql
        "%MYSQL_EXE%" -h %DB_HOST% -P %DB_PORT% -u %DB_USERNAME% -p"%DB_PASSWORD%" < "%DATA_SQL%"
        if errorlevel 1 (
            echo   [WARN] data.sql failed, continuing anyway
        )
    )
)
echo   [OK] Database is ready
echo.

echo [INFO] Freeing ports 18090/3000 (kills any stale backend/frontend from prior runs)
call :kill_stale_port 18090
call :kill_stale_port 3000
echo.
echo [4/6] Building backend
pushd "%BACKEND_DIR%"
call "%MAVEN_EXE%" -Dmaven.test.skip=true clean package
if errorlevel 1 (
    popd
    echo   [ERROR] Backend build failed
    goto :fail
)
popd
if not exist "%BACKEND_JAR%" (
    echo   [ERROR] Backend runnable JAR not found: %BACKEND_JAR%
    goto :fail
)
echo   [OK] Backend build completed
echo.

echo [5/6] Preparing frontend dependencies
pushd "%FRONTEND_DIR%"
if not exist "%FRONTEND_DIR%\node_modules" (
    echo   [INFO] First run detected. Installing frontend dependencies...
    call "%NPM_EXE%" install
    if errorlevel 1 (
        popd
        echo   [ERROR] Frontend dependency installation failed
        goto :fail
    )
)
popd
echo   [OK] Frontend dependencies are ready
echo.

echo [6/6] Starting backend and frontend
set "DB_URL=jdbc:mysql://%DB_HOST%:%DB_PORT%/%DB_NAME%?useUnicode=true&characterEncoding=UTF-8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true"
start "Campus Backend" cmd /k ""%BASE_DIR%start-backend.bat""
start "Campus Frontend" cmd /k ""%BASE_DIR%start-frontend.bat""

echo.
echo ============================================
echo   Startup commands have been sent
echo   Frontend: http://localhost:3000
echo   Backend:  http://localhost:18090
echo   Docs:     http://localhost:18090/swagger-ui.html
echo.
echo   Test accounts:
echo   - superadmin / 123456
echo   - campusadmin / 123456
echo   - testuser / 123456
echo ============================================
echo.
call :pause_if_needed
exit /b 0

:find_mysql
for %%I in (mysql.exe) do if not "%%~$PATH:I"=="" set "MYSQL_EXE=%%~$PATH:I"
if defined MYSQL_EXE exit /b 0
for %%I in (
    "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe"
    "C:\Program Files\MySQL\MySQL Server 8.3\bin\mysql.exe"
    "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
    "D:\MySQL80\bin\mysql.exe"
    "D:\MySQL84\bin\mysql.exe"
    "C:\MySQL80\bin\mysql.exe"
    "C:\wamp64\bin\mysql\mysql8.0\bin\mysql.exe"
    "C:\xampp\mysql\bin\mysql.exe"
) do (
    if not defined MYSQL_EXE if exist %%~I set "MYSQL_EXE=%%~I"
)
if defined MYSQL_EXE exit /b 0
echo   [ERROR] mysql.exe not found. Install MySQL 8.0+ or add it to PATH.
exit /b 1

:find_command
set "%~1="
if not "%~3"=="" if exist "%~3" set "%~1=%~3"
if defined %~1 exit /b 0
for %%I in (%~2) do if not "%%~$PATH:I"=="" set "%~1=%%~$PATH:I"
if defined %~1 exit /b 0
echo   [ERROR] Required command not found: %~2
exit /b 1

:fail
echo.
echo ============================================
echo   One click startup failed
echo ============================================
echo.
call :pause_if_needed
exit /b 1

:pause_if_needed
if defined NO_PAUSE exit /b 0
pause
exit /b 0


:kill_stale_port
:: Usage: call :kill_stale_port <port>
:: Kills any process LISTENING on the given TCP port. Silent if the port is free.
set "KSP_PORT=%~1"
for /f "tokens=5" %%P in ('netstat -ano ^| findstr /R ":%KSP_PORT%.*LISTENING" 2^>nul') do (
    if %%P NEQ 0 (
        taskkill /PID %%P /F /T >nul 2>&1
        echo   [INFO] Killed stale PID %%P on :%KSP_PORT%
    )
)
exit /b 0
