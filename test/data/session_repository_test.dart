import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/data/database/app_database.dart';
import 'package:tonfit/data/repositories/session_repository.dart';
import 'package:tonfit/domain/epoch_day.dart';

// Weeks used below (all Mondays in 2026):
//   Oct 5, Oct 12, Oct 19, Oct 26
// Epoch-day of Mon 19 Oct 2026 is 20745.

late AppDatabase db;
late SessionRepository repo;
late DateTime now;
int goal = 4;

DateTime at(int month, int day, [int hour = 18, int minute = 0]) =>
    DateTime(2026, month, day, hour, minute);

Future<int> programId(String name) async => (await (db.select(db.programs)
          ..where((t) => t.name.equals(name)))
        .getSingle())
    .id;

Future<int> exerciseId(String program, String name) async {
  final pid = await programId(program);
  return (await (db.select(db.exercises)
            ..where((t) => t.programId.equals(pid) & t.name.equals(name)))
          .getSingle())
      .id;
}

/// Logs a whole workout. [sets] maps exercise name -> list of (kg, reps).
/// Returns the session id.
Future<int> workout(
  String program,
  DateTime when,
  Map<String, List<(int, int)>> sets,
) async {
  now = when;
  final sessionId = await repo.startSession(programId: await programId(program));
  var minute = 0;
  for (final entry in sets.entries) {
    final logId = await repo.addExercise(
      sessionId: sessionId,
      exerciseId: await exerciseId(program, entry.key),
    );
    for (final (kg, reps) in entry.value) {
      await repo.addSet(
        exerciseLogId: logId,
        weight: kg * 100,
        reps: reps,
        at: when.add(Duration(minutes: minute++)),
      );
    }
  }
  return sessionId;
}

Future<ExerciseLog> logOf(int sessionId, String program, String name) async {
  final eid = await exerciseId(program, name);
  return (db.select(db.exerciseLogs)
        ..where((t) => t.sessionId.equals(sessionId) & t.exerciseId.equals(eid)))
      .getSingle();
}

Future<Session> sessionRow(int id) =>
    (db.select(db.sessions)..where((t) => t.id.equals(id))).getSingle();

Future<List<Suggestion>> suggestionsFor(int sessionId) =>
    (db.select(db.suggestions)..where((t) => t.sessionId.equals(sessionId)))
        .get();

Future<Map<String, Object?>> snapshot() async => {
      'logs': [
        for (final r in await (db.select(db.exerciseLogs)
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get())
          r.toJson(),
      ],
      'sessions': [
        for (final r in await (db.select(db.sessions)
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get())
          r.toJson(),
      ],
      'days': [
        for (final r in await (db.select(db.daySummaries)
              ..orderBy([(t) => OrderingTerm.asc(t.day)]))
            .get())
          r.toJson(),
      ],
      'weeks': [
        for (final r in await (db.select(db.weekSummaries)
              ..orderBy([(t) => OrderingTerm.asc(t.weekStart)]))
            .get())
          r.toJson(),
      ],
      'stats': [
        for (final r in await (db.select(db.exerciseStats)
              ..orderBy([(t) => OrderingTerm.asc(t.exerciseId)]))
            .get())
          r.toJson(),
      ],
      'streak': (await db.select(db.streakStates).getSingle()).toJson(),
      // Suggestion ids are regenerated, so compare their content only.
      'suggestions': [
        for (final r in await (db.select(db.suggestions)
              ..orderBy([
                (t) => OrderingTerm.asc(t.sessionId),
                (t) => OrderingTerm.asc(t.priority),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get())
          [r.sessionId, r.exerciseLogId, r.ruleId, r.priority, r.params],
      ],
    };

void main() {
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = at(10, 19);
    goal = 4;
    repo = SessionRepository(db, clock: () => now, weeklyGoal: () => goal);
  });

  tearDown(() => db.close());

  test('seed data exists', () async {
    final programs = await db.select(db.programs).get();
    expect(programs.map((p) => p.name).toList(),
        equals(['Push', 'Pull', 'Legs', 'Upper', 'Full Body']));
    final streak = await db.select(db.streakStates).getSingle();
    expect(streak.currentWeeks, equals(0));
  });

  test('starting a session twice on one day returns the same session', () async {
    final push = await programId('Push');
    final a = await repo.startSession(programId: push);
    final b = await repo.startSession(programId: push);
    expect(a, equals(b));
    expect((await db.select(db.sessions).get()).length, equals(1));
  });

  test('first session shows "New" and updates every summary', () async {
    goal = 1;
    final sid = await workout('Push', at(10, 19), {
      'Bench Press': [(60, 10), (60, 8), (57, 8)],
    });

    final log = await logOf(sid, 'Push', 'Bench Press');
    expect(log.pct, isNull);
    expect(log.prevLogId, isNull);
    expect(log.setCount, equals(3));
    expect(log.volume, equals(6000 * 10 + 6000 * 8 + 5700 * 8));
    expect(log.bestWeight, equals(6000));
    expect(log.repsAtTop, equals(10));

    final s = await sessionRow(sid);
    expect(s.summaryPct, isNull);
    expect(s.prevSessionId, isNull);
    expect(s.setCount, equals(3));

    final day = await (db.select(db.daySummaries)
          ..where((t) => t.day.equals(20745)))
        .getSingle();
    expect(day.setCount, equals(3));
    expect(day.isRest, isFalse);

    final week = await db.select(db.weekSummaries).getSingle();
    expect(week.weekStart, equals(20745));
    expect(week.sessionCount, equals(1));

    final stats = await db.select(db.exerciseStats).getSingle();
    expect(stats.bestWeight, equals(6000));
    expect(stats.bestRepsAtWeight, equals(10));

    final streak = await db.select(db.streakStates).getSingle();
    expect(streak.currentWeeks, equals(1));
    expect(streak.longestWeeks, equals(1));
  });

  test('time in and time out come from the first and last set', () async {
    final sid = await workout('Push', at(10, 19, 18, 0), {
      'Bench Press': [(60, 10), (60, 8)],
      'Overhead Press': [(40, 8)],
    });
    final s = await sessionRow(sid);
    final first = at(10, 19, 18, 0).millisecondsSinceEpoch ~/ 1000;
    final last = at(10, 19, 18, 2).millisecondsSinceEpoch ~/ 1000;
    expect(s.timeIn, equals(first));
    expect(s.timeOut, equals(last));
  });

  test('second session compares with the previous one of the same program',
      () async {
    final a = await workout('Push', at(10, 19), {
      'Bench Press': [(60, 10), (60, 10), (60, 10)], // 180000
    });
    final b = await workout('Push', at(10, 26), {
      'Bench Press': [(60, 10), (60, 10), (60, 11)], // 186000
    });

    final logA = await logOf(a, 'Push', 'Bench Press');
    final logB = await logOf(b, 'Push', 'Bench Press');
    expect(logB.prevLogId, equals(logA.id));
    expect(logB.pct, equals(33)); // +3.3%

    final sB = await sessionRow(b);
    expect(sB.prevSessionId, equals(a));
    expect(sB.summaryPct, equals(33));
  });

  test('skipped and new exercises do not distort the session percentage',
      () async {
    await workout('Push', at(10, 19), {
      'Bench Press': [(60, 10)], // 60000
      'Overhead Press': [(40, 10)], // 40000, skipped next time
    });
    final b = await workout('Push', at(10, 26), {
      'Bench Press': [(66, 10)], // 66000 (+10%)
      'Incline Dumbbell Press': [(50, 10)], // new this time
    });
    expect((await sessionRow(b)).summaryPct, equals(100)); // +10.0%
    final incline = await logOf(b, 'Push', 'Incline Dumbbell Press');
    expect(incline.pct, isNull);
  });

  test('editing a past set updates the following session', () async {
    final a = await workout('Push', at(10, 19), {
      'Bench Press': [(60, 10)],
    });
    final b = await workout('Push', at(10, 26), {
      'Bench Press': [(66, 10)],
    });
    expect((await logOf(b, 'Push', 'Bench Press')).pct, equals(100));

    final logA = await logOf(a, 'Push', 'Bench Press');
    final target = await (db.select(db.setEntries)
          ..where((t) => t.exerciseLogId.equals(logA.id)))
        .getSingle();
    await repo.updateSet(setId: target.id, weight: 5500, reps: 10); // 55000

    // (66000 - 55000) / 55000 = +20.0%
    expect((await logOf(b, 'Push', 'Bench Press')).pct, equals(200));
    expect((await sessionRow(b)).summaryPct, equals(200));
  });

  test('deleting a set renumbers the rest and refreshes totals', () async {
    final sid = await workout('Push', at(10, 19), {
      'Bench Press': [(60, 10), (60, 8), (57, 8)],
    });
    final log = await logOf(sid, 'Push', 'Bench Press');
    final second = await (db.select(db.setEntries)
          ..where((t) => t.exerciseLogId.equals(log.id) & t.idx.equals(2)))
        .getSingle();

    await repo.deleteSet(second.id);

    final rows = await (db.select(db.setEntries)
          ..where((t) => t.exerciseLogId.equals(log.id))
          ..orderBy([(t) => OrderingTerm.asc(t.idx)]))
        .get();
    expect(rows.map((r) => r.idx).toList(), equals([1, 2]));
    expect(rows.map((r) => r.reps).toList(), equals([10, 8]));
    final fresh = await logOf(sid, 'Push', 'Bench Press');
    expect(fresh.volume, equals(6000 * 10 + 5700 * 8));
    expect(fresh.setCount, equals(2));
  });

  test('removing an exercise relinks the next occurrence', () async {
    final a = await workout('Push', at(10, 12), {'Bench Press': [(60, 10)]});
    final b = await workout('Push', at(10, 19), {'Bench Press': [(62, 10)]});
    final c = await workout('Push', at(10, 26), {'Bench Press': [(66, 10)]});

    final logA = await logOf(a, 'Push', 'Bench Press');
    final logB = await logOf(b, 'Push', 'Bench Press');
    expect((await logOf(c, 'Push', 'Bench Press')).prevLogId, equals(logB.id));

    await repo.removeExercise(logB.id);

    final logC = await logOf(c, 'Push', 'Bench Press');
    expect(logC.prevLogId, equals(logA.id));
    expect(logC.pct, equals(100)); // 66000 vs 60000

    // Session b is now empty, so session c compares with session a instead.
    final sC = await sessionRow(c);
    expect(sC.prevSessionId, equals(a));
    expect(sC.summaryPct, equals(100));
  });

  test('rest days: markable, cleared by a session, refused on session days',
      () async {
    final day = EpochDay.fromDate(DateTime(2026, 10, 20));
    expect(await repo.markRest(day), isTrue);
    var row = await (db.select(db.daySummaries)
          ..where((t) => t.day.equals(day)))
        .getSingle();
    expect(row.isRest, isTrue);

    now = at(10, 20);
    await repo.startSession(programId: await programId('Pull'));
    row = await (db.select(db.daySummaries)..where((t) => t.day.equals(day)))
        .getSingle();
    expect(row.isRest, isFalse);

    expect(await repo.markRest(day), isFalse); // has a session now
  });

  test('weekly streak counts weeks that reach the goal', () async {
    goal = 2;
    await workout('Push', at(10, 19), {'Bench Press': [(60, 10)]}); // Mon
    var streak = await db.select(db.streakStates).getSingle();
    expect(streak.currentWeeks, equals(0)); // 1 of 2 sessions so far

    await workout('Pull', at(10, 21), {'Barbell Row': [(50, 10)]}); // Wed
    streak = await db.select(db.streakStates).getSingle();
    expect(streak.currentWeeks, equals(1));
    expect(streak.longestWeeks, equals(1));
  });

  test('stall suggestion appears after four flat sessions', () async {
    int? last;
    for (final d in [5, 12, 19, 26]) {
      last = await workout('Push', at(10, d), {
        'Overhead Press': [(40, 8), (40, 8), (40, 8)],
      });
    }
    final hits = await suggestionsFor(last!);
    expect(hits.length, equals(1));
    expect(hits.single.ruleId, equals('stall'));

    // The third session only has three sessions of history: no message.
    final all = await db.select(db.sessions).get();
    final third = all.firstWhere((s) => s.day == EpochDay.fromDate(DateTime(2026, 10, 19)));
    expect(await suggestionsFor(third.id), isEmpty);
  });

  test('personal best suggestion after a heavier session', () async {
    await workout('Push', at(10, 19), {'Bench Press': [(60, 8)]});
    final b = await workout('Push', at(10, 26), {'Bench Press': [(62, 5)]});
    final hits = await suggestionsFor(b);
    expect(hits.single.ruleId, equals('pr'));
  });

  test('rebuildAll restores every cached value after corruption', () async {
    goal = 1;
    for (final d in [5, 12, 19, 26]) {
      await workout('Push', at(10, d), {
        'Overhead Press': [(40, 8), (40, 8), (40, 8)],
        'Bench Press': [(60, 10)],
      });
    }
    await repo.markRest(EpochDay.fromDate(DateTime(2026, 10, 21)));
    final before = await snapshot();
    expect((before['suggestions'] as List), isNotEmpty); // the stall rule fired

    // Corrupt every derived table.
    await db.customStatement(
        'UPDATE exercise_logs SET volume = 0, pct = 999, prev_log_id = NULL, '
        'best_weight = 1, reps_at_top = 99');
    await db.customStatement(
        'UPDATE sessions SET volume = 0, summary_pct = 500, '
        'prev_session_id = NULL, set_count = 0');
    await db.customStatement('DELETE FROM suggestions');
    await db.customStatement('DELETE FROM week_summaries');
    await db.customStatement('DELETE FROM exercise_stats');
    await db.customStatement(
        'UPDATE day_summaries SET set_count = 0 WHERE is_rest = 0');
    await db.customStatement(
        'UPDATE streak_states SET current_weeks = 42, longest_weeks = 42');
    expect(await snapshot(), isNot(equals(before)));

    await repo.rebuildAll();

    expect(await snapshot(), equals(before));
  });

  test('deleting a session removes it and repairs what depended on it', () async {
    goal = 1;
    final a = await workout('Push', at(10, 12), {'Bench Press': [(60, 10)]});
    final b = await workout('Push', at(10, 19), {'Bench Press': [(62, 10)]});
    final c = await workout('Push', at(10, 26), {'Bench Press': [(66, 10)]});
    expect((await logOf(c, 'Push', 'Bench Press')).pct, equals(65)); // vs 62 kg

    var streak = await db.select(db.streakStates).getSingle();
    expect([streak.currentWeeks, streak.longestWeeks], equals([3, 3]));

    await repo.deleteSession(b);

    // Gone: the session, its exercises, its sets and its heatmap day.
    expect(await (db.select(db.sessions)..where((t) => t.id.equals(b))).get(), isEmpty);
    expect(await (db.select(db.exerciseLogs)..where((t) => t.sessionId.equals(b))).get(),
        isEmpty);
    expect(await db.select(db.setEntries).get().then((r) => r.length), equals(2));
    final day = EpochDay.fromDate(DateTime(2026, 10, 19));
    expect(await (db.select(db.daySummaries)..where((t) => t.day.equals(day))).get(),
        isEmpty);

    // The next session now compares with the one before the deleted one.
    final logA = await logOf(a, 'Push', 'Bench Press');
    final logC = await logOf(c, 'Push', 'Bench Press');
    expect(logC.prevLogId, equals(logA.id));
    expect(logC.pct, equals(100)); // 66 kg vs 60 kg
    final sC = await sessionRow(c);
    expect(sC.prevSessionId, equals(a));
    expect(sC.summaryPct, equals(100));

    // The deleted week no longer counts, so the streak is broken.
    final weeks = await (db.select(db.weekSummaries)
          ..orderBy([(t) => OrderingTerm.asc(t.weekStart)]))
        .get();
    expect(weeks.map((w) => w.weekStart).toList(), equals([20738, 20752]));
    streak = await db.select(db.streakStates).getSingle();
    expect([streak.currentWeeks, streak.longestWeeks], equals([1, 1]));

    // Personal bests no longer include the deleted session.
    final stats = await db.select(db.exerciseStats).getSingle();
    expect(stats.bestWeight, equals(6600));
  });

  test('a day can be logged again after its session is deleted', () async {
    final first = await workout('Push', at(10, 19), {'Bench Press': [(60, 10)]});
    await repo.deleteSession(first);
    expect(await db.select(db.sessions).get(), isEmpty);

    await workout('Pull', at(10, 19), {'Barbell Row': [(50, 10)]});
    final sessions = await db.select(db.sessions).get();
    expect(sessions.length, equals(1));
    expect(sessions.single.programId, equals(await programId('Pull')));
  });

  test('logging a past day updates the session that follows it', () async {
    final c = await workout('Push', at(10, 26), {'Bench Press': [(66, 10)]});
    expect((await logOf(c, 'Push', 'Bench Press')).pct, isNull); // first Push

    // Backfill the 19th while "today" is still the 26th.
    final pid = await programId('Push');
    final eid = await exerciseId('Push', 'Bench Press');
    final a = await repo.startSession(
      programId: pid,
      day: EpochDay.fromDate(DateTime(2026, 10, 19)),
    );
    final logId = await repo.addExercise(sessionId: a, exerciseId: eid);
    await repo.addSet(exerciseLogId: logId, weight: 6000, reps: 10);

    final logC = await logOf(c, 'Push', 'Bench Press');
    expect(logC.prevLogId, equals(logId));
    expect(logC.pct, equals(100)); // 66 kg vs 60 kg
    expect((await sessionRow(c)).prevSessionId, equals(a));

    // Times are only stamped for today's session, never for a backfilled day.
    final past = await sessionRow(a);
    expect(past.timeIn, isNull);
    expect(past.timeOut, isNull);
  });
}
