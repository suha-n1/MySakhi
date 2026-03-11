import 'package:flutter/material.dart';

class AppColors {
  static const Color rose = Color(0xFFE8637A);
  static const Color roseDark = Color(0xFFC0485F);
  static const Color roseLight = Color(0xFFF5B8C4);
  static const Color rosePale = Color(0xFFFDEEF1);
  static const Color cream = Color(0xFFFDF6F7);
  static const Color dark = Color(0xFF2D1F23);
  static const Color muted = Color(0xFF8A6D72);
  static const Color border = Color(0xFFF0DDE0);
  static const Color success = Color(0xFF4CAF8A);
}

ThemeData appTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.rose,
      primary: AppColors.rose,
      secondary: AppColors.roseLight,
    ),
    scaffoldBackgroundColor: AppColors.cream,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.rose,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.rose, width: 2),
      ),
      hintStyle: const TextStyle(color: AppColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
  );
}
