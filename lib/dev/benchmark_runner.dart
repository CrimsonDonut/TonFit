import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import '../data/queries/workout_queries.dart';
import '../data/repositories/session_repository.dart';
import '../domain/epoch_day.dart';
import 'stats.dart';

/// Times the operations the requirements set targets for (section 4.4) against
/// whatever data is loaded. Meant for a 10-year dataset from
/// [SyntheticHistory], on a real phone in profile mode.
///
/// Writes are undone: every set it adds it deletes again.
class BenchmarkRunner {
  BenchmarkRunner({
    required this.db,
    required this.queries,
    required this.repo,
    int seed = 7,
  }) : _random = math.Random(seed);

  final AppDatabase db;
  final WorkoutQueries queries;
  final SessionRepository repo;
  final math.Random _random;

  Future<List<BenchResult>> run({void Function(String message)? onProgress}) async {
    final sessions = await (db.select(db.sessions)
          ..orderBy([(t) => OrderingTerm.asc(t.day)]))
        .get();
    if (sessions.length < 50) {
      throw StateError('Load the 10-year test data first (only ${sessions.length} sessions found).');
    }
    final days = [for (final s in sessions) s.day];
    final years = {for (final d in days) EpochDay.toDate(d).year}.toList()..sort();
    final today = EpochDay.today();

    final results = <BenchResult>[];

    onProgress?.call('Expanding days...');
    results.add(BenchResult(
      'Expand a day (load its sets)',
      100,
      await _sample(40, (_) => queries.loadDay(days[_random.nextInt(days.length)])),
    ));

    onProgress?.call('Opening years...');
    results.add(BenchResult(
      'Open a year in History (list and heatmap)',
      300,
      await _sample(years.length * 2, (i) async {
        final year = years[i % years.length];
        await queries.loadYear(year);
        await queries.loadHeatmap(year);
      }),
    ));

    onProgress?.call('Loading the dashboard...');
    results.add(BenchResult(
      'Dashboard data (today, streak, heatmap)',
      300,
      await _sample(10, (_) async {
        await queries.loadDay(today);
        await queries.watchStreak().first;
        await queries.loadHeatmap(EpochDay.toDate(today).year);
      }),
    ));

    onProgress?.call('Saving sets in recent sessions...');
    final recent = sessions.sublist(math.max(0, sessions.length - 20));
    results.add(BenchResult(
      'Save a set, recent session (all caches)',
      50,
      await _saveSets(15, () => recent[_random.nextInt(recent.length)].id),
    ));

    onProgress?.call('Saving sets in old sessions...');
    final old = sessions.sublist(0, sessions.length ~/ 3);
    results.add(BenchResult(
      'Save a set, old session (updates what follows)',
      50,
      await _saveSets(15, () => old[_random.nextInt(old.length)].id),
    ));

    onProgress?.call('Refreshing suggestions...');
    results.add(BenchResult(
      'Suggestion engine for a session',
      100,
      await _sample(20, (_) async {
        final s = recent[_random.nextInt(recent.length)];
        await repo.rebuildSuggestionsFor(s.id);
      }),
    ));

    return results;
  }

  /// One timed run of the slow, whole-history repair action, in milliseconds.
  Future<double> timeRebuildAll() async {
    final sw = Stopwatch()..start();
    await repo.rebuildAll();
    return sw.elapsedMicroseconds / 1000;
  }

  // ---------------------------------------------------------------------------

  /// Runs [action] twice to warm up, then [count] timed runs.
  Future<List<double>> _sample(int count, Future<void> Function(int i) action) async {
    for (var i = 0; i < 2; i++) {
      await action(i);
    }
    final samples = <double>[];
    for (var i = 0; i < count; i++) {
      final sw = Stopwatch()..start();
      await action(i);
      samples.add(sw.elapsedMicroseconds / 1000);
    }
    return samples;
  }

  /// Times adding one set to a random session from [pick], then removes it.
  Future<List<double>> _saveSets(int count, int Function() pick) async {
    final samples = <double>[];
    for (var i = -2; i < count; i++) {
      final log = await (db.select(db.exerciseLogs)
            ..where((t) => t.sessionId.equals(pick()))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])
            ..limit(1))
          .getSingleOrNull();
      if (log == null) continue;

      final sw = Stopwatch()..start();
      final id = await repo.addSet(exerciseLogId: log.id, weight: 6000, reps: 8);
      final ms = sw.elapsedMicroseconds / 1000;
      await repo.deleteSet(id); // leave the data as it was
      if (i >= 0) samples.add(ms); // the first two runs only warm up
    }
    return samples;
  }
}
