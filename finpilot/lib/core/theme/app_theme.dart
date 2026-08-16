import 'package:flutter/material.dart';

class AppTheme {
  // Light
  static const Color primary = Color(0xFF16A34A);
  static const Color secondary = Color(0xFF2563EB);

  static const Color lightBackground = Color(0xFFF1F5F2);
  static const Color lightCard = Color(0xFFFFFFFF);

  static const Color lightText = Color(0xFF1F2937);
  static const Color lightSecondaryText = Color(0xFF64748B);

  // Dark
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);

  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkSecondaryText = Color(0xFF94A3B8);

  static const balanceAccent = Color(0xFF2563EB);
  static const incomeAccent = Color(0xFF16A34A);
  static const expenseAccent = Color(0xFFDC2626);
  static const savingsAccent = Color(0xFFD97706);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: lightBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightText,
      elevation: 1,
      shadowColor: Colors.black12,
    ),

    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),

    scaffoldBackgroundColor: darkBackground,

    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkText,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
