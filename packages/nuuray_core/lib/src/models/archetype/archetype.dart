import 'package:equatable/equatable.dart';
import 'archetype_mappings.dart';

/// Archetyp-Model: Kombination aus Name, Adjektiv und Signatur-Satz
///
/// Der Archetyp ist die persönliche Identität einer Nutzerin in Nuuray Glow.
/// Er besteht aus drei Komponenten:
/// 1. Name (aus Lebenszahl) - z.B. "Die Strategin"
/// 2. Adjektiv (aus Bazi Day Master) - z.B. "Die intuitive"
/// 3. Signatur-Satz (Claude API generiert) - 2-3 Sätze Synthese
///
/// Beispiel: "✨ Die intuitive Strategin"
///          "In dir verbindet sich die präzise Kraft..."
class Archetype extends Equatable {
  /// Archetyp-Name Key (z.B. "strategist" für i18n-Lookup)
  final String nameKey;

  /// Bazi-Adjektiv Key (z.B. "intuitive" für i18n-Lookup)
  final String adjectiveKey;

  /// Claude-generierter Signatur-Satz (2-3 Sätze, ~150-200 Zeichen)
  ///
  /// Dieser Text wird einmalig beim Onboarding generiert und in der
  /// Datenbank gecacht (profiles.signature_text).
  ///
  /// Kann null sein wenn:
  /// - Noch nicht generiert (z.B. API-Fehler beim Onboarding)
  /// - User hat Onboarding vor Archetyp-System abgeschlossen
  final String? signatureText;

  /// Lebenszahl (1-9, 11, 22, 33) - für Debugging
  final int lifePathNumber;

  /// Day Master Stem (z.B. "Gui") - für Debugging
  final String dayMasterStem;

  const Archetype({
    required this.nameKey,
    required this.adjectiveKey,
    this.signatureText,
    required this.lifePathNumber,
    required this.dayMasterStem,
  });

  /// Factory: Erstelle Archetyp aus BirthChart-Daten
  ///
  /// Verwendet die hardcoded Mappings aus [ArchetypeNames] und [BaziAdjectives].
  ///
  /// Beispiel:
  /// ```dart
  /// final archetype = Archetype.fromBirthChart(
  ///   lifePathNumber: 8,
  ///   dayMasterStem: 'Gui',
  ///   signatureText: 'In dir verbindet sich...',
  /// );
  /// // → nameKey: 'strategist', adjectiveKey: 'intuitive'
  /// ```
  factory Archetype.fromBirthChart({
    required int lifePathNumber,
    required String dayMasterStem,
    String? signatureText,
  }) {
    return Archetype(
      nameKey: ArchetypeNames.getNameKey(lifePathNumber),
      adjectiveKey: BaziAdjectives.getAdjectiveKey(dayMasterStem),
      signatureText: signatureText,
      lifePathNumber: lifePathNumber,
      dayMasterStem: dayMasterStem,
    );
  }

  /// Hat einen Signatur-Satz?
  bool get hasSignature => signatureText != null && signatureText!.isNotEmpty;

  /// Ist der Archetyp vollständig? (Name + Adjektiv valide)
  bool get isValid =>
      nameKey != 'unknown' && adjectiveKey != 'unknown';

  /// Ist der Archetyp eine Meisterzahl? (11, 22, 33)
  bool get isMasterNumber =>
      lifePathNumber == 11 || lifePathNumber == 22 || lifePathNumber == 33;

  @override
  List<Object?> get props => [
        nameKey,
        adjectiveKey,
        signatureText,
        lifePathNumber,
        dayMasterStem,
      ];

  /// CopyWith für Updates
  Archetype copyWith({
    String? nameKey,
    String? adjectiveKey,
    String? signatureText,
    int? lifePathNumber,
    String? dayMasterStem,
  }) {
    return Archetype(
      nameKey: nameKey ?? this.nameKey,
      adjectiveKey: adjectiveKey ?? this.adjectiveKey,
      signatureText: signatureText ?? this.signatureText,
      lifePathNumber: lifePathNumber ?? this.lifePathNumber,
      dayMasterStem: dayMasterStem ?? this.dayMasterStem,
    );
  }

  @override
  String toString() {
    return 'Archetype(nameKey: $nameKey, adjectiveKey: $adjectiveKey, '
        'lifePathNumber: $lifePathNumber, dayMasterStem: $dayMasterStem, '
        'hasSignature: $hasSignature)';
  }
}
