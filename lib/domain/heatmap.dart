import 'dart:math' as math;

import 'epoch_day.dart';

/// Heatmap rules (requirements FR-6, FR-23): which months to show, how big the
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

  // --- which months ----------------------------------------------------------

  /// First month (1 to 12) to draw for [year], so a new user is not shown a
  /// mostly empty year: the heatmap starts in the first month with any data,
  /// or in the current month when there is none yet, and runs to December.
  ///
  /// [firstDataDay] is the earliest day with a session or rest mark across all
  /// years (null when there is no data). Years after the first one always start
  /// in January.
  static int startMonth({
    required int year,
    required int? firstDataDay,
    required int today,
  }) {
    final now = EpochDay.toDate(today);
    if (firstDataDay == null) return year == now.year ? now.month : 1;

    final first = EpochDay.toDate(firstDataDay);
    if (year != first.year) return 1;

    // The first year with data. If it is also the current year, never start
    // later than the current month.
    return year == now.year ? math.min(first.month, now.month) : first.month;
  }

  /// Epoch-day of the first day drawn.
  static int firstDay(int year, int startMonth) =>
      EpochDay.fromDate(DateTime(year, startMonth, 1));

  /// Epoch-day of the last day drawn (31 December).
  static int lastDay(int year) => EpochDay.fromDate(DateTime(year, 12, 31));

  /// Number of week columns from [startMonth] to the end of the year.
  static int columns(int year, int startMonth) {
    final firstWeek = EpochDay.weekStart(firstDay(year, startMonth));
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
