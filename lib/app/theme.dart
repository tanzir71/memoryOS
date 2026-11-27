import 'package:flutter/material.dart';
import 'tokens.dart';

ThemeData buildMemoryTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppType.bodyFamily,
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      primaryContainer: AppColors.accentSoft,
      onPrimaryContainer: AppColors.accent,
      secondary: AppColors.attention,
      onSecondary: AppColors.onAccent,
      secondaryContainer: AppColors.attentionSoft,
      onSecondaryContainer: AppColors.attention,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.ink2,
      outline: AppColors.lineStrong,
      outlineVariant: AppColors.line,
      error: AppColors.attention,
      onError: AppColors.onAccent,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.canvas,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    textTheme: const TextTheme(
      displaySmall: AppType.displayDay,
      headlineMedium: AppType.displayTitle,
      titleLarge: AppType.titleLg,
      titleMedium: AppType.titleMd,
      titleSmall: AppType.titleSm,
      bodyLarge: AppType.bodyMd,
      bodyMedium: AppType.bodyMd,
      bodySmall: AppType.bodySm,
      labelLarge: AppType.labelMd,
      labelMedium: AppType.labelSm,
      labelSmall: AppType.labelNav,
    ),
  );
}
