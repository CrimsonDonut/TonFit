import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/dev/stats.dart';

void main() {
  group('percentile (nearest rank)', () {
    final hundred = [for (var i = 1; i <= 100; i++) i.toDouble()];

    test('p50 and p95 of 1..100', () {
      expect(percentile(hundred, 50), equals(50));
      expect(percentile(hundred, 95), equals(95));
      expect(percentile(hundred, 100), equals(100));
    });

    test('order of the input does not matter', () {
      expect(percentile([5, 1, 4, 2, 3], 50), equals(3));
      expect(percentile([30, 10, 20], 95), equals(30));
    });

    test('one sample, and none', () {
      expect(percentile([7], 95), equals(7));
      expect(percentile([], 95), equals(0));
    });
  });

  group('BenchResult', () {
    test('passes on p95, so one outlier does not fail it', () {
      final samples = [for (var i = 0; i < 99; i++) 10.0, 500.0];
      final r = BenchResult('x', 100, samples);
      expect(r.p95, equals(10));
      expect(r.worst, equals(500));
      expect(r.passes, isTrue);
    });

    test('fails when it is consistently slow', () {
      final r = BenchResult('x', 100, [for (var i = 0; i < 20; i++) 150.0]);
      expect(r.passes, isFalse);
    });

    test('no samples is not a pass', () {
      expect(const BenchResult('x', 100, []).passes, isFalse);
    });

    test('the report line says what happened', () {
      final line = BenchResult('Save a set', 50, [4.0, 6.0, 12.0, 9.0]).line;
      expect(line, contains('PASS'));
      expect(line, contains('Save a set'));
      expect(line, contains('target 50 ms'));
      expect(line, contains('4 runs'));
    });
  });

  group('formatReport', () {
    test('lists every result, the database size and a verdict', () {
      final text = formatReport(
        [
          const BenchResult('Fast', 100, [5, 6, 7]),
          const BenchResult('Slow', 50, [80, 90, 95]),
        ],
        dbSizeBytes: 9 * 1048576,
        header: 'Benchmark',
      );
      expect(text, contains('Benchmark'));
      expect(text, contains('PASS  Fast'));
      expect(text, contains('FAIL  Slow'));
      expect(text, contains('PASS  Database size'));
      expect(text, contains('9.0 MB'));
      expect(text, contains('1 timed check(s) over target'));
    });

    test('a database over the limit fails', () {
      final text = formatReport([], dbSizeBytes: 20 * 1048576);
      expect(text, contains('FAIL  Database size'));
    });

    test('everything within target', () {
      final text = formatReport([const BenchResult('A', 10, [1, 2, 3])]);
      expect(text, contains('All timed checks are within target.'));
    });
  });
}
