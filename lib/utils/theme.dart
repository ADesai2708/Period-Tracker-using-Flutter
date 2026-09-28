import 'package:flutter/material.dart';

/// Central place for the app's color palette and theme so screens
/// don't hardcode colors individually.
class AppColors {
  static const primary = Color(0xFFE85D75); // rose
  static const primaryLight = Color(0xFFFCE4EC);
  static const fertile = Color(0xFF9C89E8); // lavender
  static const fertileLight = Color(0xFFEDE7F6);
  static const predicted = Color(0xFFF8BBD0);
  static const background = Color(0xFFFFF9FA);
  static const surface = Colors.white;
  static const textDark = Color(0xFF3A2E33);
  static const textMuted = Color(0xFF8C7B82);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      centerTitle: true,
    ),
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
          fontWeight: FontWeight.bold, color: AppColors.textDark),
      titleLarge:
          TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
      bodyMedium: TextStyle(color: AppColors.textDark),
      bodySmall: TextStyle(color: AppColors.textMuted),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
