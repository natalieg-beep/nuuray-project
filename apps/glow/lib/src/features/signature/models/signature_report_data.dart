import 'package:nuuray_core/nuuray_core.dart';

/// Datenmodell für den Signatur-Report PDF Export
///
/// Bündelt alle Daten die für die PDF-Generierung benötigt werden.
/// Wird vom [signatureReportProvider] zusammengebaut, nachdem alle
/// Texte generiert/gecacht wurden.
class SignatureReportData {
  // === IDENTITÄT ===
  /// Display-Name des Users (z.B. "Natalie")
  final String displayName;

  /// Archetyp-Titel (z.B. "Die Visionäre Brückenbauerin")
  final String? archetypeTitle;

  /// Geburtsdatum
  final DateTime? birthDate;

  // === CHART-DATEN ===
  /// Vollständiges BirthChart für die Identitäts-Seite
  final BirthChart birthChart;

  // === TEXTE (alle gecacht aus profiles) ===
  /// Tiefe Drei-System-Synthese (900-1200 Wörter)
  final String synthesisText;

  /// Western Astrology Kapitel (~500 Wörter, Claude-generiert)
  final String chapterWestern;

  /// Bazi Kapitel (~500 Wörter, Claude-generiert)
  final String chapterBazi;

  /// Numerologie Kapitel (~600 Wörter, Claude-generiert)
  final String chapterNumerology;

  /// 3 Schlüsselerkenntnisse aus der Synthese
  final List<Map<String, String>> keyInsights;

  /// 7 Reflexionsfragen
  final List<String> reflectionQuestions;

  // === META ===
  /// Sprache des Reports ("de" oder "en")
  final String language;

  /// Zeitpunkt der Report-Generierung
  final DateTime generatedAt;

  const SignatureReportData({
    required this.displayName,
    this.archetypeTitle,
    this.birthDate,
    required this.birthChart,
    required this.synthesisText,
    required this.chapterWestern,
    required this.chapterBazi,
    required this.chapterNumerology,
    required this.keyInsights,
    required this.reflectionQuestions,
    required this.language,
    required this.generatedAt,
  });

  /// Prüft ob alle Texte vorhanden sind
  bool get isComplete =>
      synthesisText.isNotEmpty &&
      chapterWestern.isNotEmpty &&
      chapterBazi.isNotEmpty &&
      chapterNumerology.isNotEmpty &&
      keyInsights.isNotEmpty &&
      reflectionQuestions.isNotEmpty;
}
