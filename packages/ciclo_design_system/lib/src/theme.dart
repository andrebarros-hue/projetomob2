import "package:flutter/material.dart";

import "tokens.dart";

class CicloTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: CicloColors.accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: CicloColors.accent,
      onPrimary: CicloColors.surface,
      secondary: CicloColors.green,
      onSecondary: CicloColors.surface,
      surface: CicloColors.canvas,
      onSurface: CicloColors.ink,
      error: CicloColors.danger,
      onError: CicloColors.surface,
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(CicloRadius.md),
      borderSide: const BorderSide(color: CicloColors.line),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: "Outfit",
      colorScheme: scheme,
      scaffoldBackgroundColor: CicloColors.canvas,
      dividerColor: CicloColors.line,
      splashColor: CicloColors.softAccent,
      appBarTheme: const AppBarTheme(
        backgroundColor: CicloColors.canvas,
        foregroundColor: CicloColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: "Outfit",
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: CicloColors.ink,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: "Fraunces",
          fontSize: 36,
          height: 1.05,
          fontWeight: FontWeight.w600,
          color: CicloColors.ink,
          letterSpacing: -0.8,
        ),
        headlineSmall: TextStyle(
          fontFamily: "Fraunces",
          fontSize: 28,
          height: 1.12,
          fontWeight: FontWeight.w600,
          color: CicloColors.ink,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          fontFamily: "Outfit",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CicloColors.ink,
        ),
        titleMedium: TextStyle(
          fontFamily: "Outfit",
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: CicloColors.ink,
        ),
        bodyLarge: TextStyle(
          fontFamily: "Outfit",
          fontSize: 16,
          height: 1.45,
          color: CicloColors.ink,
        ),
        bodyMedium: TextStyle(
          fontFamily: "Outfit",
          fontSize: 14,
          height: 1.4,
          color: CicloColors.muted,
        ),
        labelLarge: TextStyle(
          fontFamily: "Outfit",
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: CicloColors.ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CicloColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: CicloColors.muted, fontFamily: "Outfit"),
        hintStyle: const TextStyle(color: CicloColors.muted, fontFamily: "Outfit"),
        prefixIconColor: CicloColors.muted,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: CicloColors.accent, width: 1.4),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: CicloColors.danger),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(color: CicloColors.danger, width: 1.4),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: CicloColors.ink,
        contentTextStyle: TextStyle(
          fontFamily: "Outfit",
          color: CicloColors.surface,
        ),
      ),
    );
  }
}
