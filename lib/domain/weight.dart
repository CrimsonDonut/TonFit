enum WeightUnit { kg, lb }

/// Weights are stored as integer hundredths of a kilogram (60 kg = 6000).
/// Units only matter for entry and display.
abstract final class Weight {
  static const double _lbPerKg = 2.2046226218;

  /// Convert a value typed in [unit] to the stored form.
  static int toStored(double value, WeightUnit unit) {
    final kg = unit == WeightUnit.kg ? value : value / _lbPerKg;
    return (kg * 100).round();
  }

  static double fromStored(int stored, WeightUnit unit) {
    final kg = stored / 100;
    return unit == WeightUnit.kg ? kg : kg * _lbPerKg;
  }

  /// Display text: kg to the nearest 0.1, lb to the nearest 0.5, and no
  /// trailing ".0" ("60", "57.5").
  static String format(int stored, WeightUnit unit) {
    final v = fromStored(stored, unit);
    final rounded =
        unit == WeightUnit.kg ? (v * 10).round() / 10 : (v * 2).round() / 2;
    return rounded == rounded.roundToDouble()
        ? rounded.round().toString()
        : rounded.toString();
  }

  /// Default stepper increment (requirements FR-10).
  static double step(WeightUnit unit) => unit == WeightUnit.kg ? 2.5 : 5;
}
