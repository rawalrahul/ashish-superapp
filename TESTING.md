# Testing guide — Pause & Reflect

How to install the app on an Android phone and verify every feature works. No coding needed.

## Prerequisites
- An Android phone (Android 7.0 / SDK 24 or newer).
- USB cable, with **USB debugging** enabled on the phone:
  Settings → About phone → tap "Build number" 7 times → back → Developer options → enable
  "USB debugging". Plug into the PC and accept the "Allow USB debugging?" prompt.
- The toolchain set up per `SETUP.md`, and the app already built (`flutter build apk --debug`).

## 1. Install the app on the phone
From the project folder (`ashish-superapp`):
```cmd
flutter devices            :: confirm your phone is listed
flutter install            :: installs the debug APK onto it
```
Or install the file directly:
```cmd
adb install build\app\outputs\flutter-apk\app-debug.apk
```
You'll see a **Pause & Reflect** icon in the app drawer.

> Tip: to watch logs / hot-reload while testing, run `flutter run` instead — it installs, launches,
> and streams logs. Press `q` to quit.

## 2. One-time permission setup (in the app)
1. Open **Pause & Reflect** → go to the **Settings** tab.
2. Tap **Enable service** → in the system Accessibility screen, find "Pause & Reflect" and turn it
   ON → confirm the warning dialog. Back out to the app.
3. Tap **Allow over other apps** → toggle the permission ON for this app. Back out.
4. Tap the refresh icon on the permission card — it should now show **"Accessibility service enabled"**
   with a green check.

## 3. Choose what to pause
- In **Settings → Watched apps**, toggle ON any AI apps you have installed (ChatGPT, Claude,
  Gemini, Perplexity, Copilot). Apps not installed are labeled "(not installed)".
- **No AI app installed?** You can still test: toggle ON a common app to use as a stand-in. The
  curated list only shows AI apps, so for a pure test use `flutter run` and temporarily watch the
  phone's Settings app, or install one of the AI apps from Play.

## 4. Verify each behavior
Open a **watched** app and confirm:

| What to do | Expected result |
|---|---|
| Open a watched app | The pause screen appears over it, showing a reflection prompt |
| Watch the **Continue** button | Disabled, counting down ("Continue in 15", 14, …) |
| Wait for countdown to hit 0 | **Continue** becomes enabled |
| Tap **Continue** | Returns you into the AI app |
| Tap **Skip** during countdown | Proceeds immediately into the app (doesn't wait) |
| Press **Back** on the pause screen | Leaves without entering the app (records a back-out) |
| Type in the text box, then proceed | Counts as a "reflection" in stats |
| Reopen the same app right after proceeding | **No** pause screen (grace window active) |
| Reopen after the grace window (default 5 min) | Pause screen appears again |
| Open the app several times | Prompt **rotates** to the next one each time |

### Settings to exercise
- **Pause delay** slider → change to e.g. 5s, reopen a watched app, countdown starts at 5.
- **Grace window** slider → set to 1 min to test grace expiry quickly.
- **Require a reflection before continuing** → ON: Continue stays disabled until you type something.
- **Edit prompts** → change the list; new prompts show on the next pause.

## 5. Check the dashboard
Go to the **Stats** tab. The counters must match what you did:
- **Pauses** = total times the pause screen appeared.
- **Reflections** = times you typed something.
- **Backed out** = times you pressed back without entering.
- **Waited** / **Skipped** = Continue-after-countdown vs Skip.
- **By app** / **By day** breakdowns populate accordingly.
Pull down to refresh.

## 6. Troubleshooting
- **Pause screen doesn't appear:** re-check steps 2–3 (service enabled + overlay granted + app is
  in the watched list). Some phones (Xiaomi/Oppo/Vivo) need "Autostart"/"Display pop-up while
  running in background" enabled for the app in system settings.
- **It re-prompts too often or not enough:** check the grace-window setting.
- **See live logs:** run `flutter run` and watch the console while reproducing.

## What's not in v1
- **iOS**: the app runs but the interception section shows "coming in v2" (Apple's Screen Time API
  can't render this pause UX — see `plan.md`).
