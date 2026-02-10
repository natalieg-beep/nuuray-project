import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';
import '../../../core/widgets/expandable_card.dart';

/// Bazi Section
///
/// Zeigt Day Master und optional die Vier Säulen in expandable Cards.
class BaziSection extends StatelessWidget {
  const BaziSection({
    required this.baziChart,
    super.key,
  });

  final BaziChart baziChart;

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
                'Chinesisches Bazi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Deine Vier Säulen des Schicksals',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Day Master Card
        ExpandableCard(
          icon: _getDayMasterIcon(baziChart.dayMaster.earthlyBranch),
          title: _getDayMasterName(baziChart.dayMaster),
          subtitle: 'Tag-Meister • ${_getElementName(baziChart.dayMaster.heavenlyStem.element)}',
          content: _buildDayMasterContent(),
        ),
      ],
    );
  }

  Widget _buildDayMasterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),

        // Element-Balance Anzeige
        _buildElementBalance(),

        const SizedBox(height: 16),

        // Beschreibung
        Text(
          'Der Day Master ist der Kern deiner Bazi-Persönlichkeit. Er zeigt deine innere Natur, '
          'deine Stärken und wie du mit der Welt interagierst.',
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
                  'Detaillierte Day Master Beschreibung folgt in Phase 3',
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

  Widget _buildElementBalance() {
    final balance = baziChart.elementBalance;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Element-Balance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          _buildElementRow('Holz 🌳', balance.wood, const Color(0xFF4A7C59)),
          _buildElementRow('Feuer 🔥', balance.fire, const Color(0xFFD32F2F)),
          _buildElementRow('Erde 🏔️', balance.earth, const Color(0xFF8B6F47)),
          _buildElementRow('Metall ⚙️', balance.metal, const Color(0xFF9E9E9E)),
          _buildElementRow('Wasser 💧', balance.water, const Color(0xFF1976D2)),
        ],
      ),
    );
  }

  Widget _buildElementRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: count / 8, // Max 8
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayMasterName(BaziDayMaster dayMaster) {
    final stem = _getStemName(dayMaster.heavenlyStem);
    final branch = _getBranchName(dayMaster.earthlyBranch);
    return '$stem $branch';
  }

  String _getStemName(HeavenlyStem stem) {
    final polarityMap = {
      Polarity.yang: 'Yang',
      Polarity.yin: 'Yin',
    };
    final elementMap = {
      Element.wood: 'Holz',
      Element.fire: 'Feuer',
      Element.earth: 'Erde',
      Element.metal: 'Metall',
      Element.water: 'Wasser',
    };
    return '${polarityMap[stem.polarity]} ${elementMap[stem.element]}';
  }

  String _getBranchName(EarthlyBranch branch) {
    const branchNames = {
      EarthlyBranch.rat: 'Ratte',
      EarthlyBranch.ox: 'Büffel',
      EarthlyBranch.tiger: 'Tiger',
      EarthlyBranch.rabbit: 'Hase',
      EarthlyBranch.dragon: 'Drache',
      EarthlyBranch.snake: 'Schlange',
      EarthlyBranch.horse: 'Pferd',
      EarthlyBranch.goat: 'Ziege',
      EarthlyBranch.monkey: 'Affe',
      EarthlyBranch.rooster: 'Hahn',
      EarthlyBranch.dog: 'Hund',
      EarthlyBranch.pig: 'Schwein',
    };
    return branchNames[branch] ?? branch.toString();
  }

  String _getElementName(Element element) {
    const elementNames = {
      Element.wood: 'Holz',
      Element.fire: 'Feuer',
      Element.earth: 'Erde',
      Element.metal: 'Metall',
      Element.water: 'Wasser',
    };
    return elementNames[element] ?? element.toString();
  }

  String _getDayMasterIcon(EarthlyBranch branch) {
    const icons = {
      EarthlyBranch.rat: '🐭',
      EarthlyBranch.ox: '🐂',
      EarthlyBranch.tiger: '🐯',
      EarthlyBranch.rabbit: '🐰',
      EarthlyBranch.dragon: '🐉',
      EarthlyBranch.snake: '🐍',
      EarthlyBranch.horse: '🐴',
      EarthlyBranch.goat: '🐐',
      EarthlyBranch.monkey: '🐵',
      EarthlyBranch.rooster: '🐔',
      EarthlyBranch.dog: '🐕',
      EarthlyBranch.pig: '🐷',
    };
    return icons[branch] ?? '✨';
  }
}
