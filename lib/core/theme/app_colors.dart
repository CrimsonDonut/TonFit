import 'package:flutter/material.dart';

/// Single source of truth for TonFit colors (requirements, section 7).
/// Dark theme only for the MVP.
abstract final class AppColors {
  // Neutrals
  static const canvas = Color(0xFF121212);
  static const surface = Color(0xFF181818);
  static const pressed = Color(0xFF202020);
  static const hairline = Color(0xFF242424);

  // Text
  static const textPrimary = Color(0xFFEDEDED);
  static const textStrong = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFFA0A0A0);

  // Accent: streak, links, heatmap peak, focus
  static const accent = Color(0xFFF52746);

  // Filled buttons (white text on this fill is 5.0:1)
  static const buttonFill = Color(0xFFD91E3A);

  // Progress change
  static const positive = Color(0xFF4ADE80);
  static const positiveTint = Color(0xFF12261A);
  static const negative = Color(0xFFFF6B6B);
  static const zero = Color(0xFFA0A0A0);

  /// Heatmap tiers, from no session (index 0) to heaviest (index 4).
  static const heatmap = <Color>[
    Color(0xFF1C1C1C),
    Color(0xFF4A0E18),
    Color(0xFF871427),
    Color(0xFFC01E37),
    Color(0xFFF52746),
  ];

  /// Color for a progress percentage stored as integer tenths of a percent
  /// (e.g. 38 = +3.8%). Anything that displays as 0.0% is neutral.
  static Color change(int tenths) {
    if (tenths > 0) return positive;
    if (tenths < 0) return negative;
    return zero;
  }
}
