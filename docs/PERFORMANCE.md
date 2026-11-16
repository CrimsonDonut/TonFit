# TonFit: performance check

The requirements (section 4.4) set targets for a ten-year history of about
100,000 sets. This guide measures them. Do it once before the first release, and
again after any change to the database or to what the History tab loads.

| What | Target |
|---|---|
| Cold start to the dashboard | under 1.5 s |
| Expand a day card | under 100 ms |
| Open a year in History | under 300 ms |
| Save a set in a recent session, including every summary it affects | under 50 ms |
| Save a set in an old session (also updates the sessions after it) | under 150 ms |
| Suggestion engine for a session | under 100 ms |
| Database file after ten years | under about 15 MB |

The in-app benchmark judges each timing on its **95th percentile**: one slow run
does not fail a check, but a consistently slow operation does.

## 1. Quick check on your PC (about two minutes)

```
flutter test --dart-define=RUN_SLOW=true test/dev/ten_year_performance_test.dart
```

This builds a real database file with ten years of generated data, times every
operation above, and checks the file size. A PC is faster than a phone, so a
pass here is a good sign, not proof. A **fail** here is a real problem: send me
the printed report.

## 2. The real check, on a phone

Use a physical phone, not the emulator, and a **profile** build. Debug builds are
much slower and tell you nothing about the release.

```
flutter run --profile
```

1. **Export a backup first** (Settings > Export / Import) if you want to keep
   your own data. The next step replaces everything.
2. Settings > **Developer tools** (this row exists only in debug and profile
   builds, never in a release) > **Load 10-year test data**. It takes a minute
   or two on a phone. It also proves that restoring a large backup works.
3. **Run benchmark.** Read the PASS / FAIL lines, then tap **Copy** and paste
   the report to me.
4. Optional: **Time "Rebuild summaries"**. It is the one action that touches the
   whole history, so a few seconds to a minute is expected.

## 3. Cold start

With the ten-year data loaded, in PowerShell:

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
1..5 | ForEach-Object {
  & $adb shell am force-stop com.carlanthonypena.tonfit
  & $adb shell am start -W -n com.carlanthonypena.tonfit/.MainActivity | Select-String 'TotalTime'
}
```

`TotalTime` is milliseconds from launch to the first frame. Take the median of
the five runs; the target is under 1500. The first run after installing is
usually slower, so ignore it if it is the outlier.

## 4. Smoothness

Open DevTools (the link `flutter run` prints), go to the **Performance** tab, and
use the app on the ten-year data: scroll the History tab, switch years, expand and
collapse several days, scroll the heatmap sideways, open the add-set sheet. Look
for runs of red frames. An occasional slow frame is normal; a stutter you can feel
is not.

## 5. If something fails

Send me the copied report. The usual causes and fixes:

- **Open a year is slow:** the History list loads one year; the fix is to load
  one month at a time.
- **Save a set in an old session is slow:** that is the case that has to update
  every session after it. Fix: limit how far the update reaches.
- **Database is too big:** check for an index that is larger than the data.

## 6. Back to your own data

Settings > Export / Import > **Restore from backup**, and pick the file you
exported in step 2.1.
