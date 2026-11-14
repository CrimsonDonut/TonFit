import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/domain/exercise_type.dart';
import 'package:tonfit/domain/progress.dart';

void main() {
  group('metrics', () {
    test('weighted volume is sum of weight x reps', () {
      final m = Progress.metrics(const [
        SetData(6000, 10),
        SetData(6000, 8),
        SetData(5750, 8),
      ]);
      expect(m.volume, equals(60000 + 48000 + 46000));
      expect(m.setCount, equals(3));
      expect(m.topWeight, equals(6000));
      expect(m.repsAtTop, equals(10));
    });

    test('bodyweight volume uses the reference body weight', () {
      final m = Progress.metrics(
        const [SetData(null, 10), SetData(null, 8)],
        type: ExerciseType.bodyweight,
      );
      expect(m.volume, equals(7000 * 18));
      expect(m.topWeight, equals(0));
      expect(m.repsAtTop, equals(10));
    });

    test('added weight raises bodyweight volume smoothly', () {
      final plain = Progress.metrics(const [SetData(null, 8)], type: ExerciseType.bodyweight);
      final added = Progress.metrics(const [SetData(1000, 8)], type: ExerciseType.bodyweight);
      final pct = Progress.pctTenths(added.volume, plain.volume);
      expect(pct, equals(143)); // +14.3%, not thousands of percent
    });

    test('timed volume is total seconds and the best set is the longest', () {
      final m = Progress.metrics(
        const [SetData(null, 60), SetData(null, 45), SetData(null, 75)],
        type: ExerciseType.timed,
      );
      expect(m.volume, equals(180));
      expect(m.setCount, equals(3));
      expect(m.topWeight, equals(0));
      expect(m.repsAtTop, equals(75));
    });

    test('sport is measured the same way, in seconds', () {
      final m = Progress.metrics(
        const [SetData(null, 5400)],
        type: ExerciseType.sport,
      );
      expect(m.volume, equals(5400));
      expect(m.repsAtTop, equals(5400));
    });

    test('with distance tracked, volume is total metres and the best set the farthest', () {
      final m = Progress.metrics(
        const [
          SetData(null, 1710, distance: 5000),
          SetData(null, 600, distance: 2000),
        ],
        type: ExerciseType.timed,
        trackDistance: true,
      );
      expect(m.volume, equals(7000));
      expect(m.setCount, equals(2));
      expect(m.repsAtTop, equals(5000));
    });

    test('without tracking distance, time is still what counts', () {
      final m = Progress.metrics(
        const [SetData(null, 1710, distance: 5000)],
        type: ExerciseType.timed,
      );
      expect(m.volume, equals(1710));
    });

    test('a longer run shows as a gain, a faster one over the same distance does not', () {
      int vol(int metres, int seconds) => Progress.metrics(
            [SetData(null, seconds, distance: metres)],
            type: ExerciseType.timed,
            trackDistance: true,
          ).volume;
      expect(Progress.pctTenths(vol(5500, 1800), vol(5000, 1800)), equals(100));
      expect(Progress.pctTenths(vol(5000, 1500), vol(5000, 1800)), equals(0));
    });

    test('sets with different distances are not equal', () {
      expect(const SetData(null, 60, distance: 1000) == const SetData(null, 60, distance: 2000),
          isFalse);
      expect(const SetData(null, 60, distance: 1000) == const SetData(null, 60, distance: 1000),
          isTrue);
    });

    test('a longer plank shows as a gain', () {
      final before = Progress.metrics(const [SetData(null, 60)], type: ExerciseType.timed);
      final after = Progress.metrics(const [SetData(null, 66)], type: ExerciseType.timed);
      expect(Progress.pctTenths(after.volume, before.volume), equals(100)); // +10.0%
    });

    test('no sets gives zeros', () {
      final m = Progress.metrics(const []);
      expect(m.volume, equals(0));
      expect(m.topWeight, equals(0));
      expect(m.repsAtTop, equals(0));
    });
  });

  group('pctTenths', () {
    test('gain, loss, flat', () {
      expect(Progress.pctTenths(1038, 1000), equals(38));
      expect(Progress.pctTenths(979, 1000), equals(-21));
      expect(Progress.pctTenths(1000, 1000), equals(0));
    });

    test('rounds to the nearest tenth', () {
      expect(Progress.pctTenths(154000, 147000), equals(48)); // 4.76%
    });

    test('New when there is no usable previous value', () {
      expect(Progress.pctTenths(1000, null), isNull);
      expect(Progress.pctTenths(1000, 0), isNull);
    });
  });

  group('sessionPctTenths', () {
    test('counts only exercises present in both sessions', () {
      final now = {1: 1100, 2: 500, 3: 99999}; // 3 is new this time
      final prev = {1: 1000, 2: 500, 4: 99999}; // 4 was skipped
      // (1100 + 500) vs (1000 + 500) = +6.7%
      expect(Progress.sessionPctTenths(now, prev), equals(67));
    });

    test('New when nothing is shared', () {
      expect(Progress.sessionPctTenths({1: 10}, {2: 10}), isNull);
      expect(Progress.sessionPctTenths({1: 10}, {}), isNull);
    });
  });

  group('sessionPctByKind', () {
    test('a strength-only session matches sessionPctTenths', () {
      final now = {1: 1100, 2: 500};
      final prev = {1: 1000, 2: 500};
      expect(
        Progress.sessionPctByKind(
          nowStrength: now,
          previousStrength: prev,
          nowTimed: {},
          previousTimed: {},
        ),
        equals(Progress.sessionPctTenths(now, prev)),
      );
    });

    test('a timed-only session is compared on seconds', () {
      expect(
        Progress.sessionPctByKind(
          nowStrength: {},
          previousStrength: {},
          nowTimed: {5: 330}, // 5:30 run
          previousTimed: {5: 300}, // 5:00 run
        ),
        equals(100), // +10.0%
      );
    });

    test('mixed sessions average the two kinds instead of adding units', () {
      // strength +10.0%, timed -20.0% -> average -5.0%
      expect(
        Progress.sessionPctByKind(
          nowStrength: {1: 1100},
          previousStrength: {1: 1000},
          nowTimed: {5: 240},
          previousTimed: {5: 300},
        ),
        equals(-50),
      );
    });

    test('a kind with nothing in common is ignored, not counted as zero', () {
      expect(
        Progress.sessionPctByKind(
          nowStrength: {1: 1100},
          previousStrength: {1: 1000},
          nowTimed: {5: 240}, // a timed exercise that is new this time
          previousTimed: {6: 300},
        ),
        equals(100),
      );
    });

    test('nothing comparable gives null', () {
      expect(
        Progress.sessionPctByKind(
          nowStrength: {},
          previousStrength: {},
          nowTimed: {},
          previousTimed: {},
        ),
        isNull,
      );
    });
  });

  group('format', () {
    test('always signed with one decimal', () {
      expect(Progress.format(38), equals('+3.8%'));
      expect(Progress.format(-21), equals('-2.1%'));
      expect(Progress.format(0), equals('0.0%'));
      expect(Progress.format(5), equals('+0.5%'));
      expect(Progress.format(-5), equals('-0.5%'));
      expect(Progress.format(1234), equals('+123.4%'));
      expect(Progress.format(null), equals('New'));
    });
  });
}
