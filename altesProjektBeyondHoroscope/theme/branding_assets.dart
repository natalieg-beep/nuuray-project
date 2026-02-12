// ============================================================
// BRANDING ASSETS - Zentrale Asset-Pfade für Beyond Horoscope
// ============================================================
//
// Dieses File enthält alle Pfade zu den Branding-Assets.
// Verwendung: BrandingAssets.logoGoldNude
//
// ============================================================

/// Zentrale Klasse für alle Branding-Asset-Pfade
class BrandingAssets {
  BrandingAssets._(); // Prevent instantiation

  // ============================================================
  // BASE PATH
  // ============================================================

  static const String _basePath = 'assets/images/branding';

  // ============================================================
  // HAUPTLOGOS (PNG) - Für allgemeine Verwendung
  // ============================================================

  /// Logo auf Cosmic Nude Hintergrund - Standard für helle Screens
  static const String logoGoldNude = '$_basePath/logo_gold_nude.png';

  /// Logo auf weißem Hintergrund - Für Cards/Elevated Surfaces
  static const String logoGoldWhite = '$_basePath/logo_gold_white.png';

  // ============================================================
  // ICON-VARIANTEN (PNG) - Für kompakte Darstellung
  // ============================================================

  /// Nur das Icon/Symbol auf Nude - Für App-Bar, Badges, PDF-Siegel
  static const String logoIconGoldNude = '$_basePath/logo_icon_gold_nude.png';

  /// Nur das Icon/Symbol auf Weiß
  static const String logoIconGoldWhite = '$_basePath/logo_icon_gold_white.png';

  // ============================================================
  // VEKTOR-FORMATE (SVG) - Für skalierbare Darstellung
  // ============================================================

  /// Vollständiges Logo als Vektor - Für Onboarding, Marketing
  static const String logoVectorNude = '$_basePath/logo_vector_nude.svg';

  /// Weiße Variante als Vektor - Für dunkle Hintergründe
  static const String logoVectorWhite = '$_basePath/logo_vector_white.svg';

  // ============================================================
  // ANIMATIONEN (MP4) - Für Splash Screen
  // ============================================================

  /// Animiertes Logo auf Nude - Primär für Splash Screen
  static const String logoAnimationNude = '$_basePath/logo_animation_nude.mp4';

  /// Animierte weiße Variante - Für dunkle Modi
  static const String logoAnimationWhite = '$_basePath/logo_animation_white.mp4';

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Gibt das passende Logo für den aktuellen Kontext zurück
  /// [isDarkBackground] - true für dunkle Hintergründe (z.B. Shadow & Light PDF)
  static String getLogo({bool isDarkBackground = false}) {
    return isDarkBackground ? logoGoldWhite : logoGoldNude;
  }

  /// Gibt das passende Icon für den aktuellen Kontext zurück
  static String getLogoIcon({bool isDarkBackground = false}) {
    return isDarkBackground ? logoIconGoldWhite : logoIconGoldNude;
  }

  /// Gibt die passende Animation für den aktuellen Kontext zurück
  static String getAnimation({bool isDarkBackground = false}) {
    return isDarkBackground ? logoAnimationWhite : logoAnimationNude;
  }

  /// Gibt das passende SVG-Logo zurück
  static String getVectorLogo({bool isDarkBackground = false}) {
    return isDarkBackground ? logoVectorWhite : logoVectorNude;
  }
}

// ============================================================
// BRANDING COLORS - Finalisierte Farbpalette
// ============================================================

/// Finalisierte Branding-Farben (passend zu den Assets)
class BrandingColors {
  BrandingColors._(); // Prevent instantiation

  /// Cosmic Nude - Hintergrundfrequenz der Marke
  /// Verwendet in: logo_*_nude Assets, Splash Background
  static const int cosmicNude = 0xFFE8E4DD;

  /// Primary Gold - Akzentfarbe, Logo-Elemente
  /// Verwendet in: Logo-Gold-Elemente, Highlights
  static const int primaryGold = 0xFFD4AF37;

  /// Deep Charcoal - Textfarbe, Kontrast
  /// Verwendet in: Headlines, wichtige Texte
  static const int deepCharcoal = 0xFF2D2926;

  /// Warm White - Helle Hintergründe
  /// Verwendet in: Cards, Elevated Surfaces
  static const int warmWhite = 0xFFFAF8F5;
}
