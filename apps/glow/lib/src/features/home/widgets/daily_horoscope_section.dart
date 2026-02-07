import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuuray_core/nuuray_core.dart';

import '../../../shared/constants/app_colors.dart';
import '../../signature/providers/signature_provider.dart';
import '../../horoscope/providers/daily_horoscope_provider.dart';
import '../../horoscope/widgets/personal_insight_card.dart';
import '../../horoscope/utils/personal_insights.dart';

/// Tageshoroskop-Section mit PersonalInsightCards (Variante A)
///
/// Zeigt:
/// 1. Basis-Horoskop (gecacht)
/// 2. Bazi-Insight (statisch)
/// 3. Numerologie-Insight (statisch)
class DailyHoroscopeSection extends ConsumerWidget {
  const DailyHoroscopeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signatureAsync = ref.watch(signatureProvider);

    return signatureAsync.when(
      data: (birthChart) {
        if (birthChart == null) {
          return _buildPlaceholder(context);
        }

        // Zodiac Sign für Horoskop-Lookup (englischer Name, lowercase)
        final zodiacSignEn = birthChart.sunSign.toLowerCase();

        // Lade Basis-Horoskop
        final horoscopeAsync = ref.watch(dailyHoroscopeProvider(zodiacSignEn));

        return horoscopeAsync.when(
          data: (horoscopeText) => _buildHoroscopeContent(
            context,
            horoscopeText: horoscopeText,
            birthChart: birthChart,
          ),
          loading: () => _buildLoading(context),
          error: (error, stack) => _buildError(context, error),
        );
      },
      loading: () => _buildLoading(context),
      error: (error, stack) => _buildError(context, error),
    );
  }

  Widget _buildHoroscopeContent(
    BuildContext context, {
    required String horoscopeText,
    required BirthChart birthChart,
  }) {
    // Zodiac Sign Emoji/Symbol holen
    final zodiacSymbols = {
      'aries': '♈',
      'taurus': '♉',
      'gemini': '♊',
      'cancer': '♋',
      'leo': '♌',
      'virgo': '♍',
      'libra': '♎',
      'scorpio': '♏',
      'sagittarius': '♐',
      'capricorn': '♑',
      'aquarius': '♒',
      'pisces': '♓',
    };

    final zodiacNamesDE = {
      'aries': 'Widder',
      'taurus': 'Stier',
      'gemini': 'Zwillinge',
      'cancer': 'Krebs',
      'leo': 'Löwe',
      'virgo': 'Jungfrau',
      'libra': 'Waage',
      'scorpio': 'Skorpion',
      'sagittarius': 'Schütze',
      'capricorn': 'Steinbock',
      'aquarius': 'Wassermann',
      'pisces': 'Fische',
    };

    final sunSignEn = birthChart.sunSign.toLowerCase();
    final zodiacName = zodiacNamesDE[sunSignEn] ?? birthChart.sunSign;
    final zodiacSymbol = zodiacSymbols[sunSignEn] ?? '';

    // Day Master für Bazi-Insight (kombiniere Stem + Element)
    final dayMaster = birthChart.baziDayStem != null && birthChart.baziElement != null
        ? '${birthChart.baziDayStem} ${birthChart.baziElement}'
        : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dein Tageshoroskop',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Zodiac Sign
            Text(
              '$zodiacName $zodiacSymbol',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: 16),

            // Basis-Horoskop Text
            Text(
              horoscopeText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
            ),

            const SizedBox(height: 24),

            // Divider mit Text
            Row(
              children: [
                Expanded(
                  child: Divider(color: AppColors.textTertiary.withOpacity(0.3)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Persönlich für dich',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                  ),
                ),
                Expanded(
                  child: Divider(color: AppColors.textTertiary.withOpacity(0.3)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bazi Insight Card
            if (dayMaster != null)
              PersonalInsightCard(
                title: 'Dein Bazi heute',
                insight: PersonalInsights.getBaziInsight(dayMaster),
                emoji: PersonalInsights.getElementEmoji(dayMaster),
                accentColor: Colors.red.shade700,
              ),

            // Numerologie Insight Card
            if (birthChart.lifePathNumber != null)
              PersonalInsightCard(
                title: 'Deine Numerologie',
                insight: PersonalInsights.getNumerologyInsight(
                  birthChart.lifePathNumber!,
                ),
                emoji: PersonalInsights.getNumerologyEmoji(
                  birthChart.lifePathNumber!,
                ),
                accentColor: Colors.purple.shade700,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Lade dein Horoskop...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Horoskop konnte nicht geladen werden',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Bitte versuche es später erneut.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Geburtsdaten fehlen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Bitte vervollständige deine Geburtsdaten, um dein persönliches Horoskop zu sehen.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
