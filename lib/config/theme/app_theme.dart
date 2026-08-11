import 'package:flutter/material.dart';

class AppTheme {
  // Gamified Palette (Comic/Game Style)
  static const Color gameBackground = Color(0xFFF4F7FE); // Soft blue background to make cards pop
  static const Color gameBorder = Color(0xFF1E1E24); // Solid black for thick borders and hard shadows
  
  static const Color accentPrimary = Color(0xFFFF6B6B); // Punchy Red/Pink
  static const Color accentSecondary = Color(0xFF4D96FF); // Bright Blue
  static const Color accentTertiary = Color(0xFFF9D923); // Bright Yellow
  
  static const Color textDark = Color(0xFF1E1E24); // Dark heavy text
  static const Color textMuted = Color(0xFF757575); // Gray for secondary text
  static const Color textLight = Colors.white; // Light text
  
  static const Color cardColor = Colors.white;

  // Additional Gamified Colors
  static const Color green = Color(0xFF6BCB77);
  static const Color glassCyan = Color(0xFF00838F); // Updated cyan for better contrast
  static const Color glassPurple = Color(0xFFBA68C8);
  static const Color deepNavy = Color(0xFF1A237E);

  // State colors (Game Accents)
  static const Color success = Color(0xFF6BCB77); // Game Green
  static const Color warning = Color(0xFFF9D923); // Game Yellow
  static const Color danger = Color(0xFFFF6B6B); // Game Red
  static const Color accent = Color(0xFF4D96FF); // Game Blue

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: gameBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentSecondary,
        primary: accentSecondary,
        secondary: accentTertiary,
        surface: gameBackground,
        error: danger,
        brightness: Brightness.light,
      ),
      fontFamily: 'Inter', // Using Inter but we will make it extra bold
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900, // Black weight for gaming feel
          color: textDark,
          letterSpacing: -1.0,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: textDark,
        ),
        titleSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textMuted,
        ),
      ),
      iconTheme: const IconThemeData(
        color: textDark,
        size: 28,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentSecondary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: gameBorder, width: 3),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ).copyWith(
          // Simulate solid drop shadow on buttons? Usually done via custom widgets, but let's stick to standard buttons for dialogs
        ),
      ),
    );
  }
}


