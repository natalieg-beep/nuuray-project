import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuuray_core/nuuray_core.dart';
import '../../../core/providers/app_providers.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../models/signature_report_data.dart';

/// Provider für den Signatur-Report — Orchestriert alle Daten + Generierung
///
/// Sammelt alle benötigten Texte (Deep Synthesis, Chapters, Key Insights)
/// und generiert fehlende Kapitel parallel via Claude API.
///
/// Cache-First Pattern:
/// 1. Profile laden (hat bereits: deep_synthesis_text, key_insights, reflection_questions)
/// 2. Cache-Check: chapter_western, chapter_bazi, chapter_numerology
/// 3. Fehlende Kapitel generieren (parallel mit Future.wait)
/// 4. In DB cachen
/// 5. SignatureReportData zusammenbauen + returnen
final signatureReportProvider = FutureProvider.family<SignatureReportData, BirthChart>((ref, birthChart) async {
  final supabase = ref.read(supabaseClientProvider);
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final userId = profile?.id;

  if (userId == null || profile == null) {
    throw Exception('Kein User-Profil vorhanden');
  }

  // 1. Alle gecachten Daten auf einmal laden
  log('📄 [Report] Lade Report-Daten für User: $userId');

  final cached = await supabase
      .from('profiles')
      .select('deep_synthesis_text, key_insights, reflection_questions, chapter_western, chapter_bazi, chapter_numerology, signature_text')
      .eq('id', userId)
      .maybeSingle();

  if (cached == null) {
    throw Exception('Profil nicht gefunden');
  }

  // 2. Pflichtfelder prüfen
  final synthesisText = cached['deep_synthesis_text'] as String?;
  if (synthesisText == null || synthesisText.isEmpty) {
    throw Exception('Deep Synthesis muss zuerst generiert werden. Bitte öffne den Signatur-Screen und warte, bis deine Synthese erstellt wurde.');
  }

  // Key Insights + Fragen (müssen vorhanden sein)
  final rawInsights = cached['key_insights'];
  final rawQuestions = cached['reflection_questions'];

  if (rawInsights == null || rawQuestions == null) {
    throw Exception('Key Insights müssen zuerst generiert werden. Bitte scrolle auf dem Signatur-Screen nach unten und warte auf "Das Wesentliche".');
  }

  final keyInsights = (rawInsights as List).map<Map<String, String>>((item) {
    final map = item as Map<String, dynamic>;
    return {
      'label': (map['label'] ?? '') as String,
      'text': (map['text'] ?? '') as String,
    };
  }).toList();

  final reflectionQuestions = (rawQuestions as List).map<String>((q) => q.toString()).toList();

  // 3. Chapter-Texte — Cache-Check + fehlende generieren
  String? chapterWestern = cached['chapter_western'] as String?;
  String? chapterBazi = cached['chapter_bazi'] as String?;
  String? chapterNumerology = cached['chapter_numerology'] as String?;

  final claudeService = ref.read(claudeApiServiceProvider);
  if (claudeService == null) {
    throw Exception('Claude API Service nicht verfügbar — API Key fehlt');
  }

  final language = profile.language;
  final gender = profile.gender;

  // Fehlende Kapitel parallel generieren
  final futures = <String, Future<String>>{};

  if (chapterWestern == null || chapterWestern.isEmpty) {
    log('🤖 [Report] Generiere Western Astrology Kapitel...');
    futures['western'] = claudeService.generateChapterWestern(
      sunSign: birthChart.sunSign,
      moonSign: birthChart.moonSign,
      ascendantSign: birthChart.ascendantSign,
      sunDegree: birthChart.sunDegree,
      moonDegree: birthChart.moonDegree,
      ascendantDegree: birthChart.ascendantDegree,
      language: language,
      gender: gender,
    );
  }

  if (chapterBazi == null || chapterBazi.isEmpty) {
    log('🤖 [Report] Generiere Bazi Kapitel...');
    futures['bazi'] = claudeService.generateChapterBazi(
      baziDayStem: birthChart.baziDayStem,
      baziDayBranch: birthChart.baziDayBranch,
      baziElement: birthChart.baziElement,
      baziYearStem: birthChart.baziYearStem,
      baziYearBranch: birthChart.baziYearBranch,
      baziMonthStem: birthChart.baziMonthStem,
      baziMonthBranch: birthChart.baziMonthBranch,
      baziHourStem: birthChart.baziHourStem,
      baziHourBranch: birthChart.baziHourBranch,
      language: language,
      gender: gender,
    );
  }

  if (chapterNumerology == null || chapterNumerology.isEmpty) {
    log('🤖 [Report] Generiere Numerologie Kapitel...');
    futures['numerology'] = claudeService.generateChapterNumerology(
      lifePathNumber: birthChart.lifePathNumber,
      birthdayNumber: birthChart.birthdayNumber,
      attitudeNumber: birthChart.attitudeNumber,
      personalYear: birthChart.personalYear,
      maturityNumber: birthChart.maturityNumber,
      birthExpressionNumber: birthChart.birthExpressionNumber,
      birthSoulUrgeNumber: birthChart.birthSoulUrgeNumber,
      currentExpressionNumber: birthChart.currentExpressionNumber,
      currentSoulUrgeNumber: birthChart.currentSoulUrgeNumber,
      karmicDebtLifePath: birthChart.karmicDebtLifePath,
      karmicLessons: birthChart.karmicLessons,
      challengeNumbers: birthChart.challengeNumbers,
      language: language,
      gender: gender,
    );
  }

  // Parallel ausführen (spart ~4-6 Sekunden bei Erstgenerierung)
  if (futures.isNotEmpty) {
    log('⏳ [Report] Generiere ${futures.length} Kapitel parallel...');
    final results = await Future.wait(
      futures.entries.map((e) async {
        final text = await e.value;
        return MapEntry(e.key, text);
      }),
    );

    final resultMap = Map.fromEntries(results);

    if (resultMap.containsKey('western')) {
      chapterWestern = resultMap['western']!;
    }
    if (resultMap.containsKey('bazi')) {
      chapterBazi = resultMap['bazi']!;
    }
    if (resultMap.containsKey('numerology')) {
      chapterNumerology = resultMap['numerology']!;
    }

    log('✨ [Report] ${futures.length} Kapitel generiert');

    // 4. In DB cachen
    try {
      final updateData = <String, dynamic>{};
      if (resultMap.containsKey('western')) updateData['chapter_western'] = chapterWestern;
      if (resultMap.containsKey('bazi')) updateData['chapter_bazi'] = chapterBazi;
      if (resultMap.containsKey('numerology')) updateData['chapter_numerology'] = chapterNumerology;

      if (updateData.isNotEmpty) {
        await supabase.from('profiles').update(updateData).eq('id', userId);
        log('💾 [Report] Kapitel in DB gecacht');
      }
    } catch (e) {
      log('⚠️ [Report] Fehler beim Cachen: $e');
      // Weiter — Texte sind im Memory vorhanden
    }
  } else {
    log('✅ [Report] Alle Kapitel aus Cache geladen');
  }

  // 5. Archetyp-Titel aus signatureText extrahieren
  // signatureText Format: "Archetyp-Titel\n\nMini-Synthese..."
  String? archetypeTitle;
  final signatureTextRaw = cached['signature_text'] as String?;
  if (signatureTextRaw != null && signatureTextRaw.isNotEmpty) {
    final lines = signatureTextRaw.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isNotEmpty) {
      archetypeTitle = lines.first.trim();
    }
  }

  // 6. SignatureReportData zusammenbauen
  return SignatureReportData(
    displayName: profile.displayName,
    archetypeTitle: archetypeTitle,
    birthDate: profile.birthDate,
    birthChart: birthChart,
    synthesisText: synthesisText,
    chapterWestern: chapterWestern!,
    chapterBazi: chapterBazi!,
    chapterNumerology: chapterNumerology!,
    keyInsights: keyInsights,
    reflectionQuestions: reflectionQuestions,
    language: language,
    generatedAt: DateTime.now(),
  );
});

/// Löscht alle Report-Chapter-Caches (Debug/Testing)
Future<void> resetReportChaptersCache(
  dynamic supabase,
  String userId,
) async {
  await supabase
      .from('profiles')
      .update({
        'chapter_western': null,
        'chapter_bazi': null,
        'chapter_numerology': null,
      })
      .eq('id', userId);
  log('🗑️ [Report] Chapter-Caches gelöscht');
}
