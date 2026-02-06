import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';

/// Western Astrology Card
///
/// Zeigt Sonne, Mond, Aszendent mit Symbolen und Graden.
/// Gold-Gradient für warme, sonnige Energie.
class WesternAstrologyCard extends StatelessWidget {
  final BirthChart birthChart;

  const WesternAstrologyCard({
    super.key,
    required this.birthChart,
  });

  @override
  Widget build(BuildContext context) {
    // Sternzeichen-Objekte laden
    final sunSign = ZodiacSign.fromKey(birthChart.sunSign);
    final moonSign = birthChart.moonSign != null
        ? ZodiacSign.fromKey(birthChart.moonSign!)
        : null;
    final ascendantSign = birthChart.ascendantSign != null
        ? ZodiacSign.fromKey(birthChart.ascendantSign!)
        : null;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD700), // Gold
            Color(0xFFFFB347), // Orange-Gold
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
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
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
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
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.wb_sunny_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Western Astrology',
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
                    'Deine Planetenpositionen',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sonne
                  _buildPlanetRow(
                    symbol: sunSign.symbol,
                    label: 'Sonne',
                    sign: sunSign.nameDe,
                    degree: birthChart.sunDegree,
                  ),

                  const SizedBox(height: 16),

                  // Mond
                  if (moonSign != null)
                    _buildPlanetRow(
                      symbol: moonSign.symbol,
                      label: 'Mond',
                      sign: moonSign.nameDe,
                      degree: birthChart.moonDegree,
                    ),

                  if (moonSign != null) const SizedBox(height: 16),

                  // Aszendent
                  if (ascendantSign != null)
                    _buildPlanetRow(
                      symbol: ascendantSign.symbol,
                      label: 'Aszendent',
                      sign: ascendantSign.nameDe,
                      degree: birthChart.ascendantDegree,
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

  Widget _buildPlanetRow({
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
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                sign,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${degree.toStringAsFixed(2)}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
