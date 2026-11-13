import 'dart:convert';

import 'epoch_day.dart';

// The TonFit backup format (requirements FR-33, FR-34).
//
// A backup holds only the source of truth: programs, exercises, sessions with
// their exercises and sets, and rest days. Every cached summary (percentages,
// heatmap, streak, suggestions) is rebuilt after a restore.
//
// The JSON is produced in pieces (prefix, one session at a time, suffix) so a
// 10-year history never has to sit in memory as one big string.

class BackupProgram {
  const BackupProgram({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.archived,
  });
  final int id;
  final String name;
  final int sortOrder;
  final bool archived;

  Map<String, Object?> toJson() =>
      {'id': id, 'name': name, 'sortOrder': sortOrder, 'archived': archived};
}

class BackupExercise {
  const BackupExercise({
    required this.id,
    required this.programId,
    required this.name,
    required this.type,
    required this.archived,
  });
  final int id;
  final int programId;
  final String name;

  /// 'weighted', 'bodyweight', 'timed' or 'sport'.
  final String type;
  final bool archived;

  Map<String, Object?> toJson() => {
        'id': id,
        'programId': programId,
        'name': name,
        'type': type,
        'archived': archived,
      };
}

class BackupSet {
  const BackupSet({required this.weight, required this.reps});

  /// Hundredths of a kilogram; null for a pure bodyweight set and for timed
  /// and sport exercises.
  final int? weight;

  /// Repetitions, or for timed and sport exercises the duration in seconds.
  final int reps;

  /// Compact form: [weight, reps].
  List<Object?> toJson() => [weight, reps];
}

class BackupLog {
  const BackupLog({required this.exerciseId, required this.sets});
  final int exerciseId;

  /// In order; the position is the set number.
  final List<BackupSet> sets;

  Map<String, Object?> toJson() => {
        'exerciseId': exerciseId,
        'sets': [for (final s in sets) s.toJson()],
      };
}

class BackupSession {
  const BackupSession({
    required this.day,
    required this.programId,
    required this.timeIn,
    required this.timeOut,
    required this.logs,
  });
  final int day;
  final int programId;
  final int? timeIn;
  final int? timeOut;

  /// In order; the position is the exercise order within the session.
  final List<BackupLog> logs;

  Map<String, Object?> toJson() => {
        'day': day,
        'programId': programId,
        'timeIn': timeIn,
        'timeOut': timeOut,
        'logs': [for (final l in logs) l.toJson()],
      };
}

class BackupData {
  const BackupData({
    required this.version,
    required this.exportedAt,
    required this.settings,
    required this.programs,
    required this.exercises,
    required this.restDays,
    required this.sessions,
  });

  final int version;
  final String exportedAt;
  final Map<String, Object?> settings;
  final List<BackupProgram> programs;
  final List<BackupExercise> exercises;
  final List<int> restDays;
  final List<BackupSession> sessions;

  int get setCount => sessions.fold<int>(
        0,
        (a, s) => a + s.logs.fold<int>(0, (b, l) => b + l.sets.length),
      );
}

abstract final class BackupFormat {
  static const String app = 'tonfit';
  static const int version = 1;

  // --- writing ---------------------------------------------------------------

  /// Everything before the first session.
  static String prefix({
    required String exportedAt,
    required Map<String, Object?> settings,
    required List<BackupProgram> programs,
    required List<BackupExercise> exercises,
    required List<int> restDays,
  }) {
    return '{'
        '"app":${jsonEncode(app)},'
        '"version":$version,'
        '"exportedAt":${jsonEncode(exportedAt)},'
        '"settings":${jsonEncode(settings)},'
        '"programs":${jsonEncode([for (final p in programs) p.toJson()])},'
        '"exercises":${jsonEncode([for (final e in exercises) e.toJson()])},'
        '"restDays":${jsonEncode(restDays)},'
        '"sessions":[';
  }

  static String sessionJson(BackupSession s) => jsonEncode(s.toJson());

  static const String suffix = ']}';

  /// The whole document as one string. The app streams the pieces instead;
  /// this exists for tests and small data.
  static String encode(BackupData d) {
    return prefix(
          exportedAt: d.exportedAt,
          settings: d.settings,
          programs: d.programs,
          exercises: d.exercises,
          restDays: d.restDays,
        ) +
        d.sessions.map(sessionJson).join(',') +
        suffix;
  }

  // --- reading ---------------------------------------------------------------

  /// Parses and validates a backup. Throws [FormatException] with a message
  /// that is safe to show to the user.
  static BackupData parse(String source) {
    final Object? root;
    try {
      root = jsonDecode(source);
    } on FormatException {
      throw const FormatException('This file is not a TonFit backup.');
    }
    if (root is! Map<String, Object?> || root['app'] != app) {
      throw const FormatException('This file is not a TonFit backup.');
    }
    final fileVersion = root['version'];
    if (fileVersion is! int || fileVersion < 1) {
      throw const FormatException('This backup has no valid version.');
    }
    if (fileVersion > version) {
      throw const FormatException(
        'This backup was made by a newer version of TonFit. Update the app first.',
      );
    }

    final programs = [
      for (final p in _list(root, 'programs'))
        BackupProgram(
          id: _int(_map(p, 'program')['id'], 'program id'),
          name: _string(_map(p, 'program')['name'], 'program name'),
          sortOrder: _int(_map(p, 'program')['sortOrder'], 'program order'),
          archived: _bool(_map(p, 'program')['archived']),
        ),
    ];
    final programIds = {for (final p in programs) p.id};
    if (programIds.length != programs.length) {
      throw const FormatException('The backup lists a program twice.');
    }

    final exercises = [
      for (final e in _list(root, 'exercises'))
        BackupExercise(
          id: _int(_map(e, 'exercise')['id'], 'exercise id'),
          programId: _int(_map(e, 'exercise')['programId'], 'exercise program'),
          name: _string(_map(e, 'exercise')['name'], 'exercise name'),
          type: _type(_map(e, 'exercise')['type']),
          archived: _bool(_map(e, 'exercise')['archived']),
        ),
    ];
    final exerciseIds = {for (final e in exercises) e.id};
    if (exerciseIds.length != exercises.length) {
      throw const FormatException('The backup lists an exercise twice.');
    }
    for (final e in exercises) {
      if (!programIds.contains(e.programId)) {
        throw FormatException('Exercise “${e.name}” belongs to a missing program.');
      }
    }

    final sessionDays = <int>{};
    final sessions = <BackupSession>[];
    for (final raw in _list(root, 'sessions')) {
      final s = _map(raw, 'session');
      final day = _int(s['day'], 'session day');
      final programId = _int(s['programId'], 'session program');
      if (!programIds.contains(programId)) {
        throw const FormatException('A session belongs to a missing program.');
      }
      if (!sessionDays.add(day)) {
        throw FormatException(
          'The backup has two sessions on ${_dateLabel(day)}.',
        );
      }
      final logs = <BackupLog>[];
      final seenExercises = <int>{};
      for (final rawLog in _list(s, 'logs')) {
        final l = _map(rawLog, 'exercise entry');
        final exerciseId = _int(l['exerciseId'], 'exercise id');
        if (!exerciseIds.contains(exerciseId)) {
          throw const FormatException('A session uses a missing exercise.');
        }
        if (!seenExercises.add(exerciseId)) {
          throw FormatException(
            'The same exercise appears twice on ${_dateLabel(day)}.',
          );
        }
        final sets = <BackupSet>[];
        for (final rawSet in _list(l, 'sets')) {
          if (rawSet is! List || rawSet.length != 2) {
            throw const FormatException('A set is not in the expected form.');
          }
          final weight = rawSet[0];
          final reps = _int(rawSet[1], 'reps');
          if (weight != null && (weight is! int || weight < 0)) {
            throw const FormatException('A set has an invalid weight.');
          }
          if (reps < 1) {
            throw const FormatException('A set has an invalid number of reps.');
          }
          sets.add(BackupSet(weight: weight as int?, reps: reps));
        }
        logs.add(BackupLog(exerciseId: exerciseId, sets: sets));
      }
      sessions.add(BackupSession(
        day: day,
        programId: programId,
        timeIn: _intOrNull(s['timeIn']),
        timeOut: _intOrNull(s['timeOut']),
        logs: logs,
      ));
    }

    final restDays = [
      for (final d in _list(root, 'restDays')) _int(d, 'rest day'),
    ];

    final settings = root['settings'];
    return BackupData(
      version: fileVersion,
      exportedAt: root['exportedAt'] is String ? root['exportedAt'] as String : '',
      settings: settings is Map<String, Object?> ? settings : const {},
      programs: programs,
      exercises: exercises,
      restDays: restDays,
      sessions: sessions,
    );
  }

  // --- CSV -------------------------------------------------------------------

  static const String csvHeader =
      'date,program,exercise,set,weight_kg,reps,seconds\n';

  /// Escapes one CSV field (quotes when it contains a comma, quote or newline).
  static String csvField(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// "2026-10-24"
  static String dateLabel(int day) => _dateLabel(day);

  /// Stored hundredths of a kg as plain kg: 6000 -> "60", 5750 -> "57.5".
  static String kgText(int? stored) {
    if (stored == null) return '';
    var s = (stored / 100).toStringAsFixed(2);
    if (s.endsWith('0')) s = s.substring(0, s.length - 1);
    if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
    return s;
  }

  /// One set. Strength rows fill weight and reps; timed and sport rows fill
  /// only the seconds column.
  static String csvRow({
    required int day,
    required String program,
    required String exercise,
    required int setNumber,
    required int? weight,
    required int reps,
    bool timeBased = false,
  }) {
    final head = '${_dateLabel(day)},${csvField(program)},${csvField(exercise)},'
        '$setNumber,';
    return timeBased
        ? '$head,,$reps\n'
        : '$head${kgText(weight)},$reps,\n';
  }

  // --- helpers ---------------------------------------------------------------

  static String _dateLabel(int day) {
    final d = EpochDay.toDate(day);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  static List<Object?> _list(Map<String, Object?> m, String key) {
    final v = m[key];
    if (v is! List) {
      throw FormatException('The backup is missing its “$key” list.');
    }
    return v;
  }

  static Map<String, Object?> _map(Object? v, String what) {
    if (v is! Map<String, Object?>) {
      throw FormatException('A $what entry is not in the expected form.');
    }
    return v;
  }

  static int _int(Object? v, String what) {
    if (v is! int) throw FormatException('The backup has an invalid $what.');
    return v;
  }

  static int? _intOrNull(Object? v) {
    if (v == null) return null;
    if (v is! int) throw const FormatException('The backup has an invalid time.');
    return v;
  }

  static String _string(Object? v, String what) {
    if (v is! String || v.trim().isEmpty) {
      throw FormatException('The backup has an invalid $what.');
    }
    return v;
  }

  static bool _bool(Object? v) => v == true;

  static String _type(Object? v) {
    if (v == 'weighted' || v == 'bodyweight' || v == 'timed' || v == 'sport') {
      return v as String;
    }
    throw const FormatException('An exercise has an unknown type.');
  }
}
