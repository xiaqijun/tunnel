@echo off
echo ======================================
echo   Tunnel - Quick Start Script
echo ======================================
echo.

REM Check if binaries exist
if not exist "bin\tunnel-server.exe" (
    echo [INFO] Binaries not found, building...
    call build.bat
    echo.
)

REM Ask user what to run
echo What would you like to do?
echo 1. Run Server
echo 2. Run Client
echo 3. Run Both (Server + Client)
echo 4. Build Only
echo 5. Run Tests
echo 6. Exit
echo.

set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto server
if "%choice%"=="2" goto client
if "%choice%"=="3" goto both
if "%choice%"=="4" goto build
if "%choice%"=="5" goto test
if "%choice%"=="6" goto end

:server
echo.
echo [INFO] Starting Tunnel Server...
echo [INFO] Web UI will be available at: http://localhost:8080
echo [INFO] Press Ctrl+C to stop
echo.
bin\tunnel-server.exe -config config.yaml
goto end

:client
echo.
echo [INFO] Starting Tunnel Client...
echo [INFO] Press Ctrl+C to stop
echo.
bin\tunnel-client.exe -config client-config.yaml
goto end

:both
echo.
echo [INFO] Starting Server and Client...
echo.
start "Tunnel Server" bin\tunnel-server.exe -config config.yaml
timeout /t 3 /nobreak > nul
start "Tunnel Client" bin\tunnel-client.exe -config client-config.yaml
echo.
echo [INFO] Server and Client are running in separate windows
echo [INFO] Web UI: http://localhost:8080
echo.
pause
goto end

:build
echo.
echo [INFO] Building...
call build.bat
goto end

:test
echo.
echo [INFO] Running tests...
go test -v ./...
echo.
pause
goto end

:end
echo.
echo Goodbye!
