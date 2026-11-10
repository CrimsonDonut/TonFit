import 'epoch_day.dart';

class StreakResult {
  const StreakResult(this.current, this.longest);
  final int current;
  final int longest;

  @override
  bool operator ==(Object other) =>
      other is StreakResult && other.current == current && other.longest == longest;

  @override
  int get hashCode => Object.hash(current, longest);

  @override
  String toString() => 'StreakResult(current: $current, longest: $longest)';
}

/// Weekly-goal streak (requirements FR-24 to FR-26).
///
/// [weekCounts] maps a week's Monday (epoch-day) to its session count. A week
/// qualifies when its count is at least [goal]. The week in progress never
/// breaks the streak: it only adds to it once it qualifies.
StreakResult computeStreak({
  required Map<int, int> weekCounts,
  required int goal,
  required int today,
}) {
  if (weekCounts.isEmpty) return const StreakResult(0, 0);

  bool qualifies(int week) => (weekCounts[week] ?? 0) >= goal;

  final thisWeek = EpochDay.weekStart(today);
  var first = weekCounts.keys.reduce((a, b) => a < b ? a : b);
  first = EpochDay.weekStart(first);

  var run = 0;
  var longest = 0;
  for (var w = first; w < thisWeek; w += 7) {
    run = qualifies(w) ? run + 1 : 0;
    if (run > longest) longest = run;
  }

  // `run` is now the streak ending at the latest completed week.
  final current = qualifies(thisWeek) ? run + 1 : run;
  if (current > longest) longest = current;
  return StreakResult(current, longest);
}
