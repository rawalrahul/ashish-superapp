# Pause & Reflect

A Flutter app that intercepts the AI apps you choose (ChatGPT, Claude, Gemini, Perplexity,
Copilot) with a brief **pause-and-reflect** screen before you proceed — adding intentional
friction so you open them on purpose instead of by reflex. All data stays on-device; no backend.

v1 targets **Android** (via an `AccessibilityService`). iOS builds and shows stats/settings, with
interception marked "coming in v2" — see `plan.md` for why Screen Time can't deliver this UX.

## How it works

```
Open a watched AI app
  -> AccessibilityService sees the window change (AppInterceptAccessibilityService.kt)
  -> watched? and not in grace window?   (reads FlutterSharedPreferences)
  -> launch InterceptActivity on a pre-warmed cached Flutter engine (route: pauseMain)
  -> PauseScreen: rotating prompt, optional reflection text, delay countdown, Continue / Skip
  -> outcome recorded in the local drift DB; grace timestamp written back to prefs
  -> Continue/Skip -> back into the AI app (now in grace); Back -> records a back-out
```

## Project layout

- `lib/data/` — drift event log (`database.dart`), `EventRepository`, `StatsRepository`,
  `SettingsStore` (shared with native via `shared_preferences`).
- `lib/domain/pause_logic.dart` — pure prompt-rotation + grace logic (unit-tested).
- `lib/features/` — `pause/`, `home/`, `settings/` screens.
- `lib/services/` — `native_bridge.dart` (`pause/native`), `intercept_channel.dart`
  (`pause/intercept`).
- `android/app/src/main/kotlin/.../` — `PauseApplication` (engine pre-warm),
  `AppInterceptAccessibilityService`, `InterceptActivity`, `MainActivity`.

## Build & run

```bash
flutter pub get
dart run build_runner build      # generates lib/data/database.g.dart
flutter analyze
flutter test                     # 16 unit + widget tests
flutter build apk --debug        # requires Android SDK + Google Maven access
flutter run                      # on a real Android device (recommended)
```

> Note: `build_runner` output (`*.g.dart`) is committed, so `pub get` + `analyze`/`test` work
> without regenerating. Regenerate after changing drift tables.

## On-device setup (Android)

1. Open the app → Settings → choose which AI apps to watch.
2. Tap **Enable service** and turn on "Pause & Reflect" in Accessibility settings.
3. Tap **Allow over other apps** and grant the permission.
4. Open a watched app — the pause screen should appear.

To test without an AI app installed, temporarily add a common package (e.g. the Settings app) to
the watched list.
