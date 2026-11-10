import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/domain/epoch_day.dart';

void main() {
  group('EpochDay', () {
    test('day 0 is 1970-01-01, a Thursday', () {
      expect(EpochDay.fromDate(DateTime(1970, 1, 1)), equals(0));
      expect(EpochDay.weekdayOf(0), equals(4));
    });

    test('known dates', () {
      expect(EpochDay.fromDate(DateTime(2026, 10, 24)), equals(20750));
      expect(EpochDay.fromDate(DateTime(2024, 2, 29)), equals(19782));
    });

    test('time of day is ignored', () {
      expect(EpochDay.fromDate(DateTime(2026, 10, 24, 23, 59, 59)), equals(20750));
      expect(EpochDay.fromDate(DateTime(2026, 10, 24, 0, 0, 1)), equals(20750));
    });

    test('toDate round-trips', () {
      final d = EpochDay.toDate(20750);
      expect([d.year, d.month, d.day], equals([2026, 10, 24]));
      expect(EpochDay.fromDate(d), equals(20750));
    });

    test('weekday: Sat 24 Oct 2026 is 6, Sun is 7', () {
      expect(EpochDay.weekdayOf(20750), equals(6));
      expect(EpochDay.weekdayOf(20751), equals(7));
    });

    test('week starts on Monday', () {
      // Mon 19 Oct .. Sun 25 Oct 2026 all map to 20745.
      for (var d = 20745; d <= 20751; d++) {
        expect(EpochDay.weekStart(d), equals(20745));
      }
      expect(EpochDay.weekStart(20752), equals(20752)); // next Monday
    });

    test('next midnight rolls over month and year ends', () {
      expect(EpochDay.nextMidnight(DateTime(2026, 10, 31, 23, 59)),
          equals(DateTime(2026, 11, 1)));
      expect(EpochDay.nextMidnight(DateTime(2026, 12, 31, 12)),
          equals(DateTime(2027, 1, 1)));
    });
  });
}
