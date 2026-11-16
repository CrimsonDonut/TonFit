import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/data/backup/backup_repository.dart';
import 'package:tonfit/data/database/app_database.dart';
import 'package:tonfit/data/queries/workout_queries.dart';
import 'package:tonfit/data/repositories/session_repository.dart';
import 'package:tonfit/dev/benchmark_runner.dart';
import 'package:tonfit/dev/stats.dart';
import 'package:tonfit/dev/synthetic_history.dart';
import 'package:tonfit/domain/epoch_day.dart';

/// Slow (a minute or two), so it is off by default. Run it with:
///
///   flutter test --dart-define=RUN_SLOW=true test/dev/ten_year_performance_test.dart
///
/// It loads a ten-year history into a real database file on this computer and
/// checks the timed targets and the file size. A PC is faster than a phone, so
/// a pass here is a good sign, not proof: the on-phone benchmark in Settings >
/// Developer tools is the real check.
const _runSlow = bool.fromEnvironment('RUN_SLOW');

void main() {
  test(
    'ten years of data meets the performance targets',
    () async {
      final tmp = Directory.systemTemp.createTempSync('tonfit_perf_');
      addTearDown(() => tmp.deleteSync(recursive: true));
      final file = File('${tmp.path}/perf.sqlite');
      final db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);

      final sessions = SessionRepository(db);
      final backup = BackupRepository(db, sessions);

      final sw = Stopwatch()..start();
      final summary = await backup.restore(
        SyntheticHistory.generate(endDay: EpochDay.today()),
      );
      // ignore: avoid_print
      print('Loaded ${summary.sessions} sessions and ${summary.sets} sets in '
          '${sw.elapsed.inSeconds} s (including rebuilding every summary).');
      expect(summary.sets, greaterThan(80000));

      final results = await BenchmarkRunner(
        db: db,
        queries: WorkoutQueries(db),
        repo: sessions,
      ).run();

      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
      final bytes = file.lengthSync();
      // ignore: avoid_print
      print(formatReport(results, dbSizeBytes: bytes, header: 'Ten-year benchmark (this computer)'));

      for (final r in results) {
        expect(r.passes, isTrue, reason: '${r.name}: p95 ${r.p95.toStringAsFixed(1)} ms, target ${r.targetMs} ms');
      }
      expect(bytes, lessThan(15 * 1024 * 1024), reason: 'database file size');
    },
    skip: _runSlow
        ? false
        : 'Slow. Run: flutter test --dart-define=RUN_SLOW=true test/dev/ten_year_performance_test.dart',
    timeout: const Timeout(Duration(minutes: 15)),
  );
}
