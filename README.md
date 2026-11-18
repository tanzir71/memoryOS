# memoryOS

A Flutter app that passively logs activity from your phone into a local timeline, so you can look back at what you did, where you were and what you heard or read. The Android side does most of the capture work.

## Features

- Seven capture sources, each toggled individually on the Sources screen: voice notes, location, calendar, notifications, Bluetooth, photos (screenshots) and reading (clipboard).
- Android background capture through a persistent foreground service and a notification listener service written in Kotlin.
- Every capture is stored as a "memory node" (source, content, metadata) in a local SQLite database on the device.
- Four screens: Timeline, Insights, Sources and Threads (related memories grouped into trails).
- Voice recorder falls back to a simulation mode when microphone permission or native audio is unavailable.

## Tech stack

Flutter (Dart SDK ^3.12), `sqflite`, `permission_handler`, `record`, `flutter_background`, `audioplayers`, `path_provider`, `intl`, `google_fonts`. Android native code in Kotlin under `android/app/src/main/kotlin`.

## Getting started

Prerequisites: the Flutter SDK matching `pubspec.yaml` and an Android device or emulator (the capture services rely on Android-specific permissions and services).

```sh
flutter pub get
flutter run
```

On first use, grant the permissions for the sources you turn on (microphone, location including background location, calendar, notifications access, Bluetooth, photos). Notification capture also requires enabling notification access for the app in Android settings. For long-running capture, allow the app to ignore battery optimizations.

## Tests

```sh
flutter test
```

Unit tests in `test/` cover capture metadata, location capture policy and metadata, the insight aggregator and the memory node model.

## Project structure

```
lib/models/     memory node model
lib/services/   capture service, SQLite database service, metadata and insight logic
lib/screens/    Timeline, Insights, Sources, Threads and the app shell
android/        Kotlin persistent service, notification listener, screenshot observer, SQLite helper
```

Platform folders for iOS, web, Windows, macOS and Linux are the default Flutter scaffolding; the capture features are implemented for Android.
