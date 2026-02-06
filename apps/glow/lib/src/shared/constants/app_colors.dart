import 'package:flutter/material.dart';

/// Glow-spezifische Farbpalette
/// Primary: Warm Gold (#C8956E)
/// Ton: Unterhaltsam, staunend, überraschend
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFFC8956E); // Warm Gold
  static const Color primaryLight = Color(0xFFE5C8A8);
  static const Color primaryDark = Color(0xFFA67C5A);

  // Background
  static const Color background = Color(0xFFFFFBF7); // Sehr helles Beige
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFFF5F0EB);

  // Text
  static const Color textPrimary = Color(0xFF2C2416); // Dunkelbraun
  static const Color textSecondary = Color(0xFF6B5E52);
  static const Color textTertiary = Color(0xFF9B8E82);

  // Accent Colors
  static const Color accent = Color(0xFFD4A574); // Gold-Beige
  static const Color accentLight = Color(0xFFE8C9A1);

  // Status Colors
  static const Color success = Color(0xFF7FA672);
  static const Color warning = Color(0xFFE8B25C);
  static const Color error = Color(0xFFD17A6F);
  static const Color info = Color(0xFF8BA7C7);

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color scrim = Color(0x4D000000);

  // Zodiac-specific colors (für Highlights)
  static const Map<String, Color> zodiacColors = {
    'aries': Color(0xFFE85D4A),
    'taurus': Color(0xFF7FA672),
    'gemini': Color(0xFFE8C96A),
    'cancer': Color(0xFF89AEBD),
    'leo': Color(0xFFD4A574),
    'virgo': Color(0xFF9B8E82),
    'libra': Color(0xFFD8A8B5),
    'scorpio': Color(0xFF8E5F6B),
    'sagittarius': Color(0xFFB56D3A),
    'capricorn': Color(0xFF5C6B5E),
    'aquarius': Color(0xFF6F92AE),
    'pisces': Color(0xFF9FA7C7),
  };
}
