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

## M1: Foundation

### Completed
- Added packages: `flutter_riverpod 3.5.0`, `go_router 18.1.4`, `drift 2.35.4`, `sqlite3 3.9.2`, `workmanager 0.10.10`, `lucide_icons_flutter 4.0.5`, `drift_dev 2.35.3`, `build_runner 2.17.1`, `pigeon 30.0.4`. Removed `cupertino_icons` and `sqflite`.
- Bundled `Newsreader` and `Instrument Sans` variable TTF fonts in `assets/fonts/` so no network font fetch occurs.
- Built design tokens (`lib/app/tokens.dart`), theme (`lib/app/theme.dart`), and all shared components in `lib/widgets/` (`Glyph`, `IntentTag`, `CertaintyTag`, `DecisionControl`, `AppButton`, `CapturePill`, `AppSwitch`, `MemoryNavBar`, `RailEntry`, `SectionHeader`), each with widget tests (`test/widgets_test.dart`).
- Created Drift `memory.db` schema (`lib/data/tables_core.dart`, `lib/data/tables_engine.dart`, `lib/data/database.dart`) with all tables, unique constraints, indexes, and FTS5 `search_index`, plus legacy `memoryos.db` migration and rename (`lib/data/legacy_migration.dart`).
- Added Kotlin `inbox.db` with WAL (`InboxDatabase.kt`), Pigeon schema (`pigeons/capture_api.dart`) and host implementation (`CaptureApiImpl.kt`), Dart inbox drainer (`lib/capture/inbox_drainer.dart`), and 15-minute WorkManager drain (`lib/capture/background_worker.dart`).
- Built new 4-tab shell (`Today`, `Threads`, `People`, `Ahead`) via `go_router` + `Riverpod`.
- Added vector notification icons (`ic_stat_memoryos.xml`, `ic_stat_memoryos_paused.xml`) and adaptive launcher icon (`mipmap-anydpi-v26/ic_launcher.xml`).

### Decisions
- Used `sqlite3 3.9.2` native hooks directly (removed EOL `sqlite3_flutter_libs 0.6.0+eol`) and read legacy `memoryos.db` directly via `sqlite3` so `sqflite` could be removed cleanly in M1.
- Added a `channel_score` table alongside `app_rule` to track per-(package, channel) triage scores cleanly.
- Used `package:flutter/material.dart` (deprecated info in Flutter 3.50.1) because `go_router` and Material widgets still rely on it; zero errors and zero warnings.

### Checks
- `flutter analyze --no-fatal-infos`: 0 errors, 0 warnings.
- `flutter test`: 32/32 tests passed (including Drift in-memory tests for all tables + FTS5, legacy migration test, and widget tests for every component).
- `flutter build apk --debug`: succeeded (`build/app/outputs/flutter-apk/app-debug.apk`).

## M2: Capture

### Completed
- Rewrote `NotificationListener.kt` to write full notification fields (`category`, `flags`, `importance` from `Ranking`, `sbn_key`, `group_key`, `is_conversation`, `is_group`, `EXTRA_MESSAGES`, `EXTRA_REMOTE_INPUT_HISTORY`, `EXTRA_TEXT_LINES`, `title`, `text`, `big_text`, `people_json`, `extras_json`, `posted_at`, `redacted`) into WAL `inbox.db` via `NotificationMapper.kt`, updating in place by `sbn.key` for non-conversations and recording removal reason/time in `onNotificationRemoved`.
- Moved status notification (`StatusNotifier.kt` + `StatusActionReceiver`) and Bluetooth connect-to-disconnect interval recording into `NotificationListener.kt`.
- Deleted `PersistentService.kt`, `DatabaseHelper.kt`, `ScreenshotObserver.kt`, and removed `flutter_background` from `pubspec.yaml` and `AndroidManifest.xml`.
- Implemented `HistoryImporters.kt` for SMS inbox, call log, contacts, and calendar instances (30 days back to 30 days ahead with attendees and recurrence), wired behind `CaptureApiImpl.kt` and `HistoryImportCoordinator` + WorkManager.
- Updated `AndroidManifest.xml`: added `READ_SMS`, `READ_CALL_LOG`, `READ_CONTACTS`; removed `WRITE_CALENDAR`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `requestLegacyExternalStorage`, `BLUETOOTH_ADMIN`, `FOREGROUND_SERVICE*`, `WAKE_LOCK`, `IsolateHolderService`, and `PersistentService`.
- Added `RestrictedSettingsBanner` and updated `SeesScreen` to guide sideloaded users through Android 13+/15+ "Allow restricted settings" with an "Open app info" button.
- Implemented Dart dedupe & parser helpers (`lib/capture/capture_dedupe.dart`) for +880 phone normalisation, SMS vs notification dedupe, overlapping call-log vs call-notification dedupe, and tolerant chat/call parsers.

### Decisions
- Used pure-JVM JUnit 4 + `org.json` with `NotificationMapper.mapExtras` / `NotificationExtrasData` (with `NotificationMapper.fromBundle` adapting `android.os.Bundle`) so Kotlin JVM unit tests run fast without downloading a 170 MB Robolectric Android SDK image.

### Checks
- `flutter analyze --no-fatal-infos`: 0 errors, 0 warnings.
- `flutter test`: 41/41 tests passed (including `test/capture_dedupe_test.dart`).
- `./gradlew :app:testDebugUnitTest`: all 5 `NotificationMapperTest` tests passed.
- `flutter build apk --debug`: succeeded (`build/app/outputs/flutter-apk/app-debug.apk`).
