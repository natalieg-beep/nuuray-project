import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuuray_core/nuuray_core.dart';
import '../../../core/widgets/expandable_card.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/language_provider.dart';

/// Bazi Section
///
/// Zeigt Vier Säulen + Element-Balance + Day Master + Synthese + Säulen-Details
/// Reihenfolge: Vier Säulen → Element-Balance → Day Master → Synthese → Details
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

        // 1. Vier Säulen Tabelle
        if (birthChart.baziYearStem != null) ...[
          _buildFourPillarsTable(),
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

        const SizedBox(height: 16),

        // 4. Bazi-Synthese (alle Säulen zusammen)
        if (birthChart.baziDayStem != null) ...[
          _buildBaziSynthesis(),
          const SizedBox(height: 16),
        ],

        // 5. Jahr-Säule (expandable mit Content Library)
        if (birthChart.baziYearStem != null && birthChart.baziYearBranch != null) ...[
          _buildPillarCard(
            contentService: contentService,
            locale: locale,
            category: 'bazi_year_pillar',
            stem: birthChart.baziYearStem!,
            branch: birthChart.baziYearBranch!,
            icon: '📅',
            title: 'Jahr-Säule',
            subtitle: 'Familiäre Wurzeln & öffentliches Image · 0–15 Jahre',
          ),
          const SizedBox(height: 12),
        ],

        // 6. Monat-Säule (expandable mit Content Library)
        if (birthChart.baziMonthStem != null && birthChart.baziMonthBranch != null) ...[
          _buildPillarCard(
            contentService: contentService,
            locale: locale,
            category: 'bazi_month_pillar',
            stem: birthChart.baziMonthStem!,
            branch: birthChart.baziMonthBranch!,
            icon: '🌙',
            title: 'Monat-Säule',
            subtitle: 'Karriere & Eltern-Beziehung · 15–30 Jahre',
          ),
          const SizedBox(height: 12),
        ],

        // 7. Stunden-Säule (expandable mit Content Library)
        if (birthChart.baziHourStem != null && birthChart.baziHourBranch != null) ...[
          _buildPillarCard(
            contentService: contentService,
            locale: locale,
            category: 'bazi_hour_pillar',
            stem: birthChart.baziHourStem!,
            branch: birthChart.baziHourBranch!,
            icon: '⏰',
            title: 'Stunden-Säule',
            subtitle: 'Kinder & Vermächtnis · 60+ Jahre',
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  /// Bazi-Synthese: Kurze Zusammenfassung aller 4 Säulen
  Widget _buildBaziSynthesis() {
    // Baue einen kompakten Überblick der Spannungen/Synergien
    final dayStem = birthChart.baziDayStem;
    final dayBranch = birthChart.baziDayBranch;
    final yearStem = birthChart.baziYearStem;
    final monthStem = birthChart.baziMonthStem;

    if (dayStem == null) return const SizedBox.shrink();

    final dayElement = _translateElement(_stemToElement(dayStem));
    final dayPolarity = _stemToPolarity(dayStem);
    final dayBranchDe = dayBranch != null ? _translateBranch(dayBranch.toLowerCase()) : '';

    // Erkenne dominantes Element
    final elementCounts = _calculateElementBalance();
    final dominantEntry = elementCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    final dominantElement = _translateElement(dominantEntry.key);

    // Erkenne Spannungen (z.B. Day Master Feuer, aber dominantes Element Wasser)
    final dayElementRaw = _stemToElement(dayStem);
    final hasTension = dominantEntry.key != dayElementRaw && dominantEntry.value >= 2;

    String synthesisText;
    if (hasTension) {
      synthesisText =
          'Du bist ein $dayPolarity-$dayElement Day Master ($dayStem–$dayBranchDe) — '
          'das ist dein Kern, dein "Ich". '
          'Gleichzeitig dominiert $dominantElement dein Chart mit ${dominantEntry.value} Vorkommen. '
          'Diese Spannung zwischen deinem $dayElement-Kern und der $dominantElement-Dominanz '
          'ist kein Widerspruch — sie ist dein Motor. '
          'Der Schlüssel liegt darin, beide Energien bewusst zu nutzen statt gegen sie zu kämpfen.';
    } else {
      synthesisText =
          'Du bist ein $dayPolarity-$dayElement Day Master ($dayStem–$dayBranchDe) — '
          'das ist dein Kern, dein "Ich". '
          'Dein Chart wird von $dominantElement (${dominantEntry.value}×) unterstützt — '
          'diese Energie fließt natürlich durch alle Lebensbereiche. '
          '${yearStem != null && monthStem != null ? 'Jahr- und Monat-Säule ergänzen deinen Day Master auf ihre eigene Art.' : ''}';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Deine Bazi-Synthese',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            synthesisText,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.6,
            ),
          ),
        ],
      ),
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
    final stemElement = _stemToElementKey(stem);
    final branchKey = branch.toLowerCase();
    final key = '${stemElement}_$branchKey';

    // Format: "Gui · Yin-Wasser · Schwein"
    final polarity = _stemToPolarity(stem);
    final element = _translateElement(_stemToElement(stem));
    final branchDe = _translateBranch(branchKey);
    final displayText = '$stem · $polarity-$element · $branchDe';

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

  /// Content für Säulen-Cards
  Widget _buildPillarContent(String? description, String context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const Divider(height: 24),
        if (description != null)
          Text(
            description,
            style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.6),
          )
        else
          Text(
            'Lädt Beschreibung...',
            style: TextStyle(fontSize: 15, color: Colors.grey[500], fontStyle: FontStyle.italic),
          ),
      ],
    );
  }

  /// Day Master Content
  Widget _buildDayMasterContent(String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        if (description != null)
          Text(
            description,
            style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.6),
          )
        else
          Text(
            'Lädt Beschreibung...',
            style: TextStyle(fontSize: 15, color: Colors.grey[500], fontStyle: FontStyle.italic),
          ),
      ],
    );
  }

  /// Vier Säulen Tabelle — jetzt MIT deutschen Element-Namen
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

  /// Einzelne Säule — jetzt mit Element-Zeile
  Widget _buildPillar(String label, String? stem, String? branch, {bool isHighlight = false}) {
    final highlightColor = const Color(0xFFD4AF37);
    final textColor = isHighlight ? highlightColor : Colors.grey[800]!;
    final subtextColor = isHighlight ? highlightColor.withOpacity(0.8) : Colors.grey[600]!;

    // Element-Label bauen: z.B. "Yang-Feuer"
    String? elementLabel;
    if (stem != null) {
      final polarity = _stemToPolarity(stem);
      final element = _translateElement(_stemToElement(stem));
      elementLabel = '$polarity-$element';
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isHighlight ? const Color(0xFFFFF9E6) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isHighlight
              ? Border.all(color: highlightColor, width: 1.5)
              : Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            // Label (Jahr/Monat/Tag/Stunde)
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isHighlight ? highlightColor : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            if (stem != null && branch != null) ...[
              // Chinesischer Stem-Name (Bing, Jia, etc.)
              Text(
                stem,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              // Deutsches Element (Yang-Feuer, Yin-Holz, etc.)
              Text(
                elementLabel ?? '',
                style: TextStyle(
                  fontSize: 9,
                  color: subtextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              // Branch (Tier)
              Text(
                _translateBranch(branch.toLowerCase()),
                style: TextStyle(
                  fontSize: 10,
                  color: subtextColor,
                ),
              ),
            ] else
              Text('?', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }

  /// Element Balance Visualisierung
  Widget _buildElementBalance() {
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
    const maxCount = 3;
    final strength = count / maxCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
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
              style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Berechne Element-Balance aus allen Säulen
  Map<String, int> _calculateElementBalance() {
    final counts = <String, int>{
      'wood': 0, 'fire': 0, 'earth': 0, 'metal': 0, 'water': 0,
    };

    for (final stem in [
      birthChart.baziYearStem,
      birthChart.baziMonthStem,
      birthChart.baziDayStem,
      birthChart.baziHourStem,
    ]) {
      if (stem == null) continue;
      final element = _stemToElement(stem);
      counts[element] = (counts[element] ?? 0) + 1;
    }

    for (final branch in [
      birthChart.baziYearBranch,
      birthChart.baziMonthBranch,
      birthChart.baziDayBranch,
      birthChart.baziHourBranch,
    ]) {
      if (branch == null) continue;
      final element = _branchToElement(branch);
      counts[element] = (counts[element] ?? 0) + 1;
    }

    return counts;
  }

  // ── Helper-Methoden ──────────────────────────────────────────────────────

  String _stemToElement(String stem) {
    const map = {
      'Jia': 'wood', 'jia': 'wood', 'Yi': 'wood', 'yi': 'wood',
      'Bing': 'fire', 'bing': 'fire', 'Ding': 'fire', 'ding': 'fire',
      'Wu': 'earth', 'wu': 'earth', 'Ji': 'earth', 'ji': 'earth',
      'Geng': 'metal', 'geng': 'metal', 'Xin': 'metal', 'xin': 'metal',
      'Ren': 'water', 'ren': 'water', 'Gui': 'water', 'gui': 'water',
    };
    return map[stem] ?? 'earth';
  }

  String _stemToPolarity(String stem) {
    const yangStems = {'Jia', 'jia', 'Bing', 'bing', 'Wu', 'wu', 'Geng', 'geng', 'Ren', 'ren'};
    return yangStems.contains(stem) ? 'Yang' : 'Yin';
  }

  String _branchToElement(String branch) {
    const map = {
      'Rat': 'water', 'rat': 'water', 'Ox': 'earth', 'ox': 'earth',
      'Tiger': 'wood', 'tiger': 'wood', 'Rabbit': 'wood', 'rabbit': 'wood',
      'Dragon': 'earth', 'dragon': 'earth', 'Snake': 'fire', 'snake': 'fire',
      'Horse': 'fire', 'horse': 'fire', 'Goat': 'earth', 'goat': 'earth',
      'Monkey': 'metal', 'monkey': 'metal', 'Rooster': 'metal', 'rooster': 'metal',
      'Dog': 'earth', 'dog': 'earth', 'Pig': 'water', 'pig': 'water',
    };
    return map[branch] ?? 'earth';
  }

  String _stemToElementKey(String stem) {
    const stemMap = {
      'Jia': 'yang_wood', 'jia': 'yang_wood', 'Yi': 'yin_wood', 'yi': 'yin_wood',
      'Bing': 'yang_fire', 'bing': 'yang_fire', 'Ding': 'yin_fire', 'ding': 'yin_fire',
      'Wu': 'yang_earth', 'wu': 'yang_earth', 'Ji': 'yin_earth', 'ji': 'yin_earth',
      'Geng': 'yang_metal', 'geng': 'yang_metal', 'Xin': 'yin_metal', 'xin': 'yin_metal',
      'Ren': 'yang_water', 'ren': 'yang_water', 'Gui': 'yin_water', 'gui': 'yin_water',
    };
    return stemMap[stem] ?? stem.toLowerCase();
  }

  String _formatDayMaster(String key) {
    final parts = key.split('_');
    if (parts.length < 3) return key;
    final polarity = parts[0][0].toUpperCase() + parts[0].substring(1);
    final element = _translateElement(parts[1]);
    final branch = _translateBranch(parts[2]);
    return '$polarity-$element · $branch';
  }

  String _translateElement(String element) {
    const map = {
      'wood': 'Holz', 'fire': 'Feuer', 'earth': 'Erde',
      'metal': 'Metall', 'water': 'Wasser',
    };
    return map[element] ?? element;
  }

  String _translateBranch(String branch) {
    const map = {
      'rat': 'Ratte', 'ox': 'Ochse', 'tiger': 'Tiger', 'rabbit': 'Hase',
      'dragon': 'Drache', 'snake': 'Schlange', 'horse': 'Pferd', 'goat': 'Ziege',
      'monkey': 'Affe', 'rooster': 'Hahn', 'dog': 'Hund', 'pig': 'Schwein',
    };
    return map[branch] ?? branch;
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
}
