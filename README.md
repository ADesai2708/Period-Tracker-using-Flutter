# Cycle Tracker (Flutter)

A simple, elegant period/cycle tracking app. Fully offline — all data is
stored locally on-device with `shared_preferences`, no backend required.

## Features
- Log periods with start/end date, flow intensity, symptoms, and notes
- Calendar view highlighting logged periods, predicted next period, and
  the fertile window
- Cycle predictions that automatically improve as you log more history
  (falls back to your configured averages until 2+ cycles are logged)
- Editable history list (tap to edit, swipe to delete)
- Configurable average cycle/period length in Settings

## Project structure
```
lib/
  main.dart                  # App entry point
  models/cycle_entry.dart    # CycleEntry + CycleSettings data models
  services/storage_service.dart  # SharedPreferences persistence
  utils/cycle_calculator.dart    # Prediction logic (pure, testable)
  utils/theme.dart               # Colors + ThemeData
  screens/home_screen.dart       # Calendar + status card
  screens/log_period_screen.dart # Bottom sheet for logging/editing
  screens/history_screen.dart    # List of past periods
  screens/settings_screen.dart   # Cycle length configuration
```

## Setup

1. Make sure you have the Flutter SDK installed:
   https://docs.flutter.dev/get-started/install

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Run on a connected device/emulator:
   ```
   flutter run
   ```

4. To build a release APK:
   ```
   flutter build apk --release
   ```

## Notes for submission
- No backend/API keys needed — everything runs locally.
- If your task requires cloud sync/auth, the natural next step is
  swapping `StorageService` for Firebase/Firestore calls while keeping
  the same method signatures (`loadEntries`, `saveEntries`, etc.), so
  the rest of the app doesn't need to change.
- Dependencies used: `table_calendar`, `shared_preferences`, `intl`,
  `fl_chart` (chart package included for easy extension, e.g. a cycle
  length trend graph, not yet wired into a screen).
