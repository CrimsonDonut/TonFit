# TonFit: release guide

Follow these in order. Items marked **(you)** need your accounts or machine.

## 0. Already prepared in the project

- Launcher icon: the logo on the app's `#121212` background, as an adaptive icon (sharp at every size), a themed-icon layer for Android 13+, and legacy PNGs. The 512 x 512 Play Store icon is `store/play_store_icon_512.png`.
- App version `1.0.0` and a migration scaffold in `app_database.dart`.
- Settings shows a privacy-policy link once `privacyPolicyUrl` is set in `lib/core/app_info.dart`, plus a short "data stays on this device / not medical advice" note.
- `store/privacy_policy.md` and `store/listing.md` (text to paste into Play Console).
- `tool/release_check.ps1` (builds and checks the release).

## 1. One-time project setup (you)

### 1.1 pubspec.yaml

```yaml
version: 1.0.0+1
```

The number after `+` is Google Play's version code. It must go up by at least 1 for every upload (`1.0.0+2`, `1.0.1+3`, ...). Then add the new package for the privacy link:

```
flutter pub add url_launcher
```

### 1.2 Create your upload key (once)

`keytool` ships with the Java that comes with Android Studio. Find it with `flutter doctor -v` (look for "Java binary at"); `keytool.exe` is in the same folder.

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v `
  -keystore $env:USERPROFILE\upload-keystore.jks -storetype JKS `
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- Keep the `.jks` file **outside** the project, and back it up in two places (a password manager and a second drive).
- Write the passwords down. Google Play App Signing holds the real app-signing key, so a lost upload key can be reset through Play support, but it costs days.

### 1.3 android/key.properties

Copy `android/key.properties.example` to `android/key.properties` and fill it in. Add these lines to your `.gitignore` so the key never reaches git:

```
android/key.properties
*.jks
*.keystore
```

### 1.4 android/app/build.gradle.kts

At the very top of the file, before `plugins {`:

```kotlin
import java.io.FileInputStream
import java.util.Properties
```

Just before the `android {` block:

```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Inside `android { ... }` (you already set `targetSdk = 36`; keep `minSdk = 26`):

```kotlin
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
```

If a release build starts but crashes at launch (debug works), R8 removed something it needed; send me the log and I'll add the keep rule.

### 1.5 android/app/src/main/AndroidManifest.xml

On the `<application` tag:

```xml
android:label="TonFit"
android:allowBackup="false"
```

`android:icon="@mipmap/ic_launcher"` is already there and now points to the new icon.

**About `allowBackup`.** With it on, Android silently copies the database file to Google Drive and restores it on a new phone. That is convenient, but a SQLite database in WAL mode can be backed up in an inconsistent state, and a damaged restore is hard to diagnose. For a first release I recommend `false`: users move their data with Export / Import, which is tested. If you prefer automatic restore, leave it `true` and be ready to handle reports of unreadable data.

### 1.6 Freeze the database schema (you)

Version 1 of the schema is what your first users get. Save it as the baseline for future migration tests:

```
dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/
```

Commit the `drift_schemas/drift_schema_v1.json` it creates. From now on, every change to `tables.dart` needs a version bump and an `onUpgrade` step (see the comment in `app_database.dart`), then:

```
dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/
dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
```

and a migration test that opens a v1 database and upgrades it. Ask me for that when the first schema change comes up.

### 1.7 Privacy policy URL (you)

Google Play requires a public web page. Fill in the `[placeholders]` in `store/privacy_policy.md`, then publish it somewhere with a stable address (GitHub Pages is free and takes a few minutes). Put the address in `privacyPolicyUrl` in `lib/core/app_info.dart` and in Play Console.

## 2. Verify the release build (you)

```powershell
.\tool\release_check.ps1
```

It runs the tests, builds a release APK and the app bundle, and reports:

- **Size.** The target is under 15 MB. If it is over, run `flutter build apk --release --analyze-size --target-platform android-arm64` and send me the output.
- **Permissions.** It should say there is no INTERNET permission. If a package adds one, tell me which.
- **16 KB alignment.** Google Play requires apps to work on devices with 16 KB memory pages, which affects native libraries such as SQLite. If the check or the Play Console reports a problem, send me the message.

Then install the release build on a real phone, not only the emulator:

```
flutter install --release
```

Checklist on the phone:

1. Fresh install shows the new icon and the name "TonFit".
2. Log a session with weighted, bodyweight, timed and sport exercises. Close the app from Recents and reopen: everything is still there.
3. Log yesterday from History, reorder exercises, delete a session.
4. Export a backup, uninstall, reinstall, restore: sessions, percentages, heatmap and streak match.
5. Turn on the largest system font size and check the main screens for clipped text.
6. Change the device date to tomorrow, reopen: the dashboard shows the new day.
7. Airplane mode on: nothing changes (the app should not need the internet).

## 3. Google Play Console (you)

### 3.1 Create the app

All apps > Create app. App name `TonFit: Workout Log`, language, App (not game), Free, accept the declarations. Upload `store/play_store_icon_512.png` and the other graphics from `store/listing.md`.

### 3.2 App content (Policy > App content)

- **Privacy policy:** your URL from 1.7.
- **Ads:** No ads.
- **App access:** all functionality is available without logging in.
- **Content rating:** answer the questionnaire honestly (a workout log with no user-generated content should come out as suitable for everyone).
- **Target audience:** adults and teens, not designed for children.
- **Data safety:** TonFit has no account, no analytics, no ads and no network permission, so you should be able to declare that it **collects no user data and shares none**. Read each question's definition in the form before answering, and make sure the answers match the privacy policy exactly.
- **Health apps declaration:** complete it. A workout log is a fitness app, and the form is required even for apps with no health features. Say that the app stores workout logs only on the device.
- **Government apps, financial features, news:** No.

### 3.3 Closed test, then production

If your developer account is **personal** and was created after 13 November 2023, Google requires a closed test with at least 12 testers opted in for 14 continuous days before you can apply for production access. Organization accounts are exempt. See what your Play Console says under Testing > Closed testing.

1. Build the bundle (the script does it) and upload `app-release.aab` under Testing > Closed testing > Create track > Create release. Accept Play App Signing.
2. Create a testers list (email addresses, or a Google Group) with at least 12 people who have a Google account and an Android phone. Share the opt-in link they get.
3. Ask each tester to **accept the invitation and install the app from Play**, and keep it installed for the 14 days. Invite a few more than 12, because if testers opt out and the count drops below 12 the 14 days do not count.
4. After 14 days, apply for production access in the Dashboard, answer the questions about your testing, then create the production release (the same bundle, or a newer one with a higher version code).

### 3.4 Every later release

1. Bump the number after `+` in pubspec.yaml.
2. Run `.\tool\release_check.ps1`.
3. Upload the new `.aab`, and keep that release's `build\symbols` folder.
4. If `tables.dart` changed: bump `schemaVersion`, add the `onUpgrade` step and its test first.
