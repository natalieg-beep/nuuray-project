/// Dashboard Widget Helpers
///
/// Hilfsfunktionen für die Mini-Widgets auf dem Home Screen Dashboard.
/// Enthält Mappings für:
/// - Western Astrology: Sonnenzeichen → Element
/// - Bazi: Day Master Formatierung, Jahrestier
/// - Numerologie: Life Path → Keywords

/// Western Astrology Element Mapping
enum WesternElement {
  fire,
  earth,
  air,
  water,
}

class DashboardHelpers {
  /// Gibt das Element des Sonnenzeichens zurück
  ///
  /// Mapping:
  /// - Feuer: Widder, Löwe, Schütze
  /// - Erde: Stier, Jungfrau, Steinbock
  /// - Luft: Zwillinge, Waage, Wassermann
  /// - Wasser: Krebs, Skorpion, Fische
  static WesternElement getWesternElement(String zodiacSignKey) {
    switch (zodiacSignKey.toLowerCase()) {
      case 'aries':
      case 'leo':
      case 'sagittarius':
        return WesternElement.fire;

      case 'taurus':
      case 'virgo':
      case 'capricorn':
        return WesternElement.earth;

      case 'gemini':
      case 'libra':
      case 'aquarius':
        return WesternElement.air;

      case 'cancer':
      case 'scorpio':
      case 'pisces':
        return WesternElement.water;

      default:
        return WesternElement.fire; // Fallback
    }
  }

  /// Formatiert den Day Master als "Name · Polarität-Element"
  ///
  /// Beispiel: "Gui" → "Gui · Yin-Wasser"
  static String formatDayMaster(String stem) {
    final info = _stemInfo[stem];
    if (info == null) return stem;

    return '$stem · ${info['polarity']}-${info['element']}';
  }

  /// Mapping: Heavenly Stem → Polarität + Element
  static const Map<String, Map<String, String>> _stemInfo = {
    'Jia': {'polarity': 'Yang', 'element': 'Holz'},
    'Yi': {'polarity': 'Yin', 'element': 'Holz'},
    'Bing': {'polarity': 'Yang', 'element': 'Feuer'},
    'Ding': {'polarity': 'Yin', 'element': 'Feuer'},
    'Wu': {'polarity': 'Yang', 'element': 'Erde'},
    'Ji': {'polarity': 'Yin', 'element': 'Erde'},
    'Geng': {'polarity': 'Yang', 'element': 'Metall'},
    'Xin': {'polarity': 'Yin', 'element': 'Metall'},
    'Ren': {'polarity': 'Yang', 'element': 'Wasser'},
    'Gui': {'polarity': 'Yin', 'element': 'Wasser'},
  };

  /// Gibt das Jahrestier für einen Earthly Branch zurück
  ///
  /// Beispiel: "Snake" → "Schlange" (DE) oder "Snake" (EN)
  static String getYearAnimal(String branch, {required bool isGerman}) {
    final animals = _branchAnimals[branch];
    if (animals == null) return branch;

    return isGerman ? animals['de']! : animals['en']!;
  }

  /// Mapping: Earthly Branch → Tier (DE/EN)
  static const Map<String, Map<String, String>> _branchAnimals = {
    'Rat': {'de': 'Ratte', 'en': 'Rat'},
    'Ox': {'de': 'Büffel', 'en': 'Ox'},
    'Tiger': {'de': 'Tiger', 'en': 'Tiger'},
    'Rabbit': {'de': 'Hase', 'en': 'Rabbit'},
    'Dragon': {'de': 'Drache', 'en': 'Dragon'},
    'Snake': {'de': 'Schlange', 'en': 'Snake'},
    'Horse': {'de': 'Pferd', 'en': 'Horse'},
    'Goat': {'de': 'Ziege', 'en': 'Goat'},
    'Monkey': {'de': 'Affe', 'en': 'Monkey'},
    'Rooster': {'de': 'Hahn', 'en': 'Rooster'},
    'Dog': {'de': 'Hund', 'en': 'Dog'},
    'Pig': {'de': 'Schwein', 'en': 'Pig'},
  };

  /// Gibt die Keywords für eine Life Path Number zurück
  ///
  /// Beispiel: 8 → "Erfolg · Manifestation" (DE) oder "Success · Manifestation" (EN)
  static String getLifePathKeywords(int lifePathNumber,
      {required bool isGerman}) {
    final keywords = _lifePathKeywords[lifePathNumber];
    if (keywords == null) return '';

    return isGerman ? keywords['de']! : keywords['en']!;
  }

  /// Mapping: Life Path Number → Keywords (DE/EN)
  static const Map<int, Map<String, String>> _lifePathKeywords = {
    1: {'de': 'Mut · Neuanfang', 'en': 'Courage · New Beginnings'},
    2: {'de': 'Harmonie · Empathie', 'en': 'Harmony · Empathy'},
    3: {'de': 'Ausdruck · Freude', 'en': 'Expression · Joy'},
    4: {'de': 'Struktur · Aufbau', 'en': 'Structure · Building'},
    5: {'de': 'Freiheit · Wandel', 'en': 'Freedom · Change'},
    6: {'de': 'Fürsorge · Heilung', 'en': 'Nurture · Healing'},
    7: {'de': 'Tiefe · Spiritualität', 'en': 'Depth · Spirituality'},
    8: {'de': 'Erfolg · Manifestation', 'en': 'Success · Manifestation'},
    9: {'de': 'Weisheit · Mitgefühl', 'en': 'Wisdom · Compassion'},
    11: {'de': 'Intuition · Vision', 'en': 'Intuition · Vision'},
    22: {'de': 'Meisterschaft · Aufbau', 'en': 'Mastery · Building'},
    33: {'de': 'Liebe · Heilung', 'en': 'Love · Healing'},
  };

  /// Gibt das passende Emoji für ein Sternzeichen zurück
  static String getZodiacEmoji(String zodiacSignKey) {
    switch (zodiacSignKey.toLowerCase()) {
      case 'aries':
        return '♈';
      case 'taurus':
        return '♉';
      case 'gemini':
        return '♊';
      case 'cancer':
        return '♋';
      case 'leo':
        return '♌';
      case 'virgo':
        return '♍';
      case 'libra':
        return '♎';
      case 'scorpio':
        return '♏';
      case 'sagittarius':
        return '♐';
      case 'capricorn':
        return '♑';
      case 'aquarius':
        return '♒';
      case 'pisces':
        return '♓';
      default:
        return '⭐';
    }
  }

  /// Gibt das passende Emoji für ein Bazi-Element zurück
  static String getBaziElementEmoji(String? element) {
    if (element == null) return '🔥';

    switch (element.toLowerCase()) {
      case 'wood':
      case 'holz':
        return '🌳';
      case 'fire':
      case 'feuer':
        return '🔥';
      case 'earth':
      case 'erde':
        return '⛰️';
      case 'metal':
      case 'metall':
        return '⚙️';
      case 'water':
      case 'wasser':
        return '💧';
      default:
        return '🔥';
    }
  }

  /// Gibt das passende Emoji für ein Jahrestier zurück
  static String getYearAnimalEmoji(String? branch) {
    if (branch == null) return '🐾';

    switch (branch.toLowerCase()) {
      case 'rat':
        return '🐀';
      case 'ox':
        return '🐂';
      case 'tiger':
        return '🐅';
      case 'rabbit':
        return '🐇';
      case 'dragon':
        return '🐉';
      case 'snake':
        return '🐍';
      case 'horse':
        return '🐎';
      case 'goat':
        return '🐐';
      case 'monkey':
        return '🐒';
      case 'rooster':
        return '🐓';
      case 'dog':
        return '🐕';
      case 'pig':
        return '🐖';
      default:
        return '🐾';
    }
  }

  /// Gibt ein großes Zahlen-Emoji zurück (für Life Path)
  static String getNumberEmoji(int? number) {
    if (number == null) return '🔢';

    // Unicode Circle Numbers (1-9, 11, 22, 33 als Text)
    switch (number) {
      case 1:
        return '①';
      case 2:
        return '②';
      case 3:
        return '③';
      case 4:
        return '④';
      case 5:
        return '⑤';
      case 6:
        return '⑥';
      case 7:
        return '⑦';
      case 8:
        return '⑧';
      case 9:
        return '⑨';
      case 11:
        return '⑪'; // Master Number
      case 22:
        return '㉒'; // Master Number
      case 33:
        return '㉝'; // Master Number
      default:
        return '🔢';
    }
  }
}
