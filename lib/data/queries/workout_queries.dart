import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/epoch_day.dart';
import '../../domain/suggestions.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';

// -----------------------------------------------------------------------------
// Read models
// -----------------------------------------------------------------------------

class ExerciseLogView {
  const ExerciseLogView({
    required this.log,
    required this.exercise,
    required this.sets,
  });
  final ExerciseLog log;
  final Exercise exercise;
  final List<SetEntry> sets;
}

class DayDetail {
  const DayDetail({
    required this.session,
    required this.program,
    required this.logs,
    required this.messages,
  });
  final Session session;
  final Program program;
  final List<ExerciseLogView> logs;

  /// Suggestion texts, best priority first.
  final List<String> messages;
}

class HeatmapData {
  const HeatmapData({
    required this.year,
    required this.firstYear,
    required this.setCounts,
  });
  final int year;

  /// First year that has any data, for the year switcher.
  final int firstYear;

  /// Epoch-day -> set count, for days that have a session.
  final Map<int, int> setCounts;
}

/// One row of the year list: a day with a session, or a rest day.
class YearDay {
  const YearDay({
    required this.day,
    required this.sessionId,
    required this.programName,
    required this.summaryPct,
    required this.setCount,
    required this.isRest,
  });
  final int day;
  final int? sessionId;
  final String? programName;
  final int? summaryPct;
  final int setCount;
  final bool isRest;
}

class YearData {
  const YearData({required this.year, required this.firstYear, required this.days});
  final int year;
  final int firstYear;

  /// Newest first. Only summaries: sets load when a day is expanded.
  final List<YearDay> days;
}

class ProgramView {
  const ProgramView({required this.program, required this.exerciseCount});
  final Program program;
  final int exerciseCount;
}

class ExercisePicker {
  const ExercisePicker({required this.programId, required this.options});
  final int programId;
  final List<ExerciseOption> options;
}

class ExerciseOption {
  const ExerciseOption({
    required this.exercise,
    required this.lastWeight,
    required this.lastReps,
    required this.added,
  });
  final Exercise exercise;

  /// Top set of the most recent logged occurrence (null if never logged).
  final int? lastWeight;
  final int? lastReps;

  /// Already part of this session.
  final bool added;
}

// -----------------------------------------------------------------------------
// Queries
// -----------------------------------------------------------------------------

class WorkoutQueries {
  WorkoutQueries(this.db);
  final AppDatabase db;

  /// Emits once, then again after every committed change to [tables].
  Stream<T> _watch<T>(
    Future<T> Function() load,
    List<ResultSetImplementation<dynamic, dynamic>> tables,
  ) async* {
    yield await load();
    await for (final _ in db.tableUpdates(TableUpdateQuery.onAllTables(tables))) {
      yield await load();
    }
  }

  // --- day ---

  Future<DayDetail?> loadDay(int day) async {
    final session = await (db.select(db.sessions)
          ..where((t) => t.day.equals(day)))
        .getSingleOrNull();
    if (session == null) return null;

    final program = await (db.select(db.programs)
          ..where((t) => t.id.equals(session.programId)))
        .getSingle();
    final logs = await (db.select(db.exerciseLogs)
          ..where((t) => t.sessionId.equals(session.id))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();

    final views = <ExerciseLogView>[];
    for (final log in logs) {
      final exercise = await (db.select(db.exercises)
            ..where((t) => t.id.equals(log.exerciseId)))
          .getSingle();
      final sets = await (db.select(db.setEntries)
            ..where((t) => t.exerciseLogId.equals(log.id))
            ..orderBy([(t) => OrderingTerm.asc(t.idx)]))
          .get();
      views.add(ExerciseLogView(log: log, exercise: exercise, sets: sets));
    }

    final nameByLog = {for (final v in views) v.log.id: v.exercise.name};
    final rows = await (db.select(db.suggestions)
          ..where((t) => t.sessionId.equals(session.id))
          ..orderBy([(t) => OrderingTerm.asc(t.priority)]))
        .get();
    final messages = [
      for (final r in rows)
        suggestionMessage(SuggestionHit(
          ruleId: r.ruleId,
          priority: r.priority,
          exerciseName: nameByLog[r.exerciseLogId] ?? '',
          params: Map<String, Object?>.from(jsonDecode(r.params) as Map),
        )),
    ];

    return DayDetail(
      session: session,
      program: program,
      logs: views,
      messages: messages,
    );
  }

  Stream<DayDetail?> watchDay(int day) => _watch(
        () => loadDay(day),
        [db.sessions, db.exerciseLogs, db.setEntries, db.suggestions],
      );

  /// Top set of the previous occurrence of [log]'s exercise, for the
  /// "Last session: 60 kg × 10" line.
  Future<({int? weight, int? reps})?> previousTop(ExerciseLog log) async {
    final prevId = log.prevLogId;
    if (prevId == null) return null;
    final prev = await (db.select(db.exerciseLogs)
          ..where((t) => t.id.equals(prevId)))
        .getSingleOrNull();
    if (prev == null) return null;
    return (weight: prev.bestWeight, reps: prev.repsAtTop);
  }

  // --- heatmap ---

  /// First year with any data, or [fallback] when there is none.
  Future<int> _firstYear(int fallback) async {
    final minDay = db.daySummaries.day.min();
    final row =
        await (db.selectOnly(db.daySummaries)..addColumns([minDay])).getSingle();
    final m = row.read(minDay);
    return m == null ? fallback : EpochDay.toDate(m).year;
  }

  Future<HeatmapData> loadHeatmap(int year) async {
    final start = EpochDay.fromDate(DateTime(year, 1, 1));
    final end = EpochDay.fromDate(DateTime(year, 12, 31));
    final rows = await (db.select(db.daySummaries)
          ..where((t) =>
              t.day.isBetweenValues(start, end) & t.sessionId.isNotNull()))
        .get();

    return HeatmapData(
      year: year,
      firstYear: await _firstYear(year),
      setCounts: {for (final r in rows) r.day: r.setCount},
    );
  }

  Stream<HeatmapData> watchHeatmap(int year) =>
      _watch(() => loadHeatmap(year), [db.daySummaries]);

  // --- year list ---

  Future<YearData> loadYear(int year) async {
    final start = EpochDay.fromDate(DateTime(year, 1, 1));
    final end = EpochDay.fromDate(DateTime(year, 12, 31));
    final query = db.select(db.daySummaries).join([
      leftOuterJoin(
        db.sessions,
        db.sessions.id.equalsExp(db.daySummaries.sessionId),
      ),
      leftOuterJoin(
        db.programs,
        db.programs.id.equalsExp(db.sessions.programId),
      ),
    ])
      ..where(db.daySummaries.day.isBetweenValues(start, end))
      ..orderBy([OrderingTerm.desc(db.daySummaries.day)]);

    final rows = await query.get();
    final days = <YearDay>[];
    for (final r in rows) {
      final summary = r.readTable(db.daySummaries);
      days.add(YearDay(
        day: summary.day,
        sessionId: summary.sessionId,
        programName: r.readTableOrNull(db.programs)?.name,
        summaryPct: r.readTableOrNull(db.sessions)?.summaryPct,
        setCount: summary.setCount,
        isRest: summary.isRest,
      ));
    }
    return YearData(year: year, firstYear: await _firstYear(year), days: days);
  }

  Stream<YearData> watchYear(int year) => _watch(
        () => loadYear(year),
        [db.daySummaries, db.sessions, db.programs],
      );

  // --- streak ---

  Stream<StreakState> watchStreak() => (db.select(db.streakStates)
        ..where((t) => t.id.equals(1)))
      .watchSingle();

  // --- programs and exercises ---

  Future<List<ProgramView>> loadPrograms() async {
    final programs = await (db.select(db.programs)
          ..where((t) => t.archived.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    final result = <ProgramView>[];
    for (final p in programs) {
      final count = db.exercises.id.count();
      final row = await (db.selectOnly(db.exercises)
            ..addColumns([count])
            ..where(db.exercises.programId.equals(p.id) &
                db.exercises.archived.equals(false)))
          .getSingle();
      result.add(ProgramView(program: p, exerciseCount: row.read(count) ?? 0));
    }
    return result;
  }

  Stream<List<ProgramView>> watchPrograms() =>
      _watch(loadPrograms, [db.programs, db.exercises]);

  Future<ExercisePicker> loadExercisePicker(int sessionId) async {
    final session = await (db.select(db.sessions)
          ..where((t) => t.id.equals(sessionId)))
        .getSingle();
    final exercises = await (db.select(db.exercises)
          ..where((t) =>
              t.programId.equals(session.programId) & t.archived.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    final inSession = await (db.select(db.exerciseLogs)
          ..where((t) => t.sessionId.equals(sessionId)))
        .get();
    final addedIds = {for (final l in inSession) l.exerciseId};

    final options = <ExerciseOption>[];
    for (final e in exercises) {
      final last = await (db.select(db.exerciseLogs)
            ..where((t) =>
                t.exerciseId.equals(e.id) &
                t.setCount.isBiggerThanValue(0) &
                t.sessionId.equals(sessionId).not())
            ..orderBy([(t) => OrderingTerm.desc(t.day)])
            ..limit(1))
          .getSingleOrNull();
      options.add(ExerciseOption(
        exercise: e,
        lastWeight: last?.bestWeight,
        lastReps: last?.repsAtTop,
        added: addedIds.contains(e.id),
      ));
    }
    return ExercisePicker(programId: session.programId, options: options);
  }

  Stream<ExercisePicker> watchExercisePicker(int sessionId) => _watch(
        () => loadExercisePicker(sessionId),
        [db.exercises, db.exerciseLogs],
      );
}

// -----------------------------------------------------------------------------
// Providers
// -----------------------------------------------------------------------------

final workoutQueriesProvider = Provider<WorkoutQueries>(
  (ref) => WorkoutQueries(ref.watch(appDatabaseProvider)),
);

final dayDetailProvider = StreamProvider.family<DayDetail?, int>(
  (ref, day) => ref.watch(workoutQueriesProvider).watchDay(day),
);

final heatmapProvider = StreamProvider.family<HeatmapData, int>(
  (ref, year) => ref.watch(workoutQueriesProvider).watchHeatmap(year),
);

final yearDataProvider = StreamProvider.family<YearData, int>(
  (ref, year) => ref.watch(workoutQueriesProvider).watchYear(year),
);

final streakProvider = StreamProvider<StreakState>(
  (ref) => ref.watch(workoutQueriesProvider).watchStreak(),
);

final programsProvider = StreamProvider<List<ProgramView>>(
  (ref) => ref.watch(workoutQueriesProvider).watchPrograms(),
);

final exercisePickerProvider = StreamProvider.family<ExercisePicker, int>(
  (ref, sessionId) => ref.watch(workoutQueriesProvider).watchExercisePicker(sessionId),
);
