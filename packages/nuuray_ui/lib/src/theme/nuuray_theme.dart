import 'package:flutter/material.dart';

/// NUURAY App-Identitäten.
///
/// Jede App hat ihren eigenen Farbcharakter, aber sie teilen sich
/// Typografie, Spacing und grundlegende Design-Tokens.
enum NuurayApp { glow, tide, path }

/// Zentrale Theme-Definition für alle drei NUURAY Apps.
class NuurayTheme {
  NuurayTheme._();

  // ===========================================================================
  // FARBEN PRO APP
  // ===========================================================================

  static const _glowColors = _AppColors(
    primary: Color(0xFFC8956E),       // Warm Gold
    primaryLight: Color(0xFFD4C5A9),
    primaryDark: Color(0xFF8B7355),
    accent: Color(0xFFE8B86D),
    surface: Color(0xFFFAF7F2),
    background: Color(0xFFFFFDF8),
    onPrimary: Colors.white,
  );

  static const _tideColors = _AppColors(
    primary: Color(0xFF9B7A8E),       // Rosé
    primaryLight: Color(0xFFC9A9BC),
    primaryDark: Color(0xFF6D4E63),
    accent: Color(0xFFB8849E),
    surface: Color(0xFFF8F4F6),
    background: Color(0xFFFFF9FB),
    onPrimary: Colors.white,
  );

  static const _pathColors = _AppColors(
    primary: Color(0xFF4A6FA5),       // Ruhiges Blau
    primaryLight: Color(0xFF8AAED4),
    primaryDark: Color(0xFF2D4A73),
    accent: Color(0xFF5B8CC9),
    surface: Color(0xFFF3F6FA),
    background: Color(0xFFF8FAFF),
    onPrimary: Colors.white,
  );

  /// Gibt die Farbpalette für eine App zurück.
  static _AppColors colors(NuurayApp app) => switch (app) {
    NuurayApp.glow => _glowColors,
    NuurayApp.tide => _tideColors,
    NuurayApp.path => _pathColors,
  };

  // ===========================================================================
  // SHARED FARBEN
  // ===========================================================================

  static const textPrimary = Color(0xFF2C2C2C);
  static const textSecondary = Color(0xFF666666);
  static const textTertiary = Color(0xFF999999);
  static const divider = Color(0xFFE8E4DE);
  static const error = Color(0xFFD4534B);
  static const success = Color(0xFF5BA86C);

  // ===========================================================================
  // TYPOGRAFIE
  // ===========================================================================

  // Cormorant Garamond für Überschriften (elegant, seriös)
  // DM Sans für Body-Text (modern, lesbar)
  // Quicksand für Labels/Tags (leicht, freundlich)

  static TextTheme textTheme() => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32, fontWeight: FontWeight.w300, letterSpacing: 1.2,
      color: textPrimary, height: 1.3,
    ),
    displayMedium: TextStyle(
      fontSize: 28, fontWeight: FontWeight.w300, letterSpacing: 0.8,
      color: textPrimary, height: 1.3,
    ),
    headlineLarge: TextStyle(
      fontSize: 24, fontWeight: FontWeight.w400,
      color: textPrimary, height: 1.4,
    ),
    headlineMedium: TextStyle(
      fontSize: 20, fontWeight: FontWeight.w400,
      color: textPrimary, height: 1.4,
    ),
    titleLarge: TextStyle(
      fontSize: 18, fontWeight: FontWeight.w500,
      color: textPrimary, height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 16, fontWeight: FontWeight.w500,
      color: textPrimary, height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 16, fontWeight: FontWeight.w400,
      color: textPrimary, height: 1.6,
    ),
    bodyMedium: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400,
      color: textSecondary, height: 1.6,
    ),
    labelLarge: TextStyle(
      fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.0,
      color: textTertiary, height: 1.4,
    ),
  );

  // ===========================================================================
  // SPACING
  // ===========================================================================

  static const spacing4 = 4.0;
  static const spacing8 = 8.0;
  static const spacing12 = 12.0;
  static const spacing16 = 16.0;
  static const spacing20 = 20.0;
  static const spacing24 = 24.0;
  static const spacing32 = 32.0;
  static const spacing48 = 48.0;

  static const radiusSmall = 8.0;
  static const radiusMedium = 16.0;
  static const radiusLarge = 24.0;
  static const radiusFull = 999.0;

  // ===========================================================================
  // THEME DATA
  // ===========================================================================

  /// Erstellt ein vollständiges ThemeData für eine App.
  static ThemeData themeData(NuurayApp app) {
    final c = colors(app);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: c.primary,
        secondary: c.accent,
        surface: c.surface,
        error: error,
        onPrimary: c.onPrimary,
      ),
      scaffoldBackgroundColor: c.background,
      textTheme: textTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: BorderSide(color: divider.withValues(alpha: 0.5)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
    );
  }
}

/// Interne Klasse für app-spezifische Farben.
class _AppColors {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final Color surface;
  final Color background;
  final Color onPrimary;

  const _AppColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.surface,
    required this.background,
    required this.onPrimary,
  });
}
