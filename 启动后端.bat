@echo off
setlocal EnableExtensions
chcp 65001 >nul 2>&1

set "BASE_DIR=%~dp0"
set "BACKEND_DIR=%BASE_DIR%backend"
set "MAVEN_EXE="
set "JAVA_EXE="
set "DB_HOST=%DB_HOST%"
set "DB_PORT=%DB_PORT%"
set "DB_NAME=%DB_NAME%"
set "DB_USERNAME=%DB_USERNAME%"
set "DB_PASSWORD=%DB_PASSWORD%"
set "BACKEND_JAR=%BACKEND_DIR%\target\backend-1.0.0-SNAPSHOT-runnable.jar"
set "BACKEND_JAR_FALLBACK=%BACKEND_DIR%\target\backend-1.0.0-SNAPSHOT.jar"

if "%DB_HOST%"=="" set "DB_HOST=localhost"
if "%DB_PORT%"=="" set "DB_PORT=3306"
if "%DB_NAME%"=="" set "DB_NAME=campus_lostfound"
if "%DB_USERNAME%"=="" set "DB_USERNAME=root"

if "%DB_PASSWORD%"=="" (
    set /p "DB_PASSWORD=Enter MySQL password for %DB_USERNAME%: "
)

for %%I in (mvn.cmd) do if not "%%~$PATH:I"=="" set "MAVEN_EXE=%%~$PATH:I"
for %%I in (java.exe) do if not "%%~$PATH:I"=="" set "JAVA_EXE=%%~$PATH:I"
if not defined JAVA_EXE if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" set "JAVA_EXE=%JAVA_HOME%\bin\java.exe"

if not defined MAVEN_EXE (
    echo [ERROR] Maven not found. Please install Maven 3.8+
    pause
    exit /b 1
)

if not defined JAVA_EXE (
    echo [ERROR] Java not found. Please install JDK 17+
    pause
    exit /b 1
)

pushd "%BACKEND_DIR%"
call "%MAVEN_EXE%" -DskipTests package
if errorlevel 1 (
    popd
    echo [ERROR] Backend build failed
    pause
    exit /b 1
)

if not exist "%BACKEND_JAR%" (
    if exist "%BACKEND_JAR_FALLBACK%" (
        set "BACKEND_JAR=%BACKEND_JAR_FALLBACK%"
    ) else (
        popd
        echo [ERROR] Runnable JAR not found: %BACKEND_JAR%
        pause
        exit /b 1
    )
)

set "DB_URL=jdbc:mysql://%DB_HOST%:%DB_PORT%/%DB_NAME%?useUnicode=true&characterEncoding=UTF-8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true"
echo [INFO] Starting backend service: http://localhost:8081
"%JAVA_EXE%" -jar "%BACKEND_JAR%"
popd
