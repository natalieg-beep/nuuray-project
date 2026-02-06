import 'package:equatable/equatable.dart';

/// Tages-Energie — Synthese aus Bazi-Tagesenergie + Planetenständen + Numerologie.
///
/// Wird für Glow (Tageshoroskop), Tide (Phasen-Tipps) und Path (Coaching-Timing) verwendet.
class DailyEnergy extends Equatable {
  final DateTime date;
  final String? baziDayStem;
  final String? baziDayBranch;
  final String dominantElement; // 'holz', 'feuer', 'erde', 'metall', 'wasser'
  final int numerologyDayNumber; // 1-9
  final double overallEnergy; // 0.0 - 1.0 (Synthese aller Faktoren)
  final String energyTendency; // 'aufbauend', 'reflektiv', 'aktiv', 'ruhend', 'transformativ'
  final Map<String, dynamic> metadata;

  const DailyEnergy({
    required this.date,
    this.baziDayStem,
    this.baziDayBranch,
    required this.dominantElement,
    required this.numerologyDayNumber,
    required this.overallEnergy,
    required this.energyTendency,
    this.metadata = const {},
  });

  factory DailyEnergy.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>? ?? {};
    return DailyEnergy(
      date: DateTime.parse(json['content_date'] as String),
      baziDayStem: meta['bazi_day_stem'] as String?,
      baziDayBranch: meta['bazi_day_branch'] as String?,
      dominantElement: meta['dominant_element'] as String? ?? 'erde',
      numerologyDayNumber: meta['numerology_day_number'] as int? ?? 1,
      overallEnergy: (meta['overall_energy'] as num?)?.toDouble() ?? 0.5,
      energyTendency: meta['energy_tendency'] as String? ?? 'reflektiv',
      metadata: meta,
    );
  }

  @override
  List<Object?> get props => [date, dominantElement, numerologyDayNumber];
}
