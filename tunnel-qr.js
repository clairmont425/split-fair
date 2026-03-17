/**
 * tunnel-qr.js
 * Fetches the ngrok public URL and displays a QR code + shareable link.
 * Run AFTER ngrok has started (it hits http://localhost:4040/api/tunnels).
 */
const http = require('http');
const { execSync } = require('child_process');

function showInfo(url) {
  console.log('\n============================================');
  console.log('  RENT SPLIT APP IS LIVE!');
  console.log('============================================');
  console.log('');
  console.log('  Open on your phone / share with testers:');
  console.log('  ' + url);
  console.log('');
  console.log('  ngrok dashboard: http://localhost:4040');
  console.log('============================================\n');
}

function generateQR(url) {
  // Method 1: local node_modules (most reliable)
  try {
    const qrt = require('./node_modules/qrcode-terminal');
    console.log('\nScan to open on your phone:\n');
    qrt.generate(url, { small: true }, function (code) {
      console.log(code);
      showInfo(url);
    });
    return;
  } catch (_) {}

  // Method 2: npx qrcode-terminal (downloads on demand)
  try {
    console.log('\nGenerating QR code (downloading qrcode-terminal via npx)...\n');
    execSync(`npx --yes qrcode-terminal "${url}"`, { stdio: 'inherit' });
    showInfo(url);
    return;
  } catch (_) {}

  // Method 3: fallback — just show the URL
  console.log('\n[!] QR generator unavailable. Install with: npm install -g qrcode-terminal\n');
  showInfo(url);
}

// Retry a few times to give ngrok time to start
let attempts = 0;
const maxAttempts = 6;

function fetchTunnels() {
  http.get('http://localhost:4040/api/tunnels', (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      try {
        const tunnels = JSON.parse(data).tunnels || [];
        const tunnel =
          tunnels.find(t => t.proto === 'https') ||
          tunnels.find(t => t.proto === 'http') ||
          tunnels[0];

        if (tunnel) {
          generateQR(tunnel.public_url);
        } else {
          retry('No tunnels active yet');
        }
      } catch (e) {
        retry('Parse error: ' + e.message);
      }
    });
  }).on('error', (e) => {
    retry('API not ready: ' + e.message);
  });
}

function retry(reason) {
  attempts++;
  if (attempts < maxAttempts) {
    process.stdout.write(`\r[${attempts}/${maxAttempts}] Waiting for ngrok... (${reason})`);
    setTimeout(fetchTunnels, 3000);
  } else {
    console.log('\n[!] Could not reach ngrok API after ' + maxAttempts + ' attempts.');
    console.log('Check http://localhost:4040 manually.\n');
  }
}

fetchTunnels();
