import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuuray_core/nuuray_core.dart';
import '../../profile/providers/user_profile_provider.dart';

/// Cosmic Profile Provider
///
/// Lädt das User-Profil und berechnet daraus das vollständige Cosmic Profile.
/// Cached das Ergebnis automatisch.
final cosmicProfileProvider = FutureProvider<BirthChart?>((ref) async {
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

      // Cosmic Profile berechnen
      final birthChart = await CosmicProfileService.calculateCosmicProfile(
        userId: userProfile.id,
        birthDate: birthDate,
        birthTime: birthTime,
        birthLatitude: birthLatitude,
        birthLongitude: birthLongitude,
        fullName: fullName,
      );

      return birthChart;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
