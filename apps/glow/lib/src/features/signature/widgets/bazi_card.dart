import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';
import 'package:nuuray_ui/nuuray_ui.dart';

import '../../../shared/constants/app_colors.dart';

/// Bazi (Vier Säulen) Card
///
/// Zeigt die vier Säulen, Day Master und dominantes Element.
/// Einheitliches Design mit AppColors (kein Gradient).
class BaziCard extends StatelessWidget {
  final BirthChart birthChart;

  const BaziCard({
    super.key,
    required this.birthChart,
  });

  // Stems bleiben immer gleich (pinyin)
  static const Map<String, String> _stems = {
    'Jia': 'Jia', 'Yi': 'Yi', 'Bing': 'Bing', 'Ding': 'Ding',
    'Wu': 'Wu', 'Ji': 'Ji', 'Geng': 'Geng', 'Xin': 'Xin',
    'Ren': 'Ren', 'Gui': 'Gui',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                child: const Text(
                  '🐉',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.signatureBaziTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      l10n.signatureBaziSubtitle,
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

          // Day Master (prominent)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  l10n.signatureBaziDayMaster,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_translateStem(birthChart.baziDayStem ?? 'N/A')}-${_translateBranch(context,birthChart.baziDayBranch ?? 'N/A')}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Vier Säulen (Kompakt)
          Row(
            children: [
              Expanded(
                child: _buildPillarColumn(
                  context,
                  l10n.signatureBaziYear,
                  '${_translateStem(birthChart.baziYearStem ?? 'N/A')}-${_translateBranch(context,birthChart.baziYearBranch ?? 'N/A')}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPillarColumn(
                  context,
                  l10n.signatureBaziMonth,
                  '${_translateStem(birthChart.baziMonthStem ?? 'N/A')}-${_translateBranch(context,birthChart.baziMonthBranch ?? 'N/A')}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPillarColumn(
                  context,
                  l10n.signatureBaziDay,
                  '${_translateStem(birthChart.baziDayStem ?? 'N/A')}-${_translateBranch(context,birthChart.baziDayBranch ?? 'N/A')}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPillarColumn(
                  context,
                  l10n.signatureBaziHour,
                  birthChart.baziHourStem != null
                      ? '${_translateStem(birthChart.baziHourStem!)}-${_translateBranch(context,birthChart.baziHourBranch!)}'
                      : '?',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Dominantes Element
          Row(
            children: [
              Text(
                l10n.signatureBaziDominantElement,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getElementEmoji(birthChart.baziElement ?? 'Wood') +
                      ' ' +
                      _getElementName(birthChart.baziElement ?? 'Wood', context),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
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

  Widget _buildPillarColumn(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getElementEmoji(String element) {
    switch (element.toLowerCase()) {
      case 'wood':
      case 'holz':
        return '🌳';
      case 'fire':
      case 'feuer':
        return '🔥';
      case 'earth':
      case 'erde':
        return '🏔️';
      case 'metal':
      case 'metall':
        return '⚙️';
      case 'water':
      case 'wasser':
        return '💧';
      default:
        return '🌟';
    }
  }

  String _getElementName(String element, BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (element.toLowerCase()) {
      case 'wood':
        return l10n.baziElementWood;
      case 'fire':
        return l10n.baziElementFire;
      case 'earth':
        return l10n.baziElementEarth;
      case 'metal':
        return l10n.baziElementMetal;
      case 'water':
        return l10n.baziElementWater;
      default:
        return element;
    }
  }

  String _translateStem(String stem) {
    return _stems[stem] ?? stem;
  }

  String _translateBranch(BuildContext context, String branch) {
    final l10n = AppLocalizations.of(context);

    switch (branch) {
      case 'Rat':
        return l10n.baziBranchRat;
      case 'Ox':
        return l10n.baziBranchOx;
      case 'Tiger':
        return l10n.baziBranchTiger;
      case 'Rabbit':
        return l10n.baziBranchRabbit;
      case 'Dragon':
        return l10n.baziBranchDragon;
      case 'Snake':
        return l10n.baziBranchSnake;
      case 'Horse':
        return l10n.baziBranchHorse;
      case 'Goat':
        return l10n.baziBranchGoat;
      case 'Monkey':
        return l10n.baziBranchMonkey;
      case 'Rooster':
        return l10n.baziBranchRooster;
      case 'Dog':
        return l10n.baziBranchDog;
      case 'Pig':
        return l10n.baziBranchPig;
      default:
        return branch;
    }
  }
}
