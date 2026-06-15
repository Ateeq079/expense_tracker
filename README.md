# Expense Tracker

A clean, offline expense tracker built with Flutter. Add income and expenses,
see category-wise breakdowns with pie charts, and export everything to CSV. No
account, no login, no network — all data lives on the device.

## Features

- **Add income & expenses** with category, date, optional title and note.
- **Category-wise breakdown** with percentages and entry counts.
- **Pie chart & summaries** per period (This Month / Last Month / This Year / All Time).
- **CSV export** via the system share sheet (UTF‑8 BOM, opens cleanly in Excel/Sheets).
- **Multi-currency display** (USD default; 10 currencies) and light/dark/system theme.
- **Swipe to delete**, edit on tap, and a one-tap "clear all data".
- **100% offline** — SQLite on device, no permissions requested.

## Architecture

```
lib/
  core/            theme, currency model, money/date formatters
  data/
    models/        ExpenseTransaction, Category, TransactionType
    db/            AppDatabase (sqflite + migrations)
    repositories/  TransactionRepository (all SQL lives here)
  state/           Riverpod controllers + pure analytics (summarize)
  services/        CsvExportService
  features/        dashboard, stats, add_edit, settings, home shell, shared widgets
```

- **State management:** Riverpod 3 (`Notifier` / `AsyncNotifier`).
- **Persistence:** sqflite (indexed on date) for transactions; SharedPreferences for settings.
- **Charts:** fl_chart.
- The aggregation logic (`summarize`) is a pure function, unit-tested independently of the UI.

## Getting started

```bash
flutter pub get
flutter run                  # debug on a connected device/emulator
flutter test                 # run the unit + widget test suite
flutter analyze              # static analysis (lints clean)
```

## Building for release / Play Store

### Signing

The release build is signed with an **upload key** at `android/upload-keystore.jks`,
referenced by `android/key.properties`. Both are git-ignored.

> ⚠️ **Before publishing:** the keystore in this repo was generated for local
> builds. Generate your own and keep it (and its passwords) safe — losing the
> upload key means you can't push updates. With **Play App Signing** enabled
> (recommended), Google manages the actual app-signing key and this is your
> upload key.

Regenerate your own:

```bash
keytool -genkeypair -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then update `android/key.properties` with your passwords/alias.

### Build artifacts

```bash
flutter build appbundle --release   # -> build/app/outputs/bundle/release/app-release.aab  (upload this to Play)
flutter build apk --release         # -> build/app/outputs/flutter-apk/app-release.apk     (sideload/testing)
```

The release build enables R8 minification and resource shrinking.

### Bumping the version

Edit `version:` in `pubspec.yaml` (`versionName+versionCode`, e.g. `1.0.1+2`).
The `versionCode` (number after `+`) must increase for every Play upload.

## Regenerating icons / splash

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Play Store checklist

- [x] Unique application ID: `com.ateeq.expensetracker`
- [x] Release signing configured (upload keystore, not debug keys)
- [x] R8 minification + resource shrinking enabled
- [x] Adaptive launcher icon + native splash
- [x] `targetSdk` follows Flutter's latest (meets Play's target-API requirement)
- [x] No runtime permissions requested (offline app)
- [ ] Privacy policy URL — host `PRIVACY_POLICY.md` and link it in the Play listing
- [ ] Store listing: title, short/long description, feature graphic, ≥2 screenshots
- [ ] Complete the **Data safety** form: "No data collected / no data shared"
- [ ] Set content rating and target audience in Play Console
