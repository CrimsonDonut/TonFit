/// Heatmap tier (0 to 4) from a day's set count (requirements FR-23).
/// Thresholds are constants in one place so they are easy to adjust.
abstract final class Heatmap {
  /// Upper bounds (inclusive) of tiers 1, 2 and 3. Anything above is tier 4.
  static const List<int> tierMax = [6, 12, 18];

  static int tier(int setCount) {
    if (setCount <= 0) return 0;
    for (var i = 0; i < tierMax.length; i++) {
      if (setCount <= tierMax[i]) return i + 1;
    }
    return tierMax.length + 1;
  }
}
