import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/backup_format.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../database/tables.dart';
import '../repositories/session_repository.dart';

class RestoreSummary {
  const RestoreSummary({required this.sessions, required this.sets});
  final int sessions;
  final int sets;
}

/// Export and import (requirements FR-33, FR-34, NFR-26).
///
/// Export reads the history in small batches and streams it straight into a
/// compressed file, so it never holds the whole history in memory. Import
/// replaces all data in one transaction, then rebuilds every cached summary.
class BackupRepository {
  BackupRepository(this.db, this.sessions);

  final AppDatabase db;
  final SessionRepository sessions;

  /// Sessions read per batch while exporting.
  static const int _batch = 100;

  // ---------------------------------------------------------------------------
  // Export
  // ---------------------------------------------------------------------------

  /// Writes a gzip-compressed JSON backup to [file].
  Future<void> exportJson(
    File file, {
    Map<String, Object?> settings = const {},
    DateTime? now,
  }) async {
    final programs = await _programs();
    final exercises = await _exercises();
    final restDays = await _restDays();

    final controller = StreamController<List<int>>();
    final done = controller.stream.transform(gzip.encoder).pipe(file.openWrite());

    void write(String chunk) => controller.add(utf8.encode(chunk));

    try {
      write(BackupFormat.prefix(
        exportedAt: (now ?? DateTime.now()).toIso8601String(),
        settings: settings,
        programs: programs,
        exercises: exercises,
        restDays: restDays,
      ));

      var first = true;
      await for (final batch in _sessionBatches()) {
        for (final s in batch) {
          write('${first ? '' : ','}${BackupFormat.sessionJson(s)}');
          first = false;
        }
      }
      write(BackupFormat.suffix);
    } finally {
      await controller.close();
    }
    await done;
  }

  /// Writes one row per set, for spreadsheets.
  Future<void> exportCsv(File file) async {
    final programNames = {for (final p in await _programs()) p.id: p.name};
    final exercises = {for (final e in await _exercises()) e.id: e};

    final sink = file.openWrite();
    try {
      sink.write(BackupFormat.csvHeader);
      await for (final batch in _sessionBatches()) {
        for (final s in batch) {
          for (final log in s.logs) {
            for (var i = 0; i < log.sets.length; i++) {
              sink.write(BackupFormat.csvRow(
                day: s.day,
                program: programNames[s.programId] ?? '',
                exercise: exercises[log.exerciseId]?.name ?? '',
                setNumber: i + 1,
                weight: log.sets[i].weight,
                reps: log.sets[i].reps,
                timeBased: _isTimeBased(exercises[log.exerciseId]?.type),
              ));
            }
          }
        }
      }
    } finally {
      await sink.close();
    }
  }

  static bool _isTimeBased(String? type) => type == 'timed' || type == 'sport';

  Future<List<BackupProgram>> _programs() async {
    final rows = await (db.select(db.programs)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return [
      for (final p in rows)
        BackupProgram(
          id: p.id,
          name: p.name,
          sortOrder: p.sortOrder,
          archived: p.archived,
        ),
    ];
  }

  Future<List<BackupExercise>> _exercises() async {
    final rows = await (db.select(db.exercises)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return [
      for (final e in rows)
        BackupExercise(
          id: e.id,
          programId: e.programId,
          name: e.name,
          type: e.type.name,
          archived: e.archived,
        ),
    ];
  }

  Future<List<int>> _restDays() async {
    final rows = await (db.select(db.daySummaries)
          ..where((t) => t.isRest.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.day)]))
        .get();
    return [for (final r in rows) r.day];
  }

  /// Sessions with their logs and sets, oldest first, [_batch] at a time
  /// (keyset paging on the day, never offset paging).
  Stream<List<BackupSession>> _sessionBatches() async* {
    int? after;
    while (true) {
      final rows = await (db.select(db.sessions)
            ..where((t) => after == null
                ? const Constant(true)
                : t.day.isBiggerThanValue(after!))
            ..orderBy([(t) => OrderingTerm.asc(t.day)])
            ..limit(_batch))
          .get();
      if (rows.isEmpty) return;

      final sessionIds = [for (final s in rows) s.id];
      final logs = await (db.select(db.exerciseLogs)
            ..where((t) => t.sessionId.isIn(sessionIds))
            ..orderBy([
              (t) => OrderingTerm.asc(t.sessionId),
              (t) => OrderingTerm.asc(t.sortOrder),
            ]))
          .get();
      final sets = await (db.select(db.setEntries)
            ..where((t) => t.exerciseLogId.isIn([for (final l in logs) l.id]))
            ..orderBy([
              (t) => OrderingTerm.asc(t.exerciseLogId),
              (t) => OrderingTerm.asc(t.idx),
            ]))
          .get();

      final setsByLog = <int, List<BackupSet>>{};
      for (final s in sets) {
        (setsByLog[s.exerciseLogId] ??= [])
            .add(BackupSet(weight: s.weight, reps: s.reps));
      }
      final logsBySession = <int, List<BackupLog>>{};
      for (final l in logs) {
        (logsBySession[l.sessionId] ??= []).add(
          BackupLog(exerciseId: l.exerciseId, sets: setsByLog[l.id] ?? const []),
        );
      }

      yield [
        for (final s in rows)
          BackupSession(
            day: s.day,
            programId: s.programId,
            timeIn: s.timeIn,
            timeOut: s.timeOut,
            logs: logsBySession[s.id] ?? const [],
          ),
      ];
      after = rows.last.day;
    }
  }

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  /// Reads and validates a backup file's bytes (gzip or plain JSON). Throws
  /// [FormatException] with a message that is safe to show to the user.
  BackupData read(Uint8List bytes) {
    final isGzip = bytes.length > 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;
    final String text;
    try {
      text = utf8.decode(isGzip ? gzip.decode(bytes) : bytes);
    } catch (_) {
      // Bad gzip data or invalid UTF-8: a damaged file, not a crash.
      throw const FormatException('This file is not a TonFit backup.');
    }
    return BackupFormat.parse(text);
  }

  /// Replaces ALL current data with [data], then rebuilds every summary.
  Future<RestoreSummary> restore(BackupData data) async {
    await db.transaction(() async {
      // Wipe. Deleting sessions cascades to their exercises, sets and
      // suggestions; programs go last because everything points at them.
      await db.delete(db.exerciseStats).go();
      await db.delete(db.sessions).go();
      await db.delete(db.daySummaries).go();
      await db.delete(db.weekSummaries).go();
      await db.delete(db.exercises).go();
      await db.delete(db.programs).go();

      for (final p in data.programs) {
        await db.into(db.programs).insert(ProgramsCompanion(
              id: Value(p.id),
              name: Value(p.name),
              nameKey: Value(p.name.toLowerCase()),
              sortOrder: Value(p.sortOrder),
              archived: Value(p.archived),
            ));
      }
      for (final e in data.exercises) {
        await db.into(db.exercises).insert(ExercisesCompanion(
              id: Value(e.id),
              programId: Value(e.programId),
              name: Value(e.name),
              nameKey: Value(e.name.toLowerCase()),
              type: Value(ExerciseType.values.byName(e.type)),
              archived: Value(e.archived),
            ));
      }

      for (final s in data.sessions) {
        final sessionId = await db.into(db.sessions).insert(SessionsCompanion(
              day: Value(s.day),
              programId: Value(s.programId),
              timeIn: Value(s.timeIn),
              timeOut: Value(s.timeOut),
            ));
        for (var i = 0; i < s.logs.length; i++) {
          final log = s.logs[i];
          final logId =
              await db.into(db.exerciseLogs).insert(ExerciseLogsCompanion(
                    sessionId: Value(sessionId),
                    exerciseId: Value(log.exerciseId),
                    day: Value(s.day),
                    sortOrder: Value(i),
                  ));
          await db.batch((batch) {
            batch.insertAll(db.setEntries, [
              for (var n = 0; n < log.sets.length; n++)
                SetEntriesCompanion(
                  exerciseLogId: Value(logId),
                  idx: Value(n + 1),
                  weight: Value(log.sets[n].weight),
                  reps: Value(log.sets[n].reps),
                ),
            ]);
          });
        }
      }

      final sessionDays = {for (final s in data.sessions) s.day};
      for (final day in data.restDays) {
        if (sessionDays.contains(day)) continue; // a session wins over a mark
        await db.into(db.daySummaries).insert(DaySummariesCompanion(
              day: Value(day),
              sessionId: const Value(null),
              setCount: const Value(0),
              isRest: const Value(true),
            ));
      }
    });

    await sessions.rebuildAll();
    return RestoreSummary(sessions: data.sessions.length, sets: data.setCount);
  }
}

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => BackupRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(sessionRepositoryProvider),
  ),
);
