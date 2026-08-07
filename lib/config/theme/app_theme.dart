import 'package:flutter/material.dart';

class AppTheme {
  // Neumorphism Palette
  static const Color neoBackground = Color(0xFFE0E5EC); // Light grayish blue
  static const Color neoShadowDark = Color(0xFFA3B1C6); // Dark shadow
  static const Color neoShadowLight = Color(0xFFFFFFFF); // Light shadow
  
  static const Color textDark = Color(0xFF4A4E69); // Dark grey text
  static const Color textMuted = Color(0xFF9EA7BB); // Muted text

  // State colors (Soft accents)
  static const Color success = Color(0xFF56AB91);
  static const Color warning = Color(0xFFE9C46A);
  static const Color danger = Color(0xFFE76F51);
  static const Color accent = Color(0xFF6B8DF2); // Soft blue accent

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: neoBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: accent,
        secondary: success,
        surface: neoBackground,
        error: danger,
        brightness: Brightness.light,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textDark,
          letterSpacing: -1.0,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textMuted,
        ),
      ),
      iconTheme: const IconThemeData(
        color: textDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neoBackground,
          foregroundColor: textDark,
          elevation: 0, // Shadows handled by custom containers usually
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

