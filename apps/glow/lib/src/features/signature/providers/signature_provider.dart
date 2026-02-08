import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuuray_core/nuuray_core.dart';
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
        birthName: birthName,
        currentName: currentName,
      );

      return birthChart;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
