import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/domain/distance.dart';
import 'package:tonfit/domain/weight.dart';

void main() {
  group('units', () {
    test('kilometres go with kilograms, miles with pounds', () {
      expect(Distance.unitFor(WeightUnit.kg), equals(DistanceUnit.km));
      expect(Distance.unitFor(WeightUnit.lb), equals(DistanceUnit.mi));
    });

    test('stored in whole metres', () {
      expect(Distance.toStored(5, DistanceUnit.km), equals(5000));
      expect(Distance.toStored(5.25, DistanceUnit.km), equals(5250));
      expect(Distance.toStored(3.1, DistanceUnit.mi), equals(4989));
      expect(Distance.toStored(1, DistanceUnit.mi), equals(1609));
    });

    test('converted back for display', () {
      expect(Distance.fromStored(5250, DistanceUnit.km), equals(5.25));
      expect(Distance.fromStored(4989, DistanceUnit.mi), closeTo(3.1, 0.001));
    });
  });

  group('text', () {
    test('numbers drop trailing zeros', () {
      expect(Distance.number(5000, DistanceUnit.km), equals('5'));
      expect(Distance.number(5250, DistanceUnit.km), equals('5.25'));
      expect(Distance.number(5300, DistanceUnit.km), equals('5.3'));
      expect(Distance.number(500, DistanceUnit.km), equals('0.5'));
      expect(Distance.number(0, DistanceUnit.km), equals('0'));
      expect(Distance.number(100000, DistanceUnit.km), equals('100'));
      expect(Distance.number(4989, DistanceUnit.mi), equals('3.1'));
    });

    test('with the unit', () {
      expect(Distance.format(5200, DistanceUnit.km), equals('5.2 km'));
      expect(Distance.format(5200, DistanceUnit.mi), equals('3.23 mi'));
    });
  });

  group('parse', () {
    test('accepts a dot or a comma', () {
      expect(Distance.parse('5.2'), equals(5.2));
      expect(Distance.parse('5,2'), equals(5.2));
      expect(Distance.parse('  7 '), equals(7));
    });

    test('rejects anything that is not a positive number', () {
      for (final bad in ['', 'abc', '0', '-1', '5..2', 'NaN', 'Infinity']) {
        expect(Distance.parse(bad), isNull, reason: bad);
      }
    });
  });

  group('pace', () {
    test('per kilometre', () {
      // 28:30 for 5 km = 5:42 per km
      expect(Distance.pace(seconds: 1710, meters: 5000, unit: DistanceUnit.km),
          equals('5:42 /km'));
      expect(Distance.pace(seconds: 300, meters: 1000, unit: DistanceUnit.km),
          equals('5:00 /km'));
    });

    test('per mile', () {
      expect(Distance.pace(seconds: 1710, meters: 5000, unit: DistanceUnit.mi),
          equals('9:10 /mi'));
    });

    test('nothing to show without both numbers', () {
      expect(Distance.pace(seconds: 0, meters: 5000, unit: DistanceUnit.km), isNull);
      expect(Distance.pace(seconds: 1710, meters: 0, unit: DistanceUnit.km), isNull);
    });
  });
}
