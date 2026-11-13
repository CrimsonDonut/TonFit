# TonFit release check. Run from the project root:
#     .\tool\release_check.ps1
# Runs the tests, builds a release APK and an app bundle, then reports the size,
# the permissions the release build asks for, and native-library alignment.

$ErrorActionPreference = 'Stop'

function Step($text) {
    Write-Host ''
    Write-Host "== $text ==" -ForegroundColor Cyan
}

Step 'Tests'
flutter test
if ($LASTEXITCODE -ne 0) { throw 'Tests failed. Fix them before releasing.' }

Step 'Release APK (arm64), used for the checks below'
flutter build apk --release --obfuscate --split-debug-info=build/symbols --target-platform android-arm64
if ($LASTEXITCODE -ne 0) { throw 'The APK build failed.' }
$apk = Get-Item 'build\app\outputs\flutter-apk\app-release.apk'
$mb = [math]::Round($apk.Length / 1MB, 1)
Write-Host "APK size: $mb MB (target: under 15 MB)"

Step 'Permissions requested by the release build'
$manifest = Get-ChildItem 'build\app\intermediates\merged_manifests\release' -Recurse -Filter AndroidManifest.xml -ErrorAction SilentlyContinue | Select-Object -First 1
if ($null -eq $manifest) {
    Write-Warning 'Could not find the merged manifest.'
} else {
    $lines = Select-String -Path $manifest.FullName -Pattern 'uses-permission'
    if ($lines) { $lines | ForEach-Object { Write-Host $_.Line.Trim() } } else { Write-Host 'No permissions requested.' }
    if (Select-String -Path $manifest.FullName -Pattern 'android.permission.INTERNET' -Quiet) {
        Write-Warning 'INTERNET is requested. TonFit is meant to be offline-only, so find out which package adds it.'
    } else {
        Write-Host 'OK: no INTERNET permission.' -ForegroundColor Green
    }
}

Step 'Native-library alignment for 16 KB devices (zip level)'
$sdk = $env:ANDROID_HOME
if (-not $sdk) { $sdk = $env:ANDROID_SDK_ROOT }
if (-not $sdk) { $sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
$zipalign = Get-ChildItem (Join-Path $sdk 'build-tools') -Recurse -Filter zipalign.exe -ErrorAction SilentlyContinue |
    Sort-Object FullName -Descending | Select-Object -First 1
if ($null -eq $zipalign) {
    Write-Warning 'zipalign.exe not found. Install Android SDK Build-Tools 35 or newer from the SDK Manager.'
} else {
    & $zipalign.FullName -c -P 16 -v 4 $apk.FullName | Select-String -Pattern 'FAIL|BAD|Verification'
}
Write-Host 'Also open the APK in Android Studio (Build > Analyze APK) and check the Alignment column for .so files.'

Step 'App bundle for Google Play'
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
if ($LASTEXITCODE -ne 0) { throw 'The bundle build failed.' }
Write-Host 'Upload this file: build\app\outputs\bundle\release\app-release.aab' -ForegroundColor Green
Write-Host 'Keep the build\symbols folder for every release: it decodes crash reports.'
