import 'package:flutter_test/flutter_test.dart';
import 'package:tonfit/domain/weight.dart';

void main() {
  group('Weight', () {
    test('kg is stored in hundredths', () {
      expect(Weight.toStored(60, WeightUnit.kg), equals(6000));
      expect(Weight.toStored(57.5, WeightUnit.kg), equals(5750));
    });

    test('format drops a trailing .0', () {
      expect(Weight.format(6000, WeightUnit.kg), equals('60'));
      expect(Weight.format(5750, WeightUnit.kg), equals('57.5'));
    });

    test('lb entries survive a round trip', () {
      for (final lb in [45.0, 100.0, 135.0, 102.5, 225.0, 315.0]) {
        final stored = Weight.toStored(lb, WeightUnit.lb);
        final shown = Weight.format(stored, WeightUnit.lb);
        expect(double.parse(shown), equals(lb));
      }
    });

    test('stepper increments', () {
      expect(Weight.step(WeightUnit.kg), equals(2.5));
      expect(Weight.step(WeightUnit.lb), equals(5.0));
    });
  });
}
