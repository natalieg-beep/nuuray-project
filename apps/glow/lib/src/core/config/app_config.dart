import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App-Konfiguration für Nuuray Glow
class AppConfig {
  AppConfig._();

  // App Info
  static const String appName = 'Nuuray Glow';
  static const String appVersion = '0.1.0';

  // Supabase Config (wird aus .env geladen)
  static String get supabaseUrl =>
      dotenv.get('SUPABASE_URL', fallback: '');

  static String get supabaseAnonKey =>
      dotenv.get('SUPABASE_ANON_KEY', fallback: '');

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
