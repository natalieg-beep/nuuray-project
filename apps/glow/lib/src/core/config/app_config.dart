import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App-Konfiguration für Nuuray Glow
class AppConfig {
  AppConfig._();

  // App Info
  static const String appName = 'Nuuray Glow';
  static const String appVersion = '0.1.0';

  // Supabase Config (wird aus .env geladen, mit Fallback für Development)
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://ykkayjbplutdodummcte.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      'sb_publishable_kcM8qKBrYN2xqOrevEHQGA_DdtvgmBb';

  // Google Places API
  static String get googlePlacesApiKey =>
      dotenv.get('GOOGLE_PLACES_API_KEY', fallback: '');

  // Feature Flags
  static const bool enableAppleSignIn = true;
  static const bool enableGoogleSignIn = true;
  static const bool enablePremiumFeatures = false; // Später aktivieren

  // API Limits
  static const int maxPartnerProfiles = 5;
  static const int dailyHoroscopesCacheHours = 24;

  // UI Config
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
}
