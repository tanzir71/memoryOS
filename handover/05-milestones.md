# 05. Milestones

Do them in order. After each: `flutter analyze`, `flutter test`, a debug APK
build if an SDK exists, update `handover/PROGRESS.md`, commit to `master`
with the message `M<n>: <title>`, push. The app must launch at the end of
every milestone.

## M0. Cleanup and honesty
- Add `.gitattributes` (`* text=auto eol=lf`).
- Delete everything under "Remove" in `01-current-state.md` that does not
  need the new database (fake sync, simulated logs, canned transcripts,
  false copy, clipboard polling, metadata JSON editor, PNG saving,
  word-frequency insights and threads).
- Voice notes keep audio; the card shows title and length only.
- Rewrite the README to describe what the app does now, truthfully.
Check: `grep -ri "enclave\|kernel\|AES\|Llama\|sandbox" lib android` finds
nothing.

## M1. Foundation
- Packages and folder layout from `02-architecture.md`. Riverpod, go_router.
- Tokens, bundled fonts, theme, and every component in `04-design.md` with a
  widget test each.
- drift `memory.db` with all tables, indexes and the FTS index. Legacy
  migration from `memoryos.db`, then rename it.
- Kotlin `inbox.db` with WAL, Pigeon API (`drainInbox`, `ackInbox`,
  permission checks, importers declared), drain on start, resume and through
  WorkManager.
- New shell with four tabs. Today lists kept signals for now.
- Notification icon from `06-landing-and-icon.md`.
Check: drift tests on an in-memory database for every table; a migration
test that turns a seeded legacy file into signals without losing a row.

## M2. Capture
- Rewrite the listener service to write `raw_inbox` with all fields, update
  in place by `sbn.key`, record removal reason. Status notification moves
  here. Bluetooth receiver moves here, storing intervals.
- Delete `PersistentService`, `flutter_background`, `DatabaseHelper.kt`
  writes to the old file, and `ScreenshotObserver` (screenshots return in M8).
- Importers: SMS inbox, call log, contacts, calendar instances. First import
  runs as a WorkManager job and reports progress to the app.
- Manifest changes. Permission screens, including the restricted-settings
  instruction when a grant is refused.
Check: Kotlin JVM unit tests for the notification-to-row mapper using
hand-built bundles for a WhatsApp message, a Gmail notification, an ongoing
call and a group summary. Dart tests for dedupe of SMS against SMS
notifications and of call notifications against call-log rows.

## M3. Understand
Triage, person matching, extraction with rule packs, intents, exactly as in
`03-engines.md`. `assets/rules/` complete. "Export unparsed samples" action.
Check: fixture tests. At least 60 notification and SMS fixtures across all
classes, 5 per sender pack, 30 intent fixtures spread over English, Bangla
and Banglish.

## M4. Threads and open loops
Linker with stored reasons, suggested queue, user answers, thread titles,
order and payment cross-link, meeting threads, open loops and their closing
rules, day summary.
Check: the reference day below produces the stated threads and loops.

## M5. Pattern engine and feedback
Series per family, the three cycle sources, states, late detection,
decisions, suppress rules, implicit strength, 90 day check-in. Rebuild all
series after a history import; update incrementally afterwards.
Check: fixtures for each family; the reference history below gives the
stated predictions; two drops of one kind stop proposals of that kind.

## M6. Screens
Build 01 to 11, People list, Search and the four onboarding steps from
`04-design.md`. Add a demo mode (`--dart-define=DEMO=true`) that loads the
reference day and history into an in-memory database so every screen can be
rendered without a phone.
Check: golden tests for each screen in demo mode at 412x892, and widget
tests for done, link yes/no, Decision, pause.

## M7. Landing page and release
`06-landing-and-icon.md`. Build a release APK; if `gh` is authenticated,
create release `v2.0.0` with the APK and turn on GitHub Pages from
`master` `/docs`. If not, write the two commands into `PROGRESS.md` as the
only manual steps left.

## M8. Later, each optional and independent
- Voice transcripts on the phone with `sherpa_onnx` (Whisper tiny or base
  multilingual), run in a WorkManager job, then intents on the transcript.
- Screenshots: one-time folder grant through the Storage Access Framework,
  periodic scan, ML Kit text recognition, extraction.
- Places: activity transitions plus balanced-power location, stay points
  (20 minutes within 200 m), clustered places, visits and trips on Today.
- App lock with `local_auth`; database encryption with a key in the Android
  Keystore. Only then may the copy mention encryption.
- Export and backup: JSON and Markdown export, encrypted backup file.
- Optional summary of the day by an on-device model, foreground only.

## Reference day (fixture `test/fixtures/day_2026_11_27.json`)
Friday 27 November 2026, contact Nabila Rahman with one phone number, the
same name on WhatsApp and one email address.
- 10:12 missed WhatsApp call from Nabila.
- 10:14 WhatsApp from Nabila: "Can you send the revised quote today? Need
  it before Thursday."
- 10:31 outgoing phone call to Nabila, 12 minutes.
- 11:05 email from Nabila, subject "Re: Website quote, scope changes".
- 11:20 calendar invite "Quote review", Thu 3 December 15:00 to 15:30,
  organiser Nabila's address.
- 12:31 Foodpanda order placed, 13:05 delivered, Tk 480.
- 14:58 WhatsApp from Sadia Karim: "Running 5 late, start without me."
- 15:00 to 15:30 calendar "Design sync" (weekly), Google Meet call
  notification 15:02 to 15:41, guests Imran Hossain and Sadia Karim.
- 16:10 email from Imran, subject "Notes from design sync".
- 14:15 email from Sadia, subject "Quote template v3".
- 16:42 missed phone call from Imran Hossain.
- 17:28 Daraz order "USB-C charger", 17:30 bKash payment Tk 1,250 to Daraz.
- 60 promo, status and progress notifications spread through the day.
Expected: thread "Website quote" with five signals, reasons same person,
same subject, close in time; open loop "Send the revised quote", owner me,
due today; a plan for Thu 3 December. Thread "Design sync" with the call
notification, Sadia's message and Imran's email. Sadia's "Quote template
v3" is `suggested` for "Website quote", not linked. Order thread for the
charger with the payment linked. Open loop "Call Imran back" after 3 hours.
The 60 noise notifications are all set aside.

## Reference history (fixture `test/fixtures/history.json`)
- Operator SMS "Recharge of Tk 499 successful. 30 GB, valid for 30 days." on
  31 Jul, 30 Aug, 29 Sep, 29 Oct 2026. Expected: learned, next 28 Nov, give
  or take one day.
- Provider SMS on 20 Nov: internet bill Tk 1,050 due 30/11/2026. Expected:
  stated, 30 Nov.
- One order notification for a gas cylinder on 2 Nov. Expected: guess,
  about 2 Dec.
- bKash "Send Money" of the same amount to one number on the 5th of six
  months. Expected: learned, monthly anchor, next 5 Dec.
- Outgoing calls to the contact "Ammu" on 5 of the last 6 Fridays between
  20:30 and 21:30. Expected: learned, weekly anchor, Friday about 21:00.
- A WhatsApp group with 60 messages a day for 30 days and no asks_you.
  Expected: proposed with "Suggested: drop".
