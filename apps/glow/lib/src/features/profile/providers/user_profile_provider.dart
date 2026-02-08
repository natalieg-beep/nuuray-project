import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuuray_core/nuuray_core.dart';

import '../services/user_profile_service.dart';

/// Provider für den User Profile Service
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

/// Provider für das aktuelle User-Profil (async geladen)
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final service = ref.watch(userProfileServiceProvider);
  return await service.getUserProfile();
});

/// Provider um zu prüfen ob Onboarding abgeschlossen ist
final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(userProfileServiceProvider);
  return await service.hasCompletedOnboarding();
});
