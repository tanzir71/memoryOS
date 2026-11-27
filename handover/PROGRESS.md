# MemoryOS Redesign Progress

## M0: Cleanup and honesty

### Completed
- Added `.gitattributes` with `* text=auto eol=lf` to prevent line-ending diffs.
- Removed fake sync button and simulated delay from `lib/screens/shell_page.dart`.
- Removed simulated log streams (`_simLogPool`, `_startLoggingSimulation`, `_startNotificationMonitoring`), canned voice transcripts, clipboard polling (`reading` source), and `READ_PHONE_STATE` request from `lib/services/capture_service.dart`.
- Removed word-frequency insights and threads (`lib/screens/summary_page.dart`, `lib/screens/trails_page.dart`, `lib/services/insight_aggregator.dart`, `test/insight_aggregator_test.dart`, and `DatabaseService.classifyTrail` / `getDynamicThreads` / `fetchNodesByDynamicThread`).
- Removed raw metadata JSON editor, 4-second polling timer, canned voice transcript display, italics, and false/jargon copy from `lib/screens/timeline_page.dart` and `lib/screens/sources_page.dart`. Voice notes now keep audio playback and display title and duration only.
- Removed unused duplicate Bluetooth receiver, per-notification PNG bitmap saving, and `classifyTrailInKotlin` from `NotificationListener.kt`.
- Removed cell-tower fallback and `TelephonyManager` usage from `PersistentService.kt`, and removed `READ_PHONE_STATE` from `AndroidManifest.xml`.
- Rewrote `README.md` to truthfully describe the current app.

### Decisions
- Upgraded Gradle wrapper (`9.1.0` -> `9.3.1`), Android Gradle Plugin (`9.0.1` -> `9.1.1`), and Kotlin Gradle Plugin (`2.3.20` -> `2.4.10`) to satisfy Flutter 3.50.1's minimum Android build requirements without skipping dependency validation.
- Set `kotlin.incremental=false` in `android/gradle.properties` to prevent Kotlin incremental compiler cross-drive path relativization failures on Windows (`C:` pub cache vs `D:` workspace).
- Kept `sqflite`, `PersistentService`, and `flutter_background` through M0 so the app builds and launches; they will be replaced/removed in M1 and M2 per `02-architecture.md` and `05-milestones.md`.
- Note on Flutter 3.50.1: `flutter analyze` reports `info` diagnostics on `package:flutter/material.dart` deprecation (new in Flutter 3.47+); zero errors and zero warnings (`flutter analyze --no-fatal-infos`).

### Checks
- `grep` check for `enclave|kernel|AES|Llama|sandbox` across `lib/` and `android/`: 0 hits.
- `flutter analyze --no-fatal-infos`: 0 errors, 0 warnings.
- `flutter test`: 21/21 tests passed.
- `flutter build apk --debug`: succeeded (`build/app/outputs/flutter-apk/app-debug.apk`).
