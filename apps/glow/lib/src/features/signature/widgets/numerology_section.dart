import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';
import '../../../core/widgets/expandable_card.dart';

/// Numerology Section
///
/// Zeigt Life Path Number und weitere Kern-Zahlen in expandable Cards.
class NumerologySection extends StatelessWidget {
  const NumerologySection({
    required this.numerologyChart,
    super.key,
  });

  final NumerologyChart numerologyChart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16, top: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Numerologie',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Die Zahlen deines Lebens',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Life Path Number Card
        ExpandableCard(
          icon: '🔢',
          title: 'Lebensweg-Zahl ${_formatNumber(numerologyChart.lifePathNumber)}',
          subtitle: 'Dein grundlegender Lebensweg',
          content: _buildNumberContent(
            numerologyChart.lifePathNumber,
            'Die Lebensweg-Zahl zeigt den roten Faden deines Lebens, deine Mission und die Lektionen, '
            'die du hier lernen sollst.',
          ),
        ),

        // Birthday Number Card (falls vorhanden)
        if (numerologyChart.birthdayNumber != null)
          ExpandableCard(
            icon: '🎂',
            title: 'Geburtstags-Zahl ${_formatNumber(numerologyChart.birthdayNumber!)}',
            subtitle: 'Deine natürlichen Talente',
            content: _buildNumberContent(
              numerologyChart.birthdayNumber!,
              'Die Geburtstags-Zahl zeigt deine besonderen Talente und Fähigkeiten, '
              'die du in dieses Leben mitgebracht hast.',
            ),
          ),

        // Soul Urge Number Card (falls vorhanden)
        if (numerologyChart.soulUrgeNumber != null)
          ExpandableCard(
            icon: '💫',
            title: 'Seelenwunsch-Zahl ${_formatNumber(numerologyChart.soulUrgeNumber!)}',
            subtitle: 'Deine inneren Motivationen',
            content: _buildNumberContent(
              numerologyChart.soulUrgeNumber!,
              'Die Seelenwunsch-Zahl zeigt, was dich im Innersten antreibt und was deine Seele sich wünscht.',
            ),
          ),
      ],
    );
  }

  Widget _buildNumberContent(int number, String description) {
    final isMasterNumber = number == 11 || number == 22 || number == 33;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),

        // Master Number Badge (falls zutreffend)
        if (isMasterNumber) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFF5E6D3)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('✨', style: TextStyle(fontSize: 14)),
                SizedBox(width: 6),
                Text(
                  'Meisterzahl',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Beschreibung
        Text(
          description,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            height: 1.6,
          ),
        ),

        const SizedBox(height: 16),

        // Placeholder
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
                  'Detaillierte Zahlenbedeutung folgt in Phase 3',
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

  String _formatNumber(int number) {
    final isMasterNumber = number == 11 || number == 22 || number == 33;
    return isMasterNumber ? '$number ✨' : '$number';
  }
}
