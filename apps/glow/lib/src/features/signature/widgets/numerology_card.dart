import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';
import 'package:nuuray_ui/nuuray_ui.dart';

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
    final l10n = AppLocalizations.of(context)!;

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
                      l10n.signatureNumerologyTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      l10n.numerologySubtitle,
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
                          l10n.numerologyLifePath,
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
                  _buildSmallNumberBox(context, l10n.numerologyBirthday, birthdayNumber),
                if (attitudeNumber != null)
                  _buildSmallNumberBox(context, l10n.numerologyAttitude, attitudeNumber),
                if (personalYear != null)
                  _buildSmallNumberBox(context, l10n.numerologyPersonalYear('${DateTime.now().year}'), personalYear),
                if (maturityNumber != null)
                  _buildSmallNumberBox(context, l10n.numerologyMaturity, maturityNumber),
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
                            l10n.numerologyBirthEnergy,
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
                            l10n.numerologyCurrentEnergy,
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
                      l10n.signatureNumerologyFullNameRequired,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // === ERWEITERTE NUMEROLOGIE (Karmic Debt, Challenges, Lessons, Bridges) ===
          _buildAdvancedNumerology(context),

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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (expression != null)
            _buildNumberRow(context, l10n.numerologyExpression, expression, l10n.numerologyExpressionMeaning),
          if (expression != null && soulUrge != null) const SizedBox(height: 12),
          if (soulUrge != null)
            _buildNumberRow(context, l10n.numerologySoulUrge, soulUrge, l10n.numerologySoulUrgeMeaning),
          if (soulUrge != null && personality != null) const SizedBox(height: 12),
          if (personality != null)
            _buildNumberRow(context, l10n.numerologyPersonality, personality, l10n.numerologyPersonalityMeaning),
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

  /// Baut die erweiterte Numerologie-Sektion (Karmic Debt, Challenges, Lessons, Bridges)
  Widget _buildAdvancedNumerology(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final karmicDebtLifePath = widget.birthChart.karmicDebtLifePath;
    final karmicDebtExpression = widget.birthChart.karmicDebtExpression;
    final karmicDebtSoulUrge = widget.birthChart.karmicDebtSoulUrge;
    final challengeNumbers = widget.birthChart.challengeNumbers;
    final karmicLessons = widget.birthChart.karmicLessons;
    final bridgeLifePathExpression = widget.birthChart.bridgeLifePathExpression;
    final bridgeSoulUrgePersonality = widget.birthChart.bridgeSoulUrgePersonality;

    // Prüfe ob überhaupt erweiterte Daten vorhanden sind
    final hasAnyData = karmicDebtLifePath != null ||
        karmicDebtExpression != null ||
        karmicDebtSoulUrge != null ||
        (challengeNumbers != null && challengeNumbers.isNotEmpty) ||
        (karmicLessons != null && karmicLessons.isNotEmpty) ||
        bridgeLifePathExpression != null ||
        bridgeSoulUrgePersonality != null;

    if (!hasAnyData) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          l10n.signatureNumerologyAdvancedTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 12),

        // Karmic Debt Numbers
        if (karmicDebtLifePath != null ||
            karmicDebtExpression != null ||
            karmicDebtSoulUrge != null) ...[
          _buildAdvancedSection(
            context,
            icon: '⚡',
            title: l10n.numerologyKarmicDebtTitle,
            subtitle: l10n.numerologyKarmicDebtSubtitle,
            children: [
              if (karmicDebtLifePath != null)
                _buildAdvancedItem(
                  context,
                  l10n.numerologyLifePath,
                  karmicDebtLifePath,
                  _getKarmicDebtMeaning(context, karmicDebtLifePath),
                ),
              if (karmicDebtExpression != null)
                _buildAdvancedItem(
                  context,
                  l10n.numerologyExpression,
                  karmicDebtExpression,
                  _getKarmicDebtMeaning(context, karmicDebtExpression),
                ),
              if (karmicDebtSoulUrge != null)
                _buildAdvancedItem(
                  context,
                  l10n.numerologySoulUrge,
                  karmicDebtSoulUrge,
                  _getKarmicDebtMeaning(context, karmicDebtSoulUrge),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Challenge Numbers
        if (challengeNumbers != null && challengeNumbers.isNotEmpty) ...[
          _buildAdvancedSection(
            context,
            icon: '🎯',
            title: l10n.numerologyChallengesTitle,
            subtitle: l10n.numerologyChallengesSubtitle,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < challengeNumbers.length; i++)
                    _buildChallengeChip(
                      context,
                      l10n.numerologyChallengePhase('${i + 1}'),
                      challengeNumbers[i],
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Karmic Lessons
        if (karmicLessons != null && karmicLessons.isNotEmpty) ...[
          _buildAdvancedSection(
            context,
            icon: '📚',
            title: l10n.numerologyKarmicLessonsTitle,
            subtitle: l10n.numerologyKarmicLessonsSubtitle,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final lesson in karmicLessons)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '$lesson',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Bridge Numbers
        if (bridgeLifePathExpression != null || bridgeSoulUrgePersonality != null) ...[
          _buildAdvancedSection(
            context,
            icon: '🌉',
            title: l10n.numerologyBridgesTitle,
            subtitle: l10n.numerologyBridgesSubtitle,
            children: [
              if (bridgeLifePathExpression != null)
                _buildAdvancedItem(
                  context,
                  l10n.numerologyBridgeLifepathExpression,
                  bridgeLifePathExpression,
                  l10n.numerologyBridgeLifepathMeaning,
                ),
              if (bridgeSoulUrgePersonality != null)
                _buildAdvancedItem(
                  context,
                  l10n.numerologyBridgeSoulPersonality,
                  bridgeSoulUrgePersonality,
                  l10n.numerologyBridgeSoulMeaning,
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// Baut eine Sektion für erweiterte Numerologie
  Widget _buildAdvancedSection(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.surfaceDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  /// Baut ein Item für erweiterte Numerologie
  Widget _buildAdvancedItem(
    BuildContext context,
    String label,
    int number,
    String meaning,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$number',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Baut einen Chip für Challenge Numbers
  Widget _buildChallengeChip(BuildContext context, String label, int number) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: number == 0
            ? AppColors.success.withOpacity(0.1)
            : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: number == 0
              ? AppColors.success.withOpacity(0.3)
              : AppColors.surfaceDark.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            '$number',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: number == 0 ? AppColors.success : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  /// Gibt die Bedeutung einer Karmic Debt Number zurück
  String _getKarmicDebtMeaning(BuildContext context, int number) {
    final l10n = AppLocalizations.of(context)!;

    switch (number) {
      case 13:
        return l10n.numerologyKarmicDebt13;
      case 14:
        return l10n.numerologyKarmicDebt14;
      case 16:
        return l10n.numerologyKarmicDebt16;
      case 19:
        return l10n.numerologyKarmicDebt19;
      default:
        return l10n.numerologyKarmicDebtDefault;
    }
  }

  String _getLifePathMeaning(int number) {
    final l10n = AppLocalizations.of(context)!;

    switch (number) {
      case 1:
        return l10n.numerologyLifepath1;
      case 2:
        return l10n.numerologyLifepath2;
      case 3:
        return l10n.numerologyLifepath3;
      case 4:
        return l10n.numerologyLifepath4;
      case 5:
        return l10n.numerologyLifepath5;
      case 6:
        return l10n.numerologyLifepath6;
      case 7:
        return l10n.numerologyLifepath7;
      case 8:
        return l10n.numerologyLifepath8;
      case 9:
        return l10n.numerologyLifepath9;
      case 11:
        return l10n.numerologyLifepath11;
      case 22:
        return l10n.numerologyLifepath22;
      case 33:
        return l10n.numerologyLifepath33;
      default:
        return l10n.numerologyLifePath;
    }
  }
}
