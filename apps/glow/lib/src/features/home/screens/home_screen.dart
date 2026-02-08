import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nuuray_core/nuuray_core.dart';
import 'package:nuuray_ui/nuuray_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../signature/providers/signature_provider.dart';
import '../../signature/services/archetype_signature_service.dart';
import '../../signature/widgets/western_astrology_card.dart';
import '../../signature/widgets/bazi_card.dart';
import '../../signature/widgets/numerology_card.dart';
import '../widgets/daily_horoscope_section.dart';
import '../widgets/archetype_header.dart';
import '../widgets/mini_system_widgets.dart';

/// Home-Screen: Hauptansicht mit Tageshoroskop, Mondphase, etc.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isRegeneratingSignature = false;
  bool _hasCheckedSignature = false;

  @override
  void initState() {
    super.initState();

    // Listen to profile changes and trigger regeneration if needed
    ref.listenManual(userProfileProvider, (previous, next) {
      log('👂 [HomeScreen] userProfileProvider changed');
      next.whenData((profile) {
        if (profile != null) {
          log('   Profile loaded: ${profile.displayName}');
          log('   signature_text: "${profile.signatureText}"');
          _checkAndRegenerateSignature(profile);
        }
      });
    });
  }

  /// Prüft ob signature_text NULL ist und regeneriert falls nötig
  Future<void> _checkAndRegenerateSignature(UserProfile profile) async {
    log('🔍 [HomeScreen] _checkAndRegenerateSignature aufgerufen');
    log('   _isRegeneratingSignature: $_isRegeneratingSignature');
    log('   _hasCheckedSignature: $_hasCheckedSignature');
    log('   profile.signatureText: "${profile.signatureText}"');

    if (_isRegeneratingSignature || _hasCheckedSignature) {
      log('⏭️  [HomeScreen] Überspringe - bereits geprüft oder läuft bereits');
      return;
    }
    _hasCheckedSignature = true;

    if (profile.signatureText != null && profile.signatureText!.isNotEmpty) {
      log('✅ [HomeScreen] Signatur existiert bereits - nichts zu tun');
      return; // Signatur existiert bereits
    }

    log('🔄 [HomeScreen] signature_text ist NULL - starte Regenerierung');
    setState(() => _isRegeneratingSignature = true);

    try {
      // Lade BirthChart
      final supabase = Supabase.instance.client;
      final userId = profile.id;

      final chartData = await supabase
          .from('birth_charts')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (chartData == null) {
        log('❌ [HomeScreen] Kein BirthChart gefunden');
        setState(() => _isRegeneratingSignature = false);
        return;
      }

      final birthChart = BirthChart.fromJson(chartData);

      // Claude API Service
      final claudeService = ref.read(claudeApiServiceProvider);
      if (claudeService == null) {
        log('❌ [HomeScreen] Claude API Service nicht verfügbar');
        setState(() => _isRegeneratingSignature = false);
        return;
      }

      // Generiere Signatur
      final archetypeService = ArchetypeSignatureService(
        supabase: supabase,
        claudeService: claudeService,
      );

      log('🤖 [HomeScreen] Starte Signatur-Generierung...');

      await archetypeService.generateAndCacheArchetypeSignature(
        userId: userId,
        birthChart: birthChart,
        language: profile.language,
      );

      log('✅ [HomeScreen] Signatur erfolgreich generiert');

      // Invalidiere Provider damit UI neu lädt
      ref.invalidate(userProfileProvider);
    } catch (e, stackTrace) {
      log('❌ [HomeScreen] Fehler bei Signatur-Regenerierung: $e');
      log('   StackTrace: $stackTrace');
    } finally {
      setState(() => _isRegeneratingSignature = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Settings Button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed('settings'),
            tooltip: l10n.settingsTitle,
          ),
        ],
      ),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return Center(
                child: Text(l10n.homeProfileLoadError),
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

                  // Zeige Regenerierungs-Hinweis falls läuft
                  if (_isRegeneratingSignature)
                    _buildRegenerationBanner(context),

                  // === NEU: ARCHETYP-SYSTEM ===
                  _buildArchetypeSection(context, ref, profile),

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
            child: Text('${l10n.generalError}: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildRegenerationBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.localeName.startsWith('de')
                  ? 'Archetyp-Signatur wird generiert...'
                  : 'Generating archetype signature...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String displayName) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat('EEEE, d. MMMM', locale.toString());
    final formattedDate = dateFormat.format(now);

    String greeting = l10n.homeGreetingMorning;
    final hour = now.hour;
    if (hour >= 12 && hour < 18) {
      greeting = l10n.homeGreetingDay;
    } else if (hour >= 18) {
      greeting = l10n.homeGreetingEvening;
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

  /// Archetyp-Section: Header + 3 Mini-Widgets
  Widget _buildArchetypeSection(
      BuildContext context, WidgetRef ref, UserProfile profile) {
    final l10n = AppLocalizations.of(context)!;
    final signatureAsync = ref.watch(signatureProvider);

    return signatureAsync.when(
      data: (birthChart) {
        if (birthChart == null) {
          return const SizedBox.shrink();
        }

        // Erstelle Archetyp aus BirthChart + Profil
        final archetype = Archetype.fromBirthChart(
          lifePathNumber: birthChart.lifePathNumber ?? 1,
          dayMasterStem: birthChart.baziDayStem ?? 'Jia',
          signatureText: profile.signatureText, // Aus Profile laden!
        );

        return Column(
          children: [
            // Archetyp-Header
            ArchetypeHeader(
              archetype: archetype,
              onTap: () {
                // Zeige Snackbar mit Hinweis
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.generalComingSoon),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),

            // 3 Mini-Widgets
            MiniSystemWidgets(
              birthChart: birthChart,
              onWesternTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.generalComingSoon),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              onBaziTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.generalComingSoon),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              onNumerologyTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.generalComingSoon),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildDailyEnergyCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                l10n.homeDailyEnergy,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.homeDailyEnergyMoonExample,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homeDailyEnergyDescriptionExample,
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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.homeYourSignature,
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
    final l10n = AppLocalizations.of(context)!;

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
            l10n.homeSignatureIncomplete,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homeSignatureIncompleteDescription,
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
    final l10n = AppLocalizations.of(context)!;

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
            l10n.homeSignatureLoadError,
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeQuickActions,
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
                title: l10n.homeMoonCalendar,
                subtitle: l10n.homeMoonCalendarSubtitle,
                onTap: () {
                  // TODO: Navigation zum Mondkalender
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.generalComingSoon)),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.favorite_outline,
                title: l10n.homePartnerCheck,
                subtitle: l10n.homePartnerCheckSubtitle,
                onTap: () {
                  // TODO: Navigation zum Partner-Check
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.generalComingSoon)),
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
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: OutlinedButton.icon(
        onPressed: () async {
          final authService = ref.read(authServiceProvider);
          await authService.signOut();
          // Router leitet automatisch zu /login weiter
        },
        icon: const Icon(Icons.logout),
        label: Text(l10n.settingsLogout),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
