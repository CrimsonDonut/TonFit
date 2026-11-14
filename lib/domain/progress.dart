import 'exercise_type.dart';

/// One logged set. [weight] is stored hundredths of a kg; null for pure
/// bodyweight sets (for "BW + 10 kg" it holds the added weight).
class SetData {
  const SetData(this.weight, this.reps, {this.distance});
  final int? weight;
  final int reps;

  /// Metres, for timed and sport exercises that track distance.
  final int? distance;

  @override
  bool operator ==(Object other) =>
      other is SetData &&
      other.weight == weight &&
      other.reps == reps &&
      other.distance == distance;

  @override
  int get hashCode => Object.hash(weight, reps, distance);

  @override
  String toString() => 'SetData($weight x $reps, distance $distance)';
}

/// Per-exercise numbers derived from its sets (the cached columns on
/// exercise_log).
class ExerciseMetrics {
  const ExerciseMetrics({
    required this.volume,
    required this.setCount,
    required this.topWeight,
    required this.repsAtTop,
  });

  final int volume;
  final int setCount;

  /// Heaviest set weight (stored form); 0 when no set has a weight.
  final int topWeight;

  /// Most reps in a single set at [topWeight].
  final int repsAtTop;
}

abstract final class Progress {
  /// Reference body weight (70 kg) used to give bodyweight exercises a
  /// meaningful volume. A future setting can replace this constant.
  static const int defaultBodyweightRef = 7000;

  /// Numbers for one exercise from its sets.
  ///
  /// Weighted: volume is weight x reps. Bodyweight: each rep counts as the
  /// reference body weight plus any added weight. Timed and sport: each set's
  /// `reps` holds its duration in seconds, volume is the total time, and the
  /// "best set" is the longest single set. When [trackDistance] is on, the
  /// total distance in metres is the volume instead (a longer run is progress)
  /// and the best set is the farthest single set.
  static ExerciseMetrics metrics(
    List<SetData> sets, {
    ExerciseType type = ExerciseType.weighted,
    int bodyweightRef = defaultBodyweightRef,
    bool trackDistance = false,
  }) {
    if (type.isTimeBased) {
      var total = 0;
      var longest = 0;
      for (final s in sets) {
        final amount = trackDistance ? (s.distance ?? 0) : s.reps;
        total += amount;
        if (amount > longest) longest = amount;
      }
      return ExerciseMetrics(
        volume: total,
        setCount: sets.length,
        topWeight: 0,
        repsAtTop: longest,
      );
    }

    final bodyweight = type == ExerciseType.bodyweight;
    var volume = 0;
    var top = 0;
    for (final s in sets) {
      final w = s.weight ?? 0;
      volume += (bodyweight ? bodyweightRef + w : w) * s.reps;
      if (w > top) top = w;
    }
    var repsAtTop = 0;
    for (final s in sets) {
      if ((s.weight ?? 0) == top && s.reps > repsAtTop) repsAtTop = s.reps;
    }
    return ExerciseMetrics(
      volume: volume,
      setCount: sets.length,
      topWeight: top,
      repsAtTop: repsAtTop,
    );
  }

  /// Change versus the previous volume, in tenths of a percent
  /// (+3.8% = 38). Null means "New" (no usable previous value).
  static int? pctTenths(int now, int? previous) {
    if (previous == null || previous <= 0) return null;
    return ((now - previous) * 1000 / previous).round();
  }

  /// Session % compares only exercises present in both sessions, so skipped or
  /// newly added exercises don't distort it. Maps are exerciseId -> volume.
  static int? sessionPctTenths(Map<int, int> now, Map<int, int> previous) {
    var sumNow = 0;
    var sumPrev = 0;
    var common = 0;
    for (final e in now.entries) {
      final p = previous[e.key];
      if (p == null) continue;
      sumNow += e.value;
      sumPrev += p;
      common++;
    }
    if (common == 0) return null;
    return pctTenths(sumNow, sumPrev);
  }

  /// Session % when a session mixes strength and timed work. Volume (kg x
  /// reps) and seconds can't be added together, so each kind is compared on its
  /// own, over the exercises present in both sessions, and the session % is the
  /// average of the kinds that have a comparison. A strength-only session gives
  /// exactly [sessionPctTenths]. Sport is left out: it has no comparison.
  static int? sessionPctByKind({
    required Map<int, int> nowStrength,
    required Map<int, int> previousStrength,
    required Map<int, int> nowTimed,
    required Map<int, int> previousTimed,
  }) {
    final parts = [
      sessionPctTenths(nowStrength, previousStrength),
      sessionPctTenths(nowTimed, previousTimed),
    ].whereType<int>().toList();
    if (parts.isEmpty) return null;
    return (parts.fold<int>(0, (a, b) => a + b) / parts.length).round();
  }

  /// "+3.8%", "-2.1%", "0.0%", or "New". The sign is always shown so color is
  /// never the only signal.
  static String format(int? tenths) {
    if (tenths == null) return 'New';
    final sign = tenths > 0 ? '+' : (tenths < 0 ? '-' : '');
    final abs = tenths.abs();
    return '$sign${abs ~/ 10}.${abs % 10}%';
  }
}
