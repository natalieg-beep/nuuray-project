import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nuuray_core/nuuray_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../../signature/services/archetype_signature_service.dart';
import 'onboarding_name_screen.dart';
import 'onboarding_birthdata_combined_screen.dart';

/// Onboarding-Flow: 2 Schritte (Name → Geburtsdaten kombiniert)
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
    if (_currentPage < 1) {
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

  /// Generiert Archetyp-Signatur im Hintergrund (nicht blockierend)
  Future<void> _generateArchetypeSignature(
    String userId,
    UserProfile profile,
  ) async {
    try {
      log('🎨 [Archetyp] Starte Signatur-Generierung für User: $userId');

      // 1. Chart berechnen mit SignatureService
      if (profile.birthDate == null) {
        log('⚠️ [Archetyp] Kein Geburtsdatum vorhanden - überspringe');
        return;
      }

      log('📊 [Archetyp] Berechne BirthChart...');
      final birthChart = await SignatureService.calculateSignature(
        userId: userId,
        birthDate: profile.birthDate!,
        birthTime: profile.birthTime,
        birthLatitude: profile.birthLatitude,
        birthLongitude: profile.birthLongitude,
        birthTimezone: profile.birthTimezone ?? 'Europe/Berlin',
        birthName: profile.fullFirstNames != null && profile.birthName != null
            ? '${profile.fullFirstNames} ${profile.birthName}'
            : profile.displayName,
        currentName: profile.fullFirstNames != null && profile.lastName != null
            ? '${profile.fullFirstNames} ${profile.lastName}'
            : null,
      );

      if (birthChart == null) {
        log('❌ [Archetyp] Chart-Berechnung fehlgeschlagen');
        return;
      }

      log('✅ [Archetyp] BirthChart erfolgreich berechnet');
      log('   Life Path: ${birthChart.lifePathNumber}');
      log('   Bazi Day Stem: ${birthChart.baziDayStem}');

      // 2. Claude API Service aus Provider holen
      final claudeService = ref.read(claudeApiServiceProvider);
      if (claudeService == null) {
        log('⚠️ [Archetyp] Claude API Service nicht verfügbar (API Key fehlt?)');
        return;
      }

      log('🤖 [Archetyp] Claude API Service bereit, starte Generierung...');

      final archetypeService = ArchetypeSignatureService(
        supabase: Supabase.instance.client,
        claudeService: claudeService,
      );

      final signatureText =
          await archetypeService.generateAndCacheArchetypeSignature(
        userId: userId,
        birthChart: birthChart,
        language: profile.language,
      );

      log('✨ [Archetyp] Signatur erfolgreich generiert!');
      log('   Text: "$signatureText"');
    } catch (e, stackTrace) {
      // Nicht blockieren - Signatur kann später generiert werden
      log('❌ [Archetyp] Fehler bei Signatur-Generierung: $e');
      log('📋 [Archetyp] StackTrace: $stackTrace');
    }
  }

  Future<void> _saveProfile() async {
    log('🔄 _saveProfile gestartet');

    if (_displayName == null || _birthDate == null) {
      log('❌ Pflichtfelder fehlen: displayName=$_displayName, birthDate=$_birthDate');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte fülle alle Pflichtfelder aus'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    log('✅ Pflichtfelder OK: displayName=$_displayName, birthDate=$_birthDate');
    setState(() => _isSaving = true);

    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.id;

    log('👤 User ID: $userId');

    if (userId == null) {
      log('❌ Kein User eingeloggt!');
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
    // Konvertiere TimeOfDay? zu DateTime? für Speicherung
    DateTime? birthTimeAsDateTime;
    if (_birthTime != null) {
      birthTimeAsDateTime = DateTime(
        2000, // Dummy-Datum, nur Zeit ist relevant
        1,
        1,
        _birthTime!.hour,
        _birthTime!.minute,
      );
    }

    log('📝 Erstelle UserProfile Object...');
    final profile = UserProfile(
      id: userId,
      displayName: _displayName!,
      fullFirstNames: _fullFirstNames,
      lastName: _lastName,
      birthName: _birthName,
      birthDate: _birthDate!,
      birthTime: birthTimeAsDateTime,
      hasBirthTime: _hasBirthTime,
      birthCity: _birthPlace,
      birthLatitude: _birthLatitude,
      birthLongitude: _birthLongitude,
      birthTimezone: _birthTimezone,
      createdAt: DateTime.now(),
      onboardingCompleted: true,
    );

    log('💾 Profil-Daten: ${profile.toJson()}');

    // In Supabase speichern
    log('📤 Sende Profil an Supabase...');
    final profileService = ref.read(userProfileServiceProvider);
    final success = await profileService.createUserProfile(profile);

    log('✅ Speichern abgeschlossen: success=$success');

    if (!success) {
      setState(() => _isSaving = false);
      if (!mounted) return;

      // Zeige detaillierteren Fehler
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Fehler beim Speichern des Profils.\n\nBitte Debug Console prüfen (macOS: Cmd+Shift+Y)'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    // ✨ NEU: Archetyp-Signatur generieren (warte darauf!)
    log('═══════════════════════════════════════════════════════');
    log('🎨 STARTE ARCHETYP-GENERIERUNG');
    log('═══════════════════════════════════════════════════════');
    await _generateArchetypeSignature(userId, profile);
    log('═══════════════════════════════════════════════════════');
    log('✅ ARCHETYP-GENERIERUNG ABGESCHLOSSEN');
    log('═══════════════════════════════════════════════════════');

    setState(() => _isSaving = false);

    if (!mounted) return;

    // Profil-Provider invalidieren, damit er neu geladen wird
    ref.invalidate(userProfileProvider);
    ref.invalidate(hasCompletedOnboardingProvider);

    // Zur Home-Seite navigieren
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Schritt ${_currentPage + 1} von 2',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        centerTitle: true,
        // DEBUG: Logout-Button für Testing
        actions: [
          TextButton.icon(
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
              if (!mounted) return;
              context.go('/login');
            },
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Logout'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Fortschrittsbalken
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / 2,
              backgroundColor: AppColors.surfaceDark,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 16),

          // PageView mit den 2 Screens
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
                  initialBirthName: _birthName,
                  initialLastName: _lastName,
                  onNext: (displayName, fullFirstNames, birthName, lastName) {
                    setState(() {
                      _displayName = displayName;
                      _fullFirstNames = fullFirstNames;
                      _birthName = birthName;
                      _lastName = lastName;
                    });
                    _nextPage();
                  },
                ),

                // Schritt 2: Geburtsdaten KOMBINIERT (Datum + Zeit + Ort)
                OnboardingBirthdataCombinedScreen(
                  initialBirthDate: _birthDate,
                  initialBirthTime: _birthTime,
                  initialHasBirthTime: _hasBirthTime,
                  initialBirthPlace: _birthPlace,
                  initialLatitude: _birthLatitude,
                  initialLongitude: _birthLongitude,
                  initialTimezone: _birthTimezone,
                  onComplete: (birthDate, birthTime, hasBirthTime, place,
                      latitude, longitude, timezone) {
                    setState(() {
                      _birthDate = birthDate;
                      _birthTime = birthTime;
                      _hasBirthTime = hasBirthTime;
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
