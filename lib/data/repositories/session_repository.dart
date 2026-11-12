import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/epoch_day.dart';
import '../../domain/progress.dart';
import '../../domain/streak.dart';
import '../../domain/suggestions.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../database/tables.dart';

/// All writes to workout data. Every public method runs in ONE transaction
/// that updates the set rows and every cached summary together, so caches never
/// drift out of sync (requirements NFR-14).
///
/// Cache pipeline after a change to an exercise on a day:
///   exercise log -> following logs of that exercise -> session totals ->
///   following sessions of the program -> exercise stats -> suggestions ->
///   weekly summary and streak.
/// Every step is an indexed lookup bounded by a small LIMIT or one day/week
/// range, never a scan of the whole history (requirements NFR-1).
class SessionRepository {
  SessionRepository(
    this.db, {
    DateTime Function()? clock,
    SuggestionEngine? engine,
    int Function()? weeklyGoal,
  })  : _clock = clock ?? DateTime.now,
        _engine = engine ?? SuggestionEngine(),
        _weeklyGoal = weeklyGoal ?? (() => 4);

  final AppDatabase db;
  final DateTime Function() _clock;
  final SuggestionEngine _engine;
  final int Function() _weeklyGoal;

  /// How many recent logs of one exercise the suggestion rules may read.
  static const int _historyLimit = 5;

  /// How many later sessions' suggestions are refreshed after a past edit.
  static const int _rippleSessions = 3;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Creates the session for [day] (default: today) or returns the existing
  /// one. One session per day in the MVP (requirements FR-14).
  Future<int> startSession({required int programId, int? day}) {
    return db.transaction(() async {
      final d = day ?? EpochDay.today(_clock());
      final existing = await (db.select(db.sessions)
            ..where((t) => t.day.equals(d)))
          .getSingleOrNull();
      if (existing != null) return existing.id;

      final id = await db
          .into(db.sessions)
          .insert(SessionsCompanion.insert(day: d, programId: programId));
      await _refreshSession(id);
      return id;
    });
  }

  /// Adds an exercise to a session, or returns the existing log.
  Future<int> addExercise({required int sessionId, required int exerciseId}) {
    return db.transaction(() async {
      final session = await _session(sessionId);
      final existing = await (db.select(db.exerciseLogs)
            ..where((t) =>
                t.sessionId.equals(sessionId) & t.exerciseId.equals(exerciseId)))
          .getSingleOrNull();
      if (existing != null) return existing.id;

      final maxOrder = db.exerciseLogs.sortOrder.max();
      final row = await (db.selectOnly(db.exerciseLogs)
            ..addColumns([maxOrder])
            ..where(db.exerciseLogs.sessionId.equals(sessionId)))
          .getSingle();
      final next = (row.read(maxOrder) ?? -1) + 1;

      final id = await db.into(db.exerciseLogs).insert(
            ExerciseLogsCompanion.insert(
              sessionId: sessionId,
              exerciseId: exerciseId,
              day: session.day,
              sortOrder: Value(next),
            ),
          );
      await _refreshLog(id);
      return id;
    });
  }

  /// Logs one set. [weight] is stored hundredths of a kg, or null for a pure
  /// bodyweight set. Time in / time out are stamped from [at] (default: now),
  /// but only for today's session, so editing a past day never changes its
  /// times (requirements FR-13).
  Future<int> addSet({
    required int exerciseLogId,
    int? weight,
    required int reps,
    DateTime? at,
  }) {
    return db.transaction(() async {
      final log = await _log(exerciseLogId);
      final maxIdx = db.setEntries.idx.max();
      final row = await (db.selectOnly(db.setEntries)
            ..addColumns([maxIdx])
            ..where(db.setEntries.exerciseLogId.equals(exerciseLogId)))
          .getSingle();
      final next = (row.read(maxIdx) ?? 0) + 1;

      final id = await db.into(db.setEntries).insert(
            SetEntriesCompanion.insert(
              exerciseLogId: exerciseLogId,
              idx: next,
              reps: reps,
              weight: Value(weight),
            ),
          );

      final when = at ?? _clock();
      final session = await _session(log.sessionId);
      if (session.day == EpochDay.today(when)) {
        final ts = _seconds(when);
        await (db.update(db.sessions)..where((t) => t.id.equals(session.id)))
            .write(SessionsCompanion(
          timeIn: Value(session.timeIn ?? ts),
          timeOut: Value(ts),
        ));
      }

      await _afterLogChange(exerciseLogId);
      return id;
    });
  }

  Future<void> updateSet({
    required int setId,
    int? weight,
    required int reps,
  }) {
    return db.transaction(() async {
      final row = await (db.select(db.setEntries)
            ..where((t) => t.id.equals(setId)))
          .getSingle();
      await (db.update(db.setEntries)..where((t) => t.id.equals(setId)))
          .write(SetEntriesCompanion(weight: Value(weight), reps: Value(reps)));
      await _afterLogChange(row.exerciseLogId);
    });
  }

  /// Deletes a set and renumbers the ones after it (1, 2, 3, ...).
  Future<void> deleteSet(int setId) {
    return db.transaction(() async {
      final row = await (db.select(db.setEntries)
            ..where((t) => t.id.equals(setId)))
          .getSingle();
      await (db.delete(db.setEntries)..where((t) => t.id.equals(setId))).go();

      // One at a time, in order, so the unique (log, idx) key never collides.
      final later = await (db.select(db.setEntries)
            ..where((t) =>
                t.exerciseLogId.equals(row.exerciseLogId) &
                t.idx.isBiggerThanValue(row.idx))
            ..orderBy([(t) => OrderingTerm.asc(t.idx)]))
          .get();
      for (final s in later) {
        await (db.update(db.setEntries)..where((t) => t.id.equals(s.id)))
            .write(SetEntriesCompanion(idx: Value(s.idx - 1)));
      }
      await _afterLogChange(row.exerciseLogId);
    });
  }

  /// Removes an exercise (and all its sets) from a session.
  Future<void> removeExercise(int exerciseLogId) {
    return db.transaction(() async {
      final log = await _log(exerciseLogId);
      final session = await _session(log.sessionId);
      await (db.delete(db.exerciseLogs)
            ..where((t) => t.id.equals(exerciseLogId)))
          .go();
      await _relinkFollowingLogs(log.exerciseId, log.day);
      await _afterExerciseDayChange(session, log.exerciseId);
    });
  }

  /// Deletes a whole session with its exercises and sets, then repairs
  /// everything that depended on it: the next sessions' percentages and links,
  /// personal bests, suggestions, the heatmap day, the week count and the
  /// streak. The day can be logged again afterwards.
  Future<void> deleteSession(int sessionId) {
    return db.transaction(() async {
      final session = await _session(sessionId);
      final logs = await (db.select(db.exerciseLogs)
            ..where((t) => t.sessionId.equals(sessionId)))
          .get();
      final exerciseIds = {for (final l in logs) l.exerciseId};

      // Cascades to the session's exercises, sets and suggestions.
      await (db.delete(db.sessions)..where((t) => t.id.equals(sessionId))).go();
      await (db.delete(db.daySummaries)
            ..where((t) => t.day.equals(session.day)))
          .go();

      for (final exerciseId in exerciseIds) {
        await _relinkFollowingLogs(exerciseId, session.day);
      }
      await _refreshFollowingSessions(session.programId, session.day);
      await _refreshWeek(session.day);
      for (final exerciseId in exerciseIds) {
        await _refreshStats(exerciseId);
        await _refreshSuggestionsAfter(session.day, exerciseId);
      }
      await _refreshStreak();
    });
  }

  /// Manual edit of time in / time out (epoch seconds).
  Future<void> setTimes({required int sessionId, int? timeIn, int? timeOut}) {
    return db.transaction(() async {
      await (db.update(db.sessions)..where((t) => t.id.equals(sessionId)))
          .write(SessionsCompanion(
        timeIn: Value(timeIn),
        timeOut: Value(timeOut),
      ));
    });
  }

  /// Marks [day] as a rest day, or clears the mark. Returns false (and does
  /// nothing) when the day already has a session. Rest days never affect the
  /// streak (requirements FR-15).
  Future<bool> markRest(int day, {bool rest = true}) {
    return db.transaction(() async {
      final session = await (db.select(db.sessions)
            ..where((t) => t.day.equals(day)))
          .getSingleOrNull();
      if (session != null) return false;

      if (rest) {
        await db.into(db.daySummaries).insertOnConflictUpdate(
              DaySummariesCompanion(
                day: Value(day),
                sessionId: const Value(null),
                setCount: const Value(0),
                isRest: const Value(true),
              ),
            );
      } else {
        await (db.delete(db.daySummaries)..where((t) => t.day.equals(day)))
            .go();
      }
      return true;
    });
  }

  /// Recalculates the streak, for example after the weekly goal changes.
  Future<void> refreshStreak() => db.transaction(_refreshStreak);

  /// Rebuilds EVERY cached value from the sets (requirements NFR-10), for
  /// repair, import and migrations. Rest-day marks are kept. This is the one
  /// place that touches the whole history, so it is an explicit action and
  /// never part of normal use. Takes a few seconds on a large history.
  Future<void> rebuildAll() {
    return db.transaction(() async {
      // Drop what is derived; keep sets, logs, sessions and rest-day marks.
      await db.delete(db.suggestions).go();
      await db.delete(db.exerciseStats).go();
      await db.delete(db.weekSummaries).go();
      await (db.delete(db.daySummaries)..where((t) => t.isRest.equals(false)))
          .go();

      final logs = await (db.select(db.exerciseLogs)
            ..orderBy([
              (t) => OrderingTerm.asc(t.day),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .get();

      // Metrics first for every log, then links (a link needs the earlier
      // logs' set counts to be right already).
      for (final log in logs) {
        await _updateLogMetrics(log.id);
      }
      for (final log in logs) {
        await _relinkLog(log.id);
      }

      final sessions = await (db.select(db.sessions)
            ..orderBy([(t) => OrderingTerm.asc(t.day)]))
          .get();
      for (final s in sessions) {
        await _refreshSession(s.id);
      }

      for (final exerciseId in {for (final l in logs) l.exerciseId}) {
        await _refreshStats(exerciseId);
      }
      for (final s in sessions) {
        await _refreshSuggestions(s.id);
      }
      await _refreshStreak();
    });
  }

  // ---------------------------------------------------------------------------
  // Cache pipeline
  // ---------------------------------------------------------------------------

  Future<void> _afterLogChange(int logId) async {
    final log = await _log(logId);
    final session = await _session(log.sessionId);
    await _refreshLog(logId);
    await _relinkFollowingLogs(log.exerciseId, log.day);
    await _afterExerciseDayChange(session, log.exerciseId);
  }

  Future<void> _afterExerciseDayChange(Session session, int exerciseId) async {
    await _refreshSession(session.id);
    await _refreshFollowingSessions(session.programId, session.day);
    await _refreshStats(exerciseId);
    await _refreshSuggestionsFrom(session.id, session.day, exerciseId);
    await _refreshStreak();
  }

  /// Recomputes one exercise log's cached numbers from its sets, then relinks
  /// it to the previous occurrence.
  Future<void> _refreshLog(int logId) async {
    await _updateLogMetrics(logId);
    await _relinkLog(logId);
  }

  /// Volume, set count and bests of one log, straight from its sets.
  Future<void> _updateLogMetrics(int logId) async {
    final log = await _log(logId);
    final exercise = await (db.select(db.exercises)
          ..where((t) => t.id.equals(log.exerciseId)))
        .getSingle();
    final sets = await _sets(logId);
    final m = Progress.metrics(
      sets,
      bodyweight: exercise.type == ExerciseType.bodyweight,
    );
    await (db.update(db.exerciseLogs)..where((t) => t.id.equals(logId))).write(
      ExerciseLogsCompanion(
        volume: Value(m.volume),
        setCount: Value(m.setCount),
        bestWeight: Value(m.setCount == 0 ? null : m.topWeight),
        repsAtTop: Value(m.repsAtTop),
      ),
    );
  }

  /// Points the log at the most recent EARLIER log of the same exercise that
  /// has sets, and recomputes its percentage (null means "New").
  Future<void> _relinkLog(int logId) async {
    final log = await _log(logId);
    final prev = await (db.select(db.exerciseLogs)
          ..where((t) =>
              t.exerciseId.equals(log.exerciseId) &
              t.day.isSmallerThanValue(log.day) &
              t.setCount.isBiggerThanValue(0))
          ..orderBy([(t) => OrderingTerm.desc(t.day)])
          ..limit(1))
        .getSingleOrNull();
    final pct =
        log.setCount == 0 ? null : Progress.pctTenths(log.volume, prev?.volume);
    await (db.update(db.exerciseLogs)..where((t) => t.id.equals(logId))).write(
      ExerciseLogsCompanion(prevLogId: Value(prev?.id), pct: Value(pct)),
    );
  }

  /// After a change on [afterDay], relinks the next log of the exercise, and
  /// keeps going past empty logs until it has relinked one that has sets.
  Future<void> _relinkFollowingLogs(int exerciseId, int afterDay) async {
    var day = afterDay;
    while (true) {
      final next = await (db.select(db.exerciseLogs)
            ..where((t) =>
                t.exerciseId.equals(exerciseId) & t.day.isBiggerThanValue(day))
            ..orderBy([(t) => OrderingTerm.asc(t.day)])
            ..limit(1))
          .getSingleOrNull();
      if (next == null) return;
      await _relinkLog(next.id);
      if (next.setCount > 0) return;
      day = next.day;
    }
  }

  /// Session totals, link to the previous same-program session, summary %,
  /// the day summary row (heatmap) and the week count.
  Future<void> _refreshSession(int sessionId) async {
    final s = await _session(sessionId);
    final logs = await (db.select(db.exerciseLogs)
          ..where((t) => t.sessionId.equals(sessionId)))
        .get();
    final active = logs.where((l) => l.setCount > 0).toList();
    final volume = active.fold<int>(0, (a, l) => a + l.volume);
    final setCount = active.fold<int>(0, (a, l) => a + l.setCount);

    final prev = await (db.select(db.sessions)
          ..where((t) =>
              t.programId.equals(s.programId) &
              t.day.isSmallerThanValue(s.day) &
              t.setCount.isBiggerThanValue(0))
          ..orderBy([(t) => OrderingTerm.desc(t.day)])
          ..limit(1))
        .getSingleOrNull();

    int? pct;
    if (prev != null && setCount > 0) {
      final prevLogs = await (db.select(db.exerciseLogs)
            ..where((t) =>
                t.sessionId.equals(prev.id) & t.setCount.isBiggerThanValue(0)))
          .get();
      pct = Progress.sessionPctTenths(
        {for (final l in active) l.exerciseId: l.volume},
        {for (final l in prevLogs) l.exerciseId: l.volume},
      );
    }

    await (db.update(db.sessions)..where((t) => t.id.equals(sessionId))).write(
      SessionsCompanion(
        volume: Value(volume),
        setCount: Value(setCount),
        summaryPct: Value(pct),
        prevSessionId: Value(prev?.id),
      ),
    );

    await db.into(db.daySummaries).insertOnConflictUpdate(
          DaySummariesCompanion(
            day: Value(s.day),
            sessionId: Value(s.id),
            setCount: Value(setCount),
            isRest: const Value(false),
          ),
        );
    await _refreshWeek(s.day);
  }

  /// Refreshes the next session of the program, continuing past empty ones
  /// until it has refreshed one that has sets.
  Future<void> _refreshFollowingSessions(int programId, int afterDay) async {
    var day = afterDay;
    while (true) {
      final next = await (db.select(db.sessions)
            ..where((t) =>
                t.programId.equals(programId) & t.day.isBiggerThanValue(day))
            ..orderBy([(t) => OrderingTerm.asc(t.day)])
            ..limit(1))
          .getSingleOrNull();
      if (next == null) return;
      await _refreshSession(next.id);
      if (next.setCount > 0) return;
      day = next.day;
    }
  }

  /// Number of sessions (with at least one set) in the week containing [day].
  Future<void> _refreshWeek(int day) async {
    final start = EpochDay.weekStart(day);
    final count = db.sessions.id.count();
    final row = await (db.selectOnly(db.sessions)
          ..addColumns([count])
          ..where(db.sessions.day.isBetweenValues(start, start + 6) &
              db.sessions.setCount.isBiggerThanValue(0)))
        .getSingle();
    final n = row.read(count) ?? 0;
    if (n == 0) {
      await (db.delete(db.weekSummaries)
            ..where((t) => t.weekStart.equals(start)))
          .go();
    } else {
      await db.into(db.weekSummaries).insertOnConflictUpdate(
            WeekSummariesCompanion(
              weekStart: Value(start),
              sessionCount: Value(n),
            ),
          );
    }
  }

  /// Personal bests across logs of [exerciseId], optionally only before a day.
  Future<PriorBests?> _bests(int exerciseId, {int? beforeDay}) async {
    final logs = db.exerciseLogs;
    Expression<bool> where = logs.exerciseId.equals(exerciseId) &
        logs.setCount.isBiggerThanValue(0);
    if (beforeDay != null) {
      where = where & logs.day.isSmallerThanValue(beforeDay);
    }
    final maxWeight = logs.bestWeight.max();
    final first = await (db.selectOnly(logs)
          ..addColumns([maxWeight])
          ..where(where))
        .getSingle();
    final w = first.read(maxWeight);
    if (w == null) return null;

    final maxReps = logs.repsAtTop.max();
    final second = await (db.selectOnly(logs)
          ..addColumns([maxReps])
          ..where(where & logs.bestWeight.equals(w)))
        .getSingle();
    return PriorBests(maxWeight: w, repsAtMaxWeight: second.read(maxReps) ?? 0);
  }

  Future<void> _refreshStats(int exerciseId) async {
    final bests = await _bests(exerciseId);
    if (bests == null) {
      await (db.delete(db.exerciseStats)
            ..where((t) => t.exerciseId.equals(exerciseId)))
          .go();
      return;
    }
    final logs = db.exerciseLogs;
    final maxVolume = logs.volume.max();
    final vRow = await (db.selectOnly(logs)
          ..addColumns([maxVolume])
          ..where(logs.exerciseId.equals(exerciseId) &
              logs.setCount.isBiggerThanValue(0)))
        .getSingle();
    final last = await (db.select(logs)
          ..where((t) =>
              t.exerciseId.equals(exerciseId) & t.setCount.isBiggerThanValue(0))
          ..orderBy([(t) => OrderingTerm.desc(t.day)])
          ..limit(1))
        .getSingleOrNull();

    await db.into(db.exerciseStats).insertOnConflictUpdate(
          ExerciseStatsCompanion(
            exerciseId: Value(exerciseId),
            bestWeight: Value(bests.maxWeight),
            bestRepsAtWeight: Value(bests.repsAtMaxWeight),
            bestVolume: Value(vRow.read(maxVolume) ?? 0),
            lastLogId: Value(last?.id),
          ),
        );
  }

  /// The next few sessions that contain the exercise after [day]: their
  /// suggestion history windows are the ones an edit can change.
  Future<Set<int>> _followingSessionIds(int exerciseId, int day) async {
    final following = await (db.select(db.exerciseLogs)
          ..where((t) =>
              t.exerciseId.equals(exerciseId) &
              t.day.isBiggerThanValue(day) &
              t.setCount.isBiggerThanValue(0))
          ..orderBy([(t) => OrderingTerm.asc(t.day)])
          ..limit(_rippleSessions))
        .get();
    return {for (final l in following) l.sessionId};
  }

  /// Refreshes suggestions for the session itself and for the next few
  /// sessions that contain the exercise, since their history windows changed.
  Future<void> _refreshSuggestionsFrom(
    int sessionId,
    int day,
    int exerciseId,
  ) async {
    final ids = {sessionId, ...await _followingSessionIds(exerciseId, day)};
    for (final id in ids) {
      await _refreshSuggestions(id);
    }
  }

  /// Same, for when the session at [day] no longer exists (it was deleted).
  Future<void> _refreshSuggestionsAfter(int day, int exerciseId) async {
    for (final id in await _followingSessionIds(exerciseId, day)) {
      await _refreshSuggestions(id);
    }
  }

  Future<void> _refreshSuggestions(int sessionId) async {
    final session = await _session(sessionId);
    await (db.delete(db.suggestions)
          ..where((t) => t.sessionId.equals(sessionId)))
        .go();

    final logs = await (db.select(db.exerciseLogs)
          ..where((t) =>
              t.sessionId.equals(sessionId) & t.setCount.isBiggerThanValue(0))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();

    final contexts = <SuggestionContext>[];
    final logIdByName = <String, int>{};
    for (final log in logs) {
      final exercise = await (db.select(db.exercises)
            ..where((t) => t.id.equals(log.exerciseId)))
          .getSingle();
      final recent = await (db.select(db.exerciseLogs)
            ..where((t) =>
                t.exerciseId.equals(log.exerciseId) &
                t.day.isSmallerOrEqualValue(session.day) &
                t.setCount.isBiggerThanValue(0))
            ..orderBy([(t) => OrderingTerm.desc(t.day)])
            ..limit(_historyLimit))
          .get();
      final history = <ExerciseSession>[];
      for (final r in recent) {
        history.add(ExerciseSession(
          day: r.day,
          volume: r.volume,
          topWeight: r.bestWeight ?? 0,
          repsAtTop: r.repsAtTop,
          sets: await _sets(r.id),
        ));
      }
      contexts.add(SuggestionContext(
        exerciseName: exercise.name,
        history: history,
        priorBests: await _bests(log.exerciseId, beforeDay: session.day),
      ));
      logIdByName[exercise.name] = log.id;
    }

    for (final hit in _engine.evaluateSession(contexts)) {
      await db.into(db.suggestions).insert(
            SuggestionsCompanion.insert(
              sessionId: sessionId,
              ruleId: hit.ruleId,
              priority: hit.priority,
              exerciseLogId: Value(logIdByName[hit.exerciseName]),
              params: Value(jsonEncode(hit.params)),
            ),
          );
    }
  }

  /// Streak from the weekly summary table (one row per week with sessions).
  Future<void> _refreshStreak() async {
    final rows = await db.select(db.weekSummaries).get();
    final result = computeStreak(
      weekCounts: {for (final r in rows) r.weekStart: r.sessionCount},
      goal: _weeklyGoal(),
      today: EpochDay.today(_clock()),
    );
    await db.into(db.streakStates).insertOnConflictUpdate(
          StreakStatesCompanion(
            id: const Value(1),
            currentWeeks: Value(result.current),
            longestWeeks: Value(result.longest),
            updatedAt: Value(_seconds(_clock())),
          ),
        );
  }

  // ---------------------------------------------------------------------------
  // Small helpers
  // ---------------------------------------------------------------------------

  Future<Session> _session(int id) =>
      (db.select(db.sessions)..where((t) => t.id.equals(id))).getSingle();

  Future<ExerciseLog> _log(int id) =>
      (db.select(db.exerciseLogs)..where((t) => t.id.equals(id))).getSingle();

  Future<List<SetData>> _sets(int logId) async {
    final rows = await (db.select(db.setEntries)
          ..where((t) => t.exerciseLogId.equals(logId))
          ..orderBy([(t) => OrderingTerm.asc(t.idx)]))
        .get();
    return [for (final r in rows) SetData(r.weight, r.reps)];
  }

  int _seconds(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;
}

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(
    ref.watch(appDatabaseProvider),
    weeklyGoal: () => ref.read(weeklyGoalProvider),
  ),
);
