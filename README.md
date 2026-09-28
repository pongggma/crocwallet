# CrocWallet

CrocWallet is a Flutter savings tracker for wallets, deposits, withdrawals, and savings goals. It stores data locally in SQLite and runs on Android, iOS, Windows, macOS, and Linux.

## Features

- Create wallets for different places and currencies, with optional targets and deadlines.
- Record deposits and withdrawals and review transaction history.
- Track goals using the balance of the wallet associated with each goal.
- View a savings calendar, statistics, and achievements.
- View currency estimates in Lao kip using periodically updated exchange rates.
- Back up and restore data as JSON text, change the theme, or reset app data in Settings.

Wallet balances and totals are kept separate by currency. Exchange-rate estimates are optional and require an internet connection; the app caches the last successful rates.

## Requirements

- Flutter SDK with Dart 3.7 or later
- Android Studio and Android SDK to build Android releases

## Run locally

```sh
flutter pub get
flutter run
```

## Verify

```sh
flutter analyze
flutter test
```

## Build an Android APK

```sh
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. The current Android release configuration uses the debug signing key; configure a private release keystore before distributing the app.

## Project layout

```text
assets/
  images/
    crocodiles/
    icons/
    illustrations/
lib/
  core/           # App constants, graphics, theme, and utilities
  database/       # SQLite database and DAOs
  models/
  navigation/
  providers/
  screens/
  services/
  widgets/
```

Android and iOS use the native `sqflite` implementation. Desktop builds use `sqflite_common_ffi`.
