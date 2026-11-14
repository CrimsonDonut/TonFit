import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/domain/backup_format.dart';

BackupData sample() => const BackupData(
      version: 1,
      exportedAt: '2026-10-25T12:00:00.000',
      settings: {'weightUnit': 'kg', 'weeklyGoal': 4},
      programs: [
        BackupProgram(id: 1, name: 'Push', sortOrder: 0, archived: false),
        BackupProgram(id: 2, name: 'Pull, heavy', sortOrder: 1, archived: true),
      ],
      exercises: [
        BackupExercise(
            id: 10, programId: 1, name: 'Bench Press', type: 'weighted', archived: false),
        BackupExercise(
            id: 11, programId: 1, name: 'Dips', type: 'bodyweight', archived: false),
        BackupExercise(
            id: 20, programId: 2, name: 'Row', type: 'weighted', archived: true),
      ],
      restDays: [20751],
      sessions: [
        BackupSession(
          day: 20745,
          programId: 1,
          timeIn: 1000,
          timeOut: 5000,
          logs: [
            BackupLog(exerciseId: 10, sets: [
              BackupSet(weight: 6000, reps: 10),
              BackupSet(weight: 5750, reps: 8),
            ]),
            BackupLog(exerciseId: 11, sets: [
              BackupSet(weight: null, reps: 12),
            ]),
          ],
        ),
        BackupSession(
          day: 20750,
          programId: 1,
          timeIn: null,
          timeOut: null,
          logs: [BackupLog(exerciseId: 10, sets: [])],
        ),
      ],
    );

/// Re-encodes a parsed backup, to compare documents without writing equality
/// operators on every class.
String again(BackupData d) => BackupFormat.encode(d);

FormatException? failure(String json) {
  try {
    BackupFormat.parse(json);
    return null;
  } on FormatException catch (e) {
    return e;
  }
}

Map<String, Object?> docOf(BackupData d) =>
    jsonDecode(BackupFormat.encode(d)) as Map<String, Object?>;

void main() {
  group('round trip', () {
    test('encode then parse gives the same document', () {
      final json = BackupFormat.encode(sample());
      final parsed = BackupFormat.parse(json);
      expect(again(parsed), equals(json));
      expect(parsed.programs.length, equals(2));
      expect(parsed.programs[1].archived, isTrue);
      expect(parsed.sessions.length, equals(2));
      expect(parsed.restDays, equals([20751]));
      expect(parsed.setCount, equals(3));
      expect(parsed.settings['weeklyGoal'], equals(4));
    });

    test('the streamed pieces form the same valid document', () {
      final d = sample();
      final streamed = StringBuffer()
        ..write(BackupFormat.prefix(
          exportedAt: d.exportedAt,
          settings: d.settings,
          programs: d.programs,
          exercises: d.exercises,
          restDays: d.restDays,
        ));
      for (var i = 0; i < d.sessions.length; i++) {
        if (i > 0) streamed.write(',');
        streamed.write(BackupFormat.sessionJson(d.sessions[i]));
      }
      streamed.write(BackupFormat.suffix);
      expect(streamed.toString(), equals(BackupFormat.encode(d)));
      expect(BackupFormat.parse(streamed.toString()).sessions.length, equals(2));
    });

    test('an empty history round-trips', () {
      const empty = BackupData(
        version: 1,
        exportedAt: '',
        settings: {},
        programs: [],
        exercises: [],
        restDays: [],
        sessions: [],
      );
      final parsed = BackupFormat.parse(BackupFormat.encode(empty));
      expect(parsed.sessions, isEmpty);
      expect(parsed.setCount, equals(0));
    });

    test('names with quotes, commas and unicode survive', () {
      const d = BackupData(
        version: 1,
        exportedAt: 'x',
        settings: {},
        programs: [BackupProgram(id: 1, name: 'Arms "&" Core, ñ', sortOrder: 0, archived: false)],
        exercises: [],
        restDays: [],
        sessions: [],
      );
      expect(BackupFormat.parse(BackupFormat.encode(d)).programs.single.name,
          equals('Arms "&" Core, ñ'));
    });
  });

  group('validation', () {
    test('not JSON', () {
      expect(failure('hello')?.message, contains('not a TonFit backup'));
    });

    test('JSON that is not a TonFit backup', () {
      expect(failure('{"app":"other","version":1}')?.message,
          contains('not a TonFit backup'));
      expect(failure('[1,2,3]')?.message, contains('not a TonFit backup'));
    });

    test('a newer version is refused with a helpful message', () {
      final doc = docOf(sample())..['version'] = 99;
      expect(failure(jsonEncode(doc))?.message, contains('newer version'));
    });

    test('a session pointing at a missing program', () {
      final doc = docOf(sample());
      ((doc['sessions'] as List).first as Map)['programId'] = 999;
      expect(failure(jsonEncode(doc))?.message, contains('missing program'));
    });

    test('an exercise pointing at a missing program', () {
      final doc = docOf(sample());
      ((doc['exercises'] as List).first as Map)['programId'] = 999;
      expect(failure(jsonEncode(doc))?.message, contains('missing program'));
    });

    test('a log using a missing exercise', () {
      final doc = docOf(sample());
      final logs = ((doc['sessions'] as List).first as Map)['logs'] as List;
      (logs.first as Map)['exerciseId'] = 999;
      expect(failure(jsonEncode(doc))?.message, contains('missing exercise'));
    });

    test('two sessions on the same day', () {
      final doc = docOf(sample());
      ((doc['sessions'] as List)[1] as Map)['day'] = 20745;
      expect(failure(jsonEncode(doc))?.message, contains('two sessions on 2026-10-19'));
    });

    test('the same exercise twice in one session', () {
      final doc = docOf(sample());
      final logs = ((doc['sessions'] as List).first as Map)['logs'] as List;
      (logs[1] as Map)['exerciseId'] = 10;
      expect(failure(jsonEncode(doc))?.message, contains('appears twice'));
    });

    test('invalid sets', () {
      for (final bad in [
        [6000, 0], // no reps
        [-5, 10], // negative weight
        [6000], // wrong shape
        ['60', 10], // weight not a number
      ]) {
        final doc = docOf(sample());
        final logs = ((doc['sessions'] as List).first as Map)['logs'] as List;
        ((logs.first as Map)['sets'] as List)[0] = bad;
        expect(failure(jsonEncode(doc)), isNotNull);
      }
    });

    test('an unknown exercise type', () {
      final doc = docOf(sample());
      ((doc['exercises'] as List).first as Map)['type'] = 'cardio';
      expect(failure(jsonEncode(doc))?.message, contains('unknown type'));
    });

    test('a missing list', () {
      final doc = docOf(sample())..remove('sessions');
      expect(failure(jsonEncode(doc))?.message, contains('sessions'));
    });
  });

  group('timed and sport in a backup', () {
    test('the new exercise types round-trip', () {
      const d = BackupData(
        version: 1,
        exportedAt: 'x',
        settings: {},
        programs: [BackupProgram(id: 1, name: 'Cardio', sortOrder: 0, archived: false)],
        exercises: [
          BackupExercise(id: 1, programId: 1, name: 'Plank', type: 'timed', archived: false),
          BackupExercise(id: 2, programId: 1, name: 'Basketball', type: 'sport', archived: false),
        ],
        restDays: [],
        sessions: [
          BackupSession(day: 20750, programId: 1, timeIn: null, timeOut: null, logs: [
            BackupLog(exerciseId: 1, sets: [BackupSet(weight: null, reps: 60)]),
            BackupLog(exerciseId: 2, sets: [BackupSet(weight: null, reps: 5400)]),
          ]),
        ],
      );
      final parsed = BackupFormat.parse(BackupFormat.encode(d));
      expect(parsed.exercises.map((e) => e.type).toList(), equals(['timed', 'sport']));
      expect(parsed.sessions.single.logs[1].sets.single.reps, equals(5400));
    });

    test('a timed row fills only the seconds column', () {
      expect(
        BackupFormat.csvRow(
          day: 20750,
          program: 'Cardio',
          exercise: 'Plank',
          setNumber: 2,
          weight: null,
          reps: 90,
          timeBased: true,
        ),
        equals('2026-10-24,Cardio,Plank,2,,,90,\n'),
      );
    });
  });

  group('distance in a backup', () {
    BackupData withRun() => const BackupData(
          version: 1,
          exportedAt: 'x',
          settings: {},
          programs: [BackupProgram(id: 1, name: 'Cardio', sortOrder: 0, archived: false)],
          exercises: [
            BackupExercise(
                id: 1,
                programId: 1,
                name: 'Running',
                type: 'timed',
                archived: false,
                tracksDistance: true),
            BackupExercise(
                id: 2, programId: 1, name: 'Plank', type: 'timed', archived: false),
          ],
          restDays: [],
          sessions: [
            BackupSession(day: 20750, programId: 1, timeIn: null, timeOut: null, logs: [
              BackupLog(exerciseId: 1, sets: [
                BackupSet(weight: null, reps: 1710, distance: 5250),
              ]),
              BackupLog(exerciseId: 2, sets: [BackupSet(weight: null, reps: 60)]),
            ]),
          ],
        );

    test('the flag and the distances round-trip', () {
      final parsed = BackupFormat.parse(BackupFormat.encode(withRun()));
      expect(parsed.exercises[0].tracksDistance, isTrue);
      expect(parsed.exercises[1].tracksDistance, isFalse);
      expect(parsed.sessions.single.logs[0].sets.single.distance, equals(5250));
      expect(parsed.sessions.single.logs[1].sets.single.distance, isNull);
    });

    test('a set without distance stays in the compact two-value form', () {
      expect(const BackupSet(weight: 6000, reps: 10).toJson(), equals([6000, 10]));
      expect(const BackupSet(weight: null, reps: 60, distance: 1000).toJson(),
          equals([null, 60, 1000]));
    });

    test('a negative or non-numeric distance is refused', () {
      for (final bad in [-5, '5 km', 1.5]) {
        final doc = jsonDecode(BackupFormat.encode(withRun())) as Map<String, Object?>;
        final logs = ((doc['sessions'] as List).first as Map)['logs'] as List;
        ((logs.first as Map)['sets'] as List)[0] = [null, 1710, bad];
        expect(failure(jsonEncode(doc))?.message, contains('invalid distance'));
      }
    });

    test('old backups without the field still load', () {
      final doc = jsonDecode(BackupFormat.encode(sample())) as Map<String, Object?>;
      expect(BackupFormat.parse(jsonEncode(doc)).exercises.first.tracksDistance, isFalse);
    });

    test('CSV rows carry kilometres', () {
      expect(BackupFormat.kmText(5250), equals('5.25'));
      expect(BackupFormat.kmText(5000), equals('5'));
      expect(BackupFormat.kmText(500), equals('0.5'));
      expect(BackupFormat.kmText(null), equals(''));
      expect(
        BackupFormat.csvRow(
          day: 20750,
          program: 'Cardio',
          exercise: 'Running',
          setNumber: 1,
          weight: null,
          reps: 1710,
          timeBased: true,
          distance: 5250,
        ),
        equals('2026-10-24,Cardio,Running,1,,,1710,5.25\n'),
      );
    });
  });

  group('CSV', () {
    test('header and escaping', () {
      expect(BackupFormat.csvHeader, equals('date,program,exercise,set,weight_kg,reps,seconds,distance_km\n'));
      expect(BackupFormat.csvField('Bench Press'), equals('Bench Press'));
      expect(BackupFormat.csvField('Pull, heavy'), equals('"Pull, heavy"'));
      expect(BackupFormat.csvField('The "big" one'), equals('"The ""big"" one"'));
      expect(BackupFormat.csvField('two\nlines'), equals('"two\nlines"'));
    });

    test('kg text', () {
      expect(BackupFormat.kgText(6000), equals('60'));
      expect(BackupFormat.kgText(5750), equals('57.5'));
      expect(BackupFormat.kgText(5725), equals('57.25'));
      expect(BackupFormat.kgText(100), equals('1'));
      expect(BackupFormat.kgText(0), equals('0'));
      expect(BackupFormat.kgText(null), equals(''));
    });

    test('a row', () {
      expect(
        BackupFormat.csvRow(
          day: 20750,
          program: 'Push',
          exercise: 'Bench Press',
          setNumber: 2,
          weight: 5750,
          reps: 8,
        ),
        equals('2026-10-24,Push,Bench Press,2,57.5,8,,\n'),
      );
      expect(
        BackupFormat.csvRow(
          day: 20745,
          program: 'Pull, heavy',
          exercise: 'Pull-Up',
          setNumber: 1,
          weight: null,
          reps: 12,
        ),
        equals('2026-10-19,"Pull, heavy",Pull-Up,1,,12,,\n'),
      );
    });
  });
}
