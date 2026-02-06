import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';

/// Bazi (Vier Säulen) Card
///
/// Zeigt die vier Säulen, Day Master und dominantes Element.
/// Rot-Gradient für erdige, kraftvolle Energie.
class BaziCard extends StatelessWidget {
  final BirthChart birthChart;

  const BaziCard({
    super.key,
    required this.birthChart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFDC143C), // Crimson Red
            Color(0xFF8B4513), // Saddle Brown
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
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
              top: -40,
              right: -40,
              child: Container(
                width: 140,
                height: 140,
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
                        child: const Text(
                          '🐉',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Bazi (四柱)',
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
                    'Vier Säulen des Schicksals',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Day Master (prominent)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Day Master',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${birthChart.baziDayStem}-${birthChart.baziDayBranch}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
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
                          'Jahr',
                          '${birthChart.baziYearStem}-${birthChart.baziYearBranch}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPillarColumn(
                          'Monat',
                          '${birthChart.baziMonthStem}-${birthChart.baziMonthBranch}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPillarColumn(
                          'Tag',
                          '${birthChart.baziDayStem}-${birthChart.baziDayBranch}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPillarColumn(
                          'Stunde',
                          birthChart.baziHourStem != null
                              ? '${birthChart.baziHourStem}-${birthChart.baziHourBranch}'
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
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getElementEmoji(birthChart.baziElement ?? 'Wood') +
                              ' ' +
                              (birthChart.baziElement ?? 'Wood'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
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

  Widget _buildPillarColumn(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
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
        return '🌳';
      case 'fire':
        return '🔥';
      case 'earth':
        return '🏔️';
      case 'metal':
        return '⚙️';
      case 'water':
        return '💧';
      default:
        return '🌟';
    }
  }
}
