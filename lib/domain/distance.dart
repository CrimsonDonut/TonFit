import 'weight.dart';

enum DistanceUnit { km, mi }

/// Distances are stored as whole metres. The display unit follows the weight
/// unit: kilograms go with kilometres, pounds with miles.
abstract final class Distance {
  static const double metersPerMile = 1609.344;

  static DistanceUnit unitFor(WeightUnit weightUnit) =>
      weightUnit == WeightUnit.kg ? DistanceUnit.km : DistanceUnit.mi;

  static int toStored(double value, DistanceUnit unit) =>
      (unit == DistanceUnit.km ? value * 1000 : value * metersPerMile).round();

  static double fromStored(int meters, DistanceUnit unit) =>
      unit == DistanceUnit.km ? meters / 1000 : meters / metersPerMile;

  /// The stepper increment in the display unit.
  static double step(DistanceUnit unit) => 0.5;

  /// The number only, to two decimals with trailing zeros trimmed:
  /// 5000 m -> "5", 5250 m -> "5.25", 5300 m -> "5.3".
  static String number(int meters, DistanceUnit unit) =>
      trimmed(fromStored(meters, unit));

  /// "5.25 km" or "3.1 mi".
  static String format(int meters, DistanceUnit unit) =>
      '${number(meters, unit)} ${unit.name}';

  /// A decimal to two places without trailing zeros.
  static String trimmed(double value) {
    var s = value.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      s = s.replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }

  /// Reads what a person typed ("5.2" or "5,2"). Null when it isn't a
  /// positive number.
  static double? parse(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    if (value == null || value.isNaN || value.isInfinite || value <= 0) {
      return null;
    }
    return value;
  }

  /// Time per kilometre or mile, like "5:41 /km". Null when either number is
  /// missing or zero.
  static String? pace({
    required int seconds,
    required int meters,
    required DistanceUnit unit,
  }) {
    if (seconds <= 0 || meters <= 0) return null;
    final perUnit = (seconds / fromStored(meters, unit)).round();
    final s = (perUnit % 60).toString().padLeft(2, '0');
    return '${perUnit ~/ 60}:$s /${unit.name}';
  }
}
