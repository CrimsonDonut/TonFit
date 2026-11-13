import 'dart:math' as math;

import 'epoch_day.dart';

/// Heatmap rules (requirements FR-6, FR-23): which days to show, how big the
/// cells are, and which tier a day falls in. Pure functions, no Flutter.
abstract final class Heatmap {
  // --- tiers -----------------------------------------------------------------

  /// Upper bounds (inclusive) of tiers 1, 2 and 3. Anything above is tier 4.
  /// Thresholds are constants in one place so they are easy to adjust.
  static const List<int> tierMax = [6, 12, 18];

  /// Tier (0 to 4) from a day's set count.
  static int tier(int setCount) {
    if (setCount <= 0) return 0;
    for (var i = 0; i < tierMax.length; i++) {
      if (setCount <= tierMax[i]) return i + 1;
    }
    return tierMax.length + 1;
  }

  // --- which days ------------------------------------------------------------

  /// Epoch-day of 1 January. The heatmap always shows the whole year, January
  /// to December, so days logged in the past are never cut off.
  static int firstDay(int year) => EpochDay.fromDate(DateTime(year, 1, 1));

  /// Epoch-day of 31 December.
  static int lastDay(int year) => EpochDay.fromDate(DateTime(year, 12, 31));

  /// Number of week columns in the year (53 for the years around now).
  static int columns(int year) {
    final firstWeek = EpochDay.weekStart(firstDay(year));
    final lastWeek = EpochDay.weekStart(lastDay(year));
    return (lastWeek - firstWeek) ~/ 7 + 1;
  }

  // --- size ------------------------------------------------------------------

  /// Smallest and largest distance between neighbouring cells, in logical
  /// pixels. Cells never get smaller than [minPitch]: a long range scrolls
  /// sideways instead of shrinking until it is hard to see.
  static const double minPitch = 10;
  static const double maxPitch = 20;

  /// Distance between cell centres: as large as fits the [available] width,
  /// within [minPitch] and [maxPitch].
  static double cellPitch({required double available, required int columns}) =>
      math.min(maxPitch, math.max(minPitch, available / columns));

  /// Where to scroll a too-wide heatmap so [currentColumn] sits in the middle
  /// of the view. Zero when nothing needs scrolling or there is no current
  /// column (a past year).
  static double initialScrollOffset({
    required int? currentColumn,
    required double pitch,
    required double viewportWidth,
    required double contentWidth,
  }) {
    final maxOffset = math.max(0.0, contentWidth - viewportWidth);
    if (currentColumn == null || maxOffset == 0) return 0;
    final target = currentColumn * pitch + pitch / 2 - viewportWidth / 2;
    return math.min(math.max(target, 0.0), maxOffset);
  }
}
