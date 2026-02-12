import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/providers/user_profile_provider.dart';
import '../../features/profile/services/user_profile_service.dart';

/// Provider für die aktuelle App-Sprache
///
/// Liest die Sprache aus dem User-Profil und ermöglicht das Ändern der Sprache.
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier(ref);
});

/// Provider für den aktuellen Locale-Code als String (z.B. 'de', 'en')
///
/// Wird von Content Library Service und anderen Services verwendet.
final currentLocaleProvider = Provider<String>((ref) {
  final locale = ref.watch(languageProvider);
  return locale.languageCode;
});

class LanguageNotifier extends StateNotifier<Locale> {
  final Ref ref;

  LanguageNotifier(this.ref) : super(const Locale('de')) {
    _loadLanguageFromProfile();
  }

  /// Lädt die Sprache aus dem User-Profil
  Future<void> _loadLanguageFromProfile() async {
    final profileAsync = ref.read(userProfileProvider);

    profileAsync.whenData((profile) {
      if (profile != null) {
        // Konvertiere DB-Sprache (DE/EN) zu Locale
        final languageCode = profile.language.toLowerCase();
        state = Locale(languageCode);
      }
    });
  }

  /// Ändert die App-Sprache und speichert sie im User-Profil
  Future<void> setLanguage(Locale locale) async {
    // Sofortiges Update der UI
    state = locale;

    // Speichere in Datenbank
    try {
      final profileService = UserProfileService();
      final success = await profileService.updateLanguage(locale.languageCode);

      if (!success) {
        print('Fehler beim Speichern der Sprache');
        // Rollback bei Fehler
        _loadLanguageFromProfile();
      }
    } catch (e) {
      print('Fehler beim Speichern der Sprache: $e');
      // Rollback bei Fehler
      _loadLanguageFromProfile();
    }
  }

  /// Verfügbare Sprachen
  static const List<Locale> supportedLocales = [
    Locale('de'),
    Locale('en'),
  ];

  /// Sprach-Name für UI-Anzeige
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'de':
        return 'Deutsch';
      case 'en':
        return 'English';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Sprach-Flag Emoji für UI-Anzeige
  String getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'de':
        return '🇩🇪';
      case 'en':
        return '🇬🇧';
      default:
        return '🌍';
    }
  }
}
