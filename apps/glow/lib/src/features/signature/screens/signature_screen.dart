import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../signature/providers/signature_provider.dart';
import '../widgets/hero_section.dart';
import '../widgets/western_astrology_section.dart';
import '../widgets/bazi_section.dart';
import '../widgets/numerology_section.dart';
import '../widgets/premium_synthesis_section.dart';

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
    final signatureAsync = ref.watch(signatureProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
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
      body: signatureAsync.when(
        data: (birthChart) {
          if (birthChart == null) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Section
                HeroSection(
                  archetypeTitle: 'Die kosmische Wandlerin',
                  miniSynthesis: 'Eine harmonische Verbindung aus erdverbundener Stärke, '
                      'emotionaler Tiefe und spiritueller Weisheit.',
                ),

                // 2. Western Astrology Section
                WesternAstrologySection(
                  westernChart: birthChart.westernChart,
                ),

                // 3. Bazi Section
                BaziSection(
                  baziChart: birthChart.baziChart,
                ),

                // 4. Numerology Section
                NumerologySection(
                  numerologyChart: birthChart.numerologyChart,
                ),

                // 5. Premium Synthesis Section
                const PremiumSynthesisSection(
                  isPremium: false, // TODO: Dynamisch aus Subscription Status
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
      ),
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
