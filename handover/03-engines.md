# 03. Engines

Every new signal runs through: triage, person, extract, intent, link, series.
All of it is pure Dart, deterministic and covered by fixture tests. Rules live
in `assets/rules/*.json` so they change without code.

## 1. Triage
Class: conversation, call, email, calendar, transaction, order, travel, media,
system, promo, otp. Inputs: notification category, flags, channel importance,
group-summary and ongoing flags, `assets/rules/apps.json` (package to class
and keep policy), and the existing marketing regexes.

Set aside (stored 30 days, `kept = false`, counted on Today, never shown at
top level): group summaries, promo and recommendation, importance LOW or
below, media, system and status, every progress tick of an ongoing
notification except its first and last state. One-time codes and redacted
notifications are stored as "sensitive event from <app> at <time>" with no
body.

Learning: per (package, channel) keep a score, +1 when a notification is
removed with REASON_CLICK, -1 when cancelled within 10 s of posting. Below -5
the channel is set aside by default. A user choice in `app_rule` always wins.

## 2. Person
Match in this order: phone number (call log, SMS address) to a contact; chat
display name equal to a contact name; email sender name equal to a contact
name; calendar attendee email to a contact email. No match: create a
provisional person keyed by (app, name) and merge it into a contact when a
handle matches later. Never merge two contacts automatically.

## 3. Extract
`assets/rules/senders/<name>.json`:
`{ "match": {"pkg": "...", "address": "regex"}, "patterns": [ {"kind":
"recharge", "regex": "... named groups ..."} ] }`. Named groups: amount,
trx_id, counterparty, balance, due_date, valid_days, valid_until, order_id,
tracking_no, merchant, item.

Ship packs for bKash, Nagad, mobile operator recharge and pack messages,
generic bank alert, generic utility bill, Daraz, Foodpanda, Pathao, Uber,
generic courier. There is no official format for any of these. Write the
patterns loosely, mark each pack `"verified": false`, and add a Settings
action "Export unparsed samples" that writes transactional signals no pattern
matched to a JSON file in app documents, so real wording can be added later.
Known shape for bKash: "You have received Tk 1,200.00 from 01XXXXXXXXX. Fee
Tk 0.00. Balance Tk 1,200.00. TrxID DJC9SZQV0J at 12/10/2026 15:24"; dates are
DD/MM/YYYY HH:MM, amounts use comma thousands, TrxID is 10 upper-case
letters or digits. Nagad writes "Balance: Tk".

Generic fallbacks run after the packs: money (Tk, BDT, the taka sign), dates
("30 Nov", dd/mm/yyyy, weekday names, today, tomorrow, "kal"), validity
("valid for 30 days", "valid till"), order and tracking ids.
Every pattern needs at least one fixture in `test/fixtures/extract/`.

## 4. Intent
Types: asks_you, you_said, plan, confirms, fyi. Applied to chat messages,
person-to-person SMS, email subject plus first lines, calendar invites
(always plan) and the user's own inline replies.
`assets/rules/intents.json` holds cue phrases for English, Bangla and
Banglish (Bangla in Latin letters):
- asks_you: a question or request aimed at the user ("can you", "please
  send", "pathao", "dio", "koro to").
- you_said: first-person future in the user's own text ("I'll", "I will",
  "ami pathabo", "dicchi").
- plan: a date or time with agreement ("works", "see you", "thik ache").
- confirms: "got it", "received", "thanks", "peyechi", "dhonnobad".
- fyi: everything else.
Confidence 0.9 for cue plus date, 0.7 cue only, 0.4 weak. Only 0.7 and above
may create an open loop. Resolve "today", "before Thursday", "kal shokale"
to `due_at`.

## 5. Link: building threads
Score each kept signal against threads active in the last 14 days:

| Reason | Score |
|---|---|
| Same reference: "Re:" subject chain, order id, trx id, tracking number, meeting link, calendar instance | 1.0 |
| Same person | 0.5 |
| Same subject: at least one shared topic word or entity | 0.3 |
| Close in time: within 90 minutes of the thread's last signal | 0.3 |
| Same chat conversation | 0.3 |

- 0.8 or more: link. Two reasons must agree unless it is a same reference.
- 0.3 to 0.79: `suggested`. Ask the user (screen 06). At most three
  questions pending; never ask the same pair twice.
- Below 0.3: start a new thread for conversation, call, email, calendar,
  transaction and order signals; anything else stays standalone.
Store the reasons with every link; the thread screen prints them. A user
answer is final: "no" marks the link rejected for good; "split it out"
detaches a signal the same way.

Special cases: an order and a payment link when amount matches within 1%
and the merchant shares a token within 10 minutes. A meeting thread is the
calendar instance, the overlapping call notification, messages from guests
30 minutes either side, any voice note during it, and an email from a guest
within 3 hours that shares a subject word.

Titles: order or payment uses the item or merchant; meeting uses the event
title; conversation uses the strongest shared topic phrase, else
"<Person>, <date>". The user can rename; never overwrite a rename.

## 6. Open loops
Create from asks_you and you_said (owner me), from the user's own asks seen
in inline replies (owner them), from a missed call not returned in 3 hours
(owner me), and from an order with no delivery yet (owner them).
Close when the same person sends a confirms intent in that thread, when the
user marks it done, when the planned meeting happens, or quietly after 14
days.

## 7. Pattern engine
Linking works across sources at one moment. Patterns work along time within
one kind of event, and must work from a single event.

Series key: (family, kind, counterpart). Families and what to look for:
- sms: recharge, pack expiry, utility bill, rent or any repeated transfer
  to one number, card bill, loan instalment, money received.
- chat: per person, which weekdays and hours they write; how long the user
  usually takes to open it (removal with REASON_CLICK); per group, messages
  per day and how many carried an asks_you. A group with heavy volume and no
  asks for 30 days is proposed with "Suggested: drop".
- email: sender plus subject with numbers and dates stripped. Invoices,
  renewals, statements, weekly reports. Newsletters and promos are created
  as `quiet` and never proposed.
- calendar: a recurrence rule is a stated cycle. Also learn from real join
  and leave times: usually late, usually runs long.
- call: per person, weekday and hour; calls usually returned and how fast.
- order: same merchant and item reordered; usual delivery time per merchant.
- place (M8): usual arrival, leaving and length of stay.

Cycle, in this order:
1. Stated: the signal carries valid_days, valid_until, due_date or a
   recurrence rule. One event is enough. Next date is exact.
2. Learned: three or more events. Take the gaps, the median m and the median
   absolute deviation d. Accept if d <= 0.2 m, or if day-of-month varies by
   2 or less (monthly anchor), or if the same weekday holds in 4 of the last
   6 weeks (weekly anchor). Window = last + m, give or take max(1 day, 1.5 d).
3. Guess: one or two events and nothing stated. Take the cycle from
   `assets/rules/priors.json` (recharge 30 days, utility bill, rent, card
   bill and subscription monthly, gas cylinder 30 days, grocery reorder 7
   days). Kinds with no prior get no prediction.
`certainty` is always stored and always shown beside the date.

States: expected, due (window open), late (window closed plus one day of
grace, creates an open loop "usually done by now"), then back to expected
when a matching signal arrives. Two misses in a row makes the series
dormant. A matching event tightens the cycle; a new amount inside 25% is the
same series.

## 8. Feedback
Each series has `decision`: undecided, show, quiet, drop.
- undecided: listed under New on screen 11, at most four at a time, ranked
  money due first, then people, calendar, email, chat.
- show: appears in Coming up and Ahead, may remind.
- quiet: keeps learning, appears only when late.
- drop: `tracking = false`, plus a `suppress_rule` for that counterpart.
  Two drops with the same family and kind add a rule for the whole kind, so
  that kind is no longer proposed.
Implicit signals adjust `strength`: opened +1, reminder acted on +2,
reminder dismissed -1, shown for 30 days without a tap -1. Strength below
-3 moves a shown series to quiet and says so once. Every 90 days one check-in
asks whether the shown patterns are still useful. The same table records
link answers and per-app choices.

## 9. Day summary
Facts line: conversations, meetings, money spent, and hours at the main place
once Places exists. Headline: built from the three highest ranked items of
the day (thread with an open ask, meeting, order, trip) through the phrase
table `assets/rules/headline.json`. With fewer than two items, show the date
only. No model is involved.
