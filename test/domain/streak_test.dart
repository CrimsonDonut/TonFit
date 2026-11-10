import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/domain/epoch_day.dart';
import 'package:tonfit/domain/streak.dart';

// Monday 19 Oct 2026 starts the current week; "today" is Sat 24 Oct.
const thisWeek = 20745;
const today = 20750;

/// Builds weekCounts from counts listed oldest first, ending with this week.
Map<int, int> weeks(List<int> counts) => {
      for (var i = 0; i < counts.length; i++)
        thisWeek - 7 * (counts.length - 1 - i): counts[i],
    };

void main() {
  group('computeStreak (goal 4)', () {
    test('no data', () {
      expect(computeStreak(weekCounts: {}, goal: 4, today: today),
          equals(const StreakResult(0, 0)));
    });

    test('week in progress below goal does not break a streak', () {
      // 3 qualifying weeks, then 2 sessions so far this week.
      final r = computeStreak(weekCounts: weeks([4, 5, 4, 2]), goal: 4, today: today);
      expect(r, equals(const StreakResult(3, 3)));
    });

    test('current week qualifying extends the streak', () {
      final r = computeStreak(weekCounts: weeks([4, 5, 4, 4]), goal: 4, today: today);
      expect(r, equals(const StreakResult(4, 4)));
    });

    test('a missed completed week resets the current streak', () {
      final r = computeStreak(weekCounts: weeks([4, 4, 4, 1, 4, 4]), goal: 4, today: today);
      // longest run was 3 (before the miss); the run after it is 2 (one done
      // completed week + this week qualifying).
      expect(r, equals(const StreakResult(2, 3)));
    });

    test('empty weeks in between count as misses', () {
      final r = computeStreak(
        weekCounts: {thisWeek - 21: 5, thisWeek: 4},
        goal: 4,
        today: today,
      );
      expect(r, equals(const StreakResult(1, 1)));
    });

    test('longest survives a broken current streak', () {
      final r = computeStreak(weekCounts: weeks([4, 4, 4, 4, 0, 1]), goal: 4, today: today);
      expect(r, equals(const StreakResult(0, 4)));
    });

    test('only this week, qualifying', () {
      final r = computeStreak(weekCounts: weeks([4]), goal: 4, today: today);
      expect(r, equals(const StreakResult(1, 1)));
    });

    test('goal changes re-evaluate history', () {
      final w = weeks([3, 3, 3, 3]);
      expect(computeStreak(weekCounts: w, goal: 4, today: today),
          equals(const StreakResult(0, 0)));
      expect(computeStreak(weekCounts: w, goal: 3, today: today),
          equals(const StreakResult(4, 4)));
    });

    test('week start helper agrees with the constants', () {
      expect(EpochDay.weekStart(today), equals(thisWeek));
    });
  });
}
