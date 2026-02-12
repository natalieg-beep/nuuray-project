import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nuuray_core/nuuray_core.dart';

/// Service für User-Profil-Operationen (Supabase)
class UserProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Profil des aktuell eingeloggten Users laden
  Future<UserProfile?> getUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ getUserProfile: Kein User eingeloggt');
        return null;
      }

      print('📊 getUserProfile: Lade Profil für User $userId');

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        print('❌ getUserProfile: Kein Profil gefunden für User $userId');
        return null;
      }

      print('✅ getUserProfile: Profil-Daten empfangen: ${response.keys.join(", ")}');
      print('🔍 DEBUG signature_text aus DB: "${response['signature_text']}"');

      final profile = UserProfile.fromJson(response);
      print('✅ getUserProfile: Profil erfolgreich geparst für ${profile.displayName}');
      print('🔍 DEBUG signature_text im Model: "${profile.signatureText}"');

      return profile;
    } catch (e, stackTrace) {
      print('❌ getUserProfile Fehler: $e');
      print('Stack: $stackTrace');
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

        // WICHTIG: signature_text wird bei INSERT nicht gesetzt (wird später generiert)
        data.remove('signature_text');

        // Debug: Zeige was wir senden
        log('Sende Daten an Supabase: ${data.keys.join(", ")}');

        await _supabase.from('profiles').insert(data);

        log('✅ Profil erstellt für User ${profile.id}');
        return true;
      }
    } catch (e, stackTrace) {
      log('createUserProfile Fehler: $e');
      log('StackTrace: $stackTrace');
      return false;
    }
  }

  /// Profil aktualisieren
  ///
  /// WICHTIG: Diese Methode updatet nur die Felder die im UserProfile-Objekt
  /// gesetzt sind. Felder die NULL sind werden NICHT überschrieben.
  /// Insbesondere wird signature_text NIEMALS überschrieben (muss manuell
  /// gesetzt werden via separate Methode).
  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      // Erstelle Update-Map nur mit non-null Feldern
      final Map<String, dynamic> updateData = {};

      // Basis-Felder (immer setzen falls vorhanden)
      if (profile.displayName.isNotEmpty) {
        updateData['display_name'] = profile.displayName;
      }
      if (profile.fullFirstNames != null) {
        updateData['full_first_names'] = profile.fullFirstNames;
      }
      if (profile.birthName != null) {
        updateData['birth_name'] = profile.birthName;
      }
      if (profile.lastName != null) {
        updateData['last_name'] = profile.lastName;
      }
      if (profile.gender != null) {
        updateData['gender'] = profile.gender;
      }

      // Geburtsdaten
      if (profile.birthDate != null) {
        updateData['birth_date'] = profile.birthDate!.toIso8601String().split('T').first;
      }
      if (profile.birthTime != null) {
        updateData['birth_time'] = '${profile.birthTime!.hour.toString().padLeft(2, '0')}:${profile.birthTime!.minute.toString().padLeft(2, '0')}';
      }
      updateData['has_birth_time'] = profile.hasBirthTime;

      if (profile.birthCity != null) {
        updateData['birth_place'] = profile.birthCity; // DB-Spalte heißt birth_place
      }
      if (profile.birthLatitude != null) {
        updateData['birth_latitude'] = profile.birthLatitude;
      }
      if (profile.birthLongitude != null) {
        updateData['birth_longitude'] = profile.birthLongitude;
      }
      if (profile.birthTimezone != null) {
        updateData['birth_timezone'] = profile.birthTimezone;
      }

      // Sprache & Timezone
      updateData['language'] = profile.language;
      updateData['timezone'] = profile.timezone;

      // Onboarding
      updateData['onboarding_completed'] = profile.onboardingCompleted;

      // WICHTIG: signature_text wird NICHT überschrieben!
      // Das wird nur via generateAndCacheArchetypeSignature() gesetzt.

      // Updated-At immer setzen
      updateData['updated_at'] = DateTime.now().toIso8601String();

      log('📝 updateUserProfile: Update-Felder: ${updateData.keys.join(", ")}');

      await _supabase.from('profiles').update(updateData).eq('id', profile.id);

      log('✅ Profil aktualisiert für User ${profile.id}');
      return true;
    } catch (e, stackTrace) {
      log('❌ updateUserProfile Fehler: $e');
      log('   StackTrace: $stackTrace');
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
