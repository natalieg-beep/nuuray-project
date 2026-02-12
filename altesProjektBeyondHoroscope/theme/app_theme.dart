import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// BEYOND HOROSCOPE - APP THEME
// ============================================================

class AppColors {
  AppColors._();

  // Primary - Cosmic Nude / Muted Rose
  static const Color primary = Color(0xFFB8A394);
  static const Color primaryLight = Color(0xFFE8D7D0); // Muted Rose from spec
  static const Color primaryDark = Color(0xFF9C8779);

  // Accent - Salbei / Soft Beige
  static const Color accent = Color(0xFF9CAF88);
  static const Color accentLight = Color(0xFFF5F5DC); // Soft Beige from spec
  static const Color accentDark = Color(0xFF7A9168);

  // Background - Warm whites
  static const Color background = Color(0xFFFAF8F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F2EE);
  static const Color onboardingBg = Color(0xFFFCFAF8); // Extra soft for onboarding

  // Text - Deep Charcoal
  static const Color textPrimary = Color(0xFF2D2D2D); // Deep Charcoal from spec
  static const Color textSecondary = Color(0xFF7A756E);
  static const Color textLight = Color(0xFFA39E96);
  static const Color textOnDark = Color(0xFFFAF8F5);

  // Border
  static const Color border = Color(0xFFE8E4DF);
  static const Color divider = Color(0xFFF0EDE8);

  // Semantic
  static const Color success = Color(0xFF7CB47C);
  static const Color warning = Color(0xFFD4A574);
  static const Color error = Color(0xFFCD6B6B);
  static const Color info = Color(0xFF7BA3C4);

  // Elements
  static const Color elementFire = Color(0xFFE07B5C);
  static const Color elementEarth = Color(0xFFA6926B);
  static const Color elementAir = Color(0xFF94B8C8);
  static const Color elementWater = Color(0xFF7B9BAD);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        surface: AppColors.cardBackground,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        headlineSmall: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleSmall: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodySmall: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        labelLarge: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        labelMedium: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        labelSmall: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        hintStyle: GoogleFonts.nunito(color: AppColors.textLight, fontSize: 16),
      ),
      cardTheme: CardThemeData(elevation: 0, color: AppColors.cardBackground, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      appBarTheme: AppBarTheme(
        elevation: 0, 
        backgroundColor: AppColors.background, 
        foregroundColor: AppColors.textPrimary, 
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardBackground, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
    );
  }
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadius {
  AppRadius._();
  static BorderRadius get small => BorderRadius.circular(12);
  static BorderRadius get medium => BorderRadius.circular(16);
  static BorderRadius get large => BorderRadius.circular(20);
  static BorderRadius get xl => BorderRadius.circular(24);
  static BorderRadius get pill => BorderRadius.circular(100);
}
