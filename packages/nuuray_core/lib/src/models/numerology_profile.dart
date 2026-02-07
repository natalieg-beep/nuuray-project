import 'package:equatable/equatable.dart';

/// Numerologie-Profil mit Birth Energy und Current Energy
///
/// **Spiritueller Kontext:**
/// - **Birth Energy** (Geburtsname): Unveränderliche Urenergie, Schicksal, Seelenpotenzial
/// - **Current Energy** (aktueller Name): Gewählte Identität, aktuelle Lebensphase
///
/// Beide Energien wirken parallel! Bei Namenswechsel (Heirat, etc.) verschiebt sich
/// die Expression & Soul Urge Number, aber die Birth Energy bleibt als Fundament.
class NumerologyProfile extends Equatable {
  /// Life Path Number (unveränderlich, nur vom Geburtsdatum abhängig)
  final int lifePathNumber;

  /// Birthday Number (Tag der Geburt, zeigt spezifische Begabungen)
  final int birthdayNumber;

  /// Attitude Number (Tag + Monat, erste Einstellung/Wirkung)
  final int attitudeNumber;

  /// Maturity Number (Life Path + Expression, wird ab 35-45 Jahren aktiv)
  final int? maturityNumber;

  /// Personal Year (aktuelles Jahr, ändert sich jährlich)
  final int personalYear;

  // ============================================================
  // BIRTH ENERGY (Geburtsname = Urenergie)
  // ============================================================

  /// Expression Number basierend auf Geburtsnamen
  final int? birthExpressionNumber;

  /// Soul Urge Number basierend auf Geburtsnamen
  final int? birthSoulUrgeNumber;

  /// Personality Number basierend auf Geburtsnamen
  final int? birthPersonalityNumber;

  /// Geburtsname, der für die Berechnung verwendet wurde
  final String? birthName;

  // ============================================================
  // CURRENT ENERGY (Aktueller Name = gewählte Identität)
  // ============================================================

  /// Expression Number basierend auf aktuellem Namen
  ///
  /// Nur gefüllt wenn sich der Name geändert hat (z.B. durch Heirat)
  final int? currentExpressionNumber;

  /// Soul Urge Number basierend auf aktuellem Namen
  ///
  /// Nur gefüllt wenn sich der Name geändert hat
  final int? currentSoulUrgeNumber;

  /// Personality Number basierend auf aktuellem Namen
  ///
  /// Nur gefüllt wenn sich der Name geändert hat
  final int? currentPersonalityNumber;

  /// Aktueller Name (nur wenn anders als Geburtsname)
  final String? currentName;

  // ============================================================
  // KARMIC DEBT NUMBERS (Schuldzahlen: 13, 14, 16, 19)
  // ============================================================

  /// Karmic Debt Number für Life Path (falls 13, 14, 16 oder 19)
  ///
  /// Beispiel: 19/1 bedeutet Zwischensumme war 19, reduziert zu 1
  /// 13/4, 14/5, 16/7, 19/1 sind die Schuldzahlen
  final int? karmicDebtLifePath;

  /// Karmic Debt Number für Expression (falls 13, 14, 16 oder 19)
  final int? karmicDebtExpression;

  /// Karmic Debt Number für Soul Urge (falls 13, 14, 16 oder 19)
  final int? karmicDebtSoulUrge;

  // ============================================================
  // CHALLENGE NUMBERS (Herausforderungen)
  // ============================================================

  /// Challenge Numbers zeigen Hürden im Leben (meist 3-4 Phasen)
  ///
  /// Werden durch Subtraktion der Geburtsdaten berechnet
  /// - Challenge 1 (1. Lebenshälfte): |Tag - Monat|
  /// - Challenge 2 (Jugend): |Tag - Jahr|
  /// - Challenge 3 (Mittleres Alter): |Challenge1 - Challenge2|
  /// - Challenge 4 (Reife): |Monat - Jahr|
  final List<int>? challengeNumbers;

  // ============================================================
  // KARMIC LESSONS (Fehlende Zahlen im Namen)
  // ============================================================

  /// Karmic Lessons sind Zahlen 1-9, die im Namen nicht vorkommen
  ///
  /// Beispiel: "Anna" hat nur 1 und 5 → Lessons: [2,3,4,6,7,8,9]
  /// Diese Zahlen repräsentieren Lektionen, die man in diesem Leben lernen muss
  final List<int>? karmicLessons;

  // ============================================================
  // BRIDGE NUMBERS (Brückenzahlen zwischen Kernzahlen)
  // ============================================================

  /// Bridge zwischen Life Path und Expression
  ///
  /// Zeigt den Weg, wie man sein Potenzial (Expression) mit dem Lebensweg verbindet
  /// Berechnung: |Life Path - Expression|
  final int? bridgeLifePathExpression;

  /// Bridge zwischen Soul Urge und Personality
  ///
  /// Zeigt, wie man die Lücke zwischen innerem Wunsch und äußerer Wirkung schließt
  /// Berechnung: |Soul Urge - Personality|
  final int? bridgeSoulUrgePersonality;

  const NumerologyProfile({
    required this.lifePathNumber,
    required this.birthdayNumber,
    required this.attitudeNumber,
    required this.personalYear,
    this.maturityNumber,
    this.birthExpressionNumber,
    this.birthSoulUrgeNumber,
    this.birthPersonalityNumber,
    this.birthName,
    this.currentExpressionNumber,
    this.currentSoulUrgeNumber,
    this.currentPersonalityNumber,
    this.currentName,
    this.karmicDebtLifePath,
    this.karmicDebtExpression,
    this.karmicDebtSoulUrge,
    this.challengeNumbers,
    this.karmicLessons,
    this.bridgeLifePathExpression,
    this.bridgeSoulUrgePersonality,
  });

  /// Hat der User seinen Namen geändert?
  bool get hasNameChange =>
      currentName != null && currentName != birthName && currentName!.isNotEmpty;

  /// Aktive Expression Number (Current falls vorhanden, sonst Birth)
  int? get activeExpressionNumber =>
      hasNameChange ? currentExpressionNumber : birthExpressionNumber;

  /// Aktive Soul Urge Number (Current falls vorhanden, sonst Birth)
  int? get activeSoulUrgeNumber =>
      hasNameChange ? currentSoulUrgeNumber : birthSoulUrgeNumber;

  /// Aktive Personality Number (Current falls vorhanden, sonst Birth)
  int? get activePersonalityNumber =>
      hasNameChange ? currentPersonalityNumber : birthPersonalityNumber;

  /// Aktiver Name (Current falls vorhanden, sonst Birth)
  String? get activeName => hasNameChange ? currentName : birthName;

  @override
  List<Object?> get props => [
        lifePathNumber,
        birthdayNumber,
        attitudeNumber,
        personalYear,
        maturityNumber,
        birthExpressionNumber,
        birthSoulUrgeNumber,
        birthPersonalityNumber,
        birthName,
        currentExpressionNumber,
        currentSoulUrgeNumber,
        currentPersonalityNumber,
        currentName,
        karmicDebtLifePath,
        karmicDebtExpression,
        karmicDebtSoulUrge,
        challengeNumbers,
        karmicLessons,
        bridgeLifePathExpression,
        bridgeSoulUrgePersonality,
      ];

  @override
  String toString() {
    final buffer = StringBuffer('NumerologyProfile(\n');
    buffer.writeln('  Life Path: $lifePathNumber');
    buffer.writeln('  Birthday: $birthdayNumber');
    buffer.writeln('  Attitude: $attitudeNumber');
    buffer.writeln('  Personal Year: $personalYear');
    if (maturityNumber != null) {
      buffer.writeln('  Maturity: $maturityNumber');
    }

    if (birthName != null) {
      buffer.writeln('  Birth Energy ($birthName):');
      buffer.writeln('    Expression: $birthExpressionNumber');
      buffer.writeln('    Soul Urge: $birthSoulUrgeNumber');
      buffer.writeln('    Personality: $birthPersonalityNumber');
    }

    if (hasNameChange) {
      buffer.writeln('  Current Energy ($currentName):');
      buffer.writeln('    Expression: $currentExpressionNumber');
      buffer.writeln('    Soul Urge: $currentSoulUrgeNumber');
      buffer.writeln('    Personality: $currentPersonalityNumber');
    }

    buffer.write(')');
    return buffer.toString();
  }

  /// JSON Serialization
  factory NumerologyProfile.fromJson(Map<String, dynamic> json) {
    return NumerologyProfile(
      lifePathNumber: json['life_path_number'] as int,
      birthdayNumber: json['birthday_number'] as int,
      attitudeNumber: json['attitude_number'] as int,
      personalYear: json['personal_year'] as int,
      maturityNumber: json['maturity_number'] as int?,
      birthExpressionNumber: json['birth_expression_number'] as int?,
      birthSoulUrgeNumber: json['birth_soul_urge_number'] as int?,
      birthPersonalityNumber: json['birth_personality_number'] as int?,
      birthName: json['birth_name'] as String?,
      currentExpressionNumber: json['current_expression_number'] as int?,
      currentSoulUrgeNumber: json['current_soul_urge_number'] as int?,
      currentPersonalityNumber: json['current_personality_number'] as int?,
      currentName: json['current_name'] as String?,
      karmicDebtLifePath: json['karmic_debt_life_path'] as int?,
      karmicDebtExpression: json['karmic_debt_expression'] as int?,
      karmicDebtSoulUrge: json['karmic_debt_soul_urge'] as int?,
      challengeNumbers: (json['challenge_numbers'] as List<dynamic>?)?.cast<int>(),
      karmicLessons: (json['karmic_lessons'] as List<dynamic>?)?.cast<int>(),
      bridgeLifePathExpression: json['bridge_life_path_expression'] as int?,
      bridgeSoulUrgePersonality: json['bridge_soul_urge_personality'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'life_path_number': lifePathNumber,
        'birthday_number': birthdayNumber,
        'attitude_number': attitudeNumber,
        'personal_year': personalYear,
        'maturity_number': maturityNumber,
        'birth_expression_number': birthExpressionNumber,
        'birth_soul_urge_number': birthSoulUrgeNumber,
        'birth_personality_number': birthPersonalityNumber,
        'birth_name': birthName,
        'current_expression_number': currentExpressionNumber,
        'current_soul_urge_number': currentSoulUrgeNumber,
        'current_personality_number': currentPersonalityNumber,
        'current_name': currentName,
        'karmic_debt_life_path': karmicDebtLifePath,
        'karmic_debt_expression': karmicDebtExpression,
        'karmic_debt_soul_urge': karmicDebtSoulUrge,
        'challenge_numbers': challengeNumbers,
        'karmic_lessons': karmicLessons,
        'bridge_life_path_expression': bridgeLifePathExpression,
        'bridge_soul_urge_personality': bridgeSoulUrgePersonality,
      };
}
