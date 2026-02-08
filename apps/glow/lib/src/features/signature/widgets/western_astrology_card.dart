import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';
import 'package:nuuray_ui/nuuray_ui.dart';

import '../../../shared/constants/app_colors.dart';

/// Western Astrology Card
///
/// Zeigt Sonne, Mond, Aszendent mit Symbolen und Graden.
/// Einheitliches Design mit AppColors (kein Gradient).
class WesternAstrologyCard extends StatelessWidget {
  final BirthChart birthChart;

  const WesternAstrologyCard({
    super.key,
    required this.birthChart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    // Sternzeichen-Objekte laden
    final sunSign = ZodiacSign.fromKey(birthChart.sunSign);
    final moonSign = birthChart.moonSign != null
        ? ZodiacSign.fromKey(birthChart.moonSign!)
        : null;
    final ascendantSign = birthChart.ascendantSign != null
        ? ZodiacSign.fromKey(birthChart.ascendantSign!)
        : null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.surfaceDark,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.signatureWesternTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      l10n.signatureWesternSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sonne
          _buildPlanetRow(
            context,
            symbol: sunSign.symbol,
            label: l10n.signatureSun,
            sign: locale.languageCode == 'de' ? sunSign.nameDe : sunSign.nameEn,
            degree: birthChart.sunDegree,
          ),

          const SizedBox(height: 16),

          // Mond
          if (moonSign != null)
            _buildPlanetRow(
              context,
              symbol: moonSign.symbol,
              label: l10n.signatureMoon,
              sign: locale.languageCode == 'de' ? moonSign.nameDe : moonSign.nameEn,
              degree: birthChart.moonDegree,
            ),

          if (moonSign != null) const SizedBox(height: 16),

          // Aszendent
          if (ascendantSign != null)
            _buildPlanetRow(
              context,
              symbol: ascendantSign.symbol,
              label: l10n.signatureAscendant,
              sign: locale.languageCode == 'de' ? ascendantSign.nameDe : ascendantSign.nameEn,
              degree: birthChart.ascendantDegree,
            )
          else
            // Placeholder wenn Aszendent fehlt (keine Geburtsort-Koordinaten)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.signatureAscendantRequired,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Mehr erfahren Button
          InkWell(
            onTap: () {
              // TODO: Navigate to details
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.signatureLearnMore,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetRow(
    BuildContext context, {
    required String symbol,
    required String label,
    required String sign,
    double? degree,
  }) {
    return Row(
      children: [
        // Symbol
        Text(
          symbol,
          style: const TextStyle(
            fontSize: 32,
            height: 1,
          ),
        ),
        const SizedBox(width: 12),

        // Label & Sign
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                sign,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),

        // Degree
        if (degree != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${degree.toStringAsFixed(2)}°',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
      ],
    );
  }
}
