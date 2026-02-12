import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../signature/providers/signature_provider.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../../home/widgets/archetype_header.dart';
import '../widgets/western_astrology_section.dart';
import '../widgets/bazi_section.dart';
import '../widgets/numerology_section.dart';
import '../widgets/premium_synthesis_section.dart';
import 'package:nuuray_core/nuuray_core.dart';
import 'package:nuuray_ui/nuuray_ui.dart';

/// Signature Screen — Detaillierte kosmische Signatur (Vollansicht)
///
/// Zeigt alle 5 Sektionen:
/// 1. Hero (Archetyp-Titel + Mini-Synthese)
/// 2. Western Astrology (Sonne, Mond, Aszendent)
/// 3. Bazi (Day Master + Element Balance)
/// 4. Numerologie (Life Path + Kern-Zahlen)
/// 5. Premium Synthese (CTA oder vollständiger Text)
class SignatureScreen extends ConsumerWidget {
  const SignatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Warmer Off-White
      appBar: AppBar(
        title: const Text(
          'Deine Signatur',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2C2C),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return _buildEmptyState();
          }

          // Jetzt haben wir das Profil, baue Content
          return _buildContent(context, ref, profile, l10n);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorState(ref),
      ),
    );
  }

  /// Build Content with Profile
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    AppLocalizations l10n,
  ) {
    final signatureAsync = ref.watch(signatureProvider);

    return signatureAsync.when(
      data: (birthChart) {
        if (birthChart == null) {
          return _buildEmptyState();
        }

        // Erstelle Archetyp aus BirthChart + Profile (gleiche Quelle wie Home Screen!)
        final archetype = Archetype.fromBirthChart(
          lifePathNumber: birthChart.lifePathNumber ?? 1,
          dayMasterStem: birthChart.baziDayStem ?? 'Jia',
          signatureText: profile.signatureText,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Archetyp-Hero Section (nur Titel, keine Synthese)
              ArchetypeHeader(
                archetype: archetype,
                onTap: () {
                  // Bereits auf Signatur-Screen - kein Tap-Verhalten nötig
                },
                showSynthesis: false, // Nur Titel anzeigen
              ),
              const SizedBox(height: 24),

              // Überleitung: "Deine Signatur setzt sich aus drei Perspektiven zusammen..."
              Text(
                l10n.signatureOverviewIntro,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // 2. Western Astrology Section
              WesternAstrologySection(
                birthChart: birthChart,
              ),

              // 3. Bazi Section
              BaziSection(
                birthChart: birthChart,
              ),

              // 4. Numerology Section
              NumerologySection(
                birthChart: birthChart,
              ),

              const SizedBox(height: 40),

              // Outro: "Und so fügt sich alles zusammen:"
              Text(
                l10n.signatureOverviewOutro,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Kosmische Synthese (Info Footer)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Alle drei Systeme arbeiten zusammen und ergänzen sich gegenseitig.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => _buildErrorState(ref),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.stars_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Profil wird berechnet...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Fehler beim Laden der Signatur',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.refresh(signatureProvider),
            child: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }
}
