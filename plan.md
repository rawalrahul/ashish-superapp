# Plan: AI-App Pause/Reflection App (v1 — Android)

## Context

Build a mobile app that intercepts the opening of user-selected AI apps (ChatGPT, Claude,
Gemini, Perplexity, etc.) and interrupts with a "pause and reflect" screen before the user
proceeds. Goal: add intentional friction so users reflect instead of reflexively opening AI
apps. Tracks behavior (opens, reflection attempts written, back-outs) fully locally, no backend.

**Key constraint discovered during planning (drove scope):** iOS's Screen Time API cannot
deliver the described pause screen. `ShieldConfiguration` only renders system UI (icon, title,
subtitle, ≤2 buttons) — no text field, no live delay timer. `ShieldAction` returns only
`.none`/`.close`/`.defer` and **cannot open the host app** (no `UIApplication` in the extension;
Apple FB17261679 still open). Apps that achieve this UX on iOS (one sec, Opal) use Shortcuts
Automation, not the shield. Android's AccessibilityService has no such limit and supports the
full rich UI.

**Decisions (confirmed with user):**
- v1 targets **Android** with the complete feature set. iOS ships as a **stub** (app builds and
  shows home/stats/settings; interception section says "coming in v2"). No Screen Time code in v1.
- Stack: **Flutter** for all shared UI + **native Kotlin** AccessibilityService via platform
  channels.

## Architecture

```
User opens watched AI app
  -> AccessibilityService fires TYPE_WINDOW_STATE_CHANGED (packageName)
  -> Service checks: watched? AND not in grace window?   (reads FlutterSharedPreferences)
  -> If intercept: launch InterceptActivity (cached Flutter engine, route "/pause")
  -> Dart PauseScreen: rotating prompt, optional text field, delay countdown, Continue / Skip
  -> Outcome recorded in Dart local DB; grace timestamp written back to shared prefs
  -> Continue/Skip: finish activity -> returns to AI app (now in grace)
  -> Back/home (no proceed): record "backed out", leave AI app
```

**Division of labor:** the native service is a *pure detector + launcher*. All counting, prompt
rotation, timing, and persistence live in Dart (the pause UI is Flutter anyway). The only
native↔Dart shared state is config + grace timestamps in `FlutterSharedPreferences`.

**Native↔Dart bridge = shared prefs (no custom IPC for config):** Dart writes settings via the
`shared_preferences` plugin (Android file `FlutterSharedPreferences`, keys prefixed `flutter.`).
The Kotlin service reads that same file directly. `MethodChannel` is used only for actions Dart
triggers (open a11y settings, open overlay-permission settings, query installed AI packages).

## Components

### Flutter (`lib/`)
- `main.dart` — entry. Branch on launch route: normal app vs `"/pause"` (passed as the cached
  engine's initial route from `InterceptActivity`). Target package arrives as an intent extra,
  forwarded to Dart.
- `features/pause/pause_screen.dart` — the interrupt UI:
  - Rotating reflection prompt (next-in-list index persisted in prefs).
  - Optional multiline text field ("write your own attempt").
  - Configurable delay: `Continue` disabled, countdown ticks, enables at 0.
  - `Skip` button (proceeds immediately — "Skip, not Cancel": it does NOT block the app).
  - `WillPopScope`/`PopScope`: back press = record `backedOut`, finish, return user out of AI app.
  - On Continue/Skip: if text non-empty -> mark `typedAttempt`; write grace timestamp; finish.
- `features/home/home_screen.dart` — dashboard: total opens, attempts typed, back-outs, per-app
  and per-day breakdown (derived from event log).
- `features/settings/settings_screen.dart` — pick watched apps (curated AI list, installed-check
  via channel), set delay seconds + grace minutes, manage/edit prompts, buttons to enable
  accessibility service and grant "display over other apps".
- `data/` — DB layer (drift/sqflite), models, repositories. Event log is the source of truth;
  stats are aggregate queries.
- `services/native_bridge.dart` — `MethodChannel("pause/native")`: `openA11ySettings`,
  `openOverlaySettings`, `isA11yEnabled`, `queryInstalledAiApps`, `setGrace(pkg, ts)`.

### Android native (`android/app/src/main/kotlin/...`)
- `AppInterceptAccessibilityService.kt` — `onAccessibilityEvent`: filter
  `TYPE_WINDOW_STATE_CHANGED`; ignore own package + launcher/home/system UI; read watched list +
  grace map from `FlutterSharedPreferences`; if should-intercept, launch `InterceptActivity`.
- `InterceptActivity.kt` — `FlutterActivity` using a **cached pre-warmed engine** (FlutterEngineCache)
  with `initialRoute "/pause"`; `singleTask`, `excludeFromRecents`, `noHistory`; forwards target
  package extra to Dart.
- `MainActivity.kt` — normal app UI host; registers the `MethodChannel` handlers; pre-warms and
  caches the Flutter engine for fast pause-screen launch.
- `res/xml/accessibility_service_config.xml` — `typeWindowStateChanged`, generic feedback,
  `canRetrieveWindowContent=false`, no package filter (filtering done in code).
- `AndroidManifest.xml` — declare service with `BIND_ACCESSIBILITY_SERVICE`; permissions
  `SYSTEM_ALERT_WINDOW` (grants background-activity-start exemption so the service can launch the
  Activity reliably on Android 10+) and `FOREGROUND_SERVICE` if needed; `<queries>` listing the
  curated AI package names (avoids restricted `QUERY_ALL_PACKAGES`); register `InterceptActivity`.

### iOS stub (`ios/`)
- Default Flutter runner only. Settings/stats UI render; interception section shows a "coming in
  v2" placeholder. No FamilyControls/DeviceActivity/ManagedSettings entitlements in v1.

## Data model (local only)

- `InterceptEvent { id, packageName, timestamp, outcome: {proceededAfterWait|skipped|backedOut},
  typedAttempt: bool, attemptText?: String, waitedSeconds: int }`
  - `attemptText` stored locally; optional setting to store bool-only for privacy.
- `Settings { watchedPackages: List<String>, delaySeconds: int, graceMinutes: int,
  requireTextBeforeContinue: bool, promptIndex: int }` — settings in `shared_preferences`
  (shared with native). Prompts list bundled as an asset, user-editable copy in prefs.
- Metrics are aggregate queries over `InterceptEvent`:
  - opens = total events; typedAttempts = count(typedAttempt); backedOut = count(outcome=backedOut).

## Curated AI app list (v1 seed, verify each package at build time)

ChatGPT `com.openai.chatgpt`, Gemini `com.google.android.apps.bard`,
Perplexity `ai.perplexity.app.android`, Copilot `com.microsoft.copilot`,
Claude — confirm current Play package before hardcoding. User toggles from this list; each is
installed-checked via `PackageManager` through the channel. List lives in one constants file for
easy extension.

## Key technical decisions / risks

- **Activity vs overlay:** launch a full-screen `FlutterActivity` (simpler than embedding a
  FlutterView in a `TYPE_APPLICATION_OVERLAY` window). Requires `SYSTEM_ALERT_WINDOW` to be
  granted so the background activity start is allowed on Android 10+. **Fallback** if unreliable
  on some OEMs: draw a real overlay window hosting a FlutterView. Decide during testing.
- **Cold-start lag:** pre-warm a cached Flutter engine so the pause screen appears instantly when
  an app is opened.
- **Play Store policy:** accessibility-service apps get heavy review; the digital-wellbeing use
  case is legitimate (cf. one sec, Opal) but the listing must clearly justify a11y usage.
  Flag for store-submission time, not a code blocker.
- **Grace window:** after Continue/Skip, store `lastAllowed[pkg]=now`; service suppresses
  re-prompts for `graceMinutes` so the user can actually use the app.

## Why NOT start with iOS (constraints & challenges)

Starting on iOS would block the core product for weeks and still ship a worse experience.

1. **The pause screen literally cannot be built with Screen Time.** `ShieldConfiguration`
   renders only system-drawn UI: an icon, title, subtitle, and up to two buttons. No text
   field ("write your own attempt"), no live countdown delay, no custom layout. The three
   described core features are impossible inside the shield.
2. **The shield cannot open your app.** `ShieldAction` only returns `.none`/`.close`/`.defer`;
   there is no `UIApplication`/`NSExtensionContext` in the extension, so you can't bounce the
   user into a rich Flutter screen. Apple enhancement request FB17261679 has sat open for years.
3. **The real-world iOS path is different tech entirely.** Apps with this UX (one sec, Opal)
   use **Shortcuts Automation** ("when [app] opens -> open my app"), not Screen Time. That means
   per-app manual setup by the user, it's bypassable, and it's a separate implementation from
   anything Screen Time gives you — so iOS work doesn't transfer to/from the Android build.
4. **Distribution is gated by Apple approval.** Any app using Managed Settings / Device Activity
   needs the **Family Controls (Distribution) entitlement**, requestable **only by the Account
   Holder**, with approval commonly taking **~4 weeks** (reports of 31-33+ days). Each extension
   (e.g. `DeviceActivityMonitorExtension`) must be approved separately. You cannot ship to the
   store until this clears.
5. **Higher cost of iteration.** Screen Time extensions are notoriously hard to debug (separate
   process, known recycled-token and stale-shield bugs since 2020), and require a paid Apple
   account + real device from day one.

**Conclusion:** Android (AccessibilityService) delivers the exact described UX with no approval
gate and faster iteration. Build and validate the product there first; revisit iOS in v2 with the
Shortcuts-Automation approach (and Screen Time only as an optional hard-block).

## Launch costs beyond coding (non-engineering)

These are real-money / process costs to actually publish, separate from development effort.

| Item | Android (Google Play) | iOS (App Store) |
|---|---|---|
| Developer account | **$25 one-time** | **$99 / year** (recurring) |
| Special entitlement | none (a11y is a manifest permission) | **Family Controls (Distribution)** — free but Account-Holder-only request, ~4-week approval, per-extension |
| Store commission | 15-30% — **only if** you add paid IAP/subscriptions; $0 for a free app | same 15-30%, only on paid IAP/subscriptions |
| Test device | emulator usable, but a **real Android phone** strongly recommended (a11y + overlay behave differently per OEM) | a **real iPhone + paid account** required even to develop Screen Time |

Other shared, often-overlooked costs:
- **Policy review risk (Android):** accessibility-service apps get heavy Play review. The
  listing must clearly justify a11y use for digital wellbeing (legitimate; one sec / Opal do
  this) or risk rejection/removal. Budget time for a clear store listing + privacy disclosures.
- **Data-safety / privacy declarations:** both stores require a privacy policy URL and a
  data-safety form even though all data is local (you still declare "no data collected").
- **App identity assets:** icon, screenshots, feature graphic, store copy. No cash cost if you
  make them yourself, but real time.
- **Apple fee waiver** exists only for nonprofits/gov/edu; a normal indie pays the $99/yr.

Sources: [Apple Developer Program ($99/yr)](https://developer.apple.com/support/compare-memberships/),
[Google Play registration ($25 one-time)](https://support.google.com/googleplay/android-developer/answer/6112435),
[Requesting Family Controls entitlement](https://developer.apple.com/documentation/familycontrols/requesting-the-family-controls-entitlement),
[ShieldAction can't open app (Apple forum)](https://developer.apple.com/forums/thread/719905).

## Validation & v1 implementation status (2026-06-07)

Plan validated against current sources and implemented. Two corrections were folded in during
implementation:

1. **Watched list stored as a JSON string**, not `setStringList` — the `shared_preferences` list
   encoding is awkward to parse from Kotlin. See `SettingsStore.kWatchedPackagesJson` and the
   `JSONArray` read in `AppInterceptAccessibilityService.kt`.
2. **The a11y service runs in the default process** (no `android:process`) so it shares the
   `FlutterSharedPreferences` cache with the app.

Resolved package names: Claude `com.anthropic.claude`, Gemini `com.google.android.apps.bard`
(both confirmed). Background-Activity-start note refined: a bound AccessibilityService is itself
exempt; `SYSTEM_ALERT_WINDOW` is kept as a reliable fallback.

**Status:** Dart feature set + Android native + iOS stub implemented. `flutter analyze` clean and
16 unit/widget tests pass (prompt rotation, grace policy, stats aggregation, pause-screen
countdown/outcomes/back-out). **Not yet done:** `flutter build apk` and the on-device a11y test —
the Android SDK / Google Maven hosts are blocked by this environment's network policy, so these
must be run on a machine with normal network + a real device.

## Build order

1. Scaffold the Flutter app (`flutter create`, set org id, Android `minSdk ~24`).
2. Data layer: DB, models, repositories, settings, bundled prompts. Unit-test aggregation.
3. Pause screen in Dart (delay timer, prompt rotation, text field, Continue/Skip, back handling)
   — drive normal-route preview first, before native wiring. Widget-test the timer/outcomes.
4. Native: AccessibilityService + InterceptActivity + cached engine + manifest/config + channel.
5. Settings + home dashboard UI; wire native bridge (enable a11y, overlay grant, query apps).
6. iOS stub placeholder.
7. End-to-end test on a real Android device.

## Verification

- `flutter run` on a physical Android device (emulator works but install a real watched app to test).
- Enable the accessibility service and "display over other apps" via the in-app setup buttons.
- For testing without AI apps installed, temporarily add a common package (e.g. the Settings app)
  to the watched list; opening it must trigger the pause screen.
- Verify: Continue stays disabled until the countdown hits 0; Skip proceeds immediately; back
  press records a back-out and exits the app; typed text flips the attempt counter.
- Grace: after proceeding, reopening within `graceMinutes` does NOT re-prompt; after it expires,
  it does.
- Home dashboard counters match the actions taken.
- Unit tests: stats aggregation, prompt rotation, grace logic. Widget tests: delay→enable,
  outcome recording, back-out path.
- iOS: `flutter build ios` succeeds; app shows stub interception section.
