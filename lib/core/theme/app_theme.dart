import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cream2,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.coral,
        brightness: Brightness.light,
        surface: AppColors.cream2,
      ),
      fontFamily: 'SF Pro Display',
      textTheme: _textTheme(AppColors.darkText),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withOpacity(0.84),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.ink,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.coral,
        brightness: Brightness.dark,
        surface: AppColors.ink2,
      ),
      fontFamily: 'SF Pro Display',
      textTheme: _textTheme(Colors.white),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
    );
  }

  static TextTheme _textTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 46, fontWeight: FontWeight.w800, height: 0.95, color: color),
      headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: color),
      headlineMedium: TextStyle(fontSize: 27, fontWeight: FontWeight.w700, color: color),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.35, color: color),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.35, color: color.withOpacity(0.74)),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.2, color: color),
    );
  }
}
