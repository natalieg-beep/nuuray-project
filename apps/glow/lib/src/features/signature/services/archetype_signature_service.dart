import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nuuray_core/nuuray_core.dart';
import '../../../core/services/claude_api_service.dart';

/// Service für Archetyp-Signatur-Generierung und Caching
///
/// Verwaltet die Generierung des personalisierten Signatur-Satzes via Claude API
/// und cached ihn in der Supabase `profiles` Tabelle.
class ArchetypeSignatureService {
  final SupabaseClient _supabase;
  final ClaudeApiService _claudeService;

  ArchetypeSignatureService({
    required SupabaseClient supabase,
    required ClaudeApiService claudeService,
  })  : _supabase = supabase,
        _claudeService = claudeService;

  /// Generiere und cache Archetyp-Signatur-Satz
  ///
  /// Workflow:
  /// 1. Prüfe ob Signatur bereits existiert (Cache-Check)
  /// 2. Falls nicht: Generiere via Claude API
  /// 3. Speichere in Datenbank
  /// 4. Returniere Signatur-Text
  ///
  /// Kosten: ~$0.001 pro Generierung (einmalig pro User)
  ///
  /// Throws:
  /// - [Exception] wenn BirthChart ungültig (fehlende Daten)
  /// - [ClaudeApiException] wenn API-Call fehlschlägt
  /// - [PostgrestException] wenn DB-Update fehlschlägt
  Future<String> generateAndCacheArchetypeSignature({
    required String userId,
    required BirthChart birthChart,
    required String language,
    String? gender,
  }) async {
    try {
      log('📝 Generiere Archetyp-Signatur für User: $userId');

      // 1. Prüfe ob Signatur bereits existiert
      final profile = await _supabase
          .from('profiles')
          .select('signature_text')
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) {
        final existingSignature = profile['signature_text'] as String?;
        if (existingSignature != null && existingSignature.isNotEmpty) {
          log('✅ Archetyp-Signatur bereits gecacht, nutze bestehende');
          return existingSignature;
        }
      }

      // 2. Erstelle Archetyp aus BirthChart
      if (birthChart.lifePathNumber == null) {
        throw Exception('Life Path Number ist null - Chart unvollständig');
      }

      final archetype = Archetype.fromBirthChart(
        lifePathNumber: birthChart.lifePathNumber!,
        dayMasterStem: birthChart.baziDayStem ?? 'Jia', // Fallback
        signatureText: null, // Wird jetzt generiert
      );

      // Validierung: Archetyp muss valide sein
      if (!archetype.isValid) {
        throw Exception(
          'Archetyp ist ungültig: nameKey=${archetype.nameKey}, '
          'adjectiveKey=${archetype.adjectiveKey}',
        );
      }

      // 3. Hole lokalisierte Texte für Prompt
      final archetypeName = _getLocalizedArchetypeName(
        archetype.nameKey,
        language,
        gender: gender,
      );
      final baziAdjective = _getLocalizedBaziAdjective(
        archetype.adjectiveKey,
        language,
      );

      // Sonnenzeichen Name (für Prompt)
      final sunSignName = _getZodiacSignName(
        birthChart.sunSign,
        language,
      );

      // Optional: Mondzeichen
      final moonSignName = birthChart.moonSign != null
          ? _getZodiacSignName(birthChart.moonSign!, language)
          : null;

      // Optional: Aszendent
      final ascendantName = birthChart.ascendantSign != null
          ? _getZodiacSignName(birthChart.ascendantSign!, language)
          : null;

      // Day Master Element (für Prompt)
      final dayMasterElement = _getBaziElementName(
        birthChart.baziDayStem ?? '',
        language,
      );

      // Dominantes Element
      final dominantElement = _getBaziElementName(
        birthChart.baziElement ?? 'Wasser',
        language,
      );

      log('📋 Prompt-Daten:');
      log('   Archetyp: $archetypeName');
      log('   Bazi-Adjektiv: $baziAdjective');
      log('   Life Path: ${birthChart.lifePathNumber}');
      log('   Sonne: $sunSignName');
      log('   Mond: ${moonSignName ?? "nicht vorhanden"}');
      log('   Aszendent: ${ascendantName ?? "nicht vorhanden"}');
      log('   Day Master: $dayMasterElement');
      log('   Dominantes Element: $dominantElement');

      // 4. Generiere Signatur-Satz via Claude API
      final signatureText = await _claudeService.generateArchetypeSignature(
        archetypeName: archetypeName,
        baziAdjective: baziAdjective,
        lifePathNumber: birthChart.lifePathNumber!,
        sunSign: sunSignName,
        moonSign: moonSignName,
        ascendant: ascendantName,
        dayMasterElement: dayMasterElement,
        dominantElement: dominantElement,
        language: language,
        gender: gender,
      );

      log('✨ Archetyp-Signatur generiert: "$signatureText"');

      // 5. Speichere in Datenbank
      await _supabase.from('profiles').update({
        'signature_text': signatureText,
      }).eq('id', userId);

      log('💾 Archetyp-Signatur in DB gespeichert');

      return signatureText;
    } catch (e, stackTrace) {
      log('❌ Fehler bei Archetyp-Signatur-Generierung: $e');
      log('Stack Trace: $stackTrace');
      rethrow;
    }
  }

  // ============================================================
  // HILFSMETHODEN FÜR LOKALISIERUNG
  // ============================================================

  /// Hole lokalisierten Archetyp-Namen — nach Gender angepasst
  ///
  /// [gender] bestimmt die Form:
  /// - "female" → weibliche Form: "Die Pionierin"
  /// - "male"   → männliche Form: "Der Pionier"
  /// - null / andere → neutrale Form: "Der/die Pionier·in" → nur Kernname
  String _getLocalizedArchetypeName(String nameKey, String language,
      {String? gender}) {
    if (language.toUpperCase() == 'DE') {
      // Weibliche Formen (default für "female")
      const namesFemDE = {
        'pioneer': 'Die Pionierin',
        'diplomat': 'Die Diplomatin',
        'creative': 'Die Kreative',
        'architect': 'Die Architektin',
        'adventurer': 'Die Abenteurerin',
        'mentor': 'Die Mentorin',
        'seeker': 'Die Sucherin',
        'strategist': 'Die Strategin',
        'humanitarian': 'Die Humanistin',
        'visionary': 'Die Visionärin',
        'master_builder': 'Die Baumeisterin',
        'healer': 'Die Heilerin',
      };
      // Männliche Formen
      const namesMascDE = {
        'pioneer': 'Der Pionier',
        'diplomat': 'Der Diplomat',
        'creative': 'Der Kreative',
        'architect': 'Der Architekt',
        'adventurer': 'Der Abenteurer',
        'mentor': 'Der Mentor',
        'seeker': 'Der Suchende',
        'strategist': 'Der Stratege',
        'humanitarian': 'Der Humanist',
        'visionary': 'Der Visionär',
        'master_builder': 'Der Baumeister',
        'healer': 'Der Heiler',
      };
      // Neutrale Formen (ohne Artikel, ohne Endung)
      const namesNeutDE = {
        'pioneer': 'Pionier·in',
        'diplomat': 'Diplomat·in',
        'creative': 'Kreative·r',
        'architect': 'Architekt·in',
        'adventurer': 'Abenteurer·in',
        'mentor': 'Mentor·in',
        'seeker': 'Suchende·r',
        'strategist': 'Strateg·in',
        'humanitarian': 'Humanist·in',
        'visionary': 'Visionär·in',
        'master_builder': 'Baumeister·in',
        'healer': 'Heiler·in',
      };

      switch (gender) {
        case 'female':
          return namesFemDE[nameKey] ?? nameKey;
        case 'male':
          return namesMascDE[nameKey] ?? nameKey;
        default: // diverse, prefer_not_to_say, null
          return namesNeutDE[nameKey] ?? nameKey;
      }
    } else {
      // EN: gender-neutral (no articles in English)
      const namesEN = {
        'pioneer': 'The Pioneer',
        'diplomat': 'The Diplomat',
        'creative': 'The Creative',
        'architect': 'The Architect',
        'adventurer': 'The Adventurer',
        'mentor': 'The Mentor',
        'seeker': 'The Seeker',
        'strategist': 'The Strategist',
        'humanitarian': 'The Humanitarian',
        'visionary': 'The Visionary',
        'master_builder': 'The Master Builder',
        'healer': 'The Healer',
      };
      return namesEN[nameKey] ?? nameKey;
    }
  }

  /// Hole lokalisiertes Bazi-Adjektiv (OHNE Artikel)
  String _getLocalizedBaziAdjective(String adjectiveKey, String language) {
    if (language.toUpperCase() == 'DE') {
      const adjectivesDE = {
        'steadfast': 'standfeste',
        'adaptable': 'anpassungsfähige',
        'radiant': 'strahlende',
        'perceptive': 'feinfühlige',
        'grounded': 'beständige',
        'nurturing': 'nährende',
        'resolute': 'entschlossene',
        'refined': 'feine',
        'flowing': 'fließende',
        'intuitive': 'intuitive',
      };
      return adjectivesDE[adjectiveKey] ?? adjectiveKey;
    } else {
      const adjectivesEN = {
        'steadfast': 'steadfast',
        'adaptable': 'adaptable',
        'radiant': 'radiant',
        'perceptive': 'perceptive',
        'grounded': 'grounded',
        'nurturing': 'nurturing',
        'resolute': 'resolute',
        'refined': 'refined',
        'flowing': 'flowing',
        'intuitive': 'intuitive',
      };
      return adjectivesEN[adjectiveKey] ?? adjectiveKey;
    }
  }

  /// Hole Sternzeichen-Namen
  String _getZodiacSignName(String signKey, String language) {
    if (language.toUpperCase() == 'DE') {
      const signsDE = {
        'aries': 'Widder',
        'taurus': 'Stier',
        'gemini': 'Zwillinge',
        'cancer': 'Krebs',
        'leo': 'Löwe',
        'virgo': 'Jungfrau',
        'libra': 'Waage',
        'scorpio': 'Skorpion',
        'sagittarius': 'Schütze',
        'capricorn': 'Steinbock',
        'aquarius': 'Wassermann',
        'pisces': 'Fische',
      };
      return signsDE[signKey] ?? signKey;
    } else {
      const signsEN = {
        'aries': 'Aries',
        'taurus': 'Taurus',
        'gemini': 'Gemini',
        'cancer': 'Cancer',
        'leo': 'Leo',
        'virgo': 'Virgo',
        'libra': 'Libra',
        'scorpio': 'Scorpio',
        'sagittarius': 'Sagittarius',
        'capricorn': 'Capricorn',
        'aquarius': 'Aquarius',
        'pisces': 'Pisces',
      };
      return signsEN[signKey] ?? signKey;
    }
  }

  /// Hole Bazi-Element-Namen
  String _getBaziElementName(String stem, String language) {
    if (language.toUpperCase() == 'DE') {
      const elementsDE = {
        'Jia': 'Yang-Holz',
        'Yi': 'Yin-Holz',
        'Bing': 'Yang-Feuer',
        'Ding': 'Yin-Feuer',
        'Wu': 'Yang-Erde',
        'Ji': 'Yin-Erde',
        'Geng': 'Yang-Metall',
        'Xin': 'Yin-Metall',
        'Ren': 'Yang-Wasser',
        'Gui': 'Yin-Wasser',
        // Elemente allgemein
        'Holz': 'Holz',
        'Feuer': 'Feuer',
        'Erde': 'Erde',
        'Metall': 'Metall',
        'Wasser': 'Wasser',
      };
      return elementsDE[stem] ?? stem;
    } else {
      const elementsEN = {
        'Jia': 'Yang Wood',
        'Yi': 'Yin Wood',
        'Bing': 'Yang Fire',
        'Ding': 'Yin Fire',
        'Wu': 'Yang Earth',
        'Ji': 'Yin Earth',
        'Geng': 'Yang Metal',
        'Xin': 'Yin Metal',
        'Ren': 'Yang Water',
        'Gui': 'Yin Water',
        // Elemente allgemein
        'Holz': 'Wood',
        'Feuer': 'Fire',
        'Erde': 'Earth',
        'Metall': 'Metal',
        'Wasser': 'Water',
      };
      return elementsEN[stem] ?? stem;
    }
  }
}
