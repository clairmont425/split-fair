@echo off
setlocal enabledelayedexpansion
title Rent Split - Restart Tunnel + New QR
color 0A

cd /d "%~dp0"

set NGROK_EXE=C:\Users\Nico Clairmont\AppData\Local\npm-cache\_npx\094a17e86d981b10\node_modules\ngrok\bin\ngrok.exe
set TOKEN_FILE=%~dp0.ngrok-token

echo ============================================
echo   Rent Split - Restart Tunnel
echo ============================================
echo.

:: ─── KILL OLD NGROK ─────────────────────────────────────────────────────────
echo Killing existing ngrok session...
taskkill /f /im ngrok.exe >nul 2>&1
timeout /t 2 /nobreak >nul
echo [OK] Old tunnel cleared.

:: ─── RE-APPLY AUTHTOKEN (in case config was lost) ───────────────────────────
if exist "%TOKEN_FILE%" (
    set /p NGROK_TOKEN=<"%TOKEN_FILE%"
    "%NGROK_EXE%" config add-authtoken !NGROK_TOKEN! >nul 2>&1
    echo [OK] Authtoken re-applied.
) else (
    echo [!] No .ngrok-token file found — run start-tunnel-rent.bat first.
    pause & exit /b 1
)

:: ─── VERIFY FLUTTER IS UP ───────────────────────────────────────────────────
echo.
echo Checking Flutter is still live on port 8080...
curl -s -o nul -w "HTTP %%{http_code}" http://localhost:8080 2>nul | findstr /C:"200" /C:"304" >nul
if errorlevel 1 (
    echo [!] Flutter doesn't seem to be responding on :8080.
    echo     Start flutter run first, then re-run this script.
    pause & exit /b 1
)
echo [OK] Flutter is up on port 8080.

:: ─── START FRESH NGROK TUNNEL ───────────────────────────────────────────────
echo.
echo Starting fresh ngrok tunnel on port 8080...
start /min "ngrok-rent" "%NGROK_EXE%" http 8080

:: ─── WAIT FOR NGROK API ─────────────────────────────────────────────────────
echo Waiting for ngrok API to come up...
timeout /t 4 /nobreak >nul

:: ─── GENERATE QR ────────────────────────────────────────────────────────────
echo.
node "%~dp0tunnel-qr.js"

echo.
echo Press any key to kill the tunnel and exit.
pause >nul
taskkill /f /im ngrok.exe >nul 2>&1
echo [OK] Tunnel stopped.

endlocal
