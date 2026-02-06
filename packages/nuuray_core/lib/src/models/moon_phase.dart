import 'package:equatable/equatable.dart';

/// Die 8 Mondphasen.
enum MoonPhaseName {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent;

  String get keyDe => switch (this) {
    newMoon => 'Neumond',
    waxingCrescent => 'Zunehmende Sichel',
    firstQuarter => 'Erstes Viertel',
    waxingGibbous => 'Zunehmender Mond',
    fullMoon => 'Vollmond',
    waningGibbous => 'Abnehmender Mond',
    lastQuarter => 'Letztes Viertel',
    waningCrescent => 'Abnehmende Sichel',
  };

  String get keyEn => switch (this) {
    newMoon => 'New Moon',
    waxingCrescent => 'Waxing Crescent',
    firstQuarter => 'First Quarter',
    waxingGibbous => 'Waxing Gibbous',
    fullMoon => 'Full Moon',
    waningGibbous => 'Waning Gibbous',
    lastQuarter => 'Last Quarter',
    waningCrescent => 'Waning Crescent',
  };

  String get emoji => switch (this) {
    newMoon => '🌑',
    waxingCrescent => '🌒',
    firstQuarter => '🌓',
    waxingGibbous => '🌔',
    fullMoon => '🌕',
    waningGibbous => '🌖',
    lastQuarter => '🌗',
    waningCrescent => '🌘',
  };

  /// Für DB-Kompatibilität.
  String get dbKey => switch (this) {
    newMoon => 'new_moon',
    waxingCrescent => 'waxing_crescent',
    firstQuarter => 'first_quarter',
    waxingGibbous => 'waxing_gibbous',
    fullMoon => 'full_moon',
    waningGibbous => 'waning_gibbous',
    lastQuarter => 'last_quarter',
    waningCrescent => 'waning_crescent',
  };

  static MoonPhaseName fromDbKey(String key) {
    return MoonPhaseName.values.firstWhere(
      (p) => p.dbKey == key,
      orElse: () => throw ArgumentError('Unbekannte Mondphase: $key'),
    );
  }
}

/// Mondphase für einen bestimmten Tag.
class MoonPhase extends Equatable {
  final DateTime date;
  final MoonPhaseName phase;
  final double illumination; // 0.0 - 1.0
  final String? moonSign; // Zodiac key
  final double? moonDegree;
  final bool isVoidOfCourse;
  final DateTime? voidStart;
  final DateTime? voidEnd;

  const MoonPhase({
    required this.date,
    required this.phase,
    required this.illumination,
    this.moonSign,
    this.moonDegree,
    this.isVoidOfCourse = false,
    this.voidStart,
    this.voidEnd,
  });

  factory MoonPhase.fromJson(Map<String, dynamic> json) {
    return MoonPhase(
      date: DateTime.parse(json['phase_date'] as String),
      phase: MoonPhaseName.fromDbKey(json['phase_name'] as String),
      illumination: (json['illumination'] as num?)?.toDouble() ?? 0.0,
      moonSign: json['moon_sign'] as String?,
      moonDegree: (json['moon_degree'] as num?)?.toDouble(),
      isVoidOfCourse: json['is_void_of_course'] as bool? ?? false,
      voidStart: json['void_start'] != null ? DateTime.parse(json['void_start'] as String) : null,
      voidEnd: json['void_end'] != null ? DateTime.parse(json['void_end'] as String) : null,
    );
  }

  @override
  List<Object?> get props => [date, phase];
}
