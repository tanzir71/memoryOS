# 04. Design

Target: Android phone, 412 dp wide. Light theme only for now. Figma node ids
are given so the PNG in `handover/screens/` can be matched to each section.

## Tokens (`lib/app/tokens.dart`)
Colour: canvas #F4F2ED, surface #FFFFFF, sunken #EBE8E1, ink #1B1A17,
ink-2 #504E48, ink-3 #6F6C65, line #E2DED5, line-strong #CBC6BB,
accent #45398A, accent-soft #EAE7F5, on-accent #FFFFFF, attention #A84B12,
attention-soft #FAECDF, positive #2C6A4C, positive-soft #E3EFE8.
One accent, one attention colour. Icons are ink, never coloured per app.

Spacing: 2 4 6 8 10 12 14 16 20 24 28 32 40 48 56 64.
Radius: 6, 10 (glyph), 14 (inset panel), 20 (card), 28 (sheet, big panel),
999 (pill). Screen side padding 20. Card padding 16.

Type. Newsreader carries the story (day headline, screen titles, quoted
messages). Instrument Sans carries everything else. Size/line height:
- display/day Newsreader Medium 30/36, -1%
- display/title Newsreader Medium 26/32, -1%
- quote/md Newsreader Regular 18/26
- title/lg Instrument Sans SemiBold 20/26
- title/md SemiBold 17/24, title/sm SemiBold 15/20
- body/md Regular 15/22, body/sm Regular 13/18, body/sm-strong Medium 13/18
- label/md Medium 14/20, label/sm SemiBold 12/16 (+1%), label/nav Medium 11/14
Landing only: display/hero Newsreader Medium 64/68 (-2%), display/board
44/50, body/lg Instrument Sans Regular 18/28.

Icons: Lucide, 1.75 stroke, 20 dp in bars, 18 dp in glyph tiles, 14 to 16 dp
inline.

## Components (`lib/widgets/`, Figma 4:2)
- Glyph: 36x36, radius 10, sunken, 18 dp ink icon. Kinds: call (phone),
  message (message-square), email (mail), meeting (calendar), order
  (package), payment (credit-card), place (map-pin), trip (navigation),
  voice (mic), note (file-text), person (user).
- IntentTag: 6 dp dot plus label/sm text, no background. Asks you
  (attention), You said (accent), Plan (ink-2), Confirms (positive),
  FYI (ink-3).
- CertaintyTag: same shape. Stated (positive), Learned (accent), Guess (ink-3).
- Decision: pill with three segments Show, Track quietly, Drop. Selected
  segment is accent-soft with accent text. None selected for a new pattern.
- Button: Primary (accent fill), Quiet (surface, line-strong border), Text
  (accent label only). Pill, padding 10x18, label/md.
- CapturePill: Capturing (positive dot) or "Paused until <time>" (attention
  dot). Opens screen 05.
- Switch 46x28. NavBar 76 high, four tabs, active tab has an accent-soft
  pill behind an accent icon. Tabs: Today, Threads, People, Ahead.
  (Figma labels the fourth tab "Review"; build it as "Ahead", clock icon.)
- RailEntry: glyph, a 2 dp line running down to the next entry, and a body
  with a label/sm time above the title. Used for the day and for evidence.
- Section header: title/sm left, body/sm ink-3 count right.

## Copy rules
Sentence case. Short words. Times as "10:14 am", dates as "Thu 3 December",
money as "Tk 1,250". Quote messages in straight double quotes in quote/md.
Every prediction shows its certainty. Every link can show its reasons.
Say what is not read wherever a source is switched on.

## Screens
01 Today (7:286). Status bar, top bar (CapturePill, search, settings icon to
05). Day story: date, headline in display/day, facts line. "Needs you": one
card of open loops owned by me with a round done button, and a sunken footer
row for the top loop owned by others. "Coming up": up to three shown series
due within 7 days, each with date and CertaintyTag; the header opens 08.
"How the day went": RailEntry list of the day's threads and standalone kept
signals in time order. A thread with more than one channel is a card (person
line, title, channel summary, top intent); an order shows a four-step bar
(ordered, paid, shipped, delivered). Last row: "<n> notifications set aside"
opening the set-aside list. Floating mic button records a voice note.
Empty day: date, "Nothing worth keeping yet today", and the set-aside row.

02 Thread (7:443). Title in display/title, person and time span. "Still
open" panel (attention-soft for asks_you, accent-soft for you_said) with the
ask, where it came from, Mark done and Remind me. Planned row when a plan
intent exists. "How it unfolded": RailEntry per signal with IntentTag.
"Why these are together": one row per stored reason, and "Split it out".
Overflow menu: rename, merge into another thread, delete.

03 Person (8:333). Avatar initials, name, last contact, channel chips from
handles. "Between you": loops I owe, loops they owe (with Nudge, which opens
the chat app). Coming up. Threads list. This month: calls, messages, emails,
meetings. The People tab is a list of people by last contact with their
open-loop count; it is not drawn, build it from the list rows of 07.

04 Meeting (8:451). Title, place and app. Card: planned time, happened time,
guests. Before, During, After groups of RailEntry. Open loop panel at the
bottom when one exists.

05 What MemoryOS sees (9:372). Status card with CapturePill, counts and
"Pause 1 hour". One card of sources, each with a switch and two lines: what
is read, what is not. Calls, Text messages (SMS), Messages, Email, Meetings,
Orders and payments, Places (off). Rows below: Apps (per-app keep or set
aside), History already on the phone, Raw notifications (kept 30 days),
Delete a time range. Footer: "Stored on this phone only. Nothing is
uploaded."

06 Link check (9:524). Bottom sheet over the current screen. Label "One
reason only, so asking", question naming the thread, the signal, a tick row
for the reason that matched and a cross row for the one that did not, then
"Yes, add it" and "No, keep separate". Show at most one per app open.

07 Threads (9:522). Title, search, text tabs (All, People, Orders, Meetings,
Money). Groups: Needs you, Waiting on others, Done this week.

08 Ahead (13:593). Groups: This week, Later, Rhythms. Each row: glyph,
title, basis, date, CertaintyTag. Last row "All patterns" opens 11.

09 Pattern (13:686). "Next" panel: CertaintyTag, expected date, margin and
usual amount, "Remind me a day before", "Not a pattern" (= drop). "What it
is based on": dots for past events with the gap between them and a hollow
dot for the expected one, then the source messages. "Why this is Learned,
not a Guess" lists the evidence. "Cycle looks wrong? Fix it" lets the user
set the interval; a user-set cycle is never overwritten.

10 History (13:773). Onboarding step 3 of 4. Switches for SMS inbox and Call
history with counts, "Found so far" with the first patterns, the
restricted-settings note, "Use this history" and "Skip, learn from now on".
Other steps, not drawn: 1 what the app does, with a sample day; 2
notification access; 4 contacts and calendar, then Today.

11 Patterns (15:743). Text tabs by family. "New": cards with glyph, title,
basis, CertaintyTag or "Suggested: drop", and a Decision control. "Showing"
list, "Tracking quietly" row, "Dropped" row.

Search (not drawn): a field and thread rows from the FTS index.

Reference boards: linking model (5:237), pattern engine (12:583), pattern
families and feedback (15:855).
