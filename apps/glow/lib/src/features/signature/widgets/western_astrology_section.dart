import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';
import '../../../core/widgets/expandable_card.dart';

/// Western Astrology Section
///
/// Zeigt Sonne, Mond, Aszendent in expandable Cards.
class WesternAstrologySection extends StatelessWidget {
  const WesternAstrologySection({
    required this.westernChart,
    super.key,
  });

  final WesternChart westernChart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Westliche Astrologie',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Deine grundlegende kosmische Identität',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Sonne Card
        ExpandableCard(
          icon: '☀️',
          title: '${_getSignName(westernChart.sunSign)} in Sonne',
          subtitle: '${westernChart.sunDegree.toStringAsFixed(1)}° ${_getSignName(westernChart.sunSign)}',
          content: _buildPlaceholderContent(
            'Deine Kern-Identität, Lebenskraft und bewusster Ausdruck. '
            'Die Sonne zeigt, wer du im Innersten bist und wie du in der Welt leuchtest.',
          ),
        ),

        // Mond Card
        ExpandableCard(
          icon: '🌙',
          title: '${_getSignName(westernChart.moonSign)} in Mond',
          subtitle: '${westernChart.moonDegree.toStringAsFixed(1)}° ${_getSignName(westernChart.moonSign)}',
          content: _buildPlaceholderContent(
            'Deine emotionale Natur, Bedürfnisse und innere Welt. '
            'Der Mond zeigt, wie du fühlst und was dich nährt.',
          ),
        ),

        // Aszendent Card
        if (westernChart.risingSign != null)
          ExpandableCard(
            icon: '⬆️',
            title: '${_getSignName(westernChart.risingSign!)} im Aszendent',
            subtitle: '${westernChart.risingDegree?.toStringAsFixed(1) ?? "–"}° ${_getSignName(westernChart.risingSign!)}',
            content: _buildPlaceholderContent(
              'Deine äußere Erscheinung, erste Eindrücke und wie du auf die Welt zugehst. '
              'Der Aszendent ist deine Maske und dein Tor zur Welt.',
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderContent(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Detaillierte Beschreibung aus Content Library folgt in Phase 3',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getSignName(ZodiacSign sign) {
    const signNames = {
      ZodiacSign.aries: 'Widder',
      ZodiacSign.taurus: 'Stier',
      ZodiacSign.gemini: 'Zwillinge',
      ZodiacSign.cancer: 'Krebs',
      ZodiacSign.leo: 'Löwe',
      ZodiacSign.virgo: 'Jungfrau',
      ZodiacSign.libra: 'Waage',
      ZodiacSign.scorpio: 'Skorpion',
      ZodiacSign.sagittarius: 'Schütze',
      ZodiacSign.capricorn: 'Steinbock',
      ZodiacSign.aquarius: 'Wassermann',
      ZodiacSign.pisces: 'Fische',
    };
    return signNames[sign] ?? sign.toString();
  }
}
