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

## M3: Understand

### Completed
- Created JSON rule packs in `assets/rules/` (`apps.json`, `intents.json`, `priors.json`, `headline.json`) and 10 sender packs under `assets/rules/senders/` (`bkash`, `nagad`, `mobile_operator`, `bank_alert`, `utility_bill`, `daraz`, `foodpanda`, `pathao`, `uber`, `courier`), all marked `"verified": false`.
- Implemented `TriageEngine` (`lib/engine/triage.dart`) covering all 11 classes, OTP/redacted redaction ("sensitive event from <app> at <time>" with empty body), group-summary/low-importance/progress-tick/promo/media/system set-aside rules, per-(package, channel) score updates, and user `app_rule` override precedence.
- Implemented `PersonMatcher` (`lib/engine/person_matcher.dart`) following exact match priority (phone -> chat name -> email sender name -> email address), provisional creation and merge into contacts, and never merging two contacts automatically.
- Implemented `ExtractionEngine` (`lib/engine/extractor.dart`) with sender packs, named group extraction, entity normalisation, generic money/date/validity/order/tracking/trx/balance fallbacks, and `exportUnparsedTransactionalSamples` (`lib/engine/unparsed_exporter.dart`, wired into `SeesScreen`).
- Implemented `IntentDetector` (`lib/engine/intent_detector.dart`) across English, Bangla, and Banglish with 0.9 / 0.7 / 0.4 confidence tiers and due-date resolution.
- Added 66 triage fixtures (`test/fixtures/triage/triage_fixtures.json`), 50 extract fixtures (5 per sender pack, `test/fixtures/extract/extract_fixtures.json`), and 36 intent fixtures (12 EN, 12 Banglish, 12 Bangla, `test/fixtures/intent/intent_fixtures.json`).

### Decisions
- Added a `_compileRegex` helper in `EngineRules` that converts leading `(?i)` in JSON rule packs to Dart's `caseSensitive: false` flag so packs remain portable regex strings.
- Required at least one digit inside generic `order_id` / `tracking_no` fallbacks so plain words like `"delivered"` after `"Parcel"` are never misread as tracking IDs.

### Checks
- `flutter analyze --no-fatal-infos`: 0 errors, 0 warnings.
- `flutter test`: 52/52 tests passed (all 152+ fixtures green).
- `flutter build apk --debug`: succeeded (`build/app/outputs/flutter-apk/app-debug.apk`).

## M4: Threads and open loops

### Completed
- Implemented `ThreadLinker` (`lib/engine/linker.dart`), `ThreadActions` (`lib/engine/thread_actions.dart`), and `topic_utils.dart` with weighted scoring (`same_reference` 1.0, `same_person` 0.5, `same_subject` 0.3, `close_in_time` 0.3, `same_conversation` 0.3), 2-reason auto-link rule, 0.3–0.79 `suggested` queue (max 3 pending, never re-asked), stored reasons, order+payment cross-link (1% amount + merchant token within 10 minutes), and meeting threads (calendar + overlapping Meet/Zoom/Teams call + guest messages within 30 min + voice notes during + guest email within 3 h sharing a subject word).
- Implemented `OpenLoopEngine` (`lib/engine/open_loop_engine.dart`) for creating loops from `asks_you`, `you_said`, user's own inline asks (`owner = 'them'`), missed calls unreturned after 3 hours, and undelivered orders, plus closing via `confirms`, delivery, return call, user mark-done, meeting completion, and 14-day quiet timeout.
- Implemented `DaySummaryEngine` (`lib/engine/day_summary_engine.dart`) computing facts (`conversations`, `meetings`, `money_spent` deduplicated per order/payment thread, `set_aside_count`) and deterministic headlines (falling back to date only when fewer than 2 items).
- Implemented `SignalPipeline` (`lib/engine/pipeline.dart`) wiring triage -> person -> extract -> intent -> link -> open loops -> FTS.
- Added Reference Day fixture (`test/fixtures/day_2026_11_27.json`) and end-to-end verification tests (`test/reference_day_test.dart`).

### Decisions
- Isolated `meeting` threads from generic `same_person + close_in_time` scoring so unrelated calls after a meeting (such as Imran's 16:42 missed call after the 15:00 Design sync) stay separate rather than merging into the meeting thread.
- Deduplicated `money_spent` per thread in `DaySummaryEngine` so an order and its linked bKash payment count once (Tk 1,250 + Tk 480 = Tk 1,730).

### Checks
- `flutter analyze --no-fatal-infos`: 0 errors, 0 warnings.
- `flutter test`: 55/55 tests passed (including full Reference Day and user action checks).
- `flutter build apk --debug`: succeeded (`build/app/outputs/flutter-apk/app-debug.apk`).

## M5: Pattern engine and feedback

### Completed
- Implemented `CycleMath` (`lib/engine/cycle_math.dart`): median/MAD consistency check (`d <= 0.2 * m`), monthly day-of-month anchor (range <= 2), weekly weekday anchor (>= 4 of last 6 weeks with average hour/minute), stated date/`valid_days`/`rrule`, guess from `assets/rules/priors.json`, and `expected`/`due`/`late`/`dormant` state transitions (1-day grace, dormant after 2 missed cycles).
- Implemented `PatternEngine` (`lib/engine/pattern_engine.dart`): `rebuildAll` and incremental `updateForSignal` across `sms`, `chat`, `email`, `calendar`, `call`, and `order` families; 25% amount clustering; noisy-group `suggested_drop` detection; automatic `quiet` creation for newsletters; calendar overrun learning; and late-state open-loop creation (`"<Title>: usually done by now"`).
- Implemented `FeedbackEngine` (`lib/engine/feedback_engine.dart`): `show`/`quiet`/`drop` decisions, per-counterpart and 2-drop kind-wide `suppress_rule`, ranked `New` proposal queue (max 4, money due -> people -> calendar -> email -> chat), implicit strength updates (`+1`/`+2`/`-1`, demotion to `quiet` below `-3` with notice), sticky user-set intervals (`setUserCycle`), and 90-day check-in tracking.
- Added Reference History fixture (`test/fixtures/history.json`) and test suite (`test/pattern_engine_test.dart`).

### Decisions
- Checked learned 3+ event consistency before single-event `valid_days` so recurring operator recharges carrying `"valid for 30 days"` graduate to `learned` (`± 1 day`) once 3+ recharges are observed, matching Reference History item 1, while single SMS bills with explicit `due_date` remain `stated`.

### Checks
- `flutter analyze --no-fatal-infos`: 0 errors, 0 warnings.
- `flutter test`: 58/58 tests passed (including all 6 Reference History predictions and 2-drop suppression).
- `flutter build apk --debug`: succeeded (`build/app/outputs/flutter-apk/app-debug.apk`).
