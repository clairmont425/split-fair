# ─── Split Fair Phone Tunnel ───────────────────────────────────────────────────
# Run this from the rent_split folder to test on your phone via QR code.
# Requirements: Flutter in PATH, Windows 10+ (OpenSSH built-in)

Set-Location $PSScriptRoot

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Split Fair - Phone Tunnel" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Launch Flutter web in a new window
Write-Host "[1/3] Starting Flutter web on port 8080..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", `
  "Set-Location '$PSScriptRoot'; flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080"

# 2. Wait for Flutter to compile and serve
Write-Host "[2/3] Waiting 20s for Flutter to compile..." -ForegroundColor Yellow
for ($i = 20; $i -gt 0; $i--) {
    Write-Host -NoNewline "`r    $i seconds remaining...   "
    Start-Sleep -Seconds 1
}
Write-Host ""

# 3. Open SSH tunnel — serveo.net gives a public URL, no install needed
Write-Host ""
Write-Host "[3/3] Opening tunnel via serveo.net..." -ForegroundColor Green
Write-Host ""
Write-Host "------------------------------------------" -ForegroundColor Cyan
Write-Host " Your public URL will appear below." -ForegroundColor White
Write-Host " Copy it and go to qrco.de to make a QR." -ForegroundColor Yellow
Write-Host " Scan that QR with your phone to open." -ForegroundColor Yellow
Write-Host "------------------------------------------" -ForegroundColor Cyan
Write-Host ""

# Open browser to qrco.de so it's ready to paste
Start-Process "https://qrco.de"

# Start the tunnel (Ctrl+C to stop)
ssh -o StrictHostKeyChecking=no -R 80:localhost:8080 serveo.net
