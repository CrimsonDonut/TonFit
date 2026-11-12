import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/domain/epoch_day.dart';
import 'package:tonfit/domain/heatmap.dart';

int day(int y, int m, int d) => EpochDay.fromDate(DateTime(y, m, d));

// "Today" for these tests: Mon 9 Nov 2026.
final today = day(2026, 11, 9);

void main() {
  test('tiers by set count', () {
    expect(Heatmap.tier(0), equals(0));
    expect(Heatmap.tier(1), equals(1));
    expect(Heatmap.tier(6), equals(1));
    expect(Heatmap.tier(7), equals(2));
    expect(Heatmap.tier(12), equals(2));
    expect(Heatmap.tier(13), equals(3));
    expect(Heatmap.tier(18), equals(3));
    expect(Heatmap.tier(19), equals(4));
    expect(Heatmap.tier(60), equals(4));
  });

  group('startMonth', () {
    test('a brand-new user starts at the current month', () {
      expect(
        Heatmap.startMonth(year: 2026, firstDataDay: null, today: today),
        equals(11),
      );
    });

    test('the first logged month is where it starts', () {
      expect(
        Heatmap.startMonth(
            year: 2026, firstDataDay: day(2026, 11, 9), today: today),
        equals(11),
      );
      expect(
        Heatmap.startMonth(
            year: 2026, firstDataDay: day(2026, 3, 14), today: today),
        equals(3),
      );
    });

    test('starting in January shows the whole year', () {
      expect(
        Heatmap.startMonth(
            year: 2026, firstDataDay: day(2026, 1, 2), today: today),
        equals(1),
      );
    });

    test('later years start in January', () {
      expect(
        Heatmap.startMonth(
            year: 2026, firstDataDay: day(2025, 11, 20), today: today),
        equals(1),
      );
    });

    test('the first year, when it is a past year, starts at its first month', () {
      expect(
        Heatmap.startMonth(
            year: 2025, firstDataDay: day(2025, 11, 20), today: today),
        equals(11),
      );
    });

    test('data dated after today never pushes the start past the current month', () {
      expect(
        Heatmap.startMonth(
            year: 2026, firstDataDay: day(2026, 12, 20), today: today),
        equals(11),
      );
    });

    test('no data and a year that is not the current one starts in January', () {
      expect(
        Heatmap.startMonth(year: 2025, firstDataDay: null, today: today),
        equals(1),
      );
    });
  });

  group('columns', () {
    test('a full year is 53 week columns in 2026', () {
      expect(Heatmap.columns(2026, 1), equals(53));
    });

    test('November onward is 10 columns, December alone is 5', () {
      expect(Heatmap.columns(2026, 11), equals(10));
      expect(Heatmap.columns(2026, 12), equals(5));
    });

    test('March onward is 45', () {
      expect(Heatmap.columns(2026, 3), equals(45));
    });
  });

  group('cellPitch', () {
    test('a short range grows to the maximum, not the whole width', () {
      expect(Heatmap.cellPitch(available: 344, columns: 10), equals(20));
    });

    test('a medium range fills the width', () {
      expect(Heatmap.cellPitch(available: 344, columns: 20), closeTo(17.2, 0.001));
    });

    test('a full year stops at the minimum instead of shrinking', () {
      expect(Heatmap.cellPitch(available: 344, columns: 53), equals(10));
    });
  });

  group('initialScrollOffset', () {
    test('nothing to scroll when it fits', () {
      expect(
        Heatmap.initialScrollOffset(
            currentColumn: 3, pitch: 20, viewportWidth: 344, contentWidth: 200),
        equals(0),
      );
    });

    test('a past year starts at the left', () {
      expect(
        Heatmap.initialScrollOffset(
            currentColumn: null, pitch: 10, viewportWidth: 344, contentWidth: 530),
        equals(0),
      );
    });

    test('centres the current week, within the scrollable range', () {
      // column 25: 25*10 + 5 - 172 = 83
      expect(
        Heatmap.initialScrollOffset(
            currentColumn: 25, pitch: 10, viewportWidth: 344, contentWidth: 530),
        equals(83),
      );
      // near the end: clamped to contentWidth - viewportWidth = 186
      expect(
        Heatmap.initialScrollOffset(
            currentColumn: 50, pitch: 10, viewportWidth: 344, contentWidth: 530),
        equals(186),
      );
      // near the start: clamped to 0
      expect(
        Heatmap.initialScrollOffset(
            currentColumn: 3, pitch: 10, viewportWidth: 344, contentWidth: 530),
        equals(0),
      );
    });
  });
}
