import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/domain/epoch_day.dart';
import 'package:tonfit/domain/heatmap.dart';

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

  group('the whole year is always shown', () {
    test('from 1 January to 31 December', () {
      expect(Heatmap.firstDay(2026), equals(EpochDay.fromDate(DateTime(2026, 1, 1))));
      expect(Heatmap.lastDay(2026), equals(EpochDay.fromDate(DateTime(2026, 12, 31))));
    });

    test('a year is 53 week columns', () {
      for (final year in [2024, 2025, 2026, 2027]) {
        expect(Heatmap.columns(year), equals(53), reason: '$year');
      }
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

    test('in November 2026 the view opens on the current week, not January', () {
      final today = EpochDay.fromDate(DateTime(2026, 11, 9));
      final firstWeek = EpochDay.weekStart(Heatmap.firstDay(2026));
      final column = (today - firstWeek) ~/ 7;
      final offset = Heatmap.initialScrollOffset(
        currentColumn: column,
        pitch: 10,
        viewportWidth: 344,
        contentWidth: 530,
      );
      expect(column, equals(45));
      expect(offset, equals(186)); // scrolled to the right end, where November is
    });
  });
}
