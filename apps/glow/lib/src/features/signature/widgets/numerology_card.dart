import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';

import '../../../shared/constants/app_colors.dart';

/// Numerology Card - Erweitert mit Dual-Profil System
///
/// Zeigt alle numerologischen Zahlen in einem kompakten, schönen Design:
/// - Kern-Zahlen: Life Path, Birthday, Attitude, Personal Year, Maturity
/// - Birth Energy (Geburtsname): Expression, Soul Urge, Personality
/// - Current Energy (aktueller Name): Expression, Soul Urge, Personality
///
/// Einheitliches Design mit AppColors (kein Gradient).
class NumerologyCard extends StatefulWidget {
  final BirthChart birthChart;

  const NumerologyCard({
    super.key,
    required this.birthChart,
  });

  @override
  State<NumerologyCard> createState() => _NumerologyCardState();
}

class _NumerologyCardState extends State<NumerologyCard> {
  bool _showBirthEnergy = false;
  bool _showCurrentEnergy = false;

  @override
  Widget build(BuildContext context) {
    // Extract numbers from BirthChart
    final lifePathNumber = widget.birthChart.lifePathNumber;
    final birthdayNumber = widget.birthChart.birthdayNumber;
    final attitudeNumber = widget.birthChart.attitudeNumber;
    final personalYear = widget.birthChart.personalYear;
    final maturityNumber = widget.birthChart.maturityNumber;

    // Birth Energy
    final birthExpression = widget.birthChart.birthExpressionNumber;
    final birthSoulUrge = widget.birthChart.birthSoulUrgeNumber;
    final birthPersonality = widget.birthChart.birthPersonalityNumber;
    final birthName = widget.birthChart.birthName;

    // Current Energy
    final currentExpression = widget.birthChart.currentExpressionNumber;
    final currentSoulUrge = widget.birthChart.currentSoulUrgeNumber;
    final currentPersonality = widget.birthChart.currentPersonalityNumber;
    final currentName = widget.birthChart.currentName;

    final hasNameChange = currentName != null && currentName != birthName;

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
                  Icons.filter_9_plus_rounded,
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
                      'Numerologie',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      'Deine Lebenszahlen',
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

          // === KERN-ZAHLEN (immer sichtbar) ===

          // Life Path Number (prominent)
          if (lifePathNumber != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text(
                        '$lifePathNumber',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lebensweg',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getLifePathMeaning(lifePathNumber),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Weitere Kern-Zahlen (Grid)
          if (birthdayNumber != null || attitudeNumber != null || personalYear != null || maturityNumber != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (birthdayNumber != null)
                  _buildSmallNumberBox(context, 'Geburtstag', birthdayNumber),
                if (attitudeNumber != null)
                  _buildSmallNumberBox(context, 'Haltung', attitudeNumber),
                if (personalYear != null)
                  _buildSmallNumberBox(context, 'Jahr ${DateTime.now().year}', personalYear),
                if (maturityNumber != null)
                  _buildSmallNumberBox(context, 'Reife', maturityNumber),
              ],
            ),

          const SizedBox(height: 20),

          // === NAME ENERGIES (expandable) ===

          // Birth Energy Section
          if (birthName != null && birthName.isNotEmpty) ...[
            InkWell(
              onTap: () => setState(() => _showBirthEnergy = !_showBirthEnergy),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Urenergie',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            birthName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _showBirthEnergy ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),

            if (_showBirthEnergy) ...[
              const SizedBox(height: 8),
              _buildEnergyDetails(
                context,
                expression: birthExpression,
                soulUrge: birthSoulUrge,
                personality: birthPersonality,
              ),
            ],
          ],

          // Current Energy Section (nur wenn Name geändert)
          if (hasNameChange) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => setState(() => _showCurrentEnergy = !_showCurrentEnergy),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aktuelle Energie',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentName!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _showCurrentEnergy ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),

            if (_showCurrentEnergy) ...[
              const SizedBox(height: 8),
              _buildEnergyDetails(
                context,
                expression: currentExpression,
                soulUrge: currentSoulUrge,
                personality: currentPersonality,
              ),
            ],
          ],

          // Placeholder wenn keine Namen-Daten
          if (birthName == null || birthName.isEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vollständiger Name für weitere Zahlen erforderlich',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],

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

  Widget _buildSmallNumberBox(BuildContext context, String label, int number) {
    final isMaster = NumerologyCalculator.isMasterNumber(number);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$number',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (isMaster) ...[
                const SizedBox(width: 2),
                const Text('✨', style: TextStyle(fontSize: 12)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyDetails(
    BuildContext context, {
    required int? expression,
    required int? soulUrge,
    required int? personality,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (expression != null)
            _buildNumberRow(context, 'Ausdruck', expression, 'Talent & Fähigkeiten'),
          if (expression != null && soulUrge != null) const SizedBox(height: 12),
          if (soulUrge != null)
            _buildNumberRow(context, 'Seelenwunsch', soulUrge, 'Innere Sehnsucht'),
          if (soulUrge != null && personality != null) const SizedBox(height: 12),
          if (personality != null)
            _buildNumberRow(context, 'Persönlichkeit', personality, 'Äußere Wirkung'),
        ],
      ),
    );
  }

  Widget _buildNumberRow(BuildContext context, String label, int number, String meaning) {
    final isMaster = NumerologyCalculator.isMasterNumber(number);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                meaning,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Text(
              '$number',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (isMaster) ...[
              const SizedBox(width: 4),
              const Text('✨', style: TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ],
    );
  }

  String _getLifePathMeaning(int number) {
    switch (number) {
      case 1:
        return 'Führung & Pioniergeist';
      case 2:
        return 'Harmonie & Partnerschaft';
      case 3:
        return 'Kreativität & Ausdruck';
      case 4:
        return 'Stabilität & Struktur';
      case 5:
        return 'Freiheit & Abenteuer';
      case 6:
        return 'Fürsorge & Verantwortung';
      case 7:
        return 'Weisheit & Spiritualität';
      case 8:
        return 'Macht & Manifestation';
      case 9:
        return 'Vollendung & Mitgefühl';
      case 11:
        return 'Spiritueller Botschafter ✨';
      case 22:
        return 'Meister-Manifestierer ✨';
      case 33:
        return 'Meister-Heiler ✨';
      default:
        return 'Lebensweg';
    }
  }
}
