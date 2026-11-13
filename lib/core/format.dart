import '../domain/exercise_type.dart';
import '../domain/weight.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Display formatting. Pure functions, no Flutter imports.
abstract final class Fmt {
  /// [weekday] follows DateTime: 1 = Monday ... 7 = Sunday.
  static String weekday(int weekday) => _weekdays[weekday - 1];
  static String month(int month) => _months[month - 1];

  static String monthYear(DateTime d) => '${month(d.month)} ${d.year}';

  /// "Sat 24"
  static String dayLabel(DateTime d) => '${weekday(d.weekday)} ${d.day}';

  /// "6:02 PM" from epoch seconds, in local time.
  static String clock(int epochSeconds) {
    final t = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  /// "1h 06m" or "45m".
  static String duration(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '${minutes}m';
    return '${minutes ~/ 60}h ${(minutes % 60).toString().padLeft(2, '0')}m';
  }

  static String weightText(int stored, WeightUnit unit) =>
      '${Weight.format(stored, unit)} ${unit.name}';

  /// A timer reading: "1:30", or "1:02:05" past an hour.
  static String clockTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$s';
    return '$m:$s';
  }

  /// One set as text. Weighted: "60 kg × 10". Bodyweight: "BW × 12" or
  /// "BW + 10 kg × 8". Timed: "1:30". Sport: "1h 30m". For timed and sport,
  /// [reps] holds the duration in seconds.
  static String setLabel({
    required int? weight,
    required int reps,
    required ExerciseType type,
    required WeightUnit unit,
  }) {
    switch (type) {
      case ExerciseType.sport:
        return duration(reps);
      case ExerciseType.timed:
        return clockTime(reps);
      case ExerciseType.bodyweight:
        if (weight == null || weight == 0) return 'BW × $reps';
        return 'BW + ${weightText(weight, unit)} × $reps';
      case ExerciseType.weighted:
        return '${weightText(weight ?? 0, unit)} × $reps';
    }
  }

  static String plural(int n, String word) => n == 1 ? '$n $word' : '$n ${word}s';
}
