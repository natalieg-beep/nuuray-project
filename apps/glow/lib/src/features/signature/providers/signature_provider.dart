import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuuray_core/nuuray_core.dart';
import '../../../core/providers/app_providers.dart';
import '../../profile/providers/user_profile_provider.dart';

/// Signature Provider
///
/// Lädt das User-Profil und berechnet daraus die vollständige kosmische Signatur.
/// "Deine Signatur" = Synthese aus Western Astrology + Bazi + Numerology.
/// Cached das Ergebnis automatisch.
final signatureProvider = FutureProvider<BirthChart?>((ref) async {
  // User-Profil laden
  final userProfileAsync = ref.watch(userProfileProvider);

  return userProfileAsync.when(
    data: (userProfile) async {
      if (userProfile == null) return null;

      // Geburtsdaten sammeln
      final birthDate = userProfile.birthDate;
      if (birthDate == null) return null; // Kein Geburtsdatum = keine Berechnung möglich

      // Geburtszeit (falls vorhanden)
      DateTime? birthTime;
      if (userProfile.hasBirthTime && userProfile.birthTime != null) {
        birthTime = DateTime(
          birthDate.year,
          birthDate.month,
          birthDate.day,
          userProfile.birthTime!.hour,
          userProfile.birthTime!.minute,
        );
      }

      // Geburtsort (Koordinaten)
      final birthLatitude = userProfile.birthLatitude;
      final birthLongitude = userProfile.birthLongitude;

      // Timezone für UTC-Konvertierung
      final birthTimezone = userProfile.birthTimezone ?? 'Europe/Berlin'; // Fallback

      // Namen für Numerologie zusammenbauen
      // Birth Energy (Urenergie) = Vornamen + Geburtsname
      // Current Energy (Aktuelle Energie) = Vornamen + aktueller Nachname
      String? birthName;
      String? currentName;

      if (userProfile.fullFirstNames != null && userProfile.fullFirstNames!.isNotEmpty) {
        // Birth Energy: Vornamen + Geburtsname
        if (userProfile.birthName != null && userProfile.birthName!.isNotEmpty) {
          birthName = '${userProfile.fullFirstNames} ${userProfile.birthName}';
        } else {
          // Fallback: Nur Vornamen (falls kein Geburtsname vorhanden)
          birthName = userProfile.fullFirstNames;
        }

        // Current Energy: Vornamen + aktueller Nachname (nur wenn unterschiedlich)
        if (userProfile.lastName != null && userProfile.lastName!.isNotEmpty) {
          currentName = '${userProfile.fullFirstNames} ${userProfile.lastName}';

          // Wenn aktueller Name gleich Geburtsname, kein Current Name
          if (currentName == birthName) {
            currentName = null;
          }
        }
      } else if (userProfile.displayName.isNotEmpty) {
        // Fallback: Nur Rufname
        birthName = userProfile.displayName;
      }

      // "Deine Signatur" berechnen
      final birthChart = await SignatureService.calculateSignature(
        userId: userProfile.id,
        birthDate: birthDate,
        birthTime: birthTime,
        birthLatitude: birthLatitude,
        birthLongitude: birthLongitude,
        birthTimezone: birthTimezone,
        displayName: userProfile.displayName,
        birthName: birthName,
        currentName: currentName,
      );

      // 🔥 FIX: Chart in Datenbank speichern (UPSERT)
      try {
        final supabase = ref.read(supabaseClientProvider);

        // Upsert: Insert or Update if exists
        final chartJson = birthChart.toJson();
        chartJson['user_id'] = userProfile.id;

        await supabase
            .from('birth_charts')
            .upsert(
              chartJson,
              onConflict: 'user_id', // Konflikt auf user_id → Update statt Insert
            );

        print('✅ Birth Chart gespeichert in Datenbank (UPSERT)');
      } catch (e) {
        print('⚠️ Fehler beim Speichern des Charts: $e');
        // Chart trotzdem zurückgeben (nur Cache fehlt)
      }

      return birthChart;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
