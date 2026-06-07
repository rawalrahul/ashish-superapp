# Dev environment setup (Windows, command line only)

Everything needed to build & run **Pause & Reflect** on a fresh Windows 10/11 machine, with no
Android Studio and no GUI — just `cmd`. (This is the project's "requirements" list; a Flutter app
doesn't use a Python-style `requirements.txt`, so dependencies live in `pubspec.yaml` and the
toolchain is documented here.)

## What gets installed

| Component | Version | Where | Purpose |
|---|---|---|---|
| Git | any recent | (already installed) | clone / push |
| Flutter SDK | 3.44.1 stable | `C:\src\flutter` | build the app, Dart toolchain |
| Android cmdline-tools | latest (14742923) | `C:\Android\cmdline-tools\latest` | `sdkmanager`, build Android |
| Android platform | android-36 | `C:\Android\platforms` | Flutter 3.44 requires SDK 36 |
| Android build-tools | 36.0.0 | `C:\Android\build-tools` | compile APK |
| Android platform-tools | latest | `C:\Android\platform-tools` | `adb`, device install |
| JDK | Microsoft OpenJDK 17 | `C:\Java\jdk-17.x` | required by `sdkmanager`/Gradle |

Environment variables set: `ANDROID_HOME=C:\Android`, `JAVA_HOME=C:\Java\jdk-17.x`, and PATH
additions for `flutter\bin`, `cmdline-tools\latest\bin`, `platform-tools`, `JAVA_HOME\bin`.

> Versions move over time. If `flutter doctor` later asks for a newer Android SDK, just
> `sdkmanager "platforms;android-XX" "build-tools;XX.0.0"` for the version it names. Grab the
> current cmdline-tools filename from the "Command line tools only" box at
> https://developer.android.com/studio.

## Commands (run in order, in `cmd`)

### 1. Flutter SDK
Download `flutter_windows_3.44.1-stable.zip` from https://docs.flutter.dev/get-started/install/windows
into Downloads, then:
```cmd
mkdir C:\src 2>nul
tar -xf "%USERPROFILE%\Downloads\flutter_windows_3.44.1-stable.zip" -C C:\src
powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path','User') + ';C:\src\flutter\bin', 'User')"
```

### 2. JDK 17
```cmd
curl -L -o "%USERPROFILE%\Downloads\jdk17.zip" https://aka.ms/download-jdk/microsoft-jdk-17-windows-x64.zip
mkdir C:\Java 2>nul
tar -xf "%USERPROFILE%\Downloads\jdk17.zip" -C C:\Java
dir C:\Java
:: note the extracted folder name (e.g. jdk-17.0.19+10) and use it below
powershell -Command "[Environment]::SetEnvironmentVariable('JAVA_HOME', 'C:\Java\jdk-17.0.19+10', 'User')"
```

### 3. Android command-line tools
```cmd
curl -L -o "%USERPROFILE%\Downloads\commandlinetools-win.zip" https://dl.google.com/android/repository/commandlinetools-win-14742923_latest.zip
mkdir C:\Android\cmdline-tools 2>nul
tar -xf "%USERPROFILE%\Downloads\commandlinetools-win.zip" -C C:\Android\cmdline-tools
ren C:\Android\cmdline-tools\cmdline-tools latest
powershell -Command "[Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Android', 'User')"
```

### 4. Load the new env vars
Close and reopen `cmd` (so the permanent variables take effect), then:
```cmd
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"
flutter config --android-sdk C:\Android
flutter doctor --android-licenses
flutter doctor
```
Everything should be `[√]`.

## Build & run the app
```cmd
git clone https://github.com/rawalrahul/ashish-superapp.git
cd ashish-superapp
git checkout feat/android-pause-reflect-app
flutter pub get
flutter test            :: 16 tests should pass
flutter build apk --debug
flutter run             :: with an Android phone connected (USB debugging on)
```

The built APK lands at `build\app\outputs\flutter-apk\app-debug.apk`.
