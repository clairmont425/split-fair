/**
 * tunnel-lt.js
 * Self-contained Rent Split launcher:
 *  1. Starts Flutter web server on port 8080 (if not already running)
 *  2. Waits until Flutter is ready
 *  3. Starts Cloudflare Quick Tunnel (no auth, no password)
 *  4. Shows QR code + URL
 *
 * Usage: node tunnel-lt.js
 */
const { spawn } = require('child_process');
const { execSync } = require('child_process');
const http = require('http');
const path = require('path');

const PROJECT_DIR  = __dirname;
const FLUTTER_EXE  = 'D:\\flutter\\bin\\flutter.bat';
const CLOUDFLARED  = path.join(PROJECT_DIR, 'cloudflared.exe');
const PORT         = 8080;

// ── Helpers ──────────────────────────────────────────────────────────────────

function isPortOpen(port) {
  return new Promise(resolve => {
    const req = http.get({ host: 'localhost', port, path: '/', timeout: 2000 }, () => resolve(true));
    req.on('error', () => resolve(false));
    req.on('timeout', () => { req.destroy(); resolve(false); });
  });
}

function waitForPort(port, maxMs = 120000) {
  return new Promise(async (resolve, reject) => {
    const start = Date.now();
    while (Date.now() - start < maxMs) {
      if (await isPortOpen(port)) return resolve();
      await new Promise(r => setTimeout(r, 3000));
      process.stdout.write('.');
    }
    reject(new Error('Flutter did not start within ' + (maxMs/1000) + 's'));
  });
}

function showInfo(url) {
  console.log('\n============================================');
  console.log('  RENT SPLIT APP IS LIVE!');
  console.log('============================================');
  console.log('  ' + url);
  console.log('  QR code opened on your desktop.');
  console.log('  Press Ctrl+C to stop.');
  console.log('============================================\n');
}

function openQRImage(url) {
  const outPath = 'C:\\Users\\Nico Clairmont\\Desktop\\rent-split-qr.png';
  const qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=' + encodeURIComponent(url);
  // Use PowerShell Invoke-WebRequest — more reliable on Windows than Node https.get
  const psCmd = `powershell -NoProfile -Command "Invoke-WebRequest -Uri '${qrUrl}' -OutFile '${outPath}'; Start-Process '${outPath}'"`;
  try {
    execSync(psCmd, { timeout: 15000 });
    console.log('\n[OK] QR code image opened on your desktop.');
  } catch (e) {
    console.log('\n[!] QR image failed, open this URL on your phone:');
  }
  showInfo(url);
  setInterval(() => console.log('  Still live: ' + url), 60000);
}

function generateQR(url) {
  // Save URL to file so it can be retrieved anytime
  require('fs').writeFileSync(path.join(PROJECT_DIR, '.tunnel-url'), url, 'utf8');
  openQRImage(url);
}

// ── Step 0: Kill any stale cloudflared process ───────────────────────────────

function killStaleCloudflared() {
  try {
    execSync('taskkill /f /im cloudflared.exe >nul 2>&1', { shell: true });
    console.log('[OK] Killed stale cloudflared process.');
  } catch (_) {
    // not running — that's fine
  }
}

// ── Step 1: Start Flutter if not running ─────────────────────────────────────

async function main() {
  killStaleCloudflared();
  const flutterAlreadyUp = await isPortOpen(PORT);

  if (flutterAlreadyUp) {
    console.log('[OK] Flutter already running on port ' + PORT);
  } else {
    console.log('Starting Flutter web server...');
    const flutter = spawn(FLUTTER_EXE, ['run', '-d', 'web-server', '--web-port', String(PORT)], {
      cwd: PROJECT_DIR,
      stdio: ['ignore', 'pipe', 'pipe'],
      shell: false,
      detached: false,
    });

    flutter.stdout.on('data', d => {
      const line = d.toString();
      if (line.includes('localhost:' + PORT) || line.includes('Serving') || line.includes('running')) {
        process.stdout.write('\n  Flutter: ' + line.trim() + '\n');
      }
    });
    flutter.stderr.on('data', d => {
      const line = d.toString().trim();
      if (line && !line.includes('Waiting') && !line.includes('Debug')) {
        process.stdout.write('  ' + line + '\n');
      }
    });

    process.stdout.write('Waiting for Flutter to compile (this takes ~30-60s on first run)');
    try {
      await waitForPort(PORT, 120000);
      console.log('\n[OK] Flutter is up on port ' + PORT);
    } catch (e) {
      console.error('\n[ERR] ' + e.message);
      process.exit(1);
    }
  }

  // ── Step 2: Start Cloudflare Tunnel ────────────────────────────────────────

  console.log('\nStarting Cloudflare tunnel...\n');
  const cf = spawn(CLOUDFLARED, ['tunnel', '--url', 'http://localhost:' + PORT], {
    stdio: ['ignore', 'pipe', 'pipe']
  });

  let urlFound = false;
  function checkLine(line) {
    if (urlFound) return;
    const match = line.match(/https:\/\/[a-z0-9-]+\.trycloudflare\.com/i);
    if (match) { urlFound = true; generateQR(match[0]); }
  }

  cf.stdout.on('data', d => d.toString().split('\n').forEach(checkLine));
  cf.stderr.on('data', d => {
    d.toString().split('\n').forEach(line => {
      checkLine(line);
      if (!urlFound && line.includes('INF') && !line.includes('Request') && !line.includes('metrics')) {
        const clean = line.replace(/.*INF\s*/, '').replace(/\|/g,'').trim();
        if (clean && clean.length > 3) process.stdout.write('  ' + clean + '\n');
      }
    });
  });

  cf.on('close', code => { console.log('\n[!] Tunnel closed.'); process.exit(0); });
  process.on('SIGINT', () => { cf.kill(); process.exit(0); });
}

main().catch(e => { console.error('[ERR]', e.message); process.exit(1); });
