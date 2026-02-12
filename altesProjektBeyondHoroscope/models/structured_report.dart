// ============================================================
// STRUCTURED REPORT MODEL - Luxury Dossier Format
// ============================================================
//
// This model represents the new JSON-based report format
// designed for elegant PDF rendering with visualizations.
//
// ============================================================

/// Safely parse an int from dynamic JSON value
/// Handles: int, double, String, null, and unexpected types (like arrays)
int _safeParseInt(dynamic value, int defaultValue) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  // For any other type (including arrays), return default
  return defaultValue;
}

/// Main structured report class for the Luxury Dossier format
class StructuredReport {
  final ReportMeta meta;
  final ReportCover cover;
  final ExecutiveSummary? executiveSummary; // NEW: Executive Summary page
  final ReportIntro intro;
  final List<String> pullQuotes;
  final ReportLogicData logicData;
  final List<ReportBodySection> bodySections;
  final ReportClosing closing;
  final CuspData? cuspData; // NEW: Cusp information for planets at sign borders

  StructuredReport({
    required this.meta,
    required this.cover,
    this.executiveSummary,
    required this.intro,
    required this.pullQuotes,
    required this.logicData,
    required this.bodySections,
    required this.closing,
    this.cuspData,
  });

  factory StructuredReport.fromJson(Map<String, dynamic> json) {
    return StructuredReport(
      meta: ReportMeta.fromJson(json['meta'] ?? {}),
      cover: ReportCover.fromJson(json['cover'] ?? {}),
      executiveSummary: json['executiveSummary'] != null
          ? ExecutiveSummary.fromJson(json['executiveSummary'])
          : null,
      intro: ReportIntro.fromJson(json['intro'] ?? {}),
      pullQuotes: (json['pullQuotes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      logicData: ReportLogicData.fromJson(json['logicData'] ?? {}),
      bodySections: (json['bodySections'] as List<dynamic>?)
              ?.map((e) => ReportBodySection.fromJson(e))
              .toList() ??
          [],
      closing: ReportClosing.fromJson(json['closing'] ?? {}),
      cuspData: json['cuspData'] != null
          ? CuspData.fromJson(json['cuspData'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'cover': cover.toJson(),
      if (executiveSummary != null) 'executiveSummary': executiveSummary!.toJson(),
      'intro': intro.toJson(),
      'pullQuotes': pullQuotes,
      'logicData': logicData.toJson(),
      'bodySections': bodySections.map((e) => e.toJson()).toList(),
      'closing': closing.toJson(),
      if (cuspData != null) 'cuspData': cuspData!.toJson(),
    };
  }

  /// Total word count across all sections
  int get totalWordCount {
    int count = 0;
    count += intro.synthesis.split(RegExp(r'\s+')).length;
    for (var section in bodySections) {
      count += section.content.split(RegExp(r'\s+')).length;
    }
    count += closing.summary.split(RegExp(r'\s+')).length;
    return count;
  }

  /// Estimated page count (250 words per page)
  int get estimatedPages => (totalWordCount / 250).ceil();
}

/// Meta information about the report
class ReportMeta {
  final String reportType;
  final DateTime generatedAt;
  final int wordCount;
  final int estimatedPages;

  ReportMeta({
    required this.reportType,
    required this.generatedAt,
    required this.wordCount,
    required this.estimatedPages,
  });

  factory ReportMeta.fromJson(Map<String, dynamic> json) {
    return ReportMeta(
      reportType: json['reportType'] ?? '',
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'])
          : DateTime.now(),
      wordCount: json['wordCount'] ?? 0,
      estimatedPages: json['estimatedPages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportType': reportType,
      'generatedAt': generatedAt.toIso8601String(),
      'wordCount': wordCount,
      'estimatedPages': estimatedPages,
    };
  }
}

/// Cover page data
class ReportCover {
  final String headline;
  final String subheadline;
  final String? userName;
  final String? birthDate;
  final String? sunSign;
  final String? chineseAnimal;
  final int? lifePathNumber;

  ReportCover({
    required this.headline,
    required this.subheadline,
    this.userName,
    this.birthDate,
    this.sunSign,
    this.chineseAnimal,
    this.lifePathNumber,
  });

  factory ReportCover.fromJson(Map<String, dynamic> json) {
    return ReportCover(
      headline: json['headline'] ?? 'Beyond Dossier',
      subheadline: json['subheadline'] ?? '',
      userName: json['userName'],
      birthDate: json['birthDate'],
      sunSign: json['sunSign'],
      chineseAnimal: json['chineseAnimal'],
      lifePathNumber: json['lifePathNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headline': headline,
      'subheadline': subheadline,
      'userName': userName,
      'birthDate': birthDate,
      'sunSign': sunSign,
      'chineseAnimal': chineseAnimal,
      'lifePathNumber': lifePathNumber,
    };
  }
}

/// Executive Summary - "The Golden Three" insights at a glance
class ExecutiveSummary {
  final String biggestOpportunity;  // Größte Chance
  final String biggestBlocker;      // Größter Blocker
  final String? focusFor2026;       // Legacy field (deprecated)
  final String? focusForNextYear;   // Dynamic: Fokus für die kommenden 12 Monate

  ExecutiveSummary({
    required this.biggestOpportunity,
    required this.biggestBlocker,
    this.focusFor2026,
    this.focusForNextYear,
  });

  factory ExecutiveSummary.fromJson(Map<String, dynamic> json) {
    return ExecutiveSummary(
      biggestOpportunity: json['biggestOpportunity'] ?? '',
      biggestBlocker: json['biggestBlocker'] ?? '',
      focusFor2026: json['focusFor2026'],
      focusForNextYear: json['focusForNextYear'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'biggestOpportunity': biggestOpportunity,
      'biggestBlocker': biggestBlocker,
      if (focusFor2026 != null) 'focusFor2026': focusFor2026,
      if (focusForNextYear != null) 'focusForNextYear': focusForNextYear,
    };
  }

  /// Get the focus text, preferring dynamic over legacy
  String get focus => focusForNextYear ?? focusFor2026 ?? '';
}

/// Cusp data for planets at sign borders
class CuspData {
  final bool moonOnCusp;
  final String? moonCuspDescription; // e.g., "Waage-Mond mit Jungfrau-Einfluss"
  final bool ascendantOnCusp;
  final String? ascendantCuspDescription;
  final double? moonDegree;      // For determining cusp proximity
  final double? ascendantDegree;

  CuspData({
    this.moonOnCusp = false,
    this.moonCuspDescription,
    this.ascendantOnCusp = false,
    this.ascendantCuspDescription,
    this.moonDegree,
    this.ascendantDegree,
  });

  factory CuspData.fromJson(Map<String, dynamic> json) {
    return CuspData(
      moonOnCusp: json['moonOnCusp'] ?? false,
      moonCuspDescription: json['moonCuspDescription'],
      ascendantOnCusp: json['ascendantOnCusp'] ?? false,
      ascendantCuspDescription: json['ascendantCuspDescription'],
      moonDegree: (json['moonDegree'] as num?)?.toDouble(),
      ascendantDegree: (json['ascendantDegree'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moonOnCusp': moonOnCusp,
      if (moonCuspDescription != null) 'moonCuspDescription': moonCuspDescription,
      'ascendantOnCusp': ascendantOnCusp,
      if (ascendantCuspDescription != null) 'ascendantCuspDescription': ascendantCuspDescription,
      if (moonDegree != null) 'moonDegree': moonDegree,
      if (ascendantDegree != null) 'ascendantDegree': ascendantDegree,
    };
  }

  /// Check if a degree is on a cusp (within 3 degrees of sign boundary)
  static bool isDegreeOnCusp(double? degree) {
    if (degree == null) return false;
    final degreeInSign = degree % 30;
    return degreeInSign <= 3 || degreeInSign >= 27;
  }
}

/// Introduction/opening synthesis
class ReportIntro {
  final String synthesis;
  final String dominantVector;

  ReportIntro({
    required this.synthesis,
    required this.dominantVector,
  });

  factory ReportIntro.fromJson(Map<String, dynamic> json) {
    return ReportIntro(
      synthesis: json['synthesis'] ?? '',
      dominantVector: json['dominantVector'] ?? 'Westliche Astrologie',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'synthesis': synthesis,
      'dominantVector': dominantVector,
    };
  }
}

/// Logic data for visualizations (Beyond-Dreieck, Element-Waage, etc.)
class ReportLogicData {
  final BeyondTriangle beyondTriangle;
  final ElementBalance elementBalance;
  final NumerologyGrid numerologyGrid;

  ReportLogicData({
    required this.beyondTriangle,
    required this.elementBalance,
    required this.numerologyGrid,
  });

  factory ReportLogicData.fromJson(Map<String, dynamic> json) {
    return ReportLogicData(
      beyondTriangle: BeyondTriangle.fromJson(json['beyondTriangle'] ?? {}),
      elementBalance: ElementBalance.fromJson(json['elementBalance'] ?? {}),
      numerologyGrid: NumerologyGrid.fromJson(json['numerologyGrid'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beyondTriangle': beyondTriangle.toJson(),
      'elementBalance': elementBalance.toJson(),
      'numerologyGrid': numerologyGrid.toJson(),
    };
  }
}

/// Beyond-Dreieck percentages (must sum to 100)
class BeyondTriangle {
  final int westernAstrology;
  final int chineseAstrology;
  final int numerology;

  BeyondTriangle({
    required this.westernAstrology,
    required this.chineseAstrology,
    required this.numerology,
  });

  factory BeyondTriangle.fromJson(Map<String, dynamic> json) {
    return BeyondTriangle(
      westernAstrology: _safeParseInt(json['westernAstrology'], 33),
      chineseAstrology: _safeParseInt(json['chineseAstrology'], 33),
      numerology: _safeParseInt(json['numerology'], 34),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'westernAstrology': westernAstrology,
      'chineseAstrology': chineseAstrology,
      'numerology': numerology,
    };
  }

  /// Validate that percentages sum to 100
  bool get isValid =>
      westernAstrology + chineseAstrology + numerology == 100;
}

/// Element balance for Element-Waage visualization
class ElementBalance {
  // Western elements
  final int fire;
  final int earth;
  final int air;
  final int water;
  // Chinese elements
  final int wood;
  final int metal;

  ElementBalance({
    required this.fire,
    required this.earth,
    required this.air,
    required this.water,
    required this.wood,
    required this.metal,
  });

  factory ElementBalance.fromJson(Map<String, dynamic> json) {
    return ElementBalance(
      fire: _safeParseInt(json['fire'], 25),
      earth: _safeParseInt(json['earth'], 25),
      air: _safeParseInt(json['air'], 25),
      water: _safeParseInt(json['water'], 25),
      wood: _safeParseInt(json['wood'], 20),
      metal: _safeParseInt(json['metal'], 20),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fire': fire,
      'earth': earth,
      'air': air,
      'water': water,
      'wood': wood,
      'metal': metal,
    };
  }

  /// Get western element with highest value
  String get dominantWesternElement {
    final elements = {'Feuer': fire, 'Erde': earth, 'Luft': air, 'Wasser': water};
    return elements.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get chinese element with highest value
  String get dominantChineseElement {
    return wood > metal ? 'Holz' : 'Metall';
  }
}

/// Numerology grid data
class NumerologyGrid {
  final int lifePathNumber;
  final int destinyNumber;
  final int soulUrgeNumber;
  final int personalityNumber;
  final int maturityNumber;
  final int personalYear;

  NumerologyGrid({
    required this.lifePathNumber,
    required this.destinyNumber,
    required this.soulUrgeNumber,
    required this.personalityNumber,
    required this.maturityNumber,
    required this.personalYear,
  });

  factory NumerologyGrid.fromJson(Map<String, dynamic> json) {
    return NumerologyGrid(
      lifePathNumber: _safeParseInt(json['lifePathNumber'], 1),
      destinyNumber: _safeParseInt(json['destinyNumber'], 1),
      soulUrgeNumber: _safeParseInt(json['soulUrgeNumber'], 1),
      personalityNumber: _safeParseInt(json['personalityNumber'], 1),
      maturityNumber: _safeParseInt(json['maturityNumber'], 1),
      personalYear: _safeParseInt(json['personalYear'], 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lifePathNumber': lifePathNumber,
      'destinyNumber': destinyNumber,
      'soulUrgeNumber': soulUrgeNumber,
      'personalityNumber': personalityNumber,
      'maturityNumber': maturityNumber,
      'personalYear': personalYear,
    };
  }
}

/// A single body section of the report
class ReportBodySection {
  final String title;
  final String content;
  final String? keyInsight;
  final BeyondAction? beyondAction; // NEW: Actionable task for this section

  ReportBodySection({
    required this.title,
    required this.content,
    this.keyInsight,
    this.beyondAction,
  });

  factory ReportBodySection.fromJson(Map<String, dynamic> json) {
    return ReportBodySection(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      keyInsight: json['keyInsight'],
      beyondAction: json['beyondAction'] != null
          ? BeyondAction.fromJson(json['beyondAction'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      if (keyInsight != null) 'keyInsight': keyInsight,
      if (beyondAction != null) 'beyondAction': beyondAction!.toJson(),
    };
  }

  /// Word count for this section
  int get wordCount => content.split(RegExp(r'\s+')).length;
}

/// Beyond Action - A concrete, actionable task
class BeyondAction {
  final String task;        // The specific action to take
  final String? timeframe;  // Optional: when to do it (e.g., "This month", "This week")
  final String? category;   // Optional: category (e.g., "Finance", "Relationships")

  BeyondAction({
    required this.task,
    this.timeframe,
    this.category,
  });

  factory BeyondAction.fromJson(Map<String, dynamic> json) {
    return BeyondAction(
      task: json['task'] ?? '',
      timeframe: json['timeframe'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task': task,
      if (timeframe != null) 'timeframe': timeframe,
      if (category != null) 'category': category,
    };
  }
}

/// Closing section with summary and action items
class ReportClosing {
  final String summary;
  final List<String> actionItems;
  final DharmaChecklist? dharmaChecklist; // NEW: Monday Morning Check-In

  ReportClosing({
    required this.summary,
    required this.actionItems,
    this.dharmaChecklist,
  });

  factory ReportClosing.fromJson(Map<String, dynamic> json) {
    return ReportClosing(
      summary: json['summary'] ?? '',
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      dharmaChecklist: json['dharmaChecklist'] != null
          ? DharmaChecklist.fromJson(json['dharmaChecklist'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'actionItems': actionItems,
      if (dharmaChecklist != null) 'dharmaChecklist': dharmaChecklist!.toJson(),
    };
  }
}

/// Dharma Checklist - Monday Morning Check-In (Purpose Path only)
class DharmaChecklist {
  final String impactCheck;   // MC-based question
  final String growthCheck;   // North Node-based question
  final String talentCheck;   // Expression number-based question

  DharmaChecklist({
    required this.impactCheck,
    required this.growthCheck,
    required this.talentCheck,
  });

  factory DharmaChecklist.fromJson(Map<String, dynamic> json) {
    return DharmaChecklist(
      impactCheck: json['impactCheck'] ?? '',
      growthCheck: json['growthCheck'] ?? '',
      talentCheck: json['talentCheck'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'impactCheck': impactCheck,
      'growthCheck': growthCheck,
      'talentCheck': talentCheck,
    };
  }

  List<String> get allQuestions => [impactCheck, growthCheck, talentCheck];
}
