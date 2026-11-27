# 06. Landing page and notification icon

## Landing page (Figma 16:927, `handover/screens/landing.png`)
Static site in `docs/`: `index.html`, `styles.css`, `privacy.html`,
`img/`. No framework, no build step, no script needed. Served by GitHub Pages
from `master` `/docs`. Fonts from Google Fonts (Newsreader 400 and 500,
Instrument Sans 400, 500, 600). Same tokens as the app. No italics.

Width 1440 design, content padded 80. Under 900 px: one column, phone below
the hero text, side padding 24, hero type 40/44.

1. Nav: mark plus "MemoryOS" left. Right: "How it works", "What it reads",
   "GitHub", primary button "Get the APK".
2. Hero, two columns. Left: label "For Android. Source on GitHub. Worked out
   on the phone." Headline (display/hero): "Your phone already knows how the
   day went." Body (body/lg): "MemoryOS ties calls, messages, emails,
   meetings and payments into threads you can look back on, and tells you
   what is due next. Nothing leaves the phone." Buttons "Get the APK"
   (primary) and "View the source" (quiet). Small line: "Installed directly
   from GitHub, not from the Play Store." Right: a phone frame (ink, radius
   44, 10 px bezel) showing the Today screen. Use the demo-mode golden image
   of Today from M6; until then `handover/screens/01-today.png`.
3. Three columns, each with a hairline above, a small accent label, a title
   and a paragraph:
   - Look back / Threads, not a log / "A missed call, the message after it,
     the email and the invite become one story with one open ask."
   - Look ahead / What comes next / "Recharges, bills, rent, the call you
     make every Friday. MemoryOS learns the cycle and says how sure it is."
   - Stay in charge / You decide what matters / "Show a pattern, track it
     quietly, or drop it. Every link says why it was made and can be undone."
4. White band. Left: "What it reads, and what it never does" and "MemoryOS
   only works because it can read a lot. So the rules are short, and the app
   shows them again next to every switch." Right, two lists with hairlines.
   Reads: SMS and call history already on the phone; Notifications from the
   apps you choose; Your calendar; Voice notes you record yourself.
   Never: Uploads anything. There is no server; Records or listens to calls;
   Opens your chat apps or reads inside them; Keeps one-time codes.
5. "Install in three steps": Download the APK (from the latest release on
   GitHub); Allow it (Android asks you to allow the install, then to allow
   restricted settings for MemoryOS); Choose what it reads (start with stored
   history if you want patterns on the first day). Buttons "Get the APK" and
   "Read the install guide" (anchor to a short section or the README).
6. Footer: mark, "MemoryOS. A tanziro.com project.", links GitHub and
   Privacy.

Links: APK buttons go to
`https://github.com/tanzir71/memoryOS/releases/latest`, source to the repo.
Do not write "open source" unless a LICENSE file exists; do not add one
yourself. `privacy.html` repeats section 4 in full sentences and states
that the app has no network permission of its own once fonts are bundled
(check the merged manifest before writing that sentence; if `INTERNET` is
still present, say "makes no network requests" instead).
Check: open `docs/index.html` in a headless browser if one is available and
confirm no horizontal scroll at 1440, 900 and 390 px.

## Notification icon (Figma 15:909, `handover/screens/icon.png`)
One mark, two states. Two arches form the M and a thread through two
moments. A dot means capturing, two short bars mean paused. Single colour,
drawn inside the 20 dp live area of a 24 dp canvas. It replaces
`android.R.drawable.ic_dialog_info` and the launcher mipmap used as a small
icon.

`android/app/src/main/res/drawable/ic_stat_memoryos.xml`
```xml
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24">
  <path android:pathData="M3.5,18V12.5a3.5,3.5 0 0 1 7,0V18M10.5,12.5a3.5,3.5 0 0 1 7,0V18"
      android:strokeColor="#FFFFFFFF" android:strokeWidth="2.4"
      android:strokeLineCap="round" android:strokeLineJoin="round"
      android:fillColor="#00000000"/>
  <path android:pathData="M17.5,6.5a2,2 0 1,0 4,0a2,2 0 1,0 -4,0"
      android:fillColor="#FFFFFFFF"/>
</vector>
```
`ic_stat_memoryos_paused.xml`: the same first path, and instead of the dot:
```xml
  <path android:pathData="M18.5,3.5v4M21,3.5v4"
      android:strokeColor="#FFFFFFFF" android:strokeWidth="1.9"
      android:strokeLineCap="round" android:fillColor="#00000000"/>
```

Status notification, posted by the listener service:
- Channel id `memoryos_status`, name "Capture status", importance LOW, no
  badge.
- Small icon by state, `setColor(0xFF45398A)`, ongoing, tap opens the app.
- Capturing: title "Capturing", text "<n> threads today. <m> notifications
  set aside.", action "Pause 1 hour".
- Paused: title "Paused until <time>", text "Nothing is being read.",
  action "Resume".
Also use the mark, white on #45398A, as the adaptive launcher icon
foreground (kept inside the 66 dp safe zone of the 108 dp canvas) with a
monochrome layer for themed icons. This launcher version is not drawn in
Figma; derive it from the same path.
