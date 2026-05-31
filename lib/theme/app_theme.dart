import 'package:flutter/material.dart';

class AppTheme {
  // Brand Color Palette
  static const Color primary = Color(
    0xFF503C76,
  ); // Insight Purple / Deep Indigo
  static const Color primaryContainer = Color(
    0xFFF0F1F7,
  ); // Soft light blue-grey
  static const Color secondary = Color(0xFF533E78);
  static const Color secondaryContainer = Color(
    0xFFF4F0FF,
  ); // Very light violet
  static const Color background = Color(0xFFF8F9FA); // Neutral background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFF1F3F5);
  static const Color onSurface = Color(0xFF1E1F24);
  static const Color onSurfaceVariant = Color(0xFF5E6066);
  static const Color outline = Color(0xFF74777F);
  static const Color outlineVariant = Color(0xFFE1E2E8);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFCEAEA);

  // Context Accent Colors
  static const Color contextAmber = Color(
    0xFF604100,
  ); // Muted Dark Gold for text
  static const Color contextAmberLight = Color(
    0xFFFFBA38,
  ); // Bright gold for accents
  static const Color contextAmberContainer = Color(
    0xFFFFF1DB,
  ); // Very light gold

  static const Color contextGreen = Color(0xFF1A7544); // Safe status
  static const Color contextGreenContainer = Color(0xFFE3F7EC);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        background: background,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: onSurface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 40 / 32,
          letterSpacing: 0,
          color: onSurface,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 32 / 24,
          color: onSurface,
        ),
        headlineSmall: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 28 / 20,
          color: onSurface,
        ),
        bodyLarge: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 24 / 16,
          color: onSurface,
        ),
        bodyMedium: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 20 / 14,
          color: onSurface,
        ),
        labelLarge: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 16 / 12,
          letterSpacing: 0.05,
          color: onSurface,
        ),
        labelSmall: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 14 / 10,
          color: onSurfaceVariant,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: outlineVariant, width: 1),
        ),
      ),
    );
  }
}
