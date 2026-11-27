# 01. Current state

Flutter app, Android only in practice. About 7,600 lines of Dart and 2,000 of
Kotlin. Two commits. Tests: five small unit test files plus the default
widget test.

## Files
- `lib/main.dart`, `lib/screens/shell_page.dart`: app shell, four tabs
  (Timeline, Insights, Sources, Threads), a fake "sync" button.
- `lib/screens/timeline_page.dart` (2,383 lines): one card per database row
  for the chosen day, last 7 days only, re-queried by a 4 second `Timer`.
  Also holds the permission guide, voice recorder, manual note, edit sheet
  (exposes raw metadata JSON) and deleted items.
- `lib/screens/summary_page.dart`: "insights" that are the six most frequent
  words. `lib/screens/trails_page.dart`: "threads" that are the same six
  words, and a search that is SQL `LIKE` behind a 1.2 second fake delay.
- `lib/screens/sources_page.dart`: toggles plus a "kernel log" of invented
  lines.
- `lib/services/capture_service.dart`: toggles, permissions, clipboard polling
  every 5 s, voice recording, simulated log lines.
- `lib/services/database_service.dart`: sqflite, one table `memory_nodes`
  (id, timestamp TEXT, title, content, source, metadata JSON, trail,
  is_starred, deleted_at) and `settings`. No indexes, no FTS.
- `lib/services/capture_metadata.dart`, `insight_aggregator.dart`,
  `location_*.dart`: helpers and marketing-notification regexes.
- Kotlin, `android/app/src/main/kotlin/com/memoryos/memoryos/`:
  `NotificationListener.kt` (stores almost every notification as a row, saves
  the large icon as a full PNG each time), `PersistentService.kt` (foreground
  service of type dataSync|location, 4-hourly location sample, Bluetooth
  receiver, screenshot observers, status notification using
  `android.R.drawable.ic_dialog_info`), `DatabaseHelper.kt` (opens the same
  `memoryos.db` that sqflite has open, per insert, no WAL),
  `ScreenshotObserver.kt` (FileObserver, file name only), `MainActivity.kt`
  (method channel `com.memoryos.memoryos/persistent`).

## What is wrong
1. Unit of display is the raw row, so the timeline is mostly notifications.
2. Nothing links one event to another. `trail` is a hard-coded keyword
   `contains` check, with the owner's own words baked in.
3. Untrue claims in the UI: AES-256 encryption, "Verified by Local AI Model:
   Llama-3-Privacy", a sync that waits 1.5 s, simulated log lines, a voice
   "transcript" chosen from canned strings by title keyword.
4. Two SQLite engines write one file without WAL. Corruption risk.
5. Capture gaps: calendar has a toggle and a permission but no code;
   clipboard polling cannot work in the background on Android 10+; location
   stores rounded coordinates with no place; screenshots store a file name.
6. No SMS, call-log or contacts permission exists. The app only sees an SMS
   when it arrives as a notification.
7. An always-on `dataSync` foreground service. Android 15 caps that type at
   about 6 hours per day.
8. `flutter_background` wraps the same idea and adds a second service.
9. State is `setState` plus timers inside very large widgets.

## Remove
Fake sync, simulated logs, `_simLogPool`, canned transcripts, every
"enclave/kernel/AES/Llama" string, clipboard polling, the 4 s refresh timers,
per-notification PNG saving, the word-frequency insights and threads,
`classifyTrail` in Dart and Kotlin, the metadata JSON editor, the duplicate
unused Bluetooth receiver in `NotificationListener.kt`, `flutter_background`,
the cell-tower fallback and `READ_PHONE_STATE`.

## Keep
The marketing and screenshot notification filters and dedupe helpers in
`capture_metadata.dart` (move into triage, keep their tests), soft delete with
30 day purge, voice recording itself, the Samsung battery guide content.
