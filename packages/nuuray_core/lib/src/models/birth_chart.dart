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

  // Numerologie
  final int? lifePathNumber;
  final int? expressionNumber;
  final int? soulUrgeNumber;

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
    this.expressionNumber,
    this.soulUrgeNumber,
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
      expressionNumber: json['expression_number'] as int?,
      soulUrgeNumber: json['soul_urge_number'] as int?,
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
    'expression_number': expressionNumber,
    'soul_urge_number': soulUrgeNumber,
  };

  @override
  List<Object?> get props => [userId, sunSign, baziDayStem, lifePathNumber];
}
