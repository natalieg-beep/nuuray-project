// ============================================================
// BEYOND HOROSCOPE - DESIGN SYSTEM
// ============================================================
//
// Das zentrale Design-System für die gesamte App.
// Alle Farben, Typografie, Spacing und Icons sind hier definiert.
//
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ============================================================
// COLOR PALETTE
// ============================================================

class BeyondColors {
  BeyondColors._();

  // Primary - Marken-Gold
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color primaryGoldLight = Color(0xFFE8D48A);
  static const Color primaryGoldDark = Color(0xFFB8960E);

  // Background - Warmes Nude/Beige
  static const Color background = Color(0xFFF9F6F2);
  static const Color backgroundElevated = Color(0xFFFFFFFF);
  static const Color backgroundMuted = Color(0xFFF3EDE6);

  // Cosmic Nude (Sekundär)
  static const Color cosmicNude = Color(0xFFC9B8A8);
  static const Color cosmicNudeLight = Color(0xFFE8E0D8);
  static const Color cosmicNudeDark = Color(0xFFA89888);

  // Text
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textMuted = Color(0xFF9B9B9B);
  static const Color textOnGold = Color(0xFFFFFFFF);

  // Accent Colors
  static const Color success = Color(0xFF4A7C59);
  static const Color error = Color(0xFFB85450);
  static const Color info = Color(0xFF5B7FA8);
  static const Color warning = Color(0xFFD4A437);

  // Element Colors (Western Astrology)
  static const Color elementFire = Color(0xFFCF6B5F);
  static const Color elementEarth = Color(0xFF8B7355);
  static const Color elementAir = Color(0xFF7BA3C9);
  static const Color elementWater = Color(0xFF5B8FA8);

  // Element Colors (Chinese)
  static const Color elementWood = Color(0xFF6B8E5C);
  static const Color elementMetal = Color(0xFF9CA3A8);

  // Accent Colors
  static const Color accentCoral = Color(0xFFE85A4F);
  static const Color accentSage = Color(0xFF6B8E5C);
  static const Color accentTeal = Color(0xFF5B8FA8);

  // Moon Phase Colors
  static const Color moonLight = Color(0xFFFFFDF5);
  static const Color moonShadow = Color(0xFFD4CFC6);
  static const Color moonGlow = Color(0xFFD4AF37);

  // Card & Surface
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE8E0D8);
  static const Color divider = Color(0xFFE8E0D8);
}

// ============================================================
// TYPOGRAPHY
// ============================================================

class BeyondTypography {
  BeyondTypography._();

  // Headlines - Playfair Display (Serif)
  static TextStyle displayLarge = GoogleFonts.playfairDisplay(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: BeyondColors.textPrimary,
    letterSpacing: -1,
  );

  static TextStyle displayMedium = GoogleFonts.playfairDisplay(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: BeyondColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle displaySmall = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: BeyondColors.textPrimary,
  );

  static TextStyle headlineLarge = GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: BeyondColors.textPrimary,
  );

  static TextStyle headlineMedium = GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: BeyondColors.textPrimary,
  );

  static TextStyle headlineSmall = GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: BeyondColors.textPrimary,
  );

  // Body - Montserrat (Sans-Serif)
  static TextStyle bodyLarge = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: BeyondColors.textPrimary,
    height: 1.6,
  );

  static TextStyle bodyMedium = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: BeyondColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: BeyondColors.textSecondary,
    height: 1.5,
  );

  // Labels
  static TextStyle labelLarge = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: BeyondColors.textPrimary,
    letterSpacing: 0.5,
  );

  static TextStyle labelMedium = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: BeyondColors.textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: BeyondColors.textMuted,
    letterSpacing: 1,
  );

  // Special - Section Headers (Uppercase)
  static TextStyle sectionHeader = GoogleFonts.montserrat(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: BeyondColors.cosmicNude,
    letterSpacing: 2.5,
  );

  // Special - Pull Quotes
  static TextStyle pullQuote = GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.italic,
    color: BeyondColors.primaryGold,
    height: 1.6,
  );

  // Special - Numbers (for Numerology)
  static TextStyle numberDisplay = GoogleFonts.playfairDisplay(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: BeyondColors.primaryGold,
  );
}

// ============================================================
// SPACING
// ============================================================

class BeyondSpacing {
  BeyondSpacing._();

  // Base spacing unit: 4px
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Page padding (increased by 20% for breathing room)
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 20.0,
  );

  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);

  // Section spacing
  static const double sectionSpacing = 32.0;

  // Card radius
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double chipRadius = 20.0;
}

// ============================================================
// ICONS - Lucide Icons with Golden Style
// ============================================================

class BeyondIcons {
  BeyondIcons._();

  // Global icon style
  static const double defaultSize = 24.0;
  static const double smallSize = 20.0;
  static const double largeSize = 28.0;
  static const double strokeWidth = 1.2;
  static const Color defaultColor = BeyondColors.primaryGold;

  // Navigation Icons
  static const IconData home = LucideIcons.home;
  static const IconData profile = LucideIcons.user;
  static const IconData friends = LucideIcons.users;
  static const IconData settings = LucideIcons.settings;
  static const IconData back = LucideIcons.chevronLeft;
  static const IconData forward = LucideIcons.chevronRight;
  static const IconData close = LucideIcons.x;
  static const IconData menu = LucideIcons.menu;

  // Report Type Icons
  static const IconData reportMoney = LucideIcons.coins;
  static const IconData reportShadow = LucideIcons.moonStar;
  static const IconData reportParenting = LucideIcons.heartHandshake;
  static const IconData reportStyle = LucideIcons.sparkles;
  static const IconData reportRelocation = LucideIcons.map;
  static const IconData reportPurpose = LucideIcons.compass;
  static const IconData reportSoulmate = LucideIcons.heart;
  static const IconData reportYearly = LucideIcons.calendarDays;

  // Dashboard/Journey Icons
  static const IconData contracts = LucideIcons.fileSignature;
  static const IconData travel = LucideIcons.plane;
  static const IconData newProject = LucideIcons.rocket;
  static const IconData meditation = LucideIcons.flower2;
  static const IconData creativity = LucideIcons.palette;
  static const IconData communication = LucideIcons.messageCircle;
  static const IconData selfCare = LucideIcons.heart;
  static const IconData finance = LucideIcons.wallet;

  // Astrology Icons
  static const IconData sun = LucideIcons.sun;
  static const IconData moon = LucideIcons.moon;
  static const IconData star = LucideIcons.star;
  static const IconData constellation = LucideIcons.sparkles;

  // Action Icons
  static const IconData download = LucideIcons.download;
  static const IconData share = LucideIcons.share2;
  static const IconData edit = LucideIcons.pencil;
  static const IconData delete = LucideIcons.trash2;
  static const IconData add = LucideIcons.plus;
  static const IconData check = LucideIcons.check;
  static const IconData info = LucideIcons.info;
  static const IconData warning = LucideIcons.alertTriangle;
  static const IconData error = LucideIcons.alertCircle;
  static const IconData success = LucideIcons.checkCircle;
  static const IconData refresh = LucideIcons.refreshCw;
  static const IconData calendar = LucideIcons.calendar;
  static const IconData clock = LucideIcons.clock;
  static const IconData location = LucideIcons.mapPin;

  // Element Icons
  static const IconData elementFire = LucideIcons.flame;
  static const IconData elementEarth = LucideIcons.mountain;
  static const IconData elementAir = LucideIcons.wind;
  static const IconData elementWater = LucideIcons.droplets;
  static const IconData elementWood = LucideIcons.treePine;
  static const IconData elementMetal = LucideIcons.gem;

  /// Get report icon by report type name
  static IconData getReportIcon(String reportType) {
    switch (reportType) {
      case 'goldenMoneyBlueprint':
        return reportMoney;
      case 'shadowAndLight':
        return reportShadow;
      case 'cosmicParenting':
        return reportParenting;
      case 'aestheticStyleGuide':
        return reportStyle;
      case 'relocationAstrology':
        return reportRelocation;
      case 'thePurposePath':
        return reportPurpose;
      case 'soulMateFinder':
        return reportSoulmate;
      case 'yearlyEnergyForecast':
        return reportYearly;
      default:
        return star;
    }
  }

  /// Get element icon
  static IconData getElementIcon(String element) {
    switch (element.toLowerCase()) {
      case 'fire':
      case 'feuer':
        return elementFire;
      case 'earth':
      case 'erde':
        return elementEarth;
      case 'air':
      case 'luft':
        return elementAir;
      case 'water':
      case 'wasser':
        return elementWater;
      case 'wood':
      case 'holz':
        return elementWood;
      case 'metal':
      case 'metall':
        return elementMetal;
      default:
        return star;
    }
  }
}

// ============================================================
// ZODIAC GLYPHS (SVG Paths)
// ============================================================

class ZodiacGlyphs {
  ZodiacGlyphs._();

  /// Get the Unicode glyph for a ZodiacSign enum
  static String forSign(dynamic sign) {
    // Handle ZodiacSign enum
    final signName = sign.toString().split('.').last.toLowerCase();
    return getGlyph(signName);
  }

  /// Get the Unicode glyph for a zodiac sign by name
  static String getGlyph(String sign) {
    switch (sign.toLowerCase()) {
      case 'aries':
      case 'widder':
        return '♈';
      case 'taurus':
      case 'stier':
        return '♉';
      case 'gemini':
      case 'zwillinge':
        return '♊';
      case 'cancer':
      case 'krebs':
        return '♋';
      case 'leo':
      case 'löwe':
        return '♌';
      case 'virgo':
      case 'jungfrau':
        return '♍';
      case 'libra':
      case 'waage':
        return '♎';
      case 'scorpio':
      case 'skorpion':
        return '♏';
      case 'sagittarius':
      case 'schütze':
        return '♐';
      case 'capricorn':
      case 'steinbock':
        return '♑';
      case 'aquarius':
      case 'wassermann':
        return '♒';
      case 'pisces':
      case 'fische':
        return '♓';
      default:
        return '★';
    }
  }

  /// Sun glyph
  static const String sun = '☉';

  /// Moon glyph
  static const String moon = '☾';

  /// Ascendant symbol
  static const String ascendant = 'ASC';

  /// Get glyph text style (golden, elegant)
  static TextStyle glyphStyle({double size = 24}) {
    return TextStyle(
      fontSize: size,
      color: BeyondColors.primaryGold,
      fontWeight: FontWeight.w300,
    );
  }
}

// ============================================================
// CHINESE ZODIAC ICONS
// ============================================================

class ChineseZodiacIcons {
  ChineseZodiacIcons._();

  /// Get Lucide icon for Chinese zodiac animal
  static IconData getIcon(String animal) {
    switch (animal.toLowerCase()) {
      case 'rat':
      case 'ratte':
        return LucideIcons.mouse;
      case 'ox':
      case 'büffel':
        return LucideIcons.beef; // Closest available
      case 'tiger':
        return LucideIcons.cat; // Tiger-like
      case 'rabbit':
      case 'hase':
        return LucideIcons.leaf; // Rabbit-associated (nature)
      case 'dragon':
      case 'drache':
        return LucideIcons.flame; // Dragon-like
      case 'snake':
      case 'schlange':
        return LucideIcons.waves; // Snake-like (flowing)
      case 'horse':
      case 'pferd':
        return LucideIcons.bike; // Closest
      case 'goat':
      case 'ziege':
        return LucideIcons.mountain; // Goat-like
      case 'monkey':
      case 'affe':
        return LucideIcons.banana; // Monkey-associated
      case 'rooster':
      case 'hahn':
        return LucideIcons.bird;
      case 'dog':
      case 'hund':
        return LucideIcons.dog;
      case 'pig':
      case 'schwein':
        return LucideIcons.piggyBank;
      default:
        return LucideIcons.star;
    }
  }

  /// Get Lucide icon for ChineseAnimal enum
  static IconData forAnimal(dynamic animal) {
    // Handle ChineseAnimal enum
    final animalName = animal.toString().split('.').last.toLowerCase();
    return getIcon(animalName);
  }
}

// ============================================================
// THEME DATA BUILDER
// ============================================================

class BeyondTheme {
  BeyondTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: BeyondColors.background,
      primaryColor: BeyondColors.primaryGold,
      colorScheme: const ColorScheme.light(
        primary: BeyondColors.primaryGold,
        secondary: BeyondColors.cosmicNude,
        surface: BeyondColors.cardBackground,
        error: BeyondColors.error,
        onPrimary: BeyondColors.textOnGold,
        onSecondary: BeyondColors.textPrimary,
        onSurface: BeyondColors.textPrimary,
        onError: BeyondColors.textOnGold,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: BeyondColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: BeyondColors.primaryGold,
          size: BeyondIcons.defaultSize,
        ),
        titleTextStyle: BeyondTypography.headlineMedium,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: BeyondColors.backgroundElevated,
        selectedItemColor: BeyondColors.primaryGold,
        unselectedItemColor: BeyondColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: BeyondColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BeyondSpacing.cardRadius),
          side: const BorderSide(color: BeyondColors.cardBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BeyondColors.primaryGold,
          foregroundColor: BeyondColors.textOnGold,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BeyondSpacing.buttonRadius),
          ),
          textStyle: BeyondTypography.labelLarge.copyWith(
            color: BeyondColors.textOnGold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BeyondColors.primaryGold,
          side: const BorderSide(color: BeyondColors.primaryGold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BeyondSpacing.buttonRadius),
          ),
          textStyle: BeyondTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BeyondColors.primaryGold,
          textStyle: BeyondTypography.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BeyondColors.backgroundElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BeyondSpacing.buttonRadius),
          borderSide: const BorderSide(color: BeyondColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BeyondSpacing.buttonRadius),
          borderSide: const BorderSide(color: BeyondColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BeyondSpacing.buttonRadius),
          borderSide: const BorderSide(color: BeyondColors.primaryGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BeyondSpacing.buttonRadius),
          borderSide: const BorderSide(color: BeyondColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: BeyondTypography.bodyMedium.copyWith(
          color: BeyondColors.textMuted,
        ),
        labelStyle: BeyondTypography.labelMedium,
      ),
      dividerTheme: const DividerThemeData(
        color: BeyondColors.divider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: BeyondColors.primaryGold,
        size: BeyondIcons.defaultSize,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BeyondColors.textPrimary,
        contentTextStyle: BeyondTypography.bodyMedium.copyWith(
          color: BeyondColors.backgroundElevated,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BeyondSpacing.buttonRadius),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: BeyondTypography.displayLarge,
        displayMedium: BeyondTypography.displayMedium,
        displaySmall: BeyondTypography.displaySmall,
        headlineLarge: BeyondTypography.headlineLarge,
        headlineMedium: BeyondTypography.headlineMedium,
        headlineSmall: BeyondTypography.headlineSmall,
        bodyLarge: BeyondTypography.bodyLarge,
        bodyMedium: BeyondTypography.bodyMedium,
        bodySmall: BeyondTypography.bodySmall,
        labelLarge: BeyondTypography.labelLarge,
        labelMedium: BeyondTypography.labelMedium,
        labelSmall: BeyondTypography.labelSmall,
      ),
    );
  }
}
