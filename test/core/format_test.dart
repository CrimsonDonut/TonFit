import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/core/format.dart';
import 'package:tonfit/domain/exercise_type.dart';
import 'package:tonfit/domain/weight.dart';

int secs(int h, int m) =>
    DateTime(2026, 10, 24, h, m).millisecondsSinceEpoch ~/ 1000;

void main() {
  group('Fmt', () {
    test('dates', () {
      expect(Fmt.dayLabel(DateTime(2026, 10, 24)), equals('Sat 24'));
      expect(Fmt.monthYear(DateTime(2026, 10, 24)), equals('October 2026'));
      expect(Fmt.month(1), equals('January'));
    });

    test('clock uses 12-hour time', () {
      expect(Fmt.clock(secs(18, 2)), equals('6:02 PM'));
      expect(Fmt.clock(secs(0, 5)), equals('12:05 AM'));
      expect(Fmt.clock(secs(12, 30)), equals('12:30 PM'));
      expect(Fmt.clock(secs(9, 0)), equals('9:00 AM'));
    });

    test('duration', () {
      expect(Fmt.duration(66 * 60), equals('1h 06m'));
      expect(Fmt.duration(45 * 60), equals('45m'));
      expect(Fmt.duration(60 * 60), equals('1h 00m'));
    });

    test('set labels', () {
      String label(int? w, int r,
              {ExerciseType t = ExerciseType.weighted,
              WeightUnit u = WeightUnit.kg}) =>
          Fmt.setLabel(weight: w, reps: r, type: t, unit: u);
      expect(label(6000, 10), equals('60 kg × 10'));
      expect(label(5750, 8), equals('57.5 kg × 8'));
      expect(label(null, 12, t: ExerciseType.bodyweight), equals('BW × 12'));
      expect(label(0, 12, t: ExerciseType.bodyweight), equals('BW × 12'));
      expect(label(1000, 8, t: ExerciseType.bodyweight), equals('BW + 10 kg × 8'));
      expect(label(6124, 5, u: WeightUnit.lb), equals('135 lb × 5'));
    });

    test('timed and sport sets show a duration', () {
      String label(int s, ExerciseType t) =>
          Fmt.setLabel(weight: null, reps: s, type: t, unit: WeightUnit.kg);
      expect(label(90, ExerciseType.timed), equals('1:30'));
      expect(label(5, ExerciseType.timed), equals('0:05'));
      expect(label(3725, ExerciseType.timed), equals('1:02:05'));
      expect(label(5400, ExerciseType.sport), equals('1h 30m'));
      expect(label(2700, ExerciseType.sport), equals('45m'));
    });

    test('distance follows the time, in the unit that goes with the weight unit', () {
      String label(int s, ExerciseType t, int? d, WeightUnit u) => Fmt.setLabel(
            weight: null,
            reps: s,
            type: t,
            unit: u,
            distance: d,
          );
      expect(label(1710, ExerciseType.timed, 5200, WeightUnit.kg), equals('28:30 · 5.2 km'));
      expect(label(1710, ExerciseType.timed, 5200, WeightUnit.lb), equals('28:30 · 3.23 mi'));
      expect(label(5400, ExerciseType.sport, 7500, WeightUnit.kg), equals('1h 30m · 7.5 km'));
      expect(label(1710, ExerciseType.timed, null, WeightUnit.kg), equals('28:30'));
    });

    test('clock time', () {
      expect(Fmt.clockTime(0), equals('0:00'));
      expect(Fmt.clockTime(59), equals('0:59'));
      expect(Fmt.clockTime(600), equals('10:00'));
      expect(Fmt.clockTime(3600), equals('1:00:00'));
    });

    test('plural', () {
      expect(Fmt.plural(1, 'week'), equals('1 week'));
      expect(Fmt.plural(0, 'week'), equals('0 weeks'));
      expect(Fmt.plural(11, 'exercise'), equals('11 exercises'));
    });
  });
}
