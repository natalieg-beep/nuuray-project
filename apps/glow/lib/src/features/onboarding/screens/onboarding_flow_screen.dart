import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../../../core/config/app_config.dart';
import 'onboarding_name_screen.dart';
import 'onboarding_birthdate_screen.dart';
import 'onboarding_birthplace_geocoding_screen.dart';

/// Onboarding-Flow: 3 Schritte (Name → Geburtsdatum → Geburtsort)
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Gesammelte Daten aus allen Schritten
  String? _displayName;
  String? _fullFirstNames;
  String? _lastName;
  String? _birthName;

  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  bool _hasBirthTime = false;

  String? _birthPlace;
  double? _birthLatitude;
  double? _birthLongitude;
  String? _birthTimezone;

  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_displayName == null || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte fülle alle Pflichtfelder aus'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.id;

    if (userId == null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fehler: Kein User eingeloggt'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // UserProfile erstellen
    final profile = UserProfile(
      id: userId,
      displayName: _displayName!,
      fullFirstNames: _fullFirstNames,
      lastName: _lastName,
      birthName: _birthName,
      birthDate: _birthDate!,
      birthTime: _birthTime,
      hasBirthTime: _hasBirthTime,
      birthPlace: _birthPlace,
      birthLatitude: _birthLatitude,
      birthLongitude: _birthLongitude,
      birthTimezone: _birthTimezone,
      createdAt: DateTime.now(),
      onboardingCompleted: true,
    );

    // In Supabase speichern
    final profileService = ref.read(userProfileServiceProvider);
    final success = await profileService.createUserProfile(profile);

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      // Profil-Provider invalidieren, damit er neu geladen wird
      ref.invalidate(userProfileProvider);
      ref.invalidate(hasCompletedOnboardingProvider);

      // Zur Home-Seite navigieren
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fehler beim Speichern des Profils'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Schritt ${_currentPage + 1} von 3',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Fortschrittsbalken
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / 3,
              backgroundColor: AppColors.surfaceDark,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 16),

          // PageView mit den 3 Screens
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Nur über Buttons navigieren
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                // Schritt 1: Name
                OnboardingNameScreen(
                  initialDisplayName: _displayName,
                  initialFullFirstNames: _fullFirstNames,
                  initialLastName: _lastName,
                  initialBirthName: _birthName,
                  onNext: (displayName, fullFirstNames, lastName, birthName) {
                    setState(() {
                      _displayName = displayName;
                      _fullFirstNames = fullFirstNames;
                      _lastName = lastName;
                      _birthName = birthName;
                    });
                    _nextPage();
                  },
                ),

                // Schritt 2: Geburtsdatum & -zeit
                OnboardingBirthdateScreen(
                  initialBirthDate: _birthDate,
                  initialBirthTime: _birthTime,
                  initialHasBirthTime: _hasBirthTime,
                  onNext: (birthDate, birthTime, hasBirthTime) {
                    setState(() {
                      _birthDate = birthDate;
                      _birthTime = birthTime;
                      _hasBirthTime = hasBirthTime;
                    });
                    _nextPage();
                  },
                  onBack: _previousPage,
                ),

                // Schritt 3: Geburtsort (mit Geocoding)
                OnboardingBirthplaceGeocodingScreen(
                  initialBirthPlace: _birthPlace,
                  initialLatitude: _birthLatitude,
                  initialLongitude: _birthLongitude,
                  initialTimezone: _birthTimezone,
                  onComplete: (place, latitude, longitude, timezone) {
                    setState(() {
                      _birthPlace = place;
                      _birthLatitude = latitude;
                      _birthLongitude = longitude;
                      _birthTimezone = timezone;
                    });
                    _saveProfile();
                  },
                  onBack: _previousPage,
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
