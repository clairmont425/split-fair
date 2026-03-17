@echo off
setlocal enabledelayedexpansion
title Rent Split - Tunnel Mode
color 0A

echo ============================================
echo   Rent Split - Flutter Tunnel Launcher
echo ============================================
echo.

cd /d "%~dp0"

:: Path to Flutter and ngrok
set FLUTTER_EXE=D:\flutter\bin\flutter.bat
set NGROK_EXE=C:\Users\Nico Clairmont\AppData\Local\npm-cache\_npx\094a17e86d981b10\node_modules\ngrok\bin\ngrok.exe

:: ─── CHECK FOR NGROK AUTHTOKEN ──────────────────────────────────────────────
set TOKEN_FILE=%~dp0.ngrok-token

if exist "%TOKEN_FILE%" (
    set /p NGROK_TOKEN=<"%TOKEN_FILE%"
    echo [OK] ngrok authtoken found.
) else (
    echo [!] No ngrok authtoken detected. ngrok requires a FREE account.
    echo.
    echo  Steps:
    echo   1. Go to https://dashboard.ngrok.com/get-started/your-authtoken
    echo   2. Sign up for free (use Google)
    echo   3. Copy your authtoken from that page
    echo   4. Paste it below
    echo.
    echo Opening ngrok signup in your browser...
    start https://dashboard.ngrok.com/get-started/your-authtoken
    echo.
    set /p NGROK_TOKEN="Paste your ngrok authtoken and press Enter: "
    if "!NGROK_TOKEN!"=="" (
        echo [ERROR] No token entered. Cannot start tunnel without an authtoken.
        pause
        exit /b 1
    )
    echo !NGROK_TOKEN!> "%TOKEN_FILE%"
    echo [OK] Token saved to .ngrok-token
    echo.
)

:: ─── CONFIGURE AUTHTOKEN ────────────────────────────────────────────────────
echo Configuring ngrok authtoken...
"%NGROK_EXE%" config add-authtoken !NGROK_TOKEN!
echo [OK] Authtoken configured.

:: ─── LAUNCH FLUTTER WEB ON PORT 8080 ────────────────────────────────────────
echo.
echo Starting Flutter web server on port 8080...
start "Rent Split - Flutter" /d "%~dp0" cmd /k ""%FLUTTER_EXE%" run -d web-server --web-port 8080"

:: Wait for Flutter to compile and start (first run can take 30-60 seconds)
echo Waiting 30 seconds for Flutter to compile...
timeout /t 30 /nobreak > nul

:: ─── START NGROK TUNNEL ──────────────────────────────────────────────────────
echo.
echo Starting ngrok tunnel to port 8080...
echo Once connected, visit the URL shown below to access Rent Split.
echo.
"%NGROK_EXE%" http 8080

endlocal
pause
