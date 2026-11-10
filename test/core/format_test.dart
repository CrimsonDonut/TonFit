import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/core/format.dart';
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
      String label(int? w, int r, {bool bw = false, WeightUnit u = WeightUnit.kg}) =>
          Fmt.setLabel(weight: w, reps: r, bodyweight: bw, unit: u);
      expect(label(6000, 10), equals('60 kg × 10'));
      expect(label(5750, 8), equals('57.5 kg × 8'));
      expect(label(null, 12, bw: true), equals('BW × 12'));
      expect(label(0, 12, bw: true), equals('BW × 12'));
      expect(label(1000, 8, bw: true), equals('BW + 10 kg × 8'));
      expect(label(6124, 5, u: WeightUnit.lb), equals('135 lb × 5'));
    });

    test('plural', () {
      expect(Fmt.plural(1, 'week'), equals('1 week'));
      expect(Fmt.plural(0, 'week'), equals('0 weeks'));
      expect(Fmt.plural(11, 'exercise'), equals('11 exercises'));
    });
  });
}
