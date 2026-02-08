/// Archetyp-Mappings für Nuuray Glow
///
/// Hardcoded Mappings für:
/// - Archetyp-Namen (Lebenszahl → Name)
/// - Bazi-Adjektive (Day Master → Adjektiv)
///
/// Basis: docs/architecture/ARCHETYP_SYSTEM.md

/// Archetyp-Namen (Lebenszahl → Name)
///
/// Diese 12 Archetyp-Namen werden aus der Lebenszahl (Life Path Number)
/// abgeleitet und bilden die Haupt-Identität im Archetyp-System.
class ArchetypeNames {
  /// Mapping: Lebenszahl → i18n Key für Archetyp-Namen
  ///
  /// Beispiel:
  /// - 1 → 'pioneer' → DE: "Die Pionierin" / EN: "The Pioneer"
  /// - 8 → 'strategist' → DE: "Die Strategin" / EN: "The Strategist"
  static const Map<int, String> names = {
    1: 'pioneer',        // Unabhängigkeit, Mut, Neuanfang
    2: 'diplomat',       // Harmonie, Empathie, Verbindung
    3: 'creative',       // Ausdruck, Freude, Kommunikation
    4: 'architect',      // Struktur, Bodenhaftung, Aufbau
    5: 'adventurer',     // Freiheit, Wandel, Vielseitigkeit
    6: 'mentor',         // Fürsorge, Heilung, Verantwortung
    7: 'seeker',         // Analyse, Tiefe, Spiritualität
    8: 'strategist',     // Fülle, Macht, Manifestation
    9: 'humanitarian',   // Weisheit, Abschluss, Mitgefühl
    11: 'visionary',     // Inspiration, Intuition (Meisterzahl)
    22: 'master_builder',// Vision in Materie bringen (Meisterzahl)
    33: 'healer',        // Bedingungslose Liebe (Meisterzahl)
  };

  /// Hole i18n Key für Archetyp-Namen
  ///
  /// Returns: i18n Key (z.B. "strategist") oder "unknown" falls nicht gefunden
  static String getNameKey(int lifePathNumber) {
    return names[lifePathNumber] ?? 'unknown';
  }

  /// Prüfe ob Lebenszahl einen validen Archetyp hat
  static bool hasArchetype(int lifePathNumber) {
    return names.containsKey(lifePathNumber);
  }
}

/// Bazi-Adjektive (Day Master → Adjektiv)
///
/// Diese 10 Adjektive werden aus dem Bazi Day Master (Heavenly Stem der Tagessäule)
/// abgeleitet und beschreiben die energetische Qualität.
class BaziAdjectives {
  /// Mapping: Day Master Stem → i18n Key für Bazi-Adjektiv
  ///
  /// Beispiel:
  /// - 'Gui' → 'intuitive' → DE: "Die intuitive" / EN: "The intuitive"
  /// - 'Geng' → 'resolute' → DE: "Die entschlossene" / EN: "The resolute"
  static const Map<String, String> adjectives = {
    // Yang-Holz (甲 Jia) - Wie ein großer Baum
    'Jia': 'steadfast',

    // Yin-Holz (乙 Yi) - Wie eine Ranke
    'Yi': 'adaptable',

    // Yang-Feuer (丙 Bing) - Wie die Sonne
    'Bing': 'radiant',

    // Yin-Feuer (丁 Ding) - Wie eine Kerzenflamme
    'Ding': 'perceptive',

    // Yang-Erde (戊 Wu) - Wie ein Berg
    'Wu': 'grounded',

    // Yin-Erde (己 Ji) - Wie fruchtbare Erde
    'Ji': 'nurturing',

    // Yang-Metall (庚 Geng) - Wie ein Schwert
    'Geng': 'resolute',

    // Yin-Metall (辛 Xin) - Wie ein Juwel
    'Xin': 'refined',

    // Yang-Wasser (壬 Ren) - Wie ein Ozean
    'Ren': 'flowing',

    // Yin-Wasser (癸 Gui) - Wie Morgentau
    'Gui': 'intuitive',
  };

  /// Hole i18n Key für Bazi-Adjektiv
  ///
  /// Returns: i18n Key (z.B. "intuitive") oder "unknown" falls nicht gefunden
  static String getAdjectiveKey(String dayMasterStem) {
    return adjectives[dayMasterStem] ?? 'unknown';
  }

  /// Prüfe ob Day Master ein valides Adjektiv hat
  static bool hasAdjective(String dayMasterStem) {
    return adjectives.containsKey(dayMasterStem);
  }

  /// Alle validen Day Master Stems
  static List<String> get validStems => adjectives.keys.toList();
}
