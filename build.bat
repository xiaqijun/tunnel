# Build scripts for Windows
@echo off
echo Building Tunnel Server and Client...

echo.
echo Installing dependencies...
go mod download
go mod tidy

echo.
echo Building server...
go build -ldflags="-s -w" -o bin\tunnel-server.exe .\cmd\server
if %errorlevel% neq 0 (
    echo Failed to build server
    exit /b %errorlevel%
)

echo.
echo Building client...
go build -ldflags="-s -w" -o bin\tunnel-client.exe .\cmd\client
if %errorlevel% neq 0 (
    echo Failed to build client
    exit /b %errorlevel%
)

echo.
echo Build completed successfully!
echo Server: bin\tunnel-server.exe
echo Client: bin\tunnel-client.exe
echo.
echo To run the server: bin\tunnel-server.exe -config config.yaml
echo To run the client: bin\tunnel-client.exe -config client-config.yaml

pause
