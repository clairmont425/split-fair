@echo off
setlocal enabledelayedexpansion
title Rent Split - Tunnel + QR Code
color 0A

echo ============================================
echo   Rent Split - Tunnel with QR Code
echo ============================================
echo.

cd /d "%~dp0"

:: ─── PATHS ──────────────────────────────────────────────────────────────────
set FLUTTER_EXE=D:\flutter\bin\flutter.bat
set NGROK_EXE=C:\Users\Nico Clairmont\AppData\Local\npm-cache\_npx\094a17e86d981b10\node_modules\ngrok\bin\ngrok.exe

:: ─── CHECK FOR NGROK AUTHTOKEN ──────────────────────────────────────────────
set TOKEN_FILE=%~dp0.ngrok-token

if exist "%TOKEN_FILE%" (
    set /p NGROK_TOKEN=<"%TOKEN_FILE%"
    echo [OK] ngrok authtoken found.
) else (
    echo [!] No ngrok authtoken found.
    echo.
    echo  Steps:
    echo   1. Go to https://dashboard.ngrok.com/get-started/your-authtoken
    echo   2. Sign up free, copy your authtoken
    echo   3. Paste it below
    echo.
    start https://dashboard.ngrok.com/get-started/your-authtoken
    echo.
    set /p NGROK_TOKEN="Paste your ngrok authtoken and press Enter: "
    if "!NGROK_TOKEN!"=="" (
        echo [ERROR] No token entered.
        pause & exit /b 1
    )
    echo !NGROK_TOKEN!> "%TOKEN_FILE%"
    echo [OK] Token saved.
    echo.
)

:: ─── CONFIGURE AUTHTOKEN ────────────────────────────────────────────────────
echo Configuring ngrok authtoken...
"%NGROK_EXE%" config add-authtoken !NGROK_TOKEN! >nul 2>&1
echo [OK] Done.

:: ─── KILL EXISTING NGROK + CLEAR PORT 8080 ──────────────────────────────────
echo.
echo Clearing existing ngrok and port 8080...
taskkill /f /im ngrok.exe >nul 2>&1
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8080 " 2^>nul') do (
    taskkill /F /PID %%a >nul 2>&1
)
echo [OK] Done.

:: ─── START FLUTTER IN SEPARATE WINDOW ───────────────────────────────────────
echo.
echo Starting Flutter web server on port 8080 (separate window)...
start "Rent Split - Flutter Dev" /d "%~dp0" cmd /k ""%FLUTTER_EXE%" run -d web-server --web-port 8080"

echo.
echo Waiting 30 seconds for Flutter to compile...
timeout /t 30 /nobreak > nul
echo [OK] Flutter should be up at http://localhost:8080

:: ─── START NGROK IN BACKGROUND ──────────────────────────────────────────────
echo.
echo Starting ngrok tunnel to port 8080...
start /min "ngrok" "%NGROK_EXE%" http 8080

:: ─── DISPLAY QR CODE ─────────────────────────────────────────────────────────
echo.
node "%~dp0tunnel-qr.js"

:: ─── KEEP ALIVE ──────────────────────────────────────────────────────────────
echo.
echo Press any key to STOP the ngrok tunnel and exit.
pause >nul

taskkill /f /im ngrok.exe >nul 2>&1
echo [OK] Tunnel stopped.

endlocal
