\# Release guide — Pause \& Reflect



\## One-time setup



\### 1. Create a Play Store developer account

\- Go to https://play.google.com/console

\- Pay the one-time $25 registration fee

\- The same account is used for every app you ever publish



\### 2. Create a signing keystore (do this once, keep it safe)

From the project folder on your Windows machine:

```cmd

keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pause-reflect

```

You'll be asked for a password and some details (name, org, country). Remember the password — you need it every build.



\*\*Important:\*\* Never commit `release-key.jks` to git. Add it to `.gitignore`. If you lose this file you cannot update your app on Play Store.



\### 3. Configure signing in the project

Create the file `android/key.properties` (never commit this either):

```

storePassword=YOUR\_KEYSTORE\_PASSWORD

keyPassword=YOUR\_KEY\_PASSWORD

keyAlias=pause-reflect

storeFile=../../../release-key.jks

```



Add to the top of `android/app/build.gradle.kts`, before the `android {` block:

```kotlin

val keyProperties = java.util.Properties()

val keyPropertiesFile = rootProject.file("key.properties")

if (keyPropertiesFile.exists()) keyProperties.load(keyPropertiesFile.inputStream())

```



Replace the `buildTypes` block with:

```kotlin

signingConfigs {

&#x20;   create("release") {

&#x20;       keyAlias = keyProperties\["keyAlias"] as String

&#x20;       keyPassword = keyProperties\["keyPassword"] as String

&#x20;       storeFile = keyProperties\["storeFile"]?.let { file(it as String) }

&#x20;       storePassword = keyProperties\["storePassword"] as String

&#x20;   }

}

buildTypes {

&#x20;   release {

&#x20;       signingConfig = signingConfigs.getByName("release")

&#x20;   }

}

```



Add both files to `.gitignore`:

```

android/key.properties

release-key.jks

```



\---



\## Publishing a new version



\### Step 1 — Bump the version

In `android/app/build.gradle.kts`, increment both values:

```kotlin

versionCode = 2          // must increase by at least 1 with every upload

versionName = "1.1"      // what users see in Play Store ("1.0", "1.1", "2.0" etc)

```

`versionCode` must always go up. `versionName` is just a label — use whatever scheme you like.



\### Step 2 — Build the release APK

```cmd

flutter build apk --release

```

Output: `build\\app\\outputs\\flutter-apk\\app-release.apk`



\### Step 3 — Upload to Play Console

1\. Go to https://play.google.com/console → your app

2\. Choose a track: \*\*Internal testing\*\* (just you + Ashish), \*\*Closed testing\*\*, or \*\*Production\*\*

3\. Create a new release → upload `app-release.apk`

4\. Fill in the release notes (what changed in this version) → save and publish



\*\*You do not delete the old version.\*\* Play Console keeps the history automatically. Uploading a new APK with a higher `versionCode` makes it the current version — old versions stay in history for reference.



\### Step 4 — Users get the update

\- Users who installed from Play Store are notified automatically

\- Play Store updates the app in the background (or shows an "Update" button)

\- No uninstall/reinstall needed — updates in place



\---



\## Where things live



| What | Where |

|---|---|

| Source code changes | Git commit + push to GitHub |

| Release APK for users | Upload directly to Play Console |

| Test builds for Ashish | GitHub Releases (optional, for sideload testing) |

| Signing keystore | Local machine only — never in git |



Git and Play Store are completely independent. You push source code to GitHub; you upload APKs to Play Console. Neither one affects the other.



\---



\## Tracks explained



| Track | Who can install | Use it for |

|---|---|---|

| Internal testing | Up to 100 specific Gmail addresses you invite | Testing with just you and Ashish |

| Closed testing (alpha) | Invite-only list | Wider test group |

| Open testing (beta) | Anyone (labeled beta) | Soft launch |

| Production | Everyone | Full public release |



Start with Internal testing. Move to Production only when you're satisfied. You can stay in Internal testing as long as you want and keep pushing updates — there's no time limit.



