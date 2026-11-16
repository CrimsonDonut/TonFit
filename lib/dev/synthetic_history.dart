import 'dart:math' as math;

import '../domain/backup_format.dart';
import '../domain/epoch_day.dart';

/// A realistic fake training history for performance testing (requirements
/// section 4.4): about ten years, five sessions a week plus the odd cardio day,
/// roughly 100,000 sets. Strength rises quickly and then plateaus, with stalls,
/// bad days and deload weeks, so the suggestion rules have real work to do.
///
/// Deterministic for a given [seed]. Pure Dart: it builds a [BackupData], which
/// the app loads through the normal restore path.
abstract final class SyntheticHistory {
  static BackupData generate({
    required int endDay,
    int years = 10,
    int seed = 42,
  }) {
    final random = math.Random(seed);

    // ----- programs and exercises -----
    final programs = <BackupProgram>[];
    final exercises = <BackupExercise>[];
    final byProgram = <String, List<_Ex>>{};
    var exerciseId = 0;
    var programId = 0;
    for (final entry in _specs.entries) {
      programId++;
      programs.add(BackupProgram(
        id: programId,
        name: entry.key,
        sortOrder: programId - 1,
        archived: false,
      ));
      final list = <_Ex>[];
      for (final spec in entry.value) {
        exerciseId++;
        exercises.add(BackupExercise(
          id: exerciseId,
          programId: programId,
          name: spec.name,
          type: spec.type,
          archived: false,
          tracksDistance: spec.distance,
        ));
        list.add(_Ex(exerciseId, programId, spec));
      }
      byProgram[entry.key] = list;
    }

    // ----- sessions -----
    final startDay = endDay - years * 365;
    final firstMonday = EpochDay.weekStart(startDay);
    final sessions = <BackupSession>[];
    final used = <int>{};

    for (var weekStart = firstMonday; weekStart <= endDay; weekStart += 7) {
      final weekIndex = (weekStart - firstMonday) ~/ 7;
      if (random.nextDouble() < 0.05) continue; // a week off
      for (final (offset, programName) in _week) {
        final day = weekStart + offset;
        if (day < startDay || day > endDay) continue;
        if (random.nextDouble() > 0.95) continue; // a missed session
        final progress = (day - startDay) / (years * 365);
        final deload = weekIndex % 9 == 8;
        sessions.add(_strengthSession(
          random,
          day,
          byProgram[programName]!,
          progress,
          deload,
        ));
        used.add(day);
      }
      final sunday = weekStart + 6;
      if (sunday >= startDay && sunday <= endDay && random.nextDouble() < 0.35) {
        sessions.add(_cardioSession(random, sunday, byProgram['Cardio']!));
        used.add(sunday);
      }
    }

    // ----- a few rest days on days with no session -----
    final restDays = <int>[];
    for (var day = startDay; day <= endDay; day++) {
      if (!used.contains(day) && random.nextDouble() < 0.03) restDays.add(day);
    }

    return BackupData(
      version: BackupFormat.version,
      exportedAt: 'synthetic',
      settings: const {'weightUnit': 'kg', 'weeklyGoal': 4},
      programs: programs,
      exercises: exercises,
      restDays: restDays,
      sessions: sessions,
    );
  }

  // ---------------------------------------------------------------------------

  /// Monday = 0. Push, Pull, Legs, Upper (Friday) and Full Body (Saturday).
  static const List<(int, String)> _week = [
    (0, 'Push'),
    (1, 'Pull'),
    (2, 'Legs'),
    (4, 'Upper'),
    (5, 'Full Body'),
  ];

  static BackupSession _strengthSession(
    math.Random random,
    int day,
    List<_Ex> list,
    double progress, // 0 at the start of the history, 1 now
    bool deload,
  ) {
    // 8 to 10 of the program's exercises, in order.
    final count = math.min(list.length, 8 + random.nextInt(3));
    final logs = <BackupLog>[];
    var totalSets = 0;

    for (final ex in list.take(count)) {
      final spec = ex.spec;
      final sets = <BackupSet>[];
      final setCount = 4 + random.nextInt(2); // 4 or 5

      switch (spec.type) {
        case 'timed':
          // e.g. a plank: 40 s rising towards 2 minutes.
          final base = 40 + (80 * _curve(progress)).round();
          for (var i = 0; i < 3; i++) {
            sets.add(BackupSet(
                weight: null, reps: math.max(15, base + random.nextInt(21) - 10)));
          }
        case 'bodyweight':
          final reps = 8 + (6 * _curve(progress)).round();
          final added = progress > 0.2 && random.nextBool()
              ? 500 + 250 * random.nextInt(7)
              : null;
          for (var i = 0; i < setCount; i++) {
            sets.add(BackupSet(
              weight: added,
              reps: math.max(4, reps - i + random.nextInt(3) - 1),
            ));
          }
        default:
          var weight = _loadFor(random, spec, progress, deload);
          // A bad day now and then.
          if (random.nextDouble() < 0.07) weight -= _step(spec);
          weight = math.max(_step(spec), weight);
          var reps = 8 + random.nextInt(3); // 8 to 10
          for (var i = 0; i < setCount; i++) {
            sets.add(BackupSet(weight: weight, reps: math.max(5, reps)));
            reps -= random.nextInt(2); // sometimes one rep fewer
          }
      }
      totalSets += sets.length;
      logs.add(BackupLog(exerciseId: ex.id, sets: sets));
    }

    final start = _startSeconds(random, day);
    final minutes = 15 + (totalSets * 2.2).round() + random.nextInt(11);
    return BackupSession(
      day: day,
      programId: list.first.programId,
      timeIn: start,
      timeOut: start + minutes * 60,
      logs: logs,
    );
  }

  static BackupSession _cardioSession(
    math.Random random,
    int day,
    List<_Ex> list,
  ) {
    // One or two of: running, cycling, basketball, rowing.
    final picks = [...list]..shuffle(random);
    final chosen = picks.take(1 + random.nextInt(2)).toList();
    final logs = <BackupLog>[];
    var seconds = 0;

    for (final ex in chosen) {
      final spec = ex.spec;
      if (spec.type == 'sport') {
        final secs = 300 * (12 + random.nextInt(13)); // 60 to 120 minutes
        seconds += secs;
        logs.add(BackupLog(exerciseId: ex.id, sets: [BackupSet(weight: null, reps: secs)]));
      } else if (spec.distance) {
        final secs = 60 * (25 + random.nextInt(31)); // 25 to 55 minutes
        final pace = 330 + random.nextInt(71); // 5:30 to 6:40 per km
        seconds += secs;
        logs.add(BackupLog(exerciseId: ex.id, sets: [
          BackupSet(weight: null, reps: secs, distance: (secs / pace * 1000).round()),
        ]));
      } else {
        final secs = 60 * (20 + random.nextInt(41));
        seconds += secs;
        logs.add(BackupLog(exerciseId: ex.id, sets: [BackupSet(weight: null, reps: secs)]));
      }
    }

    final start = _startSeconds(random, day);
    return BackupSession(
      day: day,
      programId: list.first.programId,
      timeIn: start,
      timeOut: start + seconds,
      logs: logs,
    );
  }

  /// Fast gains early, then a plateau.
  static double _curve(double progress) => 1 - math.exp(-progress * 3.5);

  static int _step(_Spec spec) => spec.baseKg < 20 ? 100 : 250;

  /// The working weight for this day, in hundredths of a kilogram: it climbs
  /// along a curve, with stalls (the weight stays put) and a lighter deload week.
  static int _loadFor(
    math.Random random,
    _Spec spec,
    double progress,
    bool deload,
  ) {
    final target = spec.baseKg * (1 + 0.9 * _curve(progress)) * 100;
    // Noise of a step or so, and the lifter does not always hit the target.
    var weight = target - random.nextInt(3) * _step(spec);
    if (deload) weight *= 0.9;
    final step = _step(spec);
    return (weight / step).round() * step;
  }

  /// Epoch seconds for a session starting between 17:00 and 19:30 local time.
  static int _startSeconds(math.Random random, int day) {
    final date = EpochDay.toDate(day);
    final minutes = 17 * 60 + random.nextInt(151);
    return DateTime(date.year, date.month, date.day, minutes ~/ 60, minutes % 60)
            .millisecondsSinceEpoch ~/
        1000;
  }

  // ---------------------------------------------------------------------------

  static const Map<String, List<_Spec>> _specs = {
    'Push': [
      _Spec('Bench Press', 'weighted', baseKg: 60),
      _Spec('Incline Dumbbell Press', 'weighted', baseKg: 24),
      _Spec('Overhead Press', 'weighted', baseKg: 40),
      _Spec('Lateral Raise', 'weighted', baseKg: 10),
      _Spec('Triceps Pushdown', 'weighted', baseKg: 25),
      _Spec('Dips', 'bodyweight'),
      _Spec('Cable Fly', 'weighted', baseKg: 15),
      _Spec('Skull Crushers', 'weighted', baseKg: 25),
      _Spec('Chest Press Machine', 'weighted', baseKg: 50),
      _Spec('Push-Up', 'bodyweight'),
    ],
    'Pull': [
      _Spec('Pull-Up', 'bodyweight'),
      _Spec('Barbell Row', 'weighted', baseKg: 60),
      _Spec('Lat Pulldown', 'weighted', baseKg: 50),
      _Spec('Seated Cable Row', 'weighted', baseKg: 45),
      _Spec('Face Pull', 'weighted', baseKg: 20),
      _Spec('Biceps Curl', 'weighted', baseKg: 15),
      _Spec('Hammer Curl', 'weighted', baseKg: 14),
      _Spec('Deadlift', 'weighted', baseKg: 100),
      _Spec('Shrug', 'weighted', baseKg: 40),
      _Spec('Rear Delt Fly', 'weighted', baseKg: 8),
    ],
    'Legs': [
      _Spec('Squat', 'weighted', baseKg: 80),
      _Spec('Romanian Deadlift', 'weighted', baseKg: 70),
      _Spec('Leg Press', 'weighted', baseKg: 140),
      _Spec('Leg Curl', 'weighted', baseKg: 35),
      _Spec('Leg Extension', 'weighted', baseKg: 40),
      _Spec('Calf Raise', 'weighted', baseKg: 60),
      _Spec('Lunge', 'weighted', baseKg: 30),
      _Spec('Hip Thrust', 'weighted', baseKg: 80),
      _Spec('Hack Squat', 'weighted', baseKg: 70),
      _Spec('Plank', 'timed'),
    ],
    'Upper': [
      _Spec('Bench Press', 'weighted', baseKg: 60),
      _Spec('Barbell Row', 'weighted', baseKg: 60),
      _Spec('Overhead Press', 'weighted', baseKg: 40),
      _Spec('Lat Pulldown', 'weighted', baseKg: 50),
      _Spec('Biceps Curl', 'weighted', baseKg: 15),
      _Spec('Triceps Pushdown', 'weighted', baseKg: 25),
      _Spec('Lateral Raise', 'weighted', baseKg: 10),
      _Spec('Face Pull', 'weighted', baseKg: 20),
      _Spec('Incline Dumbbell Press', 'weighted', baseKg: 24),
      _Spec('Dips', 'bodyweight'),
    ],
    'Full Body': [
      _Spec('Squat', 'weighted', baseKg: 80),
      _Spec('Bench Press', 'weighted', baseKg: 60),
      _Spec('Barbell Row', 'weighted', baseKg: 60),
      _Spec('Overhead Press', 'weighted', baseKg: 40),
      _Spec('Romanian Deadlift', 'weighted', baseKg: 70),
      _Spec('Pull-Up', 'bodyweight'),
      _Spec('Lunge', 'weighted', baseKg: 30),
      _Spec('Plank', 'timed'),
      _Spec('Hanging Leg Raise', 'bodyweight'),
    ],
    'Cardio': [
      _Spec('Running', 'timed', distance: true),
      _Spec('Cycling', 'timed'),
      _Spec('Basketball', 'sport'),
      _Spec('Rowing', 'timed'),
    ],
  };
}

class _Spec {
  const _Spec(this.name, this.type, {this.baseKg = 0, this.distance = false});
  final String name;
  final String type;
  final int baseKg;
  final bool distance;
}

class _Ex {
  const _Ex(this.id, this.programId, this.spec);
  final int id;
  final int programId;
  final _Spec spec;
}
