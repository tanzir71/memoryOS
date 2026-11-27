# MemoryOS handover: start here

You are implementing a redesign of MemoryOS, a Flutter Android app in this repo
(`github.com/tanzir71/memoryOS`). The owner will not answer questions, test on a
phone, or review pull requests. Decide, write the decision down, move on.

## Read in this order
1. `01-current-state.md`: what exists today and what must go
2. `02-architecture.md`: target stack, data model, capture
3. `03-engines.md`: triage, intents, linking, pattern engine, feedback
4. `04-design.md`: tokens, components, every screen
5. `05-milestones.md`: the work, in order, with checks you can run
6. `06-landing-and-icon.md`: landing page and notification icon

## Working rules
- Commit straight to `master` and push after every milestone. No feature
  branches, no pull requests.
- No GitHub Actions and no other CI. Leave `origin/ci/add-workflow` alone.
- Never add a test or step that needs a person or a physical phone. Your checks
  are `flutter analyze` (zero errors), `flutter test` (all pass) and
  `flutter build apk --debug` when an Android SDK is installed. If there is no
  SDK, say so in `handover/PROGRESS.md` and carry on.
- Keep `handover/PROGRESS.md`: one section per milestone with what was done,
  decisions taken, and anything skipped with the reason.
- Do not upgrade the Flutter SDK. Use the installed one (`flutter --version`).
  `pubspec.lock` currently needs Flutter >= 3.38.4 and Dart ^3.12.
- Package versions named in these files were researched in November 2026.
  Use whatever `flutter pub add` resolves and record it.
- Everything runs on the phone. No server, no analytics, no network calls.
  Bundle the two fonts as assets so `google_fonts` never downloads.
- Copy must be true. Never claim encryption, an AI model or sync unless the
  code does it. No jargon ("enclave", "kernel", "node", "ingest", "stream").
- No italics anywhere in the UI or on the landing page.
- The working tree shows whole-file diffs caused by line endings. In M0 add
  `.gitattributes` with `* text=auto eol=lf`, and do not reformat files you
  are not changing.
- The app is installed directly (APK), not through Google Play. That is a
  decision, because it needs SMS and call-log access.

## Design source
Figma: https://www.figma.com/design/ClDA7VNOHpJrJa97Y0RvC2/MemoryOS (page
"Redesign v1"). `04-design.md` is written to stand alone. PNG exports of every
frame are in `handover/screens/`.

## The product in one paragraph
MemoryOS reads what the phone already sees (notifications, SMS, call history,
calendar, contacts) and turns it into two things. Looking back: threads, where
a call, a message, an email and a meeting about the same thing become one
story with at most one open ask. Looking ahead: patterns, where a recharge, a
bill, a weekly call or a meeting that always runs long gets an expected next
date with a stated level of certainty. The owner's complaint about the current
app is that it records everything and explains nothing. Every decision should
reduce rows on screen and increase meaning per row.
