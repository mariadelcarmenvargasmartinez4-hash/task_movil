import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color electricBlue = Color(0xFF1E50FF);
  static const Color purple = Color(0xFF7B41FF);
  static const Color green = Color(0xFF00C569);
  
  // Backgrounds & Neutrals
  static const Color backgroundLight = Color(0xFFF3F6FF);
  static const Color textDark = Color(0xFF0A0E1A);
  static const Color textMuted = Color(0xFF6B7280);

  // Gradient for Header Card
  static const Gradient headerGradient = LinearGradient(
    colors: [purple, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: electricBlue,
        primary: electricBlue,
        secondary: purple,
        surface: Colors.white,
      ),
      fontFamily: 'Inter', // Fallback to system sans-serif if not loaded
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          color: textMuted,
        ),
      ),
    );
  }
}
