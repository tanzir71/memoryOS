# 02. Architecture

## Packages
Add: `flutter_riverpod`, `go_router`, `drift` + `drift_dev` + `build_runner`
(drift on the `sqlite3` package, FTS5 on), `pigeon`, `workmanager`,
`lucide_icons_flutter` (fall back to `flutter_feather_icons` if it will not
resolve). Keep: `record`, `audioplayers`, `permission_handler`,
`path_provider`, `path`, `intl`, `google_fonts` (fonts bundled).
Remove: `flutter_background`, `cupertino_icons`, and `sqflite` once the
migration in M1 has run.

## Layout
```
lib/app/        router, theme tokens, shell
lib/data/       drift database, tables, DAOs, legacy migration
lib/capture/    pigeon API, inbox drain, history importers
lib/engine/     triage, extract, intent, person, link, pattern, feedback
lib/features/   today, thread, threads, person, meeting, ahead, pattern,
                patterns, sees, onboarding
lib/widgets/    shared components from 04-design.md
assets/rules/   JSON rule packs (see 03-engines.md)
assets/fonts/   Newsreader, Instrument Sans
test/fixtures/  JSON fixtures per engine
```
No file over 400 lines.

## Two databases, one writer each
- `inbox.db`: written only by Kotlin, WAL on, append-only. Table
  `raw_inbox(id, source, pkg, channel, category, flags, importance, sbn_key,
  group_key, is_conversation, is_group, title, text, big_text, people_json,
  extras_json, posted_at, removed_at, removal_reason, redacted, consumed)`.
  `source` is one of notification, sms, call, calendar, bluetooth, screenshot.
- `memory.db`: written only by Dart through drift.
- Dart drains the inbox through Pigeon: `drainInbox(afterId, limit)` then
  `ackInbox(upToId)`. Run on app start, on resume, every 15 minutes through
  WorkManager, and after a history import. UI reads drift streams. No timers.
- Legacy: on first run after M1 copy every row of `memory_nodes` from
  `memoryos.db` into `signal`, then rename the file to `memoryos.legacy.db`.
  Never delete user data.

## memory.db tables
- `signal`: one normalised input. id, inbox_id, source, pkg, kind, title,
  body, occurred_at, ended_at, person_id, class, kept, redacted, extras_json.
- `person`: id, display_name, contact_lookup_key, is_me.
  `person_handle`: person_id, type (phone|email|chat_name), value, app.
- `entity`: id, type (merchant|order|parcel|payment|booking|amount|place|
  topic|app), canonical_value, display. `signal_entity`: signal_id,
  entity_id, role.
- `intent`: id, signal_id, type (asks_you|you_said|plan|confirms|fyi),
  text, due_at, confidence.
- `thread`: id, title, kind (conversation|order|payment|meeting|other),
  person_id, started_at, last_at, status (open|done), user_edited.
  `thread_signal`: thread_id, signal_id.
  `link`: id, thread_id, signal_id, reasons_json, score, state
  (linked|suggested|rejected), decided_by (rule|user).
- `open_loop`: id, thread_id, intent_id, owner (me|them), title, due_at,
  state (open|done|dismissed), closed_by (confirm|user|meeting|timeout).
- `series`: id, family (sms|chat|email|calendar|call|order|place), kind,
  counterpart_key, title, cycle_json, certainty (stated|learned|guess),
  strength, decision (undecided|show|quiet|drop), tracking, last_event_at,
  next_from, next_to, state (expected|due|late|dormant).
  `series_signal`: series_id, signal_id.
- `feedback`: id, target_type (series|link|signal|app), target_id, action,
  at. `suppress_rule`: family, kind, counterpart_key (nullable), reason.
- `app_rule`: pkg, class, keep_policy, user_set. `setting`: key, value.
- `day`: date, headline, facts_json, set_aside_count.
- FTS5 `search_index(title, body, people, entities)` over threads and signals.
Indexes on every `*_at` used for ordering, `signal(sbn_key)`,
`entity(type, canonical_value)` unique, `person_handle(type, value)` unique.

## Capture (Kotlin, behind Pigeon)
- Notifications: keep `NotificationListenerService`. Store category, flags,
  channel importance from `Ranking`, `sbn.key`, group key, `isConversation`,
  `EXTRA_IS_GROUP_CONVERSATION`, conversation title, `EXTRA_MESSAGES`
  (sender, text, time), `EXTRA_REMOTE_INPUT_HISTORY`, `EXTRA_TEXT_LINES`,
  title, text, big text. If `sbn.key` already has an unconsumed row and the
  notification is not a conversation, update that row instead of adding one.
  Implement `onNotificationRemoved(sbn, rankingMap, reason)` and store the
  reason and time. Skip the app's own package. Do not save icons.
- Calls: call-log import with `READ_CALL_LOG` (`CallLog.Calls`: number,
  cached name, type, date, duration) is the source of truth. `CATEGORY_CALL`
  and `CATEGORY_MISSED_CALL` notifications cover WhatsApp and Messenger
  calls: posted time is the start, removal time is the end, the title is the
  name. Drop a notification call when a call-log row overlaps it.
- SMS: `READ_SMS`, `Telephony.Sms.Inbox` (address, body, date). Import the
  stored inbox once, then poll rows newer than the last seen date in the
  15 minute job. Dedupe against SMS notifications by address, time within
  60 s and body hash. Do not request `RECEIVE_SMS`.
- Chat and email come only from notifications. Chat: `MessagingStyle`
  messages; a message with no sender, or an entry in the remote input
  history, is the user's own reply. Email: `CATEGORY_EMAIL`, title is the
  sender, text is the subject, big text is the first lines.
- Calendar: `READ_CALENDAR`, `CalendarContract.Instances` from 30 days back
  to 30 days ahead with attendees and recurrence, re-read in the 15 minute
  job. A Meet, Zoom or Teams ongoing-call notification whose time overlaps an
  instance gives the real join and leave times.
- Contacts: `READ_CONTACTS`, used only to build `person` and
  `person_handle`. Normalise phone numbers with +880 as the default country.
- Bluetooth: register the receiver inside the listener service; store
  connect to disconnect as one interval per device; no adapter-state rows.
- Voice notes: keep recording. Until M8 there is no transcript; show the
  title and length only.
- Places and screenshots are M8 and off by default.

## Two assumptions nobody has checked on a phone
Call length from the lifetime of a call notification, and inline replies
being present in the notification extras. Write both parsers to tolerate
missing data and cover them with fixtures. Do not block on them.

## Manifest
Add `READ_SMS`, `READ_CALL_LOG`, `READ_CONTACTS`. Remove `WRITE_CALENDAR`,
`READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`,
`android:requestLegacyExternalStorage`, `READ_PHONE_STATE`,
`BLUETOOTH_ADMIN`, `FOREGROUND_SERVICE_DATA_SYNC`, and the
`flutter_background` service entry. Keep location permissions for M8 but
request nothing at runtime until the user turns Places on.

## Background model
No always-on foreground service. The listener service is bound by the system.
Batch work runs in WorkManager every 15 minutes; heavy passes (history import,
pattern rebuild) run with the charging constraint when they can wait. The
status notification is an ordinary ongoing notification posted by the listener
service, with the new icon and a Pause action that sets `listening_paused`.

## Restricted settings
An APK installed from a browser or file manager cannot be given notification
access (Android 13+) or SMS permission (Android 15+) until the user opens
App info, taps the menu and chooses "Allow restricted settings". The
onboarding step for each of those permissions must detect a refusal and show
that instruction with an "Open app info" button.
