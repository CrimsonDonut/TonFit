import 'dart:math' as math;

/// Nearest-rank percentile: the smallest sample that is at least [p] percent of
/// the way through the sorted list. Zero for an empty list.
double percentile(List<double> samples, double p) {
  if (samples.isEmpty) return 0;
  final sorted = [...samples]..sort();
  final rank = (p / 100 * sorted.length).ceil();
  return sorted[math.max(1, math.min(sorted.length, rank)) - 1];
}

/// Timings for one operation, in milliseconds, against its target.
class BenchResult {
  const BenchResult(this.name, this.targetMs, this.samplesMs);

  final String name;
  final double targetMs;
  final List<double> samplesMs;

  double get p50 => percentile(samplesMs, 50);
  double get p95 => percentile(samplesMs, 95);
  double get worst => samplesMs.isEmpty ? 0 : samplesMs.reduce(math.max);

  /// The target is judged on the 95th percentile, so one slow outlier does not
  /// fail it but a consistently slow operation does.
  bool get passes => samplesMs.isNotEmpty && p95 <= targetMs;

  static String _ms(double v) => v < 10 ? v.toStringAsFixed(1) : v.round().toString();

  String get line => '${passes ? 'PASS' : 'FAIL'}  $name\n'
      '      p50 ${_ms(p50)} ms   p95 ${_ms(p95)} ms   worst ${_ms(worst)} ms   '
      '(target ${targetMs.round()} ms, ${samplesMs.length} runs)';
}

/// A plain-text report to read on the phone and paste into a message.
String formatReport(
  List<BenchResult> results, {
  int? dbSizeBytes,
  double dbTargetMb = 15,
  String? header,
}) {
  final out = StringBuffer();
  if (header != null) out.writeln('$header\n');
  for (final r in results) {
    out.writeln(r.line);
  }
  if (dbSizeBytes != null) {
    final mb = dbSizeBytes / 1048576;
    final pass = mb <= dbTargetMb;
    out.writeln('${pass ? 'PASS' : 'FAIL'}  Database size\n'
        '      ${mb.toStringAsFixed(1)} MB   (target under ${dbTargetMb.round()} MB)');
  }
  final failed = results.where((r) => !r.passes).length;
  out.writeln(failed == 0
      ? '\nAll timed checks are within target.'
      : '\n$failed timed check(s) over target.');
  return out.toString();
}
