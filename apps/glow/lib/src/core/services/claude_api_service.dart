import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service für Claude API (Anthropic) Kommunikation
///
/// Generiert personalisierten Content für:
/// - Tageshoroskope
/// - Wochen-/Monatshoroskope (Premium)
/// - Partner-Check
/// - "Deine Signatur" Interpretationen (vormals Cosmic Profile)
///
/// Best Practices:
/// - Caching für häufig verwendete Prompts
/// - Kosten-Tracking (Token-Usage)
/// - Rate-Limiting (max. 50 Requests/Min)
/// - Fehlerbehandlung mit Retry-Logik
class ClaudeApiService {
  final String apiKey;
  final String baseUrl = 'https://api.anthropic.com/v1';
  final String model;

  ClaudeApiService({
    required this.apiKey,
    this.model = 'claude-sonnet-4-20250514', // Empfohlenes Model für MVP
  });

  /// Generiert ein Tageshoroskop für ein Sternzeichen
  ///
  /// [zodiacSign] - Sternzeichen (en: "aries", "taurus", ...)
  /// [language] - Sprache ("de" oder "en")
  /// [moonPhase] - Optionale Mondphase ("new_moon", "waxing_crescent", ...)
  /// [date] - Datum für das Horoskop (default: heute)
  ///
  /// Returns: Generierter Text + Metadaten (Token-Usage, Model)
  Future<ClaudeResponse> generateDailyHoroscope({
    required String zodiacSign,
    String language = 'de',
    String? moonPhase,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();

    // Prompt bauen
    final prompt = _buildDailyHoroscopePrompt(
      zodiacSign: zodiacSign,
      language: language,
      moonPhase: moonPhase,
      date: targetDate,
    );

    // API Call
    return await callClaude(
      systemPrompt: _getSystemPromptForHoroscope(language),
      userPrompt: prompt,
    );
  }

  /// Generiert eine Interpretation von "Deine Signatur" (Premium)
  ///
  /// [sunSign] - Sonnenzeichen
  /// [moonSign] - Mondzeichen
  /// [ascendant] - Aszendent (optional)
  /// [baziDayMaster] - Bazi Day Master (z.B. "丙火 Yang Fire")
  /// [lifePathNumber] - Numerologie Life Path Number
  /// [language] - Sprache
  ///
  /// Returns: Personalisierte Interpretation (~500 Wörter)
  Future<ClaudeResponse> generateSignatureInterpretation({
    required String sunSign,
    required String moonSign,
    String? ascendant,
    String? baziDayMaster,
    int? lifePathNumber,
    String language = 'de',
  }) async {
    final prompt = _buildSignaturePrompt(
      sunSign: sunSign,
      moonSign: moonSign,
      ascendant: ascendant,
      baziDayMaster: baziDayMaster,
      lifePathNumber: lifePathNumber,
      language: language,
    );

    return await callClaude(
      systemPrompt: _getSystemPromptForProfile(language),
      userPrompt: prompt,
    );
  }

  /// API Call (public für Variante B & C)
  Future<ClaudeResponse> callClaude({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final url = Uri.parse('$baseUrl/messages');

    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    };

    final body = jsonEncode({
      'model': model,
      'max_tokens': 2048, // Erhöht für längere Profile-Interpretationen
      'system': systemPrompt,
      'messages': [
        {
          'role': 'user',
          'content': userPrompt,
        }
      ],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ClaudeResponse.fromJson(data);
      } else {
        // Parse Error Details
        String errorDetail = response.body;
        try {
          final errorData = jsonDecode(response.body);
          errorDetail = errorData['error']?['message'] ?? response.body;
        } catch (_) {
          // Ignore JSON parse error
        }

        throw ClaudeApiException(
          'Claude API Error: ${response.statusCode}',
          errorDetail,
        );
      }
    } catch (e) {
      if (e is ClaudeApiException) rethrow;
      throw ClaudeApiException('Network Error', e.toString());
    }
  }

  /// Prompt-Builder: Tageshoroskop
  String _buildDailyHoroscopePrompt({
    required String zodiacSign,
    required String language,
    String? moonPhase,
    required DateTime date,
  }) {
    final zodiacNameDe = _getZodiacNameDe(zodiacSign);
    final zodiacNameEn = zodiacSign;

    if (language == 'de') {
      return '''
Schreibe ein Tageshoroskop für das Sternzeichen **$zodiacNameDe** ($zodiacNameEn) für den ${_formatDate(date)}.

${moonPhase != null ? 'Die aktuelle Mondphase ist: $_getMoonPhaseDe(moonPhase).' : ''}

**Anforderungen:**
- Länge: 80-120 Wörter
- Ton: Unterhaltsam, staunend, inspirierend (wie eine gute Freundin)
- Fokus: Tagesenergie, kleine Handlungsempfehlungen, emotionale Insights
- Keine generischen Floskeln
- Keine Übertreibungen oder unrealistische Vorhersagen
- Direkte Ansprache ("Du", nicht "Sie")

**Format:**
Nur der Fließtext, keine Überschrift, keine Formatierung.
''';
    } else {
      return '''
Write a daily horoscope for the zodiac sign **$zodiacNameEn** for ${_formatDate(date)}.

${moonPhase != null ? 'The current moon phase is: $moonPhase.' : ''}

**Requirements:**
- Length: 80-120 words
- Tone: Entertaining, wonder-filled, inspiring (like a good friend)
- Focus: Daily energy, small actionable tips, emotional insights
- No generic phrases
- No exaggerations or unrealistic predictions
- Direct address ("you")

**Format:**
Only the text, no heading, no formatting.
''';
    }
  }

  /// Prompt-Builder: "Deine Signatur" Interpretation
  String _buildSignaturePrompt({
    required String sunSign,
    required String moonSign,
    String? ascendant,
    String? baziDayMaster,
    int? lifePathNumber,
    required String language,
  }) {
    if (language == 'de') {
      return '''
Erstelle eine personalisierte Interpretation von "Deine Signatur" (Synthese aus 3 Systemen) für:

**Westliche Astrologie:**
- Sonnenzeichen: $sunSign
- Mondzeichen: $moonSign
${ascendant != null ? '- Aszendent: $ascendant' : ''}

${baziDayMaster != null ? '**Bazi (Chinesische Astrologie):**\n- Day Master: $baziDayMaster\n' : ''}

${lifePathNumber != null ? '**Numerologie:**\n- Life Path Number: $lifePathNumber\n' : ''}

**Aufgabe:**
Synthese der drei Systeme zu EINEM stimmigen Text über die Persönlichkeit.

**Anforderungen:**
- Länge: MINDESTENS 450 Wörter (wichtig!)
- Ton: Warm, einfühlsam, empowernd
- Struktur: 4 Absätze (Einleitung, Stärken, Herausforderungen, Lebensweg)
- Keine Auflistungen, sondern fließender Text
- Zeige die Verbindungen zwischen den Systemen auf
- Nimm dir Zeit für Details und Tiefe

**Format:**
Fließtext in Absätzen, keine Überschriften.
''';
    } else {
      return '''
Create a personalized interpretation of "Your Signature" (synthesis of 3 systems) for:

**Western Astrology:**
- Sun Sign: $sunSign
- Moon Sign: $moonSign
${ascendant != null ? '- Ascendant: $ascendant' : ''}

${baziDayMaster != null ? '**Bazi (Chinese Astrology):**\n- Day Master: $baziDayMaster\n' : ''}

${lifePathNumber != null ? '**Numerology:**\n- Life Path Number: $lifePathNumber\n' : ''}

**Task:**
Synthesize the three systems into ONE coherent text about the personality.

**Requirements:**
- Length: MINIMUM 450 words (important!)
- Tone: Warm, empathetic, empowering
- Structure: 4 paragraphs (Introduction, Strengths, Challenges, Life Path)
- No bullet points, flowing text
- Show the connections between the systems
- Take time for details and depth

**Format:**
Flowing text in paragraphs, no headings.
''';
    }
  }

  /// System-Prompt: Horoskope
  String _getSystemPromptForHoroscope(String language) {
    if (language == 'de') {
      return '''
Du bist eine erfahrene Astrologin, die für die Nuuray Glow App Tageshoroskope schreibt.

**Dein Charakter:**
- Unterhaltsam & inspirierend (wie eine gute Freundin)
- Staunend über die Magie des Kosmos
- Bodenständig & realistisch (keine leeren Versprechen)
- Empowernd (Fokus auf Handlungsfähigkeit)

**Deine Aufgabe:**
Schreibe Horoskope, die den Tag der Leserin verschönern und ihr kleine Impulse geben.

**Was du NICHT tust:**
- Dramatische Vorhersagen
- Generische Floskeln wie "Ein guter Tag für neue Beziehungen"
- Lange, schwülstige Sätze
- Übertriebene Spiritualität

**Sprache:**
Direkt, warm, authentisch. Du sprichst zur Leserin wie eine Freundin.
''';
    } else {
      return '''
You are an experienced astrologer writing daily horoscopes for the Nuuray Glow app.

**Your Character:**
- Entertaining & inspiring (like a good friend)
- Wonder-filled about the magic of the cosmos
- Down-to-earth & realistic (no empty promises)
- Empowering (focus on agency)

**Your Task:**
Write horoscopes that brighten the reader's day and give them small impulses.

**What you DON'T do:**
- Dramatic predictions
- Generic phrases like "A good day for new relationships"
- Long, flowery sentences
- Over-the-top spirituality

**Language:**
Direct, warm, authentic. You speak to the reader like a friend.
''';
    }
  }

  /// System-Prompt: "Deine Signatur" / "Your Signature"
  String _getSystemPromptForProfile(String language) {
    if (language == 'de') {
      return '''
Du bist eine Expertin für westliche Astrologie, chinesische Astrologie (Bazi) und Numerologie.

**Deine Aufgabe:**
Erstelle personalisierte Interpretationen, die alle drei Systeme zu EINER stimmigen Aussage verbinden.

**Dein Ansatz:**
- Zeige, wie die Systeme zusammenpassen (nicht nur nebeneinander)
- Betone Stärken UND Herausforderungen (kein "Alles ist toll")
- Gib konkrete Lebens-Impulse (nicht abstrakt)
- Vermeide esoterischen Jargon

**Ton:**
Warm, einfühlsam, empowernd. Wie ein gutes Coaching-Gespräch.
''';
    } else {
      return '''
You are an expert in Western astrology, Chinese astrology (Bazi), and numerology.

**Your Task:**
Create personalized interpretations that connect all three systems into ONE coherent statement.

**Your Approach:**
- Show how the systems fit together (not just side-by-side)
- Emphasize strengths AND challenges (no "Everything is great")
- Give concrete life impulses (not abstract)
- Avoid esoteric jargon

**Tone:**
Warm, empathetic, empowering. Like a good coaching conversation.
''';
    }
  }

  // Helper Functions
  String _getZodiacNameDe(String zodiacSign) {
    const names = {
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
    return names[zodiacSign] ?? zodiacSign;
  }

  String _getMoonPhaseDe(String moonPhase) {
    const phases = {
      'new_moon': 'Neumond',
      'waxing_crescent': 'Zunehmender Sichelmond',
      'first_quarter': 'Erstes Viertel',
      'waxing_gibbous': 'Zunehmender Dreiviertelmond',
      'full_moon': 'Vollmond',
      'waning_gibbous': 'Abnehmender Dreiviertelmond',
      'last_quarter': 'Letztes Viertel',
      'waning_crescent': 'Abnehmender Sichelmond',
    };
    return phases[moonPhase] ?? moonPhase;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember'
    ];
    return '${date.day}. ${months[date.month - 1]} ${date.year}';
  }

  /// Generiere Archetyp-Signatur-Satz (einmalig, gecacht)
  ///
  /// Erstellt einen personalisierten 2-3 Sätze Text, der alle drei
  /// astrologischen Systeme zu einer stimmigen Erzählung verwebt.
  ///
  /// Kosten: ~200 Input + ~80 Output Tokens = ~$0.001 pro Call
  ///
  /// Returns: Signatur-Satz als String (2-3 Sätze, max. 200 Zeichen)
  Future<String> generateArchetypeSignature({
    required String archetypeName,
    required String baziAdjective,
    required int lifePathNumber,
    required String sunSign,
    String? moonSign,
    String? ascendant,
    required String dayMasterElement,
    required String dominantElement,
    required String language,
  }) async {
    // Import Prompt-Template dynamisch
    final prompt = _buildArchetypeSignaturePrompt(
      archetypeName: archetypeName,
      baziAdjective: baziAdjective,
      lifePathNumber: lifePathNumber,
      sunSign: sunSign,
      moonSign: moonSign,
      ascendant: ascendant,
      dayMasterElement: dayMasterElement,
      dominantElement: dominantElement,
      language: language,
    );

    // API Call
    final response = await callClaude(
      systemPrompt: 'Du bist Expertin für Astrologie und Numerologie. '
          'Deine Texte sind warm, persönlich und einfühlsam.',
      userPrompt: prompt,
    );

    return response.text.trim();
  }

  /// Baue Archetyp-Signatur Prompt
  String _buildArchetypeSignaturePrompt({
    required String archetypeName,
    required String baziAdjective,
    required int lifePathNumber,
    required String sunSign,
    String? moonSign,
    String? ascendant,
    required String dayMasterElement,
    required String dominantElement,
    required String language,
  }) {
    final languageName = language.toUpperCase() == 'DE' ? 'Deutsch' : 'English';

    return '''
Erstelle einen persönlichen Signatur-Satz (2-3 Sätze, max. 280 Zeichen)
für folgendes Profil:

**Sternzeichen:** $sunSign
**Bazi Day Master:** $dayMasterElement
**Lebenspfad:** $lifePathNumber

KRITISCH - Diese drei Begriffe MÜSSEN im Text vorkommen:
1. Sternzeichen: $sunSign
2. Bazi Element: $dayMasterElement
3. Lebenspfad-Zahl: $lifePathNumber

Regeln:
- Verwebe ALLE DREI SYSTEME zu EINEM poetischen Text.
- Erwähne EXPLIZIT: $sunSign (Sternzeichen), $dayMasterElement (Bazi), $lifePathNumber (Lebenspfad).
- Beispiel (Deutsch): "Deine feurige Schütze-Natur tanzt mit der kristallklaren Präzision des Yin-Metalls durch die Weiten des Lebens, während die Kraft der Acht den Weg zu wahrer Fülle weist."
- Beispiel (English): "Your fiery Sagittarius nature dances with Yin Metal's crystalline precision through life's expanses, while the power of Eight points to true abundance."
- Ton: Warm, staunend, poetisch.
- Beginne NICHT mit "Du bist".
- Erwähne NICHT Mond oder Aszendent - NUR die drei Hauptbegriffe!
- Sprache: $languageName
- Gib NUR den Signatur-Satz zurück.
''';
  }
}

/// Response-Model für Claude API
class ClaudeResponse {
  final String text;
  final String model;
  final int inputTokens;
  final int outputTokens;

  ClaudeResponse({
    required this.text,
    required this.model,
    required this.inputTokens,
    required this.outputTokens,
  });

  factory ClaudeResponse.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as List;
    final textBlock = content.firstWhere(
      (block) => block['type'] == 'text',
      orElse: () => {'text': ''},
    );

    return ClaudeResponse(
      text: textBlock['text'] ?? '',
      model: json['model'] ?? '',
      inputTokens: json['usage']?['input_tokens'] ?? 0,
      outputTokens: json['usage']?['output_tokens'] ?? 0,
    );
  }

  /// Gesamtkosten für diesen Call (in USD)
  double get estimatedCost {
    // Claude Sonnet 4 Pricing (Stand Feb 2026):
    // Input: $3.00 / 1M tokens
    // Output: $15.00 / 1M tokens
    final inputCost = (inputTokens / 1000000) * 3.0;
    final outputCost = (outputTokens / 1000000) * 15.0;
    return inputCost + outputCost;
  }

  int get totalTokens => inputTokens + outputTokens;
}

/// Exception für Claude API Fehler
class ClaudeApiException implements Exception {
  final String message;
  final String? details;

  ClaudeApiException(this.message, [this.details]);

  @override
  String toString() => 'ClaudeApiException: $message${details != null ? '\nDetails: $details' : ''}';
}
