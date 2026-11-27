# MemoryOS

An Android Flutter app that records phone activity into a local SQLite database on the device. Nothing is uploaded.

## What it does right now (M0)

- Captures incoming Android notifications (with marketing and screenshot-capture filtering), Bluetooth device connections, periodic location coordinates, screenshot filenames, manual notes and voice notes (audio only, no transcription yet).
- Stores captured entries locally in SQLite with soft delete and automatic 30-day purge.
- Two screens while the v2 redesign is underway: **Timeline** (day view, manual notes, voice recording, deleted items) and **Sources** (per-source switches and battery exemption guide).

## Getting started

Prerequisites: Flutter SDK matching `pubspec.yaml` and an Android device or emulator.

```sh
flutter pub get
flutter test
flutter build apk --debug
```

Everything runs on the phone. There is no server, no sync, no encryption yet, and no AI model.
