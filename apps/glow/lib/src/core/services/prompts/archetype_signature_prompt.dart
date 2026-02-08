/// Prompt-Template für Archetyp-Signatur-Satz
///
/// Generiert einen personalisierten 2-3 Sätze Text, der alle drei
/// astrologischen Systeme (Western, Bazi, Numerologie) zu einer
/// stimmigen Erzählung verwebt.
///
/// Basis: docs/architecture/ARCHETYP_SYSTEM.md Punkt 5
class ArchetypeSignaturePrompt {
  /// Generiere Prompt für Claude API
  ///
  /// Input-Parameter:
  /// - [archetypeName]: Lokalisierter Archetyp-Name (z.B. "Die Strategin")
  /// - [baziAdjective]: Lokalisiertes Bazi-Adjektiv (z.B. "Die intuitive")
  /// - [sunSign]: Sonnenzeichen (z.B. "Sagittarius")
  /// - [moonSign]: Mondzeichen (optional)
  /// - [ascendant]: Aszendent (optional)
  /// - [dayMasterElement]: Day Master Element (z.B. "Yin-Wasser")
  /// - [dominantElement]: Dominantes Element aus Bazi
  /// - [language]: 'DE' oder 'EN'
  ///
  /// Returns: Vollständiger Prompt-Text für Claude API
  ///
  /// Kosten: ~200 Input Tokens + ~80 Output Tokens = ~$0.001 pro Call
  static String generatePrompt({
    required String archetypeName,
    required String baziAdjective,
    required String sunSign,
    String? moonSign,
    String? ascendant,
    required String dayMasterElement,
    required String dominantElement,
    required String language,
  }) {
    final languageName = language.toUpperCase() == 'DE' ? 'Deutsch' : 'English';

    // Optional: Mondzeichen-Zeile nur wenn vorhanden
    final moonSignLine =
        moonSign != null ? 'Mondzeichen: $moonSign\n' : '';

    // Optional: Aszendent-Zeile nur wenn vorhanden
    final ascendantLine =
        ascendant != null ? 'Aszendent: $ascendant\n' : '';

    return '''
Du bist der Texter für Nuuray Glow, eine Astrologie-App für Frauen.

Erstelle einen persönlichen Signatur-Satz (2-3 Sätze, max. 200 Zeichen)
für folgendes Profil:

Archetyp: $archetypeName
Bazi-Energie: $baziAdjective ($dayMasterElement)
Sonnenzeichen: $sunSign
$moonSignLine$ascendantLine
Dominantes Element: $dominantElement

Regeln:
- Verwebe alle drei Systeme zu EINEM stimmigen Satz — keine Auflistung.
- Ton: Warm, staunend, wie eine kluge Freundin die etwas Besonderes entdeckt hat.
- Beginne NICHT mit "Du bist" — das steht bereits darüber als Archetyp-Name.
- Verwende keine Fachbegriffe (kein "Day Master", kein "Bazi", kein "Lebenszahl").
- Sprache: $languageName
- Gib NUR den Signatur-Satz zurück, keine Erklärung, kein Intro.
''';
  }

  /// Beispiel-Prompts für Testing
  static String get exampleDE => generatePrompt(
        archetypeName: 'Die Strategin',
        baziAdjective: 'Die intuitive',
        sunSign: 'Schütze',
        moonSign: 'Waage',
        ascendant: 'Löwe',
        dayMasterElement: 'Yin-Wasser',
        dominantElement: 'Wasser',
        language: 'DE',
      );

  static String get exampleEN => generatePrompt(
        archetypeName: 'The Strategist',
        baziAdjective: 'The intuitive',
        sunSign: 'Sagittarius',
        moonSign: 'Libra',
        ascendant: 'Leo',
        dayMasterElement: 'Yin Water',
        dominantElement: 'Water',
        language: 'EN',
      );
}
