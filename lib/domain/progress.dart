/// One logged set. [weight] is stored hundredths of a kg; null for pure
/// bodyweight sets (for "BW + 10 kg" it holds the added weight).
class SetData {
  const SetData(this.weight, this.reps);
  final int? weight;
  final int reps;

  @override
  bool operator ==(Object other) =>
      other is SetData && other.weight == weight && other.reps == reps;

  @override
  int get hashCode => Object.hash(weight, reps);

  @override
  String toString() => 'SetData($weight x $reps)';
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

  static ExerciseMetrics metrics(
    List<SetData> sets, {
    bool bodyweight = false,
    int bodyweightRef = defaultBodyweightRef,
  }) {
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

  /// "+3.8%", "-2.1%", "0.0%", or "New". The sign is always shown so color is
  /// never the only signal.
  static String format(int? tenths) {
    if (tenths == null) return 'New';
    final sign = tenths > 0 ? '+' : (tenths < 0 ? '-' : '');
    final abs = tenths.abs();
    return '$sign${abs ~/ 10}.${abs % 10}%';
  }
}
