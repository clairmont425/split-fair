# Split Fair — Quick Reference

## Tunnel / Phone Preview
- **"start rent tunnel"** → Claude launches tunnel + QR on desktop
- App runs at whatever `trycloudflare.com` URL is generated
- QR saves to `Desktop/rent-split-qr.png` automatically
- Tunnel stays live until the CMD window is closed

## Hot Reload (while tunnel is running)
- In the Flutter CMD window: press **`r`** to hot reload (instant UI changes)
- Press **`R`** to hot restart (clears state)
- Press **`q`** to quit Flutter

## Key Files
| What | Where |
|------|-------|
| Screens | `lib/screens/` |
| State / IAP | `lib/models/app_state.dart` |
| Scoring algorithm | `lib/models/room.dart` |
| Theme / colors | `lib/theme/app_theme.dart` |
| IAP product IDs | `lib/models/iap_service.dart` |
| Assets (images) | `assets/images/` |

## IAP Product IDs (must match store exactly)
- `split_fair_pdf_export` — PDF Export ($1.99)
- `split_fair_saved_configs` — Saved Configs ($1.99)

## Build Commands
```bash
# Android release APK
flutter build apk --release

# iOS release (requires Mac)
flutter build ipa --release

# Web (for tunnel testing)
flutter run -d web-server --web-port 8080
```

## App Store Info
- App name: **Split Fair**
- Bundle ID: set in Xcode / build.gradle
- Android label: `Split Fair` (AndroidManifest.xml ✓)
