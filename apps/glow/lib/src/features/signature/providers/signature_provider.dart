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

      // Vollständiger Name für Numerologie
      // TODO: Später birthName + currentName unterscheiden
      String? fullName;
      if (userProfile.fullFirstNames != null && userProfile.fullFirstNames!.isNotEmpty) {
        fullName = userProfile.fullFirstNames!;
        if (userProfile.lastName != null && userProfile.lastName!.isNotEmpty) {
          fullName += ' ${userProfile.lastName}';
        }
      } else if (userProfile.displayName.isNotEmpty) {
        fullName = userProfile.displayName;
      }

      // Kosmische Signatur berechnen
      final birthChart = await CosmicProfileService.calculateCosmicProfile(
        userId: userProfile.id,
        birthDate: birthDate,
        birthTime: birthTime,
        birthLatitude: birthLatitude,
        birthLongitude: birthLongitude,
        birthTimezone: birthTimezone,  // NEU: Timezone für UTC-Konvertierung!
        fullName: fullName,
      );

      return birthChart;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
