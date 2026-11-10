import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/domain/progress.dart';

void main() {
  group('metrics', () {
    test('weighted volume is sum of weight x reps', () {
      final m = Progress.metrics(const [
        SetData(6000, 10),
        SetData(6000, 8),
        SetData(5750, 8),
      ]);
      expect(m.volume, equals(60000 + 48000 + 46000));
      expect(m.setCount, equals(3));
      expect(m.topWeight, equals(6000));
      expect(m.repsAtTop, equals(10));
    });

    test('bodyweight volume uses the reference body weight', () {
      final m = Progress.metrics(
        const [SetData(null, 10), SetData(null, 8)],
        bodyweight: true,
      );
      expect(m.volume, equals(7000 * 18));
      expect(m.topWeight, equals(0));
      expect(m.repsAtTop, equals(10));
    });

    test('added weight raises bodyweight volume smoothly', () {
      final plain = Progress.metrics(const [SetData(null, 8)], bodyweight: true);
      final added = Progress.metrics(const [SetData(1000, 8)], bodyweight: true);
      final pct = Progress.pctTenths(added.volume, plain.volume);
      expect(pct, equals(143)); // +14.3%, not thousands of percent
    });

    test('no sets gives zeros', () {
      final m = Progress.metrics(const []);
      expect(m.volume, equals(0));
      expect(m.topWeight, equals(0));
      expect(m.repsAtTop, equals(0));
    });
  });

  group('pctTenths', () {
    test('gain, loss, flat', () {
      expect(Progress.pctTenths(1038, 1000), equals(38));
      expect(Progress.pctTenths(979, 1000), equals(-21));
      expect(Progress.pctTenths(1000, 1000), equals(0));
    });

    test('rounds to the nearest tenth', () {
      expect(Progress.pctTenths(154000, 147000), equals(48)); // 4.76%
    });

    test('New when there is no usable previous value', () {
      expect(Progress.pctTenths(1000, null), isNull);
      expect(Progress.pctTenths(1000, 0), isNull);
    });
  });

  group('sessionPctTenths', () {
    test('counts only exercises present in both sessions', () {
      final now = {1: 1100, 2: 500, 3: 99999}; // 3 is new this time
      final prev = {1: 1000, 2: 500, 4: 99999}; // 4 was skipped
      // (1100 + 500) vs (1000 + 500) = +6.7%
      expect(Progress.sessionPctTenths(now, prev), equals(67));
    });

    test('New when nothing is shared', () {
      expect(Progress.sessionPctTenths({1: 10}, {2: 10}), isNull);
      expect(Progress.sessionPctTenths({1: 10}, {}), isNull);
    });
  });

  group('format', () {
    test('always signed with one decimal', () {
      expect(Progress.format(38), equals('+3.8%'));
      expect(Progress.format(-21), equals('-2.1%'));
      expect(Progress.format(0), equals('0.0%'));
      expect(Progress.format(5), equals('+0.5%'));
      expect(Progress.format(-5), equals('-0.5%'));
      expect(Progress.format(1234), equals('+123.4%'));
      expect(Progress.format(null), equals('New'));
    });
  });
}
