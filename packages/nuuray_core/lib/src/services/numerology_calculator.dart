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
  /// Berechnung: WICHTIG - Pro Namensteil erst reduzieren, DANN summieren!
  ///
  /// Beispiel: "Natalie Frauke Günes"
  /// → Natalie: N+A+T+A+L+I+E = 5+1+2+1+3+9+5 = 26 → 8
  /// → Frauke: F+R+A+U+K+E = 6+9+1+3+2+5 = 26 → 8
  /// → Günes: G+U+E+N+E+S = 7+3+5+5+5+1 = 26 → 8
  /// → SUMME: 8+8+8 = 24 → 6
  static int? calculateExpression(String fullName) {
    if (fullName.trim().isEmpty) return null;

    final normalizedName = _normalizeName(fullName);

    // Trenne Namen in Teile (Leerzeichen-getrennt)
    final nameParts = normalizedName.split(' ').where((p) => p.isNotEmpty).toList();

    if (nameParts.isEmpty) return null;

    // Berechne für jeden Namensteil die Summe und reduziere
    int totalSum = 0;
    for (final part in nameParts) {
      final partSum = _sumLetters(part);
      final reducedPart = _reduceToSingleDigit(partSum);
      totalSum += reducedPart;
    }

    // Jetzt die Gesamtsumme reduzieren (dabei Meisterzahlen beachten!)
    return _reduceToSingleDigit(totalSum);
  }

  /// Berechnet die Seelenzahl (Soul Urge Number)
  ///
  /// Repräsentiert innere Motivationen, Wünsche und was die Seele wirklich will.
  ///
  /// Berechnung: WICHTIG - Pro Namensteil erst reduzieren, DANN summieren!
  ///
  /// Beispiel: "Natalie Frauke Pawlowski"
  /// → Natalie: A+A+I+E = 1+1+9+5 = 16 → 7
  /// → Frauke: A+U+E = 1+3+5 = 9
  /// → Pawlowski: A+O+I = 1+6+9 = 16 → 7
  /// → SUMME: 7+9+7 = 23 → 5
  ///
  /// ABER: Bei Meisterzahlen-Zwischenergebnissen:
  /// → Natalie: 15 → 6
  /// → Frauke: 9
  /// → Pawlowski: 16 → 7
  /// → SUMME: 6+9+7 = 22 ✨ (Meisterzahl!)
  static int? calculateSoulUrge(String fullName) {
    if (fullName.trim().isEmpty) return null;

    final normalizedName = _normalizeName(fullName);

    // Trenne Namen in Teile (Leerzeichen-getrennt)
    final nameParts = normalizedName.split(' ').where((p) => p.isNotEmpty).toList();

    if (nameParts.isEmpty) return null;

    // Berechne für jeden Namensteil die Vokalsumme und reduziere
    int totalSum = 0;
    for (final part in nameParts) {
      final vowelsInPart = part.split('').where((c) => _vowels.contains(c)).join('');
      if (vowelsInPart.isNotEmpty) {
        final partSum = _sumLetters(vowelsInPart);
        final reducedPart = _reduceToSingleDigit(partSum);
        totalSum += reducedPart;
      }
    }

    // Jetzt die Gesamtsumme reduzieren (dabei Meisterzahlen beachten!)
    return _reduceToSingleDigit(totalSum);
  }

  /// Berechnet die Persönlichkeitszahl (Personality Number)
  ///
  /// Repräsentiert die äußere Persönlichkeit, wie andere einen wahrnehmen.
  ///
  /// Berechnung: WICHTIG - Pro Namensteil erst reduzieren, DANN summieren!
  ///
  /// Beispiel: "Natalie Frauke Günes"
  /// → Natalie (Konsonanten): N+T+L = 5+2+3 = 10 → 1
  /// → Frauke (Konsonanten): F+R+K = 6+9+2 = 17 → 8
  /// → Günes (Konsonanten): G+N+S = 7+5+1 = 13 → 4
  /// → SUMME: 1+8+4 = 13 → 4
  static int? calculatePersonality(String fullName) {
    if (fullName.trim().isEmpty) return null;

    final normalizedName = _normalizeName(fullName);

    // Trenne Namen in Teile (Leerzeichen-getrennt)
    final nameParts = normalizedName.split(' ').where((p) => p.isNotEmpty).toList();

    if (nameParts.isEmpty) return null;

    // Berechne für jeden Namensteil die Konsonantensumme und reduziere
    int totalSum = 0;
    for (final part in nameParts) {
      final consonantsInPart = part.split('').where((c) => !_vowels.contains(c) && _letterValues.containsKey(c)).join('');
      if (consonantsInPart.isNotEmpty) {
        final partSum = _sumLetters(consonantsInPart);
        final reducedPart = _reduceToSingleDigit(partSum);
        totalSum += reducedPart;
      }
    }

    // Jetzt die Gesamtsumme reduzieren (dabei Meisterzahlen beachten!)
    return _reduceToSingleDigit(totalSum);
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
    );
  }
}
