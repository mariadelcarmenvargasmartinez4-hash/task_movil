import 'package:flutter/material.dart';

class AppTheme {
  // Vibrant Colors for Glassmorphism Backgrounds
  static const Color glassBlue = Color(0xFF4A00E0);
  static const Color glassPurple = Color(0xFF8E2DE2);
  static const Color glassPink = Color(0xFFF000FF);
  static const Color glassCyan = Color(0xFF00C9FF);
  
  static const Color textLight = Colors.white;
  static const Color textMuted = Colors.white70;

  // State colors
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFD600);
  static const Color danger = Color(0xFFFF1744);

  // Backgrounds & Neutrals
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardGlass = Color(0x20FFFFFF); // Semi-transparent white
  static const Color borderGlass = Color(0x30FFFFFF);

  // Vibrant Dynamic Gradients for the Background
  static const Gradient backgroundGradient1 = LinearGradient(
    colors: [glassPurple, glassBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient backgroundGradient2 = LinearGradient(
    colors: [glassCyan, glassBlue],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent, // Transparent to show gradient behind
      colorScheme: ColorScheme.fromSeed(
        seedColor: glassPurple,
        primary: glassPurple,
        secondary: glassCyan,
        surface: Colors.transparent, // Transparent surface for glass effect
        error: danger,
        brightness: Brightness.dark, // Default to dark text for glassmorphism
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textLight,
          letterSpacing: -1.0,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textLight,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textMuted,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardGlass,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: borderGlass, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: borderGlass, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: glassCyan, width: 2),
        ),
        hintStyle: const TextStyle(color: textMuted),
      ),
      iconTheme: const IconThemeData(
        color: textLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: glassPurple.withValues(alpha: 0.8),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: borderGlass, width: 1),
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
