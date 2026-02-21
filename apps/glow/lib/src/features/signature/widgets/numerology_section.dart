import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuuray_core/nuuray_core.dart';
import '../../../core/widgets/expandable_card.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/language_provider.dart';

/// Numerology Section
///
/// Zeigt Life Path, Soul Urge, Expression Numbers mit Content aus Content Library
class NumerologySection extends ConsumerWidget {
  const NumerologySection({required this.birthChart, super.key});
  final BirthChart birthChart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentService = ref.watch(contentLibraryServiceProvider);
    final locale = ref.watch(currentLocaleProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16, top: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Numerologie', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Die Zahlen deines Lebens', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),

        // === KERN-ZAHLEN ===

        // Life Path Number
        if (birthChart.lifePathNumber != null)
          _buildNumberCard(
            contentService: contentService,
            locale: locale,
            icon: '🛤️',
            category: 'life_path_number',
            number: birthChart.lifePathNumber!,
            title: 'Lebensweg-Zahl',
            subtitle: 'Dein grundlegender Lebensweg',
          ),

        // Birthday Number
        if (birthChart.birthdayNumber != null)
          _buildNumberCard(
            contentService: contentService,
            locale: locale,
            icon: '🎂',
            category: 'birthday_number',
            number: birthChart.birthdayNumber!,
            title: 'Geburtstag-Zahl',
            subtitle: 'Deine natürlichen Talente',
          ),

        // Attitude Number
        if (birthChart.attitudeNumber != null)
          _buildNumberCard(
            contentService: contentService,
            locale: locale,
            icon: '🎭',
            category: 'attitude_number',
            number: birthChart.attitudeNumber!,
            title: 'Haltungs-Zahl',
            subtitle: 'Wie andere dich wahrnehmen',
          ),

        // Personal Year
        if (birthChart.personalYear != null)
          _buildNumberCard(
            contentService: contentService,
            locale: locale,
            icon: '📅',
            category: 'personal_year',
            number: birthChart.personalYear!,
            title: 'Persönliches Jahr',
            subtitle: 'Deine aktuelle Jahresenergie',
          ),

        // Maturity Number
        if (birthChart.maturityNumber != null)
          _buildNumberCard(
            contentService: contentService,
            locale: locale,
            icon: '🌟',
            category: 'maturity_number',
            number: birthChart.maturityNumber!,
            title: 'Reife-Zahl',
            subtitle: 'Dein Potenzial im späteren Leben',
          ),

        // Display Name Number
        if (birthChart.displayNameNumber != null)
          _buildNumberCard(
            contentService: contentService,
            locale: locale,
            icon: '📛',
            category: 'display_name_number',
            number: birthChart.displayNameNumber!,
            title: 'Rufnamen-Zahl',
            subtitle: 'Energie deines Rufnamens',
          ),

        const SizedBox(height: 16),

        // === NAME ENERGIES ===

        // Birth Energy (nur wenn vorhanden)
        if (birthChart.birthExpressionNumber != null ||
            birthChart.birthSoulUrgeNumber != null ||
            birthChart.birthPersonalityNumber != null)
          _buildNameEnergySection(
            context: context,
            contentService: contentService,
            locale: locale,
            title: '🌱 Birth Energy',
            subtitle: 'Energie deines Geburtsnamens${birthChart.birthName != null ? ': ${birthChart.birthName}' : ''}',
            expressionNumber: birthChart.birthExpressionNumber,
            soulUrgeNumber: birthChart.birthSoulUrgeNumber,
            personalityNumber: birthChart.birthPersonalityNumber,
            karmicDebtExpression: birthChart.karmicDebtExpression,
            karmicDebtSoulUrge: birthChart.karmicDebtSoulUrge,
          ),

        // Current Energy (nur wenn unterschiedlich)
        if (birthChart.currentName != null &&
            (birthChart.currentExpressionNumber != null ||
             birthChart.currentSoulUrgeNumber != null ||
             birthChart.currentPersonalityNumber != null))
          _buildNameEnergySection(
            context: context,
            contentService: contentService,
            locale: locale,
            title: '✨ Current Energy',
            subtitle: 'Energie deines aktuellen Namens: ${birthChart.currentName}',
            expressionNumber: birthChart.currentExpressionNumber,
            soulUrgeNumber: birthChart.currentSoulUrgeNumber,
            personalityNumber: birthChart.currentPersonalityNumber,
          ),

        const SizedBox(height: 32),

        // === ERWEITERTE NUMEROLOGIE ===
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Erweiterte Numerologie', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Deine Herausforderungen und Lektionen', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),

        // Karmic Debt Numbers (wenn vorhanden)
        if (birthChart.karmicDebtLifePath != null)
          _buildNumberCard(
            contentService: contentService,
            locale: locale,
            icon: '⚡',
            category: 'karmic_debt',
            number: birthChart.karmicDebtLifePath!,
            title: 'Karmische Schuld',
            subtitle: 'Alte Muster auflösen',
          ),

        // Challenge Numbers (4 Phasen)
        if (birthChart.challengeNumbers != null && birthChart.challengeNumbers!.isNotEmpty)
          _buildChallengesSection(
            contentService: contentService,
            locale: locale,
            challenges: birthChart.challengeNumbers!,
            lifePathNumber: birthChart.lifePathNumber ?? 5,
          ),

        // Karmic Lessons (fehlende Zahlen)
        if (birthChart.karmicLessons != null && birthChart.karmicLessons!.isNotEmpty)
          _buildKarmicLessonsSection(
            contentService: contentService,
            locale: locale,
            lessons: birthChart.karmicLessons!,
          ),

        // Bridge Numbers
        if (birthChart.bridgeLifePathExpression != null)
          _buildNumberCard(
            contentService: contentService,
            locale: locale,
            icon: '🌉',
            category: 'bridge_number',
            number: birthChart.bridgeLifePathExpression!,
            title: 'Brücke',
            subtitle: 'Lebensweg ↔ Ausdruck',
          ),

        if (birthChart.bridgeSoulUrgePersonality != null)
          _buildNumberCard(
            contentService: contentService,
            locale: locale,
            icon: '🌉',
            category: 'bridge_number',
            number: birthChart.bridgeSoulUrgePersonality!,
            title: 'Brücke',
            subtitle: 'Seele ↔ Außen',
          ),
      ],
    );
  }

  Widget _buildNumberCard({
    required dynamic contentService,
    required String locale,
    required String icon,
    required String category,
    required int number,
    required String title,
    required String subtitle,
  }) {
    return FutureBuilder<String?>(
      future: contentService.getDescription(
        category: category,
        key: number.toString(),
        locale: locale,
      ),
      builder: (context, snapshot) {
        final description = snapshot.data;

        return ExpandableCard(
          icon: icon,
          title: '$title $number',
          subtitle: subtitle,
          content: _buildContent(description),
        );
      },
    );
  }

  Widget _buildContent(String? description) {
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

  /// Baut eine expandable Section für Name Energy (Birth oder Current)
  Widget _buildNameEnergySection({
    required BuildContext context,
    required dynamic contentService,
    required String locale,
    required String title,
    required String subtitle,
    int? expressionNumber,
    int? soulUrgeNumber,
    int? personalityNumber,
    int? karmicDebtExpression,
    int? karmicDebtSoulUrge,
  }) {
    return ExpandableCard(
      icon: title.startsWith('🌱') ? '🌱' : '✨',
      title: title,
      subtitle: subtitle,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 24),

          // Expression Number
          if (expressionNumber != null) ...[
            Text(
              'Ausdrucks-Zahl: $expressionNumber',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Karmic Debt Badge (wenn vorhanden)
            if (karmicDebtExpression != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: _buildKarmicDebtBadge(
                  contentService: contentService,
                  locale: locale,
                  number: karmicDebtExpression,
                  type: 'Expression',
                ),
              ),

            FutureBuilder<String?>(
              future: contentService.getDescription(
                category: 'expression_number',
                key: expressionNumber.toString(),
                locale: locale,
              ),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Lädt...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // Soul Urge Number
          if (soulUrgeNumber != null) ...[
            Text(
              'Seelenwunsch-Zahl: $soulUrgeNumber',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Karmic Debt Badge (wenn vorhanden)
            if (karmicDebtSoulUrge != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: _buildKarmicDebtBadge(
                  contentService: contentService,
                  locale: locale,
                  number: karmicDebtSoulUrge,
                  type: 'Soul Urge',
                ),
              ),

            FutureBuilder<String?>(
              future: contentService.getDescription(
                category: 'soul_urge_number',
                key: soulUrgeNumber.toString(),
                locale: locale,
              ),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Lädt...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // Personality Number
          if (personalityNumber != null) ...[
            Text(
              'Persönlichkeits-Zahl: $personalityNumber',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            FutureBuilder<String?>(
              future: contentService.getDescription(
                category: 'personality_number',
                key: personalityNumber.toString(),
                locale: locale,
              ),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Lädt...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Berechnet die Altersgrenze der 4 Challenge-Phasen
  ///
  /// Phasenwechsel = 36 minus Lebenszahl (klassische Numerologie)
  /// - Phase 1: 0 bis (36 - LP)
  /// - Phase 2: (36 - LP) bis (36 - LP + 9)
  /// - Phase 3: (36 - LP + 9) bis (36 - LP + 18)
  /// - Phase 4: (36 - LP + 18) bis Lebensende
  List<String> _getChallengePhaseLabels(int lifePathNumber) {
    // Master Numbers haben eigene Phasengrenzen
    final lp = [11, 22, 33].contains(lifePathNumber) ? (lifePathNumber == 11 ? 2 : lifePathNumber == 22 ? 4 : 6) : lifePathNumber;
    final end1 = 36 - lp;
    final end2 = end1 + 9;
    final end3 = end2 + 9;
    return [
      '0–$end1 Jahre',
      '$end1–$end2 Jahre',
      '$end2–$end3 Jahre',
      'Ab $end3 Jahren',
    ];
  }

  /// Challenges Section (4 Phasen mit Altersangaben als expandable Card)
  Widget _buildChallengesSection({
    required dynamic contentService,
    required String locale,
    required List<int> challenges,
    required int lifePathNumber,
  }) {
    final phaseLabels = _getChallengePhaseLabels(lifePathNumber);
    final phaseDescriptions = [
      'Jugend & Aufbruch',
      'Aufbau & Karriere',
      'Mittleres Alter & Reife',
      'Weisheit & Ernte',
    ];

    return ExpandableCard(
      icon: '🎯',
      title: 'Challenges',
      subtitle: 'Herausforderungen in 4 Lebensphasen',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 24),
          // 4 Phasen als Chips mit Content
          ...List.generate(challenges.length > 4 ? 4 : challenges.length, (index) {
            final challenge = challenges[index];
            final ageRange = index < phaseLabels.length ? phaseLabels[index] : 'Phase ${index + 1}';
            final phaseName = index < phaseDescriptions.length ? phaseDescriptions[index] : '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(
                        label: Text(ageRange),
                        backgroundColor: Colors.grey[200],
                        labelStyle: const TextStyle(fontSize: 11),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      Chip(
                        label: Text('$challenge'),
                        backgroundColor: Colors.orange[100],
                        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      if (phaseName.isNotEmpty)
                        Text(
                          phaseName,
                          style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<String?>(
                    future: contentService.getDescription(
                      category: 'challenge_number',
                      key: challenge.toString(),
                      locale: locale,
                    ),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? 'Lädt...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Karmic Lessons Section (fehlende Zahlen)
  Widget _buildKarmicLessonsSection({
    required dynamic contentService,
    required String locale,
    required List<int> lessons,
  }) {
    return ExpandableCard(
      icon: '📚',
      title: 'Karmic Lessons',
      subtitle: 'Zu lernende Lektionen (${lessons.length} Zahlen)',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 24),
          // Zeige fehlende Zahlen als Badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: lessons.map((lesson) {
              return Chip(
                label: Text('$lesson'),
                backgroundColor: Colors.amber[100],
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Lade Beschreibung für erste Lektion
          if (lessons.isNotEmpty)
            FutureBuilder<String?>(
              future: contentService.getDescription(
                category: 'karmic_lesson',
                key: lessons.first.toString(),
                locale: locale,
              ),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? 'Lädt...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Baut ein Karmic Debt Badge mit Icon, Nummer und Beschreibung
  Widget _buildKarmicDebtBadge({
    required dynamic contentService,
    required String locale,
    required int number,
    required String type,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '⚡',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'Karmische Schuld $number ($type)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<String?>(
            future: contentService.getDescription(
              category: 'karmic_debt',
              key: number.toString(),
              locale: locale,
            ),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'Lädt...',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
