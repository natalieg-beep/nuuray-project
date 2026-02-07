import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/western_astrology_card.dart';
import '../widgets/bazi_card.dart';
import '../widgets/numerology_card.dart';
import '../providers/cosmic_profile_provider.dart';

/// Cosmic Profile Dashboard Screen
///
/// Zeigt die drei Systeme (Western Astrology, Bazi, Numerology) in Cards an.
class CosmicProfileDashboardScreen extends ConsumerWidget {
  const CosmicProfileDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cosmicProfileAsync = ref.watch(cosmicProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Warmer Off-White
      appBar: AppBar(
        title: const Text(
          'Dein Cosmic Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2C2C2C),
      ),
      body: cosmicProfileAsync.when(
        data: (birthChart) {
          if (birthChart == null) {
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Deine kosmische Identität',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Eine Synthese aus drei Weisheitstraditionen',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 32),

                // Western Astrology Card
                WesternAstrologyCard(birthChart: birthChart),
                const SizedBox(height: 20),

                // Bazi Card
                BaziCard(birthChart: birthChart),
                const SizedBox(height: 20),

                // Numerology Card
                NumerologyCard(birthChart: birthChart),
                const SizedBox(height: 40),

                // Info Footer
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
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
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
                  'Fehler beim Laden des Profils',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(cosmicProfileProvider),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
