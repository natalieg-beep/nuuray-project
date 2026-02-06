import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';

/// Numerology Card - Erweitert mit Dual-Profil System
///
/// Zeigt alle numerologischen Zahlen in einem kompakten, schönen Design:
/// - Kern-Zahlen: Life Path, Birthday, Attitude, Personal Year, Maturity
/// - Birth Energy (Geburtsname): Expression, Soul Urge, Personality
/// - Current Energy (aktueller Name): Expression, Soul Urge, Personality
///
/// Lila-Gradient für spirituelle, mystische Energie.
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9B59B6), // Amethyst Purple
            Color(0xFFE91E63), // Pink
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.filter_9_plus_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Numerologie',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deine Lebenszahlen',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // === KERN-ZAHLEN (immer sichtbar) ===

                  // Life Path Number (prominent)
                  if (lifePathNumber != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
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
                              color: Colors.white.withOpacity(0.25),
                            ),
                            child: Center(
                              child: Text(
                                '$lifePathNumber',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
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
                                  'Life Path',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getLifePathMeaning(lifePathNumber),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
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
                          _buildSmallNumberBox('Birthday', birthdayNumber),
                        if (attitudeNumber != null)
                          _buildSmallNumberBox('Attitude', attitudeNumber),
                        if (personalYear != null)
                          _buildSmallNumberBox('Jahr ${DateTime.now().year}', personalYear),
                        if (maturityNumber != null)
                          _buildSmallNumberBox('Maturity', maturityNumber),
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
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
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
                                  const Text(
                                    'Birth Energy',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    birthName,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _showBirthEnergy ? Icons.expand_less : Icons.expand_more,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_showBirthEnergy) ...[
                      const SizedBox(height: 8),
                      _buildEnergyDetails(
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
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
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
                                  const Text(
                                    'Current Energy',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currentName!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _showCurrentEnergy ? Icons.expand_less : Icons.expand_more,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_showCurrentEnergy) ...[
                      const SizedBox(height: 8),
                      _buildEnergyDetails(
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
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white.withOpacity(0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Vollständiger Name für weitere Zahlen erforderlich',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
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
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Mehr erfahren',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallNumberBox(String label, int number) {
    final isMaster = NumerologyCalculator.isMasterNumber(number);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
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

  Widget _buildEnergyDetails({
    required int? expression,
    required int? soulUrge,
    required int? personality,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (expression != null)
            _buildNumberRow('Expression', expression, 'Talent & Ausdruck'),
          if (expression != null && soulUrge != null) const SizedBox(height: 12),
          if (soulUrge != null)
            _buildNumberRow('Soul Urge', soulUrge, 'Innere Sehnsucht'),
          if (soulUrge != null && personality != null) const SizedBox(height: 12),
          if (personality != null)
            _buildNumberRow('Personality', personality, 'Äußere Wirkung'),
        ],
      ),
    );
  }

  Widget _buildNumberRow(String label, int number, String meaning) {
    final isMaster = NumerologyCalculator.isMasterNumber(number);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                meaning,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
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
