import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
    brightness: Brightness.light,
    colors: AppColors.light,
    background: const Color(0xFFFFFFFF),
    onBackground: const Color(0xFF1B1B1B),
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    colors: AppColors.dark,
    background: const Color(0xFF15120F),
    onBackground: const Color(0xFFF3EDE6),
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppColors colors,
    required Color background,
    required Color onBackground,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.teal,
      brightness: brightness,
      primary: colors.teal,
      onPrimary: colors.tealContrast,
      secondaryContainer: colors.tealSoft,
      onSecondaryContainer: onBackground,
      errorContainer: colors.coralSoft,
      onErrorContainer: colors.coral,
      surface: colors.cardSurface,
      onSurface: onBackground,
    );

    final borderRadius = BorderRadius.circular(12);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(
        color: colors.line,
        space: 20,
        thickness: 1.2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        suffixStyle: TextStyle(color: colors.muted, fontSize: 12.5),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.teal, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.coral),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: colors.coral, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.teal,
          foregroundColor: colors.tealContrast,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
