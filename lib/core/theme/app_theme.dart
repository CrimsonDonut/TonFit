import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Layout constants (requirements, section 7): 8 px grid, 16 px margins.
abstract final class AppSpacing {
  static const double grid = 8;
  static const double margin = 16;
  static const double minTouchTarget = 48;
}

/// Corner radii: data rows stay sharp; inputs and cards 8; buttons and sheets 12-16.
abstract final class AppRadius {
  static const double input = 8;
  static const double button = 12;
  static const double sheet = 16;
}

abstract final class AppTheme {
  static const String fontFamily = 'Inter';

  // Tabular figures on every style so weights, reps and percentages align.
  static const _tabular = [FontFeature.tabularFigures()];

  static TextStyle _style(
    double size,
    FontWeight weight,
    Color color, {
    double? letterSpacing,
    double? height,
  }) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontFeatures: _tabular,
      );

  static final TextTheme _textTheme = TextTheme(
    // Month title, e.g. "October 2026"
    headlineLarge: _style(28, FontWeight.w600, AppColors.textStrong,
        letterSpacing: -0.5, height: 1.15),
    // Exercise names, day headers
    titleMedium: _style(16, FontWeight.w600, AppColors.textStrong),
    // Body and set lines
    bodyLarge: _style(16, FontWeight.w400, AppColors.textPrimary, height: 1.4),
    bodyMedium:
        _style(14, FontWeight.w400, AppColors.textPrimary, height: 1.4),
    bodySmall: _style(12, FontWeight.w400, AppColors.textMuted, height: 1.4),
    // Buttons
    labelLarge: _style(16, FontWeight.w600, AppColors.textStrong),
    // Small uppercase labels: apply .toUpperCase() at the call site.
    labelSmall: _style(11, FontWeight.w500, AppColors.textMuted,
        letterSpacing: 1.2),
  );

  static final ColorScheme _colorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.accent,
    onPrimary: AppColors.textStrong,
    secondary: AppColors.accent,
    onSecondary: AppColors.textStrong,
    error: AppColors.negative,
    onError: Color(0xFF121212),
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
  );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: fontFamily,
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: AppColors.canvas,
        canvasColor: AppColors.canvas,
        textTheme: _textTheme,
        dividerTheme: const DividerThemeData(
          color: AppColors.hairline,
          thickness: 1,
          space: 1,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.canvas,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.buttonFill,
            foregroundColor: AppColors.textStrong,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            textStyle: _textTheme.labelLarge,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            minimumSize: const Size(
              AppSpacing.minTouchTarget,
              AppSpacing.minTouchTarget,
            ),
            textStyle: _textTheme.bodyMedium,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          modalBackgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.sheet),
            ),
          ),
        ),
      );
}
