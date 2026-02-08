import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nuuray_glow/src/core/services/claude_api_service.dart';

/// Service für Tageshoroskope mit 3-Stufen-Strategie
///
/// **Variante A (MVP):** Basis-Horoskop (gecacht) + UI-Synthese ($0)
/// **Variante B (Premium):** + Mini-Personalizer (1 Satz, ~$0.001)
/// **Variante C (Pro):** + Tiefe Synthese (2-3 Sätze, ~$0.0015)
///
/// Siehe: docs/glow/implementation/HOROSCOPE_STRATEGY.md
class DailyHoroscopeService {
  final SupabaseClient _supabase;
  final ClaudeApiService? _claudeService;

  DailyHoroscopeService({
    required SupabaseClient supabase,
    ClaudeApiService? claudeService,
  })  : _supabase = supabase,
        _claudeService = claudeService;

  /// Lädt Tageshoroskop für ein Sternzeichen
  ///
  /// **Variante A (Default):** Nur gecachtes Basis-Horoskop
  ///
  /// [zodiacSign] - Sternzeichen (en: "aries", "taurus", ...)
  /// [language] - Sprache ("de" oder "en")
  /// [date] - Datum (default: heute)
  ///
  /// Returns: Basis-Horoskop-Text aus Cache
  Future<String> getBaseHoroscope({
    required String zodiacSign,
    String language = 'de',
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateString = targetDate.toIso8601String().split('T')[0];

    print('🔍 [Horoskop] Suche: $zodiacSign, $language, $dateString');

    // 1. Versuche gecachtes Horoskop zu laden
    final response = await _supabase
        .from('daily_horoscopes')
        .select()
        .eq('date', dateString)
        .eq('zodiac_sign', zodiacSign)
        .eq('language', language)
        .maybeSingle();

    if (response != null && response['content_text'] != null) {
      // Cache Hit! (Normalfall)
      print('✅ [Horoskop] Cache Hit! Horoskop gefunden');
      return response['content_text'] as String;
    }

    print('❌ [Horoskop] Cache Miss! Fallback zu Claude API');

    // 2. Cache Miss → Fallback: Generiere neues Horoskop
    // (sollte nur passieren, wenn Cron Job fehlgeschlagen ist)
    if (_claudeService != null) {
      print('🤖 [Horoskop] ClaudeService vorhanden, generiere Horoskop...');

      try {
        final horoscope = await _claudeService!.generateDailyHoroscope(
          zodiacSign: zodiacSign,
          language: language,
          date: targetDate,
        );

        print('✅ [Horoskop] Horoskop generiert (${horoscope.totalTokens} tokens)');

        // Cache für nächstes Mal
        await _cacheHoroscope(
          zodiacSign: zodiacSign,
          language: language,
          date: targetDate,
          contentText: horoscope.text,
          tokensUsed: horoscope.totalTokens,
          modelUsed: horoscope.model,
        );

        return horoscope.text;
      } catch (e) {
        print('❌ [Horoskop] Fehler bei Claude API: $e');
        return _getFallbackHoroscope(zodiacSign, language);
      }
    }

    // 3. Kein Service verfügbar → Fallback-Text
    print('⚠️ [Horoskop] Kein ClaudeService verfügbar → Fallback-Text');
    return _getFallbackHoroscope(zodiacSign, language);
  }

  /// **Variante B:** Mini-Personalizer (Premium)
  ///
  /// Generiert EINEN personalisierten Satz (20 Wörter)
  ///
  /// [baseHoroscope] - Basis-Horoskop (gecacht)
  /// [moonSign] - Mondzeichen
  /// [dayMaster] - Bazi Day Master
  /// [lifePathNumber] - Numerologie Life Path
  /// [language] - Sprache
  ///
  /// Kosten: ~$0.001 pro Call
  Future<String> generateMiniPersonalization({
    required String baseHoroscope,
    required String sunSign,
    required String moonSign,
    String? dayMaster,
    int? lifePathNumber,
    String language = 'de',
  }) async {
    if (_claudeService == null) {
      throw Exception('ClaudeApiService nicht verfügbar');
    }

    final prompt = _buildMiniPersonalizationPrompt(
      baseHoroscope: baseHoroscope,
      sunSign: sunSign,
      moonSign: moonSign,
      dayMaster: dayMaster,
      lifePathNumber: lifePathNumber,
      language: language,
    );

    final response = await _claudeService!.callClaude(
      systemPrompt: _getMiniPersonalizationSystemPrompt(language),
      userPrompt: prompt,
    );

    return response.text;
  }

  /// **Variante C:** Tiefe Synthese (Pro-Tier)
  ///
  /// Generiert 2-3 personalisierte Sätze (50 Wörter)
  ///
  /// Kosten: ~$0.0015 pro Call
  Future<String> generateDeepPersonalization({
    required String baseHoroscope,
    required String sunSign,
    required String moonSign,
    String? ascendant,
    String? dayMaster,
    int? lifePathNumber,
    String language = 'de',
  }) async {
    if (_claudeService == null) {
      throw Exception('ClaudeApiService nicht verfügbar');
    }

    final prompt = _buildDeepPersonalizationPrompt(
      baseHoroscope: baseHoroscope,
      sunSign: sunSign,
      moonSign: moonSign,
      ascendant: ascendant,
      dayMaster: dayMaster,
      lifePathNumber: lifePathNumber,
      language: language,
    );

    final response = await _claudeService!.callClaude(
      systemPrompt: _getDeepPersonalizationSystemPrompt(language),
      userPrompt: prompt,
    );

    return response.text;
  }

  /// Cache Horoskop in Supabase
  Future<void> _cacheHoroscope({
    required String zodiacSign,
    required String language,
    required DateTime date,
    required String contentText,
    required int tokensUsed,
    required String modelUsed,
  }) async {
    final dateString = date.toIso8601String().split('T')[0];

    await _supabase.from('daily_horoscopes').upsert({
      'date': dateString,
      'zodiac_sign': zodiacSign,
      'language': language,
      'content_text': contentText,
      'tokens_used': tokensUsed,
      'model_used': modelUsed,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Fallback-Horoskop (falls kein Cache und kein Service)
  String _getFallbackHoroscope(String zodiacSign, String language) {
    if (language == 'de') {
      return 'Heute ist ein guter Tag, um auf deine Intuition zu hören. '
          'Die kosmische Energie unterstützt dich dabei, authentisch zu bleiben '
          'und deine wahren Bedürfnisse ernst zu nehmen.';
    } else {
      return 'Today is a good day to listen to your intuition. '
          'The cosmic energy supports you in staying authentic '
          'and taking your true needs seriously.';
    }
  }

  // ========================================================================
  // PROMPT-TEMPLATES
  // ========================================================================

  /// Prompt: Mini-Personalizer (Variante B)
  String _buildMiniPersonalizationPrompt({
    required String baseHoroscope,
    required String sunSign,
    required String moonSign,
    String? dayMaster,
    int? lifePathNumber,
    required String language,
  }) {
    if (language == 'de') {
      return '''
BASIS-HOROSKOP für $sunSign:
"$baseHoroscope"

USER-PROFIL:
- Mondzeichen: $moonSign
${dayMaster != null ? '- Bazi Day Master: $dayMaster' : ''}
${lifePathNumber != null ? '- Life Path Number: $lifePathNumber' : ''}

AUFGABE: Schreibe EINEN Satz (20 Wörter), wie dieser Tag speziell
für dieses Profil wirkt. Zeige die Synthese der Systeme.

Beispiel: "Mit deinem $moonSign-Mond und Life Path $lifePathNumber ist heute
ein perfekter Tag für [konkrete Handlung basierend auf Profil]."

NUR DEN EINEN SATZ, keine Einleitung, kein Kontext.
''';
    } else {
      return '''
BASE HOROSCOPE for $sunSign:
"$baseHoroscope"

USER PROFILE:
- Moon Sign: $moonSign
${dayMaster != null ? '- Bazi Day Master: $dayMaster' : ''}
${lifePathNumber != null ? '- Life Path Number: $lifePathNumber' : ''}

TASK: Write ONE sentence (20 words) about how this day specifically
affects this profile. Show the synthesis of the systems.

Example: "With your $moonSign Moon and Life Path $lifePathNumber, today
is perfect for [specific action based on profile]."

ONLY THE ONE SENTENCE, no introduction, no context.
''';
    }
  }

  /// Prompt: Tiefe Synthese (Variante C)
  String _buildDeepPersonalizationPrompt({
    required String baseHoroscope,
    required String sunSign,
    required String moonSign,
    String? ascendant,
    String? dayMaster,
    int? lifePathNumber,
    required String language,
  }) {
    if (language == 'de') {
      return '''
BASIS-HOROSKOP für $sunSign:
"$baseHoroscope"

USER-PROFIL:
- Sonnenzeichen: $sunSign
- Mondzeichen: $moonSign
${ascendant != null ? '- Aszendent: $ascendant' : ''}
${dayMaster != null ? '- Bazi Day Master: $dayMaster' : ''}
${lifePathNumber != null ? '- Life Path Number: $lifePathNumber' : ''}

AUFGABE: Schreibe 2-3 personalisierte Sätze (50 Wörter), die zeigen,
wie die Tagesenergie speziell für dieses Profil wirkt.

Zeige die Synthese aller drei Systeme:
- Western Astrology (Sonne/Mond/Aszendent)
- Bazi (Day Master)
- Numerologie (Life Path)

Fokus: Konkrete Handlungsempfehlungen basierend auf dem Profil.

NUR DIE 2-3 SÄTZE, keine Einleitung.
''';
    } else {
      return '''
BASE HOROSCOPE for $sunSign:
"$baseHoroscope"

USER PROFILE:
- Sun Sign: $sunSign
- Moon Sign: $moonSign
${ascendant != null ? '- Ascendant: $ascendant' : ''}
${dayMaster != null ? '- Bazi Day Master: $dayMaster' : ''}
${lifePathNumber != null ? '- Life Path Number: $lifePathNumber' : ''}

TASK: Write 2-3 personalized sentences (50 words) showing how
the daily energy specifically affects this profile.

Show the synthesis of all three systems:
- Western Astrology (Sun/Moon/Ascendant)
- Bazi (Day Master)
- Numerology (Life Path)

Focus: Concrete action recommendations based on the profile.

ONLY THE 2-3 SENTENCES, no introduction.
''';
    }
  }

  /// System-Prompt: Mini-Personalizer
  String _getMiniPersonalizationSystemPrompt(String language) {
    if (language == 'de') {
      return '''
Du bist eine Expertin für personalisierte Astrologie.

Deine Aufgabe: Schreibe EINEN prägnanten Satz, der zeigt, wie die
Tagesenergie speziell für ein User-Profil wirkt.

Anforderungen:
- Exakt EINEN Satz (20 Wörter)
- Zeige die Synthese: Western + Bazi + Numerologie
- Konkrete Handlungsempfehlung
- Nahtloser Übergang zum Basis-Horoskop

Beispiel:
"Mit deinem Löwe-Mond und Yang-Feuer ist heute ein perfekter Tag
für mutige Entscheidungen und kreative Präsentationen."
''';
    } else {
      return '''
You are an expert in personalized astrology.

Your task: Write ONE concise sentence showing how the daily energy
specifically affects a user profile.

Requirements:
- Exactly ONE sentence (20 words)
- Show the synthesis: Western + Bazi + Numerology
- Concrete action recommendation
- Seamless transition to base horoscope

Example:
"With your Leo Moon and Yang Fire, today is perfect for bold
decisions and creative presentations."
''';
    }
  }

  /// System-Prompt: Tiefe Synthese
  String _getDeepPersonalizationSystemPrompt(String language) {
    if (language == 'de') {
      return '''
Du bist eine Expertin für personalisierte Astrologie.

Deine Aufgabe: Schreibe 2-3 Sätze, die zeigen, wie die Tagesenergie
speziell für ein User-Profil wirkt.

Anforderungen:
- 2-3 Sätze (50 Wörter)
- Zeige die tiefe Synthese aller drei Systeme
- Konkrete, spezifische Handlungsempfehlungen
- Verbinde die Systeme logisch miteinander
- Nahtloser Übergang zum Basis-Horoskop

Beispiel:
"Mit deinem Krebs-Aszendenten und Löwe-Mond bildest du eine einzigartige
Brücke zwischen Sensibilität und Strahlkraft. Dein Yang-Feuer-Element
verstärkt diese Kombination heute besonders. Deine Life Path 9 erinnert
dich daran, diese Energie zum Wohl anderer einzusetzen."
''';
    } else {
      return '''
You are an expert in personalized astrology.

Your task: Write 2-3 sentences showing how the daily energy
specifically affects a user profile.

Requirements:
- 2-3 sentences (50 words)
- Show the deep synthesis of all three systems
- Concrete, specific action recommendations
- Connect the systems logically
- Seamless transition to base horoscope

Example:
"With your Cancer Ascendant and Leo Moon, you form a unique bridge
between sensitivity and radiance. Your Yang Fire element amplifies
this combination today. Your Life Path 9 reminds you to use this
energy for the benefit of others."
''';
    }
  }
}
