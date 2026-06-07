# CLAUDE.md — project context for AI sessions

Read this first. It's the single source of truth for what this project is, what's done, and how to
work on it — so you don't have to re-explore the whole codebase.

## What this is

**Pause & Reflect** — a mobile app that intercepts the opening of user-selected AI apps (ChatGPT,
Claude, Gemini, Perplexity, Copilot) and shows a "pause and reflect" screen before the user
proceeds. Goal: add intentional friction so people open AI apps on purpose, not by reflex. All data
is local; there is no backend.

- **Stack:** Flutter (shared UI + logic) + native Kotlin AccessibilityService (Android).
- **v1 = Android only.** iOS builds and shows stats/settings but the interception section says
  "coming in v2" (Apple's Screen Time API cannot render this UX — full rationale in `plan.md`).
- Repo: https://github.com/rawalrahul/ashish-superapp (default branch `main`).

## Status (as of 2026-06-07)

**v1 is implemented, builds, and is committed to `main`.**
- `flutter analyze` clean; `flutter test` = **16/16 pass**; `flutter build apk --debug` succeeds
  (Android/Kotlin layer compiles).
- APK shared via GitHub Release tag `v0.1.0-android`.
- **Not yet done:** the on-device end-to-end test (enable a11y service + overlay, confirm the pause
  screen actually intercepts a watched app on a real phone). This is the only step that needs a
  physical device — see `TESTING.md`.

## Architecture

```
Open a watched AI app
  -> AppInterceptAccessibilityService gets TYPE_WINDOW_STATE_CHANGED (package name)
  -> watched? AND not in grace window?   (reads FlutterSharedPreferences directly)
  -> launch InterceptActivity on a PRE-WARMED CACHED Flutter engine (entrypoint: pauseMain)
  -> PauseScreen (Dart): rotating prompt, optional reflection text, delay countdown, Continue/Skip
  -> record outcome in drift DB; write grace timestamp back to shared prefs
  -> Continue/Skip -> back into the AI app (now in grace); Back -> record backedOut, go home
```

**Two Flutter engines:** the normal app runs from `main()`; the pause screen runs from a separate
`@pragma('vm:entry-point') pauseMain()` on a cached engine pre-warmed in `PauseApplication` (so the
pause screen appears instantly). They are separate isolates in the same process.

**Native <-> Dart bridge = shared_preferences only.** Dart writes config/grace via `SettingsStore`;
the Kotlin service reads the same `FlutterSharedPreferences` file (keys prefixed `flutter.`).
MethodChannels are used only for actions: `pause/native` (settings/permissions/installed-apps,
in `MainActivity`) and `pause/intercept` (getTarget/exit, in `InterceptActivity`).

## Key files

| Area | File |
|---|---|
| Curated AI app list + package names | `lib/constants/ai_apps.dart` |
| drift event log + DB connection | `lib/data/database.dart` (+ generated `database.g.dart`) |
| Stats aggregates | `lib/data/stats_repository.dart` |
| Event writes | `lib/data/event_repository.dart` |
| Settings + grace (shared with native) | `lib/data/settings_store.dart` |
| Pure logic (rotation, grace) — unit-tested | `lib/domain/pause_logic.dart` |
| Pause UI (countdown/skip/back/text) | `lib/features/pause/pause_screen.dart` |
| Pause host (wires DB/prefs/native exit) | `lib/features/pause/pause_host.dart` |
| Dashboard | `lib/features/home/home_screen.dart` |
| Settings UI (+ iOS "coming in v2") | `lib/features/settings/settings_screen.dart` |
| App entrypoints (main + pauseMain) | `lib/main.dart` |
| Native bridges (Dart) | `lib/services/native_bridge.dart`, `lib/services/intercept_channel.dart` |
| A11y detector | `android/.../AppInterceptAccessibilityService.kt` |
| Intercept Activity (cached engine) | `android/.../InterceptActivity.kt` |
| Engine pre-warm | `android/.../PauseApplication.kt` |
| App host + pause/native channel | `android/.../MainActivity.kt` |
| Manifest, a11y config | `android/app/src/main/AndroidManifest.xml`, `.../res/xml/accessibility_service_config.xml` |

Tests: `test/pause_logic_test.dart`, `test/stats_repository_test.dart`, `test/pause_screen_test.dart`.

## Design decisions / gotchas (don't re-litigate these)

1. **Watched list is stored as a single JSON string** (`SettingsStore.kWatchedPackagesJson`), NOT
   `setStringList` — the plugin's list encoding is awkward to parse from Kotlin (`JSONArray`).
2. **The a11y service must stay in the default process** (no `android:process`) so it shares the
   prefs cache with the app.
3. **shared_preferences int -> Long on Android.** Kotlin reads grace/delay with `getLong` and the
   `flutter.` key prefix.
4. **Confirmed package names:** ChatGPT `com.openai.chatgpt`, Claude `com.anthropic.claude`,
   Gemini `com.google.android.apps.bard`, Perplexity `ai.perplexity.app.android`,
   Copilot `com.microsoft.copilot`.
5. **Background-activity-start:** a bound a11y service is itself exempt; `SYSTEM_ALERT_WINDOW` is
   kept as a reliable fallback. Overlay-window fallback is noted in `plan.md` if Activity launch is
   flaky on some OEMs.
6. `database.g.dart` is **committed**, so analyze/test work without rerunning build_runner.
   Regenerate after changing drift tables: `dart run build_runner build`.

## Build / test / run

```bash
flutter pub get
dart run build_runner build      # only after changing drift tables
flutter analyze
flutter test                     # 16 tests
flutter build apk --debug        # output: build/app/outputs/flutter-apk/app-debug.apk
flutter run                      # on a connected Android phone
```

## Environment notes

- **Local dev (the user's Windows machine):** Flutter 3.44.1 at `C:\src\flutter`, Android SDK at
  `C:\Android` (platform 36, build-tools 36.0.0), JDK 17 at `C:\Java\...`. Full CLI setup in
  `SETUP.md`. Builds happen HERE.
- **Cloud/remote Claude Code sessions:** the container has NO Flutter/Android SDK and the Android
  SDK/Google Maven hosts (`dl.google.com`, `maven.google.com`) are BLOCKED by the network policy.
  So you can write/analyze Dart and run `flutter test` (after installing Flutter from
  storage.googleapis.com), but you CANNOT `flutter build apk` in the cloud — the user builds locally.
- **Git in the cloud container:** historically there was no `origin` remote; code was delivered to
  the user as a `git bundle` and the user pushed from their machine. Commit signing server may 400 —
  if so, `git -c commit.gpgsign=false commit`.

## Conventions

- Pure logic goes in `lib/domain/` so it's unit-testable without device/prefs/DB.
- Keep widgets dependency-light: the pause screen emits a `PauseResult` via callback; wiring to
  DB/prefs/native lives in `pause_host.dart`.
- Don't commit build artifacts (the APK). Share builds via GitHub Releases.

## Likely next work (v2 ideas)

- On-device hardening: OEM autostart quirks, overlay-window fallback, go-home-on-backout polish.
- iOS interception via Shortcuts Automation (Screen Time can't do the rich pause screen).
- Hard-block mode, scheduled focus windows, home-screen widgets, app icon/branding, release signing.
