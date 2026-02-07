/// Statische Insights für Bazi & Numerologie (Variante A)
///
/// Diese Texte werden clientseitig gemappt (keine API Calls).
/// Kosten: $0
///
/// Strategie: Kurze, prägnante Sätze die das Profil mit der
/// Tagesenergie verbinden.
class PersonalInsights {
  /// Bazi Day Master Insights (60 Kombinationen)
  ///
  /// Format: {dayMaster: dailyInsight}
  static const Map<String, String> baziInsightsDe = {
    // Yang Holz (甲 Jia)
    '甲木 Yang Wood': 'Deine Yang-Holz-Energie strebt heute nach Wachstum. '
        'Perfekt für neue Projekte und mutige Ideen.',

    // Yin Holz (乙 Yi)
    '乙木 Yin Wood': 'Dein Yin-Holz ist flexibel und anpassungsfähig. '
        'Nutze heute deine Diplomatie in schwierigen Situationen.',

    // Yang Feuer (丙 Bing)
    '丙火 Yang Fire': 'Deine Yang-Feuer-Energie brennt heute besonders hell. '
        'Perfekt für Präsentationen und inspirierende Gespräche.',

    // Yin Feuer (丁 Ding)
    '丁火 Yin Fire': 'Dein Yin-Feuer leuchtet sanft aber beständig. '
        'Nutze heute deine Empathie und emotionale Intelligenz.',

    // Yang Erde (戊 Wu)
    '戊土 Yang Earth': 'Deine Yang-Erde gibt dir heute stabile Kraft. '
        'Ideal um Projekte zu festigen und Verantwortung zu übernehmen.',

    // Yin Erde (己 Ji)
    '己土 Yin Earth': 'Deine Yin-Erde macht dich heute besonders nährend. '
        'Perfekt um andere zu unterstützen und zu pflegen.',

    // Yang Metall (庚 Geng)
    '庚金 Yang Metal': 'Deine Yang-Metall-Energie ist heute kristallklar. '
        'Nutze deine Entschlossenheit für wichtige Entscheidungen.',

    // Yin Metall (辛 Xin)
    '辛金 Yin Metal': 'Dein Yin-Metall schärft heute deine Wahrnehmung. '
        'Ideal für Detailarbeit und ästhetische Projekte.',

    // Yang Wasser (壬 Ren)
    '壬水 Yang Water': 'Deine Yang-Wasser-Energie fließt heute kraftvoll. '
        'Perfekt um Hindernisse zu überwinden und neue Wege zu finden.',

    // Yin Wasser (癸 Gui)
    '癸水 Yin Water': 'Dein Yin-Wasser nährt heute deine Intuition. '
        'Vertraue auf deine inneren Eingebungen und träume groß.',
  };

  /// Numerologie Life Path Insights (1-33)
  static const Map<int, String> numerologyInsightsDe = {
    1: 'Als Life Path 1 bist du heute besonders unabhängig und kraftvoll. '
        'Nutze deine Führungsqualitäten.',

    2: 'Deine Life Path 2 macht dich heute zum perfekten Vermittler. '
        'Harmonie und Zusammenarbeit stehen im Fokus.',

    3: 'Life Path 3 bringt heute kreative Energie. '
        'Drücke dich aus und teile deine Ideen mit der Welt.',

    4: 'Als Life Path 4 profitierst du heute von Struktur. '
        'Plane sorgfältig und baue solide Fundamente.',

    5: 'Deine Life Path 5 liebt heute Abwechslung. '
        'Sei offen für spontane Gelegenheiten und Veränderung.',

    6: 'Life Path 6 ruft heute nach Fürsorge. '
        'Kümmere dich um deine Liebsten und schaffe Harmonie.',

    7: 'Als Life Path 7 suchst du heute nach Tiefe. '
        'Ideal für Reflexion, Lernen und spirituelle Praxis.',

    8: 'Deine Life Path 8 bringt heute manifestierende Kraft. '
        'Perfekt für geschäftliche Entscheidungen und Ziele.',

    9: 'Life Path 9 erinnert dich heute an deine humanitäre Seite. '
        'Diene anderen und teile deine Weisheit großzügig.',

    11: 'Als Meisterzahl 11 bist du heute besonders intuitiv. '
        'Vertraue deiner spirituellen Führung und inspiriere andere.',

    22: 'Deine Meisterzahl 22 gibt dir heute die Kraft des Master Builders. '
        'Verwirkliche große Visionen mit praktischer Weisheit.',

    33: 'Life Path 33 macht dich heute zum Master Teacher. '
        'Heile durch deine Worte und erhebe andere durch dein Sein.',
  };

  /// Element-Emoji für Bazi
  static const Map<String, String> elementEmojis = {
    'Wood': '🌱',
    'Fire': '🔥',
    'Earth': '🌍',
    'Metal': '⚡',
    'Water': '💧',
  };

  /// Numerologie-Emoji
  static String getNumerologyEmoji(int lifePathNumber) {
    if ([11, 22, 33].contains(lifePathNumber)) {
      return '✨'; // Meisterzahlen
    }
    return '🔢';
  }

  /// Hole Bazi Insight für Day Master
  static String getBaziInsight(String dayMaster, {String language = 'de'}) {
    if (language == 'de') {
      return baziInsightsDe[dayMaster] ??
          'Deine einzigartige Bazi-Energie unterstützt dich heute auf besondere Weise.';
    }
    // TODO: Englische Übersetzungen hinzufügen
    return 'Your unique Bazi energy supports you in a special way today.';
  }

  /// Hole Numerologie Insight für Life Path Number
  static String getNumerologyInsight(int lifePathNumber,
      {String language = 'de'}) {
    if (language == 'de') {
      return numerologyInsightsDe[lifePathNumber] ??
          'Deine Life Path Nummer $lifePathNumber bringt heute besondere Energie.';
    }
    // TODO: Englische Übersetzungen hinzufügen
    return 'Your Life Path Number $lifePathNumber brings special energy today.';
  }

  /// Extrahiere Element aus Day Master String
  ///
  /// Beispiel: "丙火 Yang Fire" → "Fire"
  static String? extractElement(String dayMaster) {
    if (dayMaster.contains('Wood')) return 'Wood';
    if (dayMaster.contains('Fire')) return 'Fire';
    if (dayMaster.contains('Earth')) return 'Earth';
    if (dayMaster.contains('Metal')) return 'Metal';
    if (dayMaster.contains('Water')) return 'Water';
    return null;
  }

  /// Hole Element-Emoji
  static String getElementEmoji(String dayMaster) {
    final element = extractElement(dayMaster);
    return element != null ? (elementEmojis[element] ?? '✨') : '✨';
  }
}
