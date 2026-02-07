import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/constants/app_colors.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../signature/providers/signature_provider.dart';
import '../../signature/widgets/western_astrology_card.dart';
import '../../signature/widgets/bazi_card.dart';
import '../../signature/widgets/numerology_card.dart';
import '../widgets/daily_horoscope_section.dart';

/// Home-Screen: Hauptansicht mit Tageshoroskop, Mondphase, etc.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return const Center(
                child: Text('Profil konnte nicht geladen werden'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header mit Begrüßung
                  _buildHeader(context, profile.displayName),
                  const SizedBox(height: 24),

                  // Tagesenergie-Card
                  _buildDailyEnergyCard(context),
                  const SizedBox(height: 16),

                  // Tageshoroskop-Card
                  const DailyHoroscopeSection(),
                  const SizedBox(height: 24),

                  // === DEINE SIGNATUR DASHBOARD ===
                  _buildSignatureSection(context, ref),

                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(context),
                  const SizedBox(height: 24),

                  // Debug: Logout Button
                  _buildDebugSection(context, ref),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, stack) => Center(
            child: Text('Fehler: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String displayName) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d. MMMM', 'de_DE');
    final formattedDate = dateFormat.format(now);

    String greeting = 'Guten Morgen';
    final hour = now.hour;
    if (hour >= 12 && hour < 18) {
      greeting = 'Guten Tag';
    } else if (hour >= 18) {
      greeting = 'Guten Abend';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $displayName',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          formattedDate,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildDailyEnergyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.nightlight_round,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Tagesenergie',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Zunehmender Mond in Steinbock',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Heute ist ein guter Tag für Struktur und Planung. Die kosmische Energie unterstützt dich dabei, deine Ziele klar zu definieren.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }


  Widget _buildEnergyIndicator(BuildContext context, String label, int level) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  Icons.star,
                  size: 16,
                  color: index < level
                      ? AppColors.accent
                      : AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection(BuildContext context, WidgetRef ref) {
    final signatureAsync = ref.watch(signatureProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            const Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Deine Signatur',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Signature Cards
        signatureAsync.when(
          data: (birthChart) {
            if (birthChart == null) {
              return _buildSignaturePlaceholder(context);
            }

            return Column(
              children: [
                // Western Astrology Card
                WesternAstrologyCard(birthChart: birthChart),
                const SizedBox(height: 16),

                // Bazi Card
                BaziCard(birthChart: birthChart),
                const SizedBox(height: 16),

                // Numerology Card
                NumerologyCard(birthChart: birthChart),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (error, stack) => _buildSignatureError(context, error),
        ),
      ],
    );
  }

  Widget _buildSignaturePlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceDark),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.auto_awesome_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Geburtsdaten unvollständig',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bitte vervollständige deine Geburtsdaten im Onboarding, um deine kosmische Signatur zu berechnen.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureError(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Fehler beim Laden',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entdecke mehr',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.calendar_month,
                title: 'Mondkalender',
                subtitle: 'Alle Mondphasen',
                onTap: () {
                  // TODO: Navigation zum Mondkalender
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming Soon!')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.favorite_outline,
                title: 'Partner-Check',
                subtitle: 'Kompatibilität',
                onTap: () {
                  // TODO: Navigation zum Partner-Check
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming Soon!')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surfaceDark,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugSection(BuildContext context, WidgetRef ref) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () async {
          final authService = ref.read(authServiceProvider);
          await authService.signOut();
          // Router leitet automatisch zu /login weiter
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
