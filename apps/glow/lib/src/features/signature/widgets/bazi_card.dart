import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';

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

  // TODO: i18n - später aus ARB-Dateien
  static const Map<String, String> _stemsDE = {
    'Jia': 'Jia', 'Yi': 'Yi', 'Bing': 'Bing', 'Ding': 'Ding',
    'Wu': 'Wu', 'Ji': 'Ji', 'Geng': 'Geng', 'Xin': 'Xin',
    'Ren': 'Ren', 'Gui': 'Gui',
  };

  static const Map<String, String> _branchesDE = {
    'Rat': 'Ratte', 'Ox': 'Büffel', 'Tiger': 'Tiger', 'Rabbit': 'Hase',
    'Dragon': 'Drache', 'Snake': 'Schlange', 'Horse': 'Pferd', 'Goat': 'Ziege',
    'Monkey': 'Affe', 'Rooster': 'Hahn', 'Dog': 'Hund', 'Pig': 'Schwein',
  };

  @override
  Widget build(BuildContext context) {
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
                      'Bazi (四柱)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      'Vier Säulen des Schicksals',
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
                  'Tages-Meister',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_translateStem(birthChart.baziDayStem ?? 'N/A')}-${_translateBranch(birthChart.baziDayBranch ?? 'N/A')}',
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
                  'Jahr',
                  '${_translateStem(birthChart.baziYearStem ?? 'N/A')}-${_translateBranch(birthChart.baziYearBranch ?? 'N/A')}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPillarColumn(
                  context,
                  'Monat',
                  '${_translateStem(birthChart.baziMonthStem ?? 'N/A')}-${_translateBranch(birthChart.baziMonthBranch ?? 'N/A')}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPillarColumn(
                  context,
                  'Tag',
                  '${_translateStem(birthChart.baziDayStem ?? 'N/A')}-${_translateBranch(birthChart.baziDayBranch ?? 'N/A')}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPillarColumn(
                  context,
                  'Stunde',
                  birthChart.baziHourStem != null
                      ? '${_translateStem(birthChart.baziHourStem!)}-${_translateBranch(birthChart.baziHourBranch!)}'
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
                'Dominantes Element:',
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
                      _getElementName(birthChart.baziElement ?? 'Wood'),
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
                    'Mehr erfahren',
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

  String _getElementName(String element) {
    // TODO: i18n - später aus ARB-Dateien
    switch (element.toLowerCase()) {
      case 'wood':
        return 'Holz';
      case 'fire':
        return 'Feuer';
      case 'earth':
        return 'Erde';
      case 'metal':
        return 'Metall';
      case 'water':
        return 'Wasser';
      default:
        return element;
    }
  }

  String _translateStem(String stem) {
    return _stemsDE[stem] ?? stem;
  }

  String _translateBranch(String branch) {
    return _branchesDE[branch] ?? branch;
  }
}
