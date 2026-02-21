import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuuray_core/nuuray_core.dart';
import '../../../core/widgets/expandable_card.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/language_provider.dart';

/// Bazi Section
///
/// Zeigt Vier Säulen + Day Master mit Content aus Content Library
class BaziSection extends ConsumerWidget {
  const BaziSection({required this.birthChart, super.key});
  final BirthChart birthChart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentService = ref.watch(contentLibraryServiceProvider);
    final locale = ref.watch(currentLocaleProvider);

    // Day Master Key aus Stem + Branch bauen (z.B. "yin_metal_pig")
    String? dayMasterKey;
    if (birthChart.baziDayStem != null && birthChart.baziDayBranch != null) {
      final stemElement = _stemToElementKey(birthChart.baziDayStem!);
      final branch = birthChart.baziDayBranch!.toLowerCase();
      dayMasterKey = '${stemElement}_$branch';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16, top: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chinesisches Bazi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Deine Vier Säulen des Schicksals', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),

        // 1. Vier Säulen Tabelle (OBERHALB von Day Master!)
        if (birthChart.baziYearStem != null) ...[
          _buildFourPillarsTable(),
          const SizedBox(height: 24),
        ],

        // 2. Jahr-Säule (expandable mit Content Library)
        if (birthChart.baziYearStem != null && birthChart.baziYearBranch != null) ...[
          _buildPillarCard(
            contentService: contentService,
            locale: locale,
            category: 'bazi_year_pillar',
            stem: birthChart.baziYearStem!,
            branch: birthChart.baziYearBranch!,
            icon: '📅',
            title: 'Jahr-Säule',
            subtitle: 'Familiäre Wurzeln & öffentliches Image',
          ),
          const SizedBox(height: 12),
        ],

        // 3. Monat-Säule (expandable mit Content Library)
        if (birthChart.baziMonthStem != null && birthChart.baziMonthBranch != null) ...[
          _buildPillarCard(
            contentService: contentService,
            locale: locale,
            category: 'bazi_month_pillar',
            stem: birthChart.baziMonthStem!,
            branch: birthChart.baziMonthBranch!,
            icon: '🌙',
            title: 'Monat-Säule',
            subtitle: 'Karriere & Eltern-Beziehung',
          ),
          const SizedBox(height: 12),
        ],

        // 4. Stunden-Säule (expandable mit Content Library)
        if (birthChart.baziHourStem != null && birthChart.baziHourBranch != null) ...[
          _buildPillarCard(
            contentService: contentService,
            locale: locale,
            category: 'bazi_hour_pillar',
            stem: birthChart.baziHourStem!,
            branch: birthChart.baziHourBranch!,
            icon: '⏰',
            title: 'Stunden-Säule',
            subtitle: 'Kinder & Vermächtnis',
          ),
          const SizedBox(height: 16),
        ],

        // 2. Element Balance
        if (birthChart.baziElement != null) ...[
          _buildElementBalance(),
          const SizedBox(height: 16),
        ],

        // 3. Day Master Card (expandable mit Content Library)
        if (dayMasterKey != null)
          FutureBuilder<String?>(
            future: contentService.getDescription(
              category: 'bazi_day_master',
              key: dayMasterKey,
              locale: locale,
            ),
            builder: (context, snapshot) {
              final description = snapshot.data;

              return ExpandableCard(
                icon: '🐉',
                title: 'Day Master',
                subtitle: _formatDayMaster(dayMasterKey!),
                content: _buildDayMasterContent(description),
              );
            },
          )
        else
          ExpandableCard(
            icon: '🐉',
            title: 'Day Master',
            subtitle: 'Geburtszeit erforderlich',
            content: Text(
              'Für die Bazi-Berechnung wird deine genaue Geburtszeit benötigt. '
              'Bitte ergänze sie in deinem Profil.',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }

  /// Baut eine Säulen-Card (Jahr/Monat/Stunde) mit Content Library
  Widget _buildPillarCard({
    required dynamic contentService,
    required String locale,
    required String category,
    required String stem,
    required String branch,
    required String icon,
    required String title,
    required String subtitle,
  }) {
    // Build key: "yang_water_dog"
    final stemElement = _stemToElementKey(stem);
    final branchKey = branch.toLowerCase();
    final key = '${stemElement}_$branchKey';

    // Format display: "Gui Schwein"
    final displayText = '$stem ${_translateBranch(branchKey)}';

    return FutureBuilder<String?>(
      future: contentService.getDescription(
        category: category,
        key: key,
        locale: locale,
      ),
      builder: (context, snapshot) {
        final description = snapshot.data;

        return ExpandableCard(
          icon: icon,
          title: title,
          subtitle: displayText,
          content: _buildPillarContent(description, subtitle),
        );
      },
    );
  }

  /// Content für Säulen-Cards (Kontext + Beschreibung)
  Widget _buildPillarContent(String? description, String context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kontext (Subtitle als Hint)
        Text(
          context,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const Divider(height: 24),

        // Beschreibung
        if (description != null)
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.6,
            ),
          )
        else
          Text(
            'Lädt Beschreibung...',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  /// Day Master Content (nur Beschreibung, Vier Säulen sind jetzt außerhalb!)
  Widget _buildDayMasterContent(String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        if (description != null)
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.6,
            ),
          )
        else
          Text(
            'Lädt Beschreibung...',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  /// Vier Säulen Tabelle (Jahr/Monat/Tag/Stunde)
  Widget _buildFourPillarsTable() {
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
            'Vier Säulen',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPillar('Jahr', birthChart.baziYearStem, birthChart.baziYearBranch),
              const SizedBox(width: 8),
              _buildPillar('Monat', birthChart.baziMonthStem, birthChart.baziMonthBranch),
              const SizedBox(width: 8),
              _buildPillar('Tag', birthChart.baziDayStem, birthChart.baziDayBranch, isHighlight: true),
              const SizedBox(width: 8),
              _buildPillar('Stunde', birthChart.baziHourStem, birthChart.baziHourBranch),
            ],
          ),
        ],
      ),
    );
  }

  /// Einzelne Säule
  Widget _buildPillar(String label, String? stem, String? branch, {bool isHighlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isHighlight ? const Color(0xFFFFF9E6) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isHighlight
              ? Border.all(color: const Color(0xFFD4AF37), width: 1.5)
              : Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isHighlight ? const Color(0xFFD4AF37) : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            if (stem != null && branch != null) ...[
              Text(
                stem,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isHighlight ? const Color(0xFFD4AF37) : Colors.grey[800],
                ),
              ),
              Text(
                _translateBranch(branch.toLowerCase()),
                style: TextStyle(
                  fontSize: 10,
                  color: isHighlight ? const Color(0xFFD4AF37) : Colors.grey[600],
                ),
              ),
            ] else
              Text(
                '?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Element Balance Visualisierung
  Widget _buildElementBalance() {
    // Zähle Elemente aus allen 8 Stems/Branches
    final elementCounts = _calculateElementBalance();

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
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildElementBar('🌳 Holz', elementCounts['wood'] ?? 0),
          _buildElementBar('🔥 Feuer', elementCounts['fire'] ?? 0),
          _buildElementBar('⛰️ Erde', elementCounts['earth'] ?? 0),
          _buildElementBar('⚙️ Metall', elementCounts['metal'] ?? 0),
          _buildElementBar('💧 Wasser', elementCounts['water'] ?? 0),
        ],
      ),
    );
  }

  /// Einzelner Element-Balken
  Widget _buildElementBar(String label, int count) {
    final maxCount = 3; // Maximum für Visualisierung
    final strength = count / maxCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: strength.clamp(0.0, 1.0),
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getElementColor(label),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              _getStrengthLabel(count),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Berechne Element-Balance aus allen Säulen
  Map<String, int> _calculateElementBalance() {
    final counts = <String, int>{
      'wood': 0,
      'fire': 0,
      'earth': 0,
      'metal': 0,
      'water': 0,
    };

    // Stems zählen (direkt Element)
    final stems = [
      birthChart.baziYearStem,
      birthChart.baziMonthStem,
      birthChart.baziDayStem,
      birthChart.baziHourStem,
    ];

    for (final stem in stems) {
      if (stem == null) continue;
      final element = _stemToElement(stem);
      counts[element] = (counts[element] ?? 0) + 1;
    }

    // Branches zählen (via Hidden Stems - vereinfacht)
    final branches = [
      birthChart.baziYearBranch,
      birthChart.baziMonthBranch,
      birthChart.baziDayBranch,
      birthChart.baziHourBranch,
    ];

    for (final branch in branches) {
      if (branch == null) continue;
      final element = _branchToElement(branch);
      counts[element] = (counts[element] ?? 0) + 1;
    }

    return counts;
  }

  /// Stem → Element (ohne Yang/Yin)
  String _stemToElement(String stem) {
    const map = {
      'Jia': 'wood', 'jia': 'wood',
      'Yi': 'wood', 'yi': 'wood',
      'Bing': 'fire', 'bing': 'fire',
      'Ding': 'fire', 'ding': 'fire',
      'Wu': 'earth', 'wu': 'earth',
      'Ji': 'earth', 'ji': 'earth',
      'Geng': 'metal', 'geng': 'metal',
      'Xin': 'metal', 'xin': 'metal',
      'Ren': 'water', 'ren': 'water',
      'Gui': 'water', 'gui': 'water',
    };
    return map[stem] ?? 'earth';
  }

  /// Branch → Element (primäres Element)
  String _branchToElement(String branch) {
    const map = {
      'Rat': 'water', 'rat': 'water',
      'Ox': 'earth', 'ox': 'earth',
      'Tiger': 'wood', 'tiger': 'wood',
      'Rabbit': 'wood', 'rabbit': 'wood',
      'Dragon': 'earth', 'dragon': 'earth',
      'Snake': 'fire', 'snake': 'fire',
      'Horse': 'fire', 'horse': 'fire',
      'Goat': 'earth', 'goat': 'earth',
      'Monkey': 'metal', 'monkey': 'metal',
      'Rooster': 'metal', 'rooster': 'metal',
      'Dog': 'earth', 'dog': 'earth',
      'Pig': 'water', 'pig': 'water',
    };
    return map[branch] ?? 'earth';
  }

  Color _getElementColor(String label) {
    if (label.contains('Holz')) return const Color(0xFF4CAF50);
    if (label.contains('Feuer')) return const Color(0xFFF44336);
    if (label.contains('Erde')) return const Color(0xFF8D6E63);
    if (label.contains('Metall')) return const Color(0xFF9E9E9E);
    if (label.contains('Wasser')) return const Color(0xFF2196F3);
    return Colors.grey;
  }

  String _getStrengthLabel(int count) {
    if (count == 0) return 'Fehlt';
    if (count == 1) return 'Schwach';
    if (count == 2) return 'Mittel';
    return 'Stark';
  }

  /// Konvertiert Stem-Namen zu yang/yin_element Format
  /// z.B. "Xin" → "yin_metal", "Jia" → "yang_wood"
  String _stemToElementKey(String stem) {
    const stemMap = {
      'Jia': 'yang_wood',   'jia': 'yang_wood',
      'Yi': 'yin_wood',     'yi': 'yin_wood',
      'Bing': 'yang_fire',  'bing': 'yang_fire',
      'Ding': 'yin_fire',   'ding': 'yin_fire',
      'Wu': 'yang_earth',   'wu': 'yang_earth',
      'Ji': 'yin_earth',    'ji': 'yin_earth',
      'Geng': 'yang_metal', 'geng': 'yang_metal',
      'Xin': 'yin_metal',   'xin': 'yin_metal',
      'Ren': 'yang_water',  'ren': 'yang_water',
      'Gui': 'yin_water',   'gui': 'yin_water',
    };
    return stemMap[stem] ?? stem.toLowerCase();
  }

  String _formatDayMaster(String key) {
    // Konvertiere "yin_metal_pig" → "Yin Metall Schwein"
    final parts = key.split('_');
    if (parts.length < 3) return key;

    final polarity = parts[0][0].toUpperCase() + parts[0].substring(1); // Yang/Yin
    final element = _translateElement(parts[1]); // Metal → Metall
    final branch = _translateBranch(parts[2]); // pig → Schwein

    return '$polarity $element $branch';
  }

  String _translateElement(String element) {
    const map = {
      'wood': 'Holz',
      'fire': 'Feuer',
      'earth': 'Erde',
      'metal': 'Metall',
      'water': 'Wasser',
    };
    return map[element] ?? element;
  }

  String _translateBranch(String branch) {
    const map = {
      'rat': 'Ratte',
      'ox': 'Ochse',
      'tiger': 'Tiger',
      'rabbit': 'Hase',
      'dragon': 'Drache',
      'snake': 'Schlange',
      'horse': 'Pferd',
      'goat': 'Ziege',
      'monkey': 'Affe',
      'rooster': 'Hahn',
      'dog': 'Hund',
      'pig': 'Schwein',
    };
    return map[branch] ?? branch;
  }
}
