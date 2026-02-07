import 'package:equatable/equatable.dart';

/// Berechnetes Geburts-Chart — Synthese aus westlicher Astrologie, Bazi und Numerologie.
class BirthChart extends Equatable {
  final String userId;

  // Westlich
  final String sunSign;
  final String? moonSign;
  final String? ascendantSign;
  final double? sunDegree;
  final double? moonDegree;
  final double? ascendantDegree;

  // Bazi
  final String? baziYearStem;
  final String? baziYearBranch;
  final String? baziMonthStem;
  final String? baziMonthBranch;
  final String? baziDayStem; // Day Master
  final String? baziDayBranch;
  final String? baziHourStem;
  final String? baziHourBranch;
  final String? baziElement; // Dominantes Element

  // Numerologie - Kern-Zahlen
  final int? lifePathNumber;
  final int? birthdayNumber;
  final int? attitudeNumber;
  final int? personalYear;
  final int? maturityNumber;

  // Numerologie - Birth Energy (Geburtsname)
  final int? birthExpressionNumber;
  final int? birthSoulUrgeNumber;
  final int? birthPersonalityNumber;
  final String? birthName;

  // Numerologie - Current Energy (aktueller Name)
  final int? currentExpressionNumber;
  final int? currentSoulUrgeNumber;
  final int? currentPersonalityNumber;
  final String? currentName;

  // Numerologie - Erweitert (Karmic Debt, Challenges, Lessons, Bridges)
  final int? karmicDebtLifePath;
  final int? karmicDebtExpression;
  final int? karmicDebtSoulUrge;
  final List<int>? challengeNumbers;
  final List<int>? karmicLessons;
  final int? bridgeLifePathExpression;
  final int? bridgeSoulUrgePersonality;

  // Deprecated - für Backward Compatibility
  @Deprecated('Use birthExpressionNumber instead')
  int? get expressionNumber => currentExpressionNumber ?? birthExpressionNumber;

  @Deprecated('Use birthSoulUrgeNumber instead')
  int? get soulUrgeNumber => currentSoulUrgeNumber ?? birthSoulUrgeNumber;

  final DateTime calculatedAt;

  const BirthChart({
    required this.userId,
    required this.sunSign,
    this.moonSign,
    this.ascendantSign,
    this.sunDegree,
    this.moonDegree,
    this.ascendantDegree,
    this.baziYearStem,
    this.baziYearBranch,
    this.baziMonthStem,
    this.baziMonthBranch,
    this.baziDayStem,
    this.baziDayBranch,
    this.baziHourStem,
    this.baziHourBranch,
    this.baziElement,
    this.lifePathNumber,
    this.birthdayNumber,
    this.attitudeNumber,
    this.personalYear,
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
    required this.calculatedAt,
  });

  /// Ob die Geburtszeit bekannt ist (ermöglicht Aszendent + Bazi-Stunde).
  bool get hasBirthTime => ascendantSign != null;

  factory BirthChart.fromJson(Map<String, dynamic> json) {
    return BirthChart(
      userId: json['user_id'] as String,
      sunSign: json['sun_sign'] as String,
      moonSign: json['moon_sign'] as String?,
      ascendantSign: json['ascendant_sign'] as String?,
      sunDegree: (json['sun_degree'] as num?)?.toDouble(),
      moonDegree: (json['moon_degree'] as num?)?.toDouble(),
      ascendantDegree: (json['ascendant_degree'] as num?)?.toDouble(),
      baziYearStem: json['bazi_year_stem'] as String?,
      baziYearBranch: json['bazi_year_branch'] as String?,
      baziMonthStem: json['bazi_month_stem'] as String?,
      baziMonthBranch: json['bazi_month_branch'] as String?,
      baziDayStem: json['bazi_day_stem'] as String?,
      baziDayBranch: json['bazi_day_branch'] as String?,
      baziHourStem: json['bazi_hour_stem'] as String?,
      baziHourBranch: json['bazi_hour_branch'] as String?,
      baziElement: json['bazi_element'] as String?,
      lifePathNumber: json['life_path_number'] as int?,
      birthdayNumber: json['birthday_number'] as int?,
      attitudeNumber: json['attitude_number'] as int?,
      personalYear: json['personal_year'] as int?,
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
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'sun_sign': sunSign,
    'moon_sign': moonSign,
    'ascendant_sign': ascendantSign,
    'sun_degree': sunDegree,
    'moon_degree': moonDegree,
    'ascendant_degree': ascendantDegree,
    'bazi_year_stem': baziYearStem,
    'bazi_year_branch': baziYearBranch,
    'bazi_month_stem': baziMonthStem,
    'bazi_month_branch': baziMonthBranch,
    'bazi_day_stem': baziDayStem,
    'bazi_day_branch': baziDayBranch,
    'bazi_hour_stem': baziHourStem,
    'bazi_hour_branch': baziHourBranch,
    'bazi_element': baziElement,
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
    'calculated_at': calculatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [userId, sunSign, baziDayStem, lifePathNumber];
}
