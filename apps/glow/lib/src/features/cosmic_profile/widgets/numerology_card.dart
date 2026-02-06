import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';

/// Numerology Card
///
/// Zeigt Life Path, Expression und Soul Urge Numbers.
/// Lila-Gradient für spirituelle, mystische Energie.
class NumerologyCard extends StatelessWidget {
  final BirthChart birthChart;

  const NumerologyCard({
    super.key,
    required this.birthChart,
  });

  @override
  Widget build(BuildContext context) {
    final lifePathNumber = birthChart.lifePathNumber;
    final expressionNumber = birthChart.expressionNumber;
    final soulUrgeNumber = birthChart.soulUrgeNumber;

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
                                  'Life Path Number',
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

                  // Expression & Soul Urge (Side by Side)
                  Row(
                    children: [
                      if (expressionNumber != null)
                        Expanded(
                          child: _buildNumberBox(
                            'Expression',
                            expressionNumber,
                            NumerologyCalculator.isMasterNumber(expressionNumber),
                          ),
                        ),
                      if (expressionNumber != null && soulUrgeNumber != null)
                        const SizedBox(width: 12),
                      if (soulUrgeNumber != null)
                        Expanded(
                          child: _buildNumberBox(
                            'Soul Urge',
                            soulUrgeNumber,
                            NumerologyCalculator.isMasterNumber(soulUrgeNumber),
                          ),
                        ),
                    ],
                  ),

                  // Hinweis wenn keine Namen-Zahlen
                  if (expressionNumber == null && soulUrgeNumber == null)
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

  Widget _buildNumberBox(String label, int number, bool isMaster) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isMaster) ...[
                const SizedBox(width: 4),
                const Text(
                  '✨',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ],
          ),
        ],
      ),
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
