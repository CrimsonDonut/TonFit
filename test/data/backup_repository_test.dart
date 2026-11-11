import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/data/backup/backup_repository.dart';
import 'package:tonfit/data/database/app_database.dart';
import 'package:tonfit/data/repositories/session_repository.dart';
import 'package:tonfit/domain/backup_format.dart';
import 'package:tonfit/domain/epoch_day.dart';

late Directory tmp;
final clock = DateTime(2026, 10, 26, 19);

class Env {
  Env() : db = AppDatabase(NativeDatabase.memory()) {
    sessions = SessionRepository(db, clock: () => clock, weeklyGoal: () => 2);
    backup = BackupRepository(db, sessions);
  }
  final AppDatabase db;
  late final SessionRepository sessions;
  late final BackupRepository backup;
}

/// Logs a workout on the day of [when]. Sets are (weight in hundredths of a
/// kg or null, reps).
Future<void> addWorkout(
  Env env,
  String program,
  DateTime when,
  Map<String, List<(int?, int)>> sets,
) async {
  final db = env.db;
  final pid = (await (db.select(db.programs)
            ..where((t) => t.name.equals(program)))
          .getSingle())
      .id;
  final sid = await env.sessions
      .startSession(programId: pid, day: EpochDay.fromDate(when));
  var minute = 0;
  for (final entry in sets.entries) {
    final eid = (await (db.select(db.exercises)
              ..where((t) => t.programId.equals(pid) & t.name.equals(entry.key)))
            .getSingle())
        .id;
    final logId = await env.sessions.addExercise(sessionId: sid, exerciseId: eid);
    for (final (weight, reps) in entry.value) {
      await env.sessions.addSet(
        exerciseLogId: logId,
        weight: weight,
        reps: reps,
        at: when.add(Duration(minutes: minute++)),
      );
    }
  }
}

Future<void> buildHistory(Env env) async {
  await addWorkout(env, 'Push', DateTime(2026, 10, 19, 18), {
    'Bench Press': [(6000, 10), (6000, 8)],
    'Dips': [(null, 12), (1000, 8)],
  });
  await addWorkout(env, 'Pull', DateTime(2026, 10, 21, 18), {
    'Barbell Row': [(5000, 10)],
  });
  await addWorkout(env, 'Push', DateTime(2026, 10, 26, 18), {
    'Bench Press': [(6250, 8), (6000, 8)],
    'Dips': [(null, 14)],
  });
  await env.sessions.markRest(EpochDay.fromDate(DateTime(2026, 10, 22)));
}

/// Everything a user can see, without database ids (restored ids may differ).
Future<Map<String, Object?>> portable(Env env) async {
  final db = env.db;
  final programs = {
    for (final p in await db.select(db.programs).get()) p.id: p.name,
  };
  final exercises = {
    for (final e in await db.select(db.exercises).get()) e.id: e.name,
  };
  final sessions = await (db.select(db.sessions)
        ..orderBy([(t) => OrderingTerm.asc(t.day)]))
      .get();

  final out = <Object?>[];
  final suggestions = <Object?>[];
  for (final s in sessions) {
    final logs = await (db.select(db.exerciseLogs)
          ..where((t) => t.sessionId.equals(s.id))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    final logOut = <Object?>[];
    for (final l in logs) {
      final sets = await (db.select(db.setEntries)
            ..where((t) => t.exerciseLogId.equals(l.id))
            ..orderBy([(t) => OrderingTerm.asc(t.idx)]))
          .get();
      logOut.add([
        exercises[l.exerciseId],
        l.pct,
        l.volume,
        [for (final x in sets) [x.idx, x.weight, x.reps]],
      ]);
    }
    out.add([
      s.day,
      programs[s.programId],
      s.setCount,
      s.volume,
      s.summaryPct,
      s.timeIn,
      s.timeOut,
      logOut,
    ]);
    final hits = await (db.select(db.suggestions)
          ..where((t) => t.sessionId.equals(s.id))
          ..orderBy([(t) => OrderingTerm.asc(t.priority)]))
        .get();
    suggestions.addAll([for (final h in hits) [s.day, h.ruleId]]);
  }

  final rest = await (db.select(db.daySummaries)
        ..where((t) => t.isRest.equals(true))
        ..orderBy([(t) => OrderingTerm.asc(t.day)]))
      .get();
  final streak = await db.select(db.streakStates).getSingle();

  return {
    'programs': programs.values.toList(),
    'exercises': exercises.values.toList(),
    'sessions': out,
    'suggestions': suggestions,
    'rest': [for (final r in rest) r.day],
    'streak': [streak.currentWeeks, streak.longestWeeks],
  };
}

void main() {
  setUp(() => tmp = Directory.systemTemp.createTempSync('tonfit_test_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test('export then restore reproduces everything the user can see', () async {
    final a = Env();
    final b = Env();
    addTearDown(a.db.close);
    addTearDown(b.db.close);
    await buildHistory(a);

    final file = File('${tmp.path}/backup.json.gz');
    await a.backup.exportJson(file, settings: {'weeklyGoal': 2}, now: clock);

    final bytes = file.readAsBytesSync();
    expect(bytes[0], equals(0x1f)); // gzip magic bytes: the file is compressed
    expect(bytes[1], equals(0x8b));

    final data = b.backup.read(bytes);
    expect(data.sessions.length, equals(3));
    expect(data.restDays, equals([EpochDay.fromDate(DateTime(2026, 10, 22))]));
    expect(data.settings['weeklyGoal'], equals(2));

    final summary = await b.backup.restore(data);
    expect(summary.sessions, equals(3));
    expect(summary.sets, equals(data.setCount));

    expect(await portable(b), equals(await portable(a)));
  });

  test('restore replaces whatever was there before', () async {
    final a = Env();
    final b = Env();
    addTearDown(a.db.close);
    addTearDown(b.db.close);
    await buildHistory(a);
    await addWorkout(b, 'Legs', DateTime(2026, 10, 5, 18), {
      'Squat': [(10000, 5)],
    });

    final file = File('${tmp.path}/backup.json.gz');
    await a.backup.exportJson(file, now: clock);
    await b.backup.restore(b.backup.read(file.readAsBytesSync()));

    final days = (await b.db.select(b.db.sessions).get()).map((s) => s.day).toList()
      ..sort();
    expect(days, equals([
      EpochDay.fromDate(DateTime(2026, 10, 19)),
      EpochDay.fromDate(DateTime(2026, 10, 21)),
      EpochDay.fromDate(DateTime(2026, 10, 26)),
    ]));
  });

  test('plain, uncompressed JSON is accepted too', () async {
    final a = Env();
    addTearDown(a.db.close);
    await buildHistory(a);
    final file = File('${tmp.path}/backup.json.gz');
    await a.backup.exportJson(file, now: clock);

    final text = utf8.decode(gzip.decode(file.readAsBytesSync()));
    final data = a.backup.read(Uint8List.fromList(utf8.encode(text)));
    expect(data.sessions.length, equals(3));
  });

  test('a bad file is rejected with a readable message', () async {
    final a = Env();
    addTearDown(a.db.close);
    expect(
      () => a.backup.read(Uint8List.fromList(utf8.encode('definitely not json'))),
      throwsA(isA<FormatException>()),
    );
    // Truncated gzip data is a bad file too, not a crash.
    expect(
      () => a.backup.read(Uint8List.fromList([0x1f, 0x8b, 0x08, 0x00, 0x01])),
      throwsA(isA<FormatException>()),
    );
  });

  test('the CSV has a header and one row per set', () async {
    final a = Env();
    addTearDown(a.db.close);
    await buildHistory(a);

    final file = File('${tmp.path}/sets.csv');
    await a.backup.exportCsv(file);
    final lines = file.readAsLinesSync();

    expect(lines.first, equals('date,program,exercise,set,weight_kg,reps'));
    // 2 + 2 sets on the 19th, 1 on the 21st, 2 + 1 on the 26th.
    expect(lines.length, equals(1 + 8));
    expect(lines, contains('2026-10-19,Push,Bench Press,1,60,10'));
    expect(lines, contains('2026-10-19,Push,Dips,1,,12')); // pure bodyweight
    expect(lines, contains('2026-10-19,Push,Dips,2,10,8')); // BW + 10 kg
    expect(lines, contains('2026-10-26,Push,Bench Press,1,62.5,8'));
  });

  test('a long history is exported across several batches in order', () async {
    final a = Env();
    final b = Env();
    addTearDown(a.db.close);
    addTearDown(b.db.close);

    // 120 sessions: more than one export batch of 100.
    final start = DateTime(2026, 1, 1, 18);
    for (var i = 0; i < 120; i++) {
      await addWorkout(a, 'Push', start.add(Duration(days: i)), {
        'Bench Press': [(6000, 8)],
      });
    }

    final file = File('${tmp.path}/big.json.gz');
    await a.backup.exportJson(file, now: clock);
    final data = b.backup.read(file.readAsBytesSync());

    expect(data.sessions.length, equals(120));
    final days = [for (final s in data.sessions) s.day];
    expect(days, equals([...days]..sort()));
    expect(days.toSet().length, equals(120));
  });
}
