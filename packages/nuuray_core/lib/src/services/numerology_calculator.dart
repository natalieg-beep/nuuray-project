import '../models/numerology_profile.dart';

/// Pythagoräische Numerologie Calculator
///
/// Berechnet die 5 Kernzahlen der Numerologie basierend auf
/// Geburtsdatum und vollständigem Geburtsnamen.
///
/// **Zwei Energie-Profile:**
/// - **Birth Energy**: Geburtsname = unveränderliche Urenergie
/// - **Current Energy**: Aktueller Name = gewählte Identität (bei Namenswechsel)
class NumerologyCalculator {
  /// Pythagoräisches Alphabet-Mapping
  /// Jeder Buchstabe entspricht einer Zahl (1-9)
  static const Map<String, int> _letterValues = {
    'A': 1, 'J': 1, 'S': 1,
    'B': 2, 'K': 2, 'T': 2,
    'C': 3, 'L': 3, 'U': 3,
    'D': 4, 'M': 4, 'V': 4,
    'E': 5, 'N': 5, 'W': 5,
    'F': 6, 'O': 6, 'X': 6,
    'G': 7, 'P': 7, 'Y': 7,
    'H': 8, 'Q': 8, 'Z': 8,
    'I': 9, 'R': 9,
  };

  /// Vokale für Soul Urge Number
  static const Set<String> _vowels = {'A', 'E', 'I', 'O', 'U'};

  /// Berechnet die Lebensweg-Zahl (Life Path Number)
  ///
  /// Die wichtigste Zahl in der Numerologie. Repräsentiert den Lebensweg,
  /// die Hauptlektionen und Herausforderungen.
  ///
  /// Berechnung: Reduktion des Geburtsdatums mit Meisterzahl-Erhalt
  ///
  /// Beispiel: 30.11.1983
  /// → Tag: 3+0 = 3
  /// → Monat: 1+1 = 2
  /// → Jahr: 1+9+8+3 = 21 → 2+1 = 3
  /// → Summe: 3+2+3 = 8
  static int calculateLifePath(DateTime birthDate) {
    final day = _reduceToSingleDigit(birthDate.day);
    final month = _reduceToSingleDigit(birthDate.month);
    final year = _reduceToSingleDigit(_sumDigits(birthDate.year));

    final sum = day + month + year;
    return _reduceToSingleDigit(sum);
  }

  /// Berechnet die Ausdruckszahl (Expression Number)
  ///
  /// Repräsentiert natürliche Talente, Fähigkeiten und die Art,
  /// wie man sich der Welt präsentiert.
  ///
  /// Berechnung: METHODE B - Gesamt-Addition (Meisterzahlen-erhaltend!)
  /// WICHTIG: ALLE Buchstaben summieren, DANN einmal reduzieren!
  ///
  /// Beispiel: "Natalie Frauke Günes"
  /// → Natalie: N+A+T+A+L+I+E = 5+1+2+1+3+9+5 = 26
  /// → Frauke: F+R+A+U+K+E = 6+9+1+3+2+5 = 26
  /// → Günes: G+U+E+N+E+S = 7+3+5+5+5+1 = 26
  /// → GESAMT: 26+26+26 = 78 → 7+8 = 15 → 1+5 = 6
  static int? calculateExpression(String fullName) {
    if (fullName.trim().isEmpty) return null;

    final normalizedName = _normalizeName(fullName);

    // Trenne Namen in Teile (Leerzeichen-getrennt)
    final nameParts = normalizedName.split(' ').where((p) => p.isNotEmpty).toList();

    if (nameParts.isEmpty) return null;

    // METHODE B: Addiere ALLE Buchstaben ohne Zwischenreduktion
    int totalLetterSum = 0;
    for (final part in nameParts) {
      totalLetterSum += _sumLetters(part);
    }

    // Nur EINE Reduktion am Ende (erhält Meisterzahlen!)
    return _reduceToSingleDigit(totalLetterSum);
  }

  /// Berechnet die Seelenzahl (Soul Urge Number)
  ///
  /// Repräsentiert innere Motivationen, Wünsche und was die Seele wirklich will.
  ///
  /// Berechnung: METHODE B - Gesamt-Addition (Meisterzahlen-erhaltend!)
  /// WICHTIG: ALLE Vokale summieren, DANN einmal reduzieren!
  ///
  /// Beispiel: "Natalie Frauke Günes"
  /// → Natalie: A+A+I+E = 1+1+9+5 = 16
  /// → Frauke: A+U+E = 1+3+5 = 9
  /// → Günes: U+E = 3+5 = 8
  /// → GESAMT: 16+9+8 = 33 ✨ (Meisterzahl!)
  ///
  /// vs. Methode A (alt): Pro Teil reduzieren = 7+9+8 = 24 → 6
  /// Methode B ist genauer, weil sie Meisterzahlen in der Gesamtenergie bewahrt!
  static int? calculateSoulUrge(String fullName) {
    if (fullName.trim().isEmpty) return null;

    final normalizedName = _normalizeName(fullName);

    // Trenne Namen in Teile (Leerzeichen-getrennt)
    final nameParts = normalizedName.split(' ').where((p) => p.isNotEmpty).toList();

    if (nameParts.isEmpty) return null;

    // METHODE B: Addiere ALLE Vokale ohne Zwischenreduktion
    int totalVowelSum = 0;
    for (final part in nameParts) {
      final vowelsInPart = part.split('').where((c) => _vowels.contains(c)).join('');
      if (vowelsInPart.isNotEmpty) {
        totalVowelSum += _sumLetters(vowelsInPart);
      }
    }

    // Nur EINE Reduktion am Ende (erhält Meisterzahlen!)
    return _reduceToSingleDigit(totalVowelSum);
  }

  /// Berechnet die Persönlichkeitszahl (Personality Number)
  ///
  /// Repräsentiert die äußere Persönlichkeit, wie andere einen wahrnehmen.
  ///
  /// Berechnung: METHODE B - Gesamt-Addition (Meisterzahlen-erhaltend!)
  /// WICHTIG: ALLE Konsonanten summieren, DANN einmal reduzieren!
  ///
  /// Beispiel: "Natalie Frauke Günes"
  /// → Natalie (Konsonanten): N+T+L = 5+2+3 = 10
  /// → Frauke (Konsonanten): F+R+K = 6+9+2 = 17
  /// → Günes (Konsonanten): G+N+S = 7+5+1 = 13
  /// → GESAMT: 10+17+13 = 40 → 4+0 = 4
  static int? calculatePersonality(String fullName) {
    if (fullName.trim().isEmpty) return null;

    final normalizedName = _normalizeName(fullName);

    // Trenne Namen in Teile (Leerzeichen-getrennt)
    final nameParts = normalizedName.split(' ').where((p) => p.isNotEmpty).toList();

    if (nameParts.isEmpty) return null;

    // METHODE B: Addiere ALLE Konsonanten ohne Zwischenreduktion
    int totalConsonantSum = 0;
    for (final part in nameParts) {
      final consonantsInPart = part.split('').where((c) => !_vowels.contains(c) && _letterValues.containsKey(c)).join('');
      if (consonantsInPart.isNotEmpty) {
        totalConsonantSum += _sumLetters(consonantsInPart);
      }
    }

    // Nur EINE Reduktion am Ende (erhält Meisterzahlen!)
    return _reduceToSingleDigit(totalConsonantSum);
  }

  /// Berechnet die Geburtstagszahl (Birthday Number)
  ///
  /// Der Tag deiner Geburt zeigt spezifische Begabungen und Werkzeuge,
  /// die dir in die Wiege gelegt wurden.
  ///
  /// Berechnung: Einfach der Tag reduziert auf eine Ziffer (1-31 → 1-9/11/22)
  ///
  /// Beispiel: 30 → 3+0 = 3 (Kommunikation & Kreativität)
  static int calculateBirthday(DateTime birthDate) {
    return _reduceToSingleDigit(birthDate.day);
  }

  /// Berechnet die Schicksalszahl / Reifezahl (Destiny/Maturity Number)
  ///
  /// Repräsentiert die Richtung, in die man im Leben reift.
  /// Wird oft in der zweiten Lebenshälfte relevanter (ab 35-45 Jahre).
  ///
  /// Berechnung: Lebensweg + Ausdruckszahl
  ///
  /// Beispiel: Life Path 8 + Expression 6 = 14 → 1+4 = 5
  static int? calculateMaturity({
    required int lifePath,
    required int? expression,
  }) {
    if (expression == null) return null;

    final sum = lifePath + expression;
    return _reduceToSingleDigit(sum);
  }

  /// Alias für calculateMaturity (älterer Name)
  @Deprecated('Use calculateMaturity instead')
  static int? calculateDestiny({
    required int lifePath,
    required int? expression,
  }) {
    return calculateMaturity(lifePath: lifePath, expression: expression);
  }

  /// Berechnet die Attitude Number (Einstellungszahl)
  ///
  /// Zeigt deine grundlegende Einstellung zum Leben und wie du auf andere wirkst.
  /// Wird oft in der ersten Begegnung sichtbar.
  ///
  /// Berechnung: Tag + Monat
  ///
  /// Beispiel: 30.11. → 3+0+1+1 = 5
  static int calculateAttitude(DateTime birthDate) {
    final day = _reduceToSingleDigit(birthDate.day);
    final month = _reduceToSingleDigit(birthDate.month);
    return _reduceToSingleDigit(day + month);
  }

  /// Berechnet das Persönliche Jahr (Personal Year)
  ///
  /// Zeigt die Energie und Themen des aktuellen Jahres für dich.
  /// Ändert sich jedes Jahr am Geburtstag.
  ///
  /// Berechnung: Tag + Monat + Aktuelles Jahr
  ///
  /// Beispiel: 30.11. in 2026 → 3+0+1+1+2+0+2+6 = 15 → 6
  static int calculatePersonalYear(DateTime birthDate, {DateTime? forDate}) {
    final referenceDate = forDate ?? DateTime.now();
    final day = _reduceToSingleDigit(birthDate.day);
    final month = _reduceToSingleDigit(birthDate.month);
    final year = _reduceToSingleDigit(_sumDigits(referenceDate.year));
    return _reduceToSingleDigit(day + month + year);
  }

  // ============================================================
  // KARMIC DEBT NUMBERS (Schuldzahlen: 13, 14, 16, 19)
  // ============================================================

  /// Berechnet Karmic Debt Number für Life Path
  ///
  /// **Konzept:** Schuldzahlen verstecken sich in den Zwischenschritten.
  /// Wenn die Summe VOR der finalen Reduktion 13, 14, 16 oder 19 ist,
  /// trägt die Person eine karmische Schuld aus einem früheren Leben.
  ///
  /// **Bedeutung:**
  /// - **13/4**: Faulheit → Harte Arbeit und Disziplin lernen
  /// - **14/5**: Überindulgenz → Balance und Mäßigung finden
  /// - **16/7**: Ego & Fall → Demut und Spiritualität entwickeln
  /// - **19/1**: Machtmissbrauch → Geben statt Nehmen lernen
  ///
  /// **Berechnung:**
  /// Beispiel: 18.10.1971
  /// → Tag: 1+8 = 9
  /// → Monat: 1+0 = 1
  /// → Jahr: 1+9+7+1 = 18 → 9
  /// → Summe: 9+1+9 = **19** ← Karmic Debt!
  /// → Final: 1+9 = 1 (Life Path = 1 mit Karmic Debt 19)
  static int? calculateKarmicDebtLifePath(DateTime birthDate) {
    final day = _reduceToSingleDigit(birthDate.day);
    final month = _reduceToSingleDigit(birthDate.month);
    final year = _reduceToSingleDigit(_sumDigits(birthDate.year));

    final sum = day + month + year;

    // Prüfe ob Zwischensumme eine Schuldzahl ist
    if (sum == 13 || sum == 14 || sum == 16 || sum == 19) {
      return sum;
    }

    return null;
  }

  /// Berechnet Karmic Debt Number für Expression
  ///
  /// Prüft die Zwischensumme aller Buchstaben VOR der finalen Reduktion.
  ///
  /// **ERWEITERTE PRÜFUNG (Hybrid Methode A + B):**
  /// - Methode B: Gesamtsumme aller Buchstaben (erhält Meisterzahlen)
  /// - Methode A: Summe der reduzierten Namensteile (traditionelle Numerologie)
  ///
  /// Beispiel: "Natalie Frauke Pawlowski"
  /// - Methode B: 26+26+39 = 91 → keine Karmic Debt
  /// - Methode A: (26→8)+(26→8)+(39→3) = 19 → Karmic Debt 19! ⚡
  static int? calculateKarmicDebtExpression(String fullName) {
    if (fullName.trim().isEmpty) return null;

    final normalizedName = _normalizeName(fullName);
    final nameParts = normalizedName.split(' ').where((p) => p.isNotEmpty).toList();

    if (nameParts.isEmpty) return null;

    // METHODE B: Gesamtsumme OHNE finale Reduktion
    int totalSum = 0;
    for (final part in nameParts) {
      totalSum += _sumLetters(part);
    }

    // Prüfe ob Gesamt-Summe eine Schuldzahl ist
    if (totalSum == 13 || totalSum == 14 || totalSum == 16 || totalSum == 19) {
      return totalSum;
    }

    // Prüfe ob Zwischenreduktion eine Schuldzahl ist
    if (totalSum > 19) {
      final reduced = _sumDigits(totalSum);
      if (reduced == 13 || reduced == 14 || reduced == 16 || reduced == 19) {
        return reduced;
      }
    }

    // METHODE A: Summe der reduzierten Teile (traditionelle Methode)
    // Jeder Namensteil wird ERST reduziert, DANN summiert
    int partReducedSum = 0;
    for (final part in nameParts) {
      final partSum = _sumLetters(part);
      partReducedSum += _reduceToSingleDigit(partSum);
    }

    // Prüfe ob Summe der reduzierten Teile eine Schuldzahl ist
    if (partReducedSum == 13 || partReducedSum == 14 || partReducedSum == 16 || partReducedSum == 19) {
      return partReducedSum;
    }

    return null;
  }

  /// Berechnet Karmic Debt Number für Soul Urge
  ///
  /// Prüft die Zwischensumme aller Vokale VOR der finalen Reduktion.
  ///
  /// **ERWEITERTE PRÜFUNG (Hybrid Methode A + B):**
  /// - Methode B: Gesamtsumme aller Vokale (erhält Meisterzahlen)
  /// - Methode A: Summe der reduzierten Vokal-Teile (traditionelle Numerologie)
  static int? calculateKarmicDebtSoulUrge(String fullName) {
    if (fullName.trim().isEmpty) return null;

    final normalizedName = _normalizeName(fullName);
    final nameParts = normalizedName.split(' ').where((p) => p.isNotEmpty).toList();

    if (nameParts.isEmpty) return null;

    // METHODE B: Gesamtsumme der Vokale OHNE finale Reduktion
    int totalVowelSum = 0;
    for (final part in nameParts) {
      final vowelsInPart = part.split('').where((c) => _vowels.contains(c)).join('');
      if (vowelsInPart.isNotEmpty) {
        totalVowelSum += _sumLetters(vowelsInPart);
      }
    }

    // Prüfe ob Gesamt-Summe eine Schuldzahl ist
    if (totalVowelSum == 13 || totalVowelSum == 14 || totalVowelSum == 16 || totalVowelSum == 19) {
      return totalVowelSum;
    }

    // Prüfe ob Zwischenreduktion eine Schuldzahl ist
    if (totalVowelSum > 19) {
      final reduced = _sumDigits(totalVowelSum);
      if (reduced == 13 || reduced == 14 || reduced == 16 || reduced == 19) {
        return reduced;
      }
    }

    // METHODE A: Summe der reduzierten Vokal-Teile (traditionelle Methode)
    int partReducedSum = 0;
    for (final part in nameParts) {
      final vowelsInPart = part.split('').where((c) => _vowels.contains(c)).join('');
      if (vowelsInPart.isNotEmpty) {
        final partSum = _sumLetters(vowelsInPart);
        partReducedSum += _reduceToSingleDigit(partSum);
      }
    }

    // Prüfe ob Summe der reduzierten Teile eine Schuldzahl ist
    if (partReducedSum == 13 || partReducedSum == 14 || partReducedSum == 16 || partReducedSum == 19) {
      return partReducedSum;
    }

    return null;
  }

  // ============================================================
  // CHALLENGE NUMBERS (Herausforderungszahlen)
  // ============================================================

  /// Berechnet die Challenge Numbers (Herausforderungen im Leben)
  ///
  /// **Konzept:** Challenges zeigen Hürden und Lektionen in verschiedenen Lebensphasen.
  /// Sie entstehen durch SUBTRAKTION der Geburtsdaten.
  ///
  /// **Berechnung:** (Beispiel: 15. Mai = 15.05.)
  /// - **Challenge 1** (1. Lebenshälfte): |Tag - Monat| = |6 - 5| = 1
  /// - **Challenge 2** (Jugend): |Tag - Jahr|
  /// - **Challenge 3** (Mittleres Alter): |Challenge1 - Challenge2|
  /// - **Challenge 4** (Reife): |Monat - Jahr|
  ///
  /// **Besonderheit:** Eine "0" als Challenge bedeutet:
  /// - Alle Herausforderungen gleichzeitig ODER
  /// - Sehr alte Seele ohne spezifische Lektionen
  ///
  /// Returns: Liste mit 4 Challenge Numbers [Challenge1, Challenge2, Challenge3, Challenge4]
  static List<int> calculateChallengeNumbers(DateTime birthDate) {
    final day = _reduceToSingleDigit(birthDate.day);
    final month = _reduceToSingleDigit(birthDate.month);
    final year = _reduceToSingleDigit(_sumDigits(birthDate.year));

    // Challenge 1: |Tag - Monat|
    final challenge1 = (day - month).abs();

    // Challenge 2: |Tag - Jahr|
    final challenge2 = (day - year).abs();

    // Challenge 3: |Challenge1 - Challenge2|
    final challenge3 = (challenge1 - challenge2).abs();

    // Challenge 4: |Monat - Jahr|
    final challenge4 = (month - year).abs();

    return [challenge1, challenge2, challenge3, challenge4];
  }

  // ============================================================
  // KARMIC LESSONS (Fehlende Zahlen im Namen)
  // ============================================================

  /// Berechnet die Karmic Lessons (Karmische Lektionen)
  ///
  /// **Konzept:** Karmic Lessons sind Zahlen 1-9, die im vollständigen Namen
  /// NICHT vorkommen. Diese Zahlen repräsentieren Fähigkeiten oder Eigenschaften,
  /// die man in diesem Leben erst lernen muss.
  ///
  /// **Bedeutung der fehlenden Zahlen:**
  /// - **1 fehlt**: Selbstvertrauen und Führung entwickeln
  /// - **2 fehlt**: Diplomatie und Teamwork lernen
  /// - **3 fehlt**: Kreativität und Ausdruck entwickeln
  /// - **4 fehlt**: Disziplin und Struktur aufbauen
  /// - **5 fehlt**: Anpassungsfähigkeit und Flexibilität lernen
  /// - **6 fehlt**: Verantwortung und Fürsorge entwickeln
  /// - **7 fehlt**: Spiritualität und Analyse lernen
  /// - **8 fehlt**: Umgang mit Geld und Macht lernen
  /// - **9 fehlt**: Mitgefühl und Weisheit entwickeln
  ///
  /// **Berechnung:**
  /// Beispiel: "ANNA" → A=1, N=5, N=5, A=1
  /// Vorhanden: {1, 5}
  /// Fehlend: [2, 3, 4, 6, 7, 8, 9]
  ///
  /// Returns: Liste der fehlenden Zahlen (leer wenn alle 1-9 vorhanden)
  static List<int> calculateKarmicLessons(String fullName) {
    if (fullName.trim().isEmpty) return [];

    final normalizedName = _normalizeName(fullName);

    // Zähle welche Zahlen vorkommen
    final presentNumbers = <int>{};

    for (int i = 0; i < normalizedName.length; i++) {
      final char = normalizedName[i];
      if (_letterValues.containsKey(char)) {
        presentNumbers.add(_letterValues[char]!);
      }
    }

    // Finde fehlende Zahlen (1-9)
    final missingNumbers = <int>[];
    for (int number = 1; number <= 9; number++) {
      if (!presentNumbers.contains(number)) {
        missingNumbers.add(number);
      }
    }

    return missingNumbers;
  }

  // ============================================================
  // BRIDGE NUMBERS (Brückenzahlen zwischen Kernzahlen)
  // ============================================================

  /// Berechnet Bridge Number zwischen Life Path und Expression
  ///
  /// **Konzept:** Bridge Numbers zeigen den Weg, wie man zwei Aspekte
  /// seiner Persönlichkeit verbinden kann.
  ///
  /// **Bridge Life Path ↔ Expression:**
  /// Zeigt, wie man sein natürliches Talent (Expression) mit dem
  /// Lebensweg (Life Path) in Einklang bringt.
  ///
  /// **Berechnung:** |Life Path - Expression|
  ///
  /// Beispiel: Life Path 7, Expression 4
  /// → Bridge = |7 - 4| = 3
  /// → Bedeutung: Nutze Kreativität (3) um Weisheit (7) mit Struktur (4) zu verbinden
  static int? calculateBridgeLifePathExpression({
    required int lifePath,
    int? expression,
  }) {
    if (expression == null) return null;
    return (lifePath - expression).abs();
  }

  /// Berechnet Bridge Number zwischen Soul Urge und Personality
  ///
  /// **Konzept:** Zeigt, wie man die Lücke zwischen innerem Wunsch
  /// (Soul Urge) und äußerer Wirkung (Personality) schließt.
  ///
  /// **Berechnung:** |Soul Urge - Personality|
  ///
  /// Beispiel: Soul Urge 33, Personality 4
  /// → Bridge = |33 - 4| = 29 → 11 (Meisterzahl!)
  /// → Bedeutung: Nutze Intuition (11) um innere Heilkraft (33) mit äußerer Stabilität (4) zu verbinden
  static int? calculateBridgeSoulUrgePersonality({
    int? soulUrge,
    int? personality,
  }) {
    if (soulUrge == null || personality == null) return null;
    final diff = (soulUrge - personality).abs();
    return _reduceToSingleDigit(diff);
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Normalisiert einen Namen für numerologische Berechnungen
  ///
  /// - Konvertiert zu GROSSBUCHSTABEN
  /// - Ersetzt Umlaute: Ä→AE, Ö→OE, Ü→UE, ß→SS
  /// - Entfernt Sonderzeichen und Zahlen
  /// - Behält nur A-Z und Leerzeichen
  static String _normalizeName(String name) {
    var normalized = name.toUpperCase();

    // Umlaute ersetzen
    normalized = normalized
        .replaceAll('Ä', 'AE')
        .replaceAll('Ö', 'OE')
        .replaceAll('Ü', 'UE')
        .replaceAll('ß', 'SS');

    // Nur A-Z und Leerzeichen behalten
    return normalized.replaceAll(RegExp(r'[^A-Z ]'), '');
  }

  /// Summiert die Werte aller Buchstaben
  static int _sumLetters(String text) {
    int sum = 0;
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (_letterValues.containsKey(char)) {
        sum += _letterValues[char]!;
      }
    }
    return sum;
  }

  /// Summiert nur die Werte der Vokale
  static int _sumVowels(String text) {
    int sum = 0;
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (_vowels.contains(char) && _letterValues.containsKey(char)) {
        sum += _letterValues[char]!;
      }
    }
    return sum;
  }

  /// Summiert nur die Werte der Konsonanten
  static int _sumConsonants(String text) {
    int sum = 0;
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (!_vowels.contains(char) && _letterValues.containsKey(char)) {
        sum += _letterValues[char]!;
      }
    }
    return sum;
  }

  /// Summiert die Ziffern einer Zahl
  ///
  /// Beispiel: 1983 → 1+9+8+3 = 21
  static int _sumDigits(int number) {
    int sum = 0;
    int remaining = number.abs();

    while (remaining > 0) {
      sum += remaining % 10;
      remaining ~/= 10;
    }

    return sum;
  }

  /// Reduziert eine Zahl auf eine einstellige Zahl (1-9)
  ///
  /// WICHTIG: Meisterzahlen 11, 22, 33 werden NICHT weiter reduziert!
  ///
  /// Beispiel:
  /// - 26 → 2+6 = 8
  /// - 11 → 11 (Meisterzahl, keine weitere Reduktion)
  /// - 29 → 2+9 = 11 (Meisterzahl!)
  static int _reduceToSingleDigit(int number) {
    int current = number;

    while (current > 9) {
      // Prüfe auf Meisterzahlen
      if (current == 11 || current == 22 || current == 33) {
        return current;
      }

      // Ziffern summieren
      current = _sumDigits(current);
    }

    return current;
  }

  /// Prüft ob eine Zahl eine Meisterzahl ist
  ///
  /// Meisterzahlen haben besondere spirituelle Bedeutung:
  /// - 11: Spiritueller Botschafter, Intuition, Erleuchtung
  /// - 22: Meister-Manifestierer, Brückenbauer zwischen Geist und Materie
  /// - 33: Meister-Heiler, kosmische Liebe, Selbstaufopferung
  static bool isMasterNumber(int number) {
    return number == 11 || number == 22 || number == 33;
  }

  // ============================================================
  // COMPLETE NUMEROLOGY PROFILE
  // ============================================================

  /// Berechnet vollständiges Numerologie-Profil mit Birth + Current Energy
  ///
  /// Parameter:
  /// - [birthDate]: Geburtsdatum (für Life Path)
  /// - [birthName]: Vollständiger Geburtsname (Pflicht für Birth Energy)
  /// - [currentName]: Aktueller Name (optional, nur bei Namenswechsel)
  ///
  /// Wenn [currentName] == null oder == [birthName]: Nur Birth Energy wird berechnet
  /// Wenn [currentName] != [birthName]: Beide Energien werden berechnet
  static NumerologyProfile calculateCompleteProfile({
    required DateTime birthDate,
    String? birthName,
    String? currentName,
  }) {
    // Life Path (immer berechenbar, nur vom Datum abhängig)
    final lifePathNumber = calculateLifePath(birthDate);

    // Birth Energy (Geburtsname)
    int? birthExpression;
    int? birthSoulUrge;
    int? birthPersonality;

    if (birthName != null && birthName.trim().isNotEmpty) {
      birthExpression = calculateExpression(birthName);
      birthSoulUrge = calculateSoulUrge(birthName);
      birthPersonality = calculatePersonality(birthName);
    }

    // Current Energy (nur wenn Name sich geändert hat)
    int? currentExpression;
    int? currentSoulUrge;
    int? currentPersonality;

    final hasNameChange = currentName != null &&
        currentName.trim().isNotEmpty &&
        currentName != birthName;

    if (hasNameChange) {
      currentExpression = calculateExpression(currentName);
      currentSoulUrge = calculateSoulUrge(currentName);
      currentPersonality = calculatePersonality(currentName);
    }

    // Birthday Number (immer berechenbar)
    final birthdayNumber = calculateBirthday(birthDate);

    // Attitude Number (immer berechenbar)
    final attitudeNumber = calculateAttitude(birthDate);

    // Personal Year (immer berechenbar)
    final personalYear = calculatePersonalYear(birthDate);

    // Maturity Number (nur wenn Expression vorhanden)
    final activeExpression = hasNameChange ? currentExpression : birthExpression;
    final maturityNumber = activeExpression != null
        ? calculateMaturity(lifePath: lifePathNumber, expression: activeExpression)
        : null;

    // ==========================================
    // KARMIC DEBT NUMBERS
    // ==========================================
    final karmicDebtLifePath = calculateKarmicDebtLifePath(birthDate);
    final karmicDebtExpression = birthName != null ? calculateKarmicDebtExpression(birthName) : null;
    final karmicDebtSoulUrge = birthName != null ? calculateKarmicDebtSoulUrge(birthName) : null;

    // ==========================================
    // CHALLENGE NUMBERS
    // ==========================================
    final challengeNumbers = calculateChallengeNumbers(birthDate);

    // ==========================================
    // KARMIC LESSONS
    // ==========================================
    final karmicLessons = birthName != null ? calculateKarmicLessons(birthName) : null;

    // ==========================================
    // BRIDGE NUMBERS
    // ==========================================
    final bridgeLifePathExpression = activeExpression != null
        ? calculateBridgeLifePathExpression(lifePath: lifePathNumber, expression: activeExpression)
        : null;

    final activeSoulUrge = hasNameChange ? currentSoulUrge : birthSoulUrge;
    final activePersonality = hasNameChange ? currentPersonality : birthPersonality;

    final bridgeSoulUrgePersonality = activeSoulUrge != null && activePersonality != null
        ? calculateBridgeSoulUrgePersonality(soulUrge: activeSoulUrge, personality: activePersonality)
        : null;

    return NumerologyProfile(
      lifePathNumber: lifePathNumber,
      birthdayNumber: birthdayNumber,
      attitudeNumber: attitudeNumber,
      personalYear: personalYear,
      maturityNumber: maturityNumber,
      birthExpressionNumber: birthExpression,
      birthSoulUrgeNumber: birthSoulUrge,
      birthPersonalityNumber: birthPersonality,
      birthName: birthName,
      currentExpressionNumber: currentExpression,
      currentSoulUrgeNumber: currentSoulUrge,
      currentPersonalityNumber: currentPersonality,
      currentName: hasNameChange ? currentName : null,
      karmicDebtLifePath: karmicDebtLifePath,
      karmicDebtExpression: karmicDebtExpression,
      karmicDebtSoulUrge: karmicDebtSoulUrge,
      challengeNumbers: challengeNumbers,
      karmicLessons: karmicLessons,
      bridgeLifePathExpression: bridgeLifePathExpression,
      bridgeSoulUrgePersonality: bridgeSoulUrgePersonality,
    );
  }
}
