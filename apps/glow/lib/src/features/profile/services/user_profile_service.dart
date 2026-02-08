import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';

/// Service für User-Profil-Operationen (Supabase)
class UserProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Profil des aktuell eingeloggten Users laden
  Future<UserProfile?> getUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        log('getUserProfile: Kein User eingeloggt');
        return null;
      }

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        log('getUserProfile: Kein Profil gefunden für User $userId');
        return null;
      }

      return UserProfile.fromJson(response);
    } catch (e) {
      log('getUserProfile Fehler: $e');
      return null;
    }
  }

  /// Profil erstellen oder aktualisieren (nach Onboarding)
  Future<bool> createUserProfile(UserProfile profile) async {
    try {
      // Prüfe ob Profil bereits existiert (durch Auth-Trigger erstellt)
      final existing = await getUserProfile();

      if (existing != null) {
        // Profil existiert → UPDATE
        log('Profil existiert bereits, führe UPDATE aus');
        return await updateUserProfile(profile);
      } else {
        // Profil existiert nicht → INSERT
        log('Erstelle neues Profil');
        final data = profile.toJson();

        // Debug: Zeige was wir senden
        log('Sende Daten an Supabase: $data');

        await _supabase.from('profiles').insert(data);

        log('Profil erstellt für User ${profile.id}');
        return true;
      }
    } catch (e, stackTrace) {
      log('createUserProfile Fehler: $e');
      log('StackTrace: $stackTrace');
      return false;
    }
  }

  /// Profil aktualisieren
  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      await _supabase
          .from('profiles')
          .update(profile.copyWith(updatedAt: DateTime.now()).toJson())
          .eq('id', profile.id);

      log('Profil aktualisiert für User ${profile.id}');
      return true;
    } catch (e) {
      log('updateUserProfile Fehler: $e');
      return false;
    }
  }

  /// Onboarding abschließen
  Future<bool> completeOnboarding(String userId) async {
    try {
      await _supabase
          .from('profiles')
          .update({'onboarding_completed': true, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);

      log('Onboarding abgeschlossen für User $userId');
      return true;
    } catch (e) {
      log('completeOnboarding Fehler: $e');
      return false;
    }
  }

  /// Prüfen ob User Onboarding abgeschlossen hat
  Future<bool> hasCompletedOnboarding() async {
    final profile = await getUserProfile();
    return profile?.onboardingCompleted ?? false;
  }

  /// Sprache aktualisieren
  Future<bool> updateLanguage(String languageCode) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        log('updateLanguage: Kein User eingeloggt');
        return false;
      }

      // Verwende lowercase für DB (de, en, etc.) - konsistent mit Flutter Locale
      final dbLanguage = languageCode.toLowerCase();

      await _supabase
          .from('profiles')
          .update({
            'language': dbLanguage,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      log('Sprache aktualisiert zu $dbLanguage für User $userId');
      return true;
    } catch (e) {
      log('updateLanguage Fehler: $e');
      return false;
    }
  }
}
