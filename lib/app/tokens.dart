import 'package:flutter/material.dart';

/// Design tokens from handover/04-design.md.
abstract final class AppColors {
  static const Color canvas = Color(0xFFF4F2ED);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color sunken = Color(0xFFEBE8E1);

  static const Color ink = Color(0xFF1B1A17);
  static const Color ink2 = Color(0xFF504E48);
  static const Color ink3 = Color(0xFF6F6C65);

  static const Color line = Color(0xFFE2DED5);
  static const Color lineStrong = Color(0xFFCBC6BB);

  static const Color accent = Color(0xFF45398A);
  static const Color accentSoft = Color(0xFFEAE7F5);
  static const Color onAccent = Color(0xFFFFFFFF);

  static const Color attention = Color(0xFFA84B12);
  static const Color attentionSoft = Color(0xFFFAECDF);

  static const Color positive = Color(0xFF2C6A4C);
  static const Color positiveSoft = Color(0xFFE3EFE8);
}

abstract final class AppSpace {
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s56 = 56;
  static const double s64 = 64;

  static const double screenHorizontal = 20;
  static const double cardPadding = 16;
}

abstract final class AppRadius {
  static const double r6 = 6;
  static const double glyph = 10;
  static const double inset = 14;
  static const double card = 20;
  static const double sheet = 28;
  static const double pill = 999;
}

abstract final class AppType {
  static const String displayFamily = 'Newsreader';
  static const String bodyFamily = 'InstrumentSans';

  static const TextStyle displayDay = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    fontSize: 30,
    height: 36 / 30,
    letterSpacing: -0.30,
    color: AppColors.ink,
    fontStyle: FontStyle.normal,
  );

  static const TextStyle displayTitle = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    fontSize: 26,
    height: 32 / 26,
    letterSpacing: -0.26,
    color: AppColors.ink,
    fontStyle: FontStyle.normal,
  );

  static const TextStyle quoteMd = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
    fontSize: 18,
    height: 26 / 18,
    color: AppColors.ink,
    fontStyle: FontStyle.normal,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    fontSize: 20,
    height: 26 / 20,
    color: AppColors.ink,
    fontStyle: FontStyle.normal,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    fontSize: 17,
    height: 24 / 17,
    color: AppColors.ink,
    fontStyle: FontStyle.normal,
  );

  static const TextStyle titleSm = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    fontSize: 15,
    height: 20 / 15,
    color: AppColors.ink,
    fontStyle: FontStyle.normal,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
    fontSize: 15,
    height: 22 / 15,
    color: AppColors.ink,
    fontStyle: FontStyle.normal,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
    fontSize: 13,
    height: 18 / 13,
    color: AppColors.ink2,
    fontStyle: FontStyle.normal,
  );

  static const TextStyle bodySmStrong = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    fontSize: 13,
    height: 18 / 13,
    color: AppColors.ink,
    fontStyle: FontStyle.normal,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.ink,
    fontStyle: FontStyle.normal,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.12,
    color: AppColors.ink2,
    fontStyle: FontStyle.normal,
  );

  static const TextStyle labelNav = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
    fontSize: 11,
    height: 14 / 11,
    color: AppColors.ink2,
    fontStyle: FontStyle.normal,
  );
}
