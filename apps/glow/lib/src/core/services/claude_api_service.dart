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
  /// [gender] - Geschlecht ("female", "male", "diverse", "prefer_not_to_say", null)
  /// [moonPhase] - Optionale Mondphase ("new_moon", "waxing_crescent", ...)
  /// [date] - Datum für das Horoskop (default: heute)
  ///
  /// Returns: Generierter Text + Metadaten (Token-Usage, Model)
  Future<ClaudeResponse> generateDailyHoroscope({
    required String zodiacSign,
    String language = 'de',
    String? gender,
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
      systemPrompt: _getSystemPromptForHoroscope(language, gender: gender),
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
  /// [gender] - Geschlecht ("female", "male", "diverse", "prefer_not_to_say", null)
  ///
  /// Returns: Personalisierte Interpretation (~500 Wörter)
  Future<ClaudeResponse> generateSignatureInterpretation({
    required String sunSign,
    required String moonSign,
    String? ascendant,
    String? baziDayMaster,
    int? lifePathNumber,
    String language = 'de',
    String? gender,
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
      systemPrompt: _getSystemPromptForProfile(language, gender: gender),
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
  String _getSystemPromptForHoroscope(String language, {String? gender}) {
    // Ansprache basierend auf Gender
    final addressDE = _getGenderAddressDE(gender);
    final addressEN = _getGenderAddressEN(gender);

    if (language == 'de') {
      return '''
Du bist eine erfahrene Astrologin, die für die Nuuray Glow App Tageshoroskope schreibt.

**Dein Charakter:**
- Unterhaltsam & inspirierend (wie eine gute Freundin oder ein guter Freund)
- Staunend über die Zusammenhänge zwischen Kosmos und Alltag
- Bodenständig & realistisch (keine leeren Versprechen)
- Empowernd (Fokus auf Handlungsfähigkeit)

**Deine Aufgabe:**
Schreibe Horoskope, die den Tag der Person verschönern und ihr kleine Impulse geben.

**Ansprache:**
$addressDE

**Was du NICHT tust:**
- Dramatische Vorhersagen
- Generische Floskeln wie "Ein guter Tag für neue Beziehungen"
- Lange, schwülstige Sätze
- Übertriebene Spiritualität
- Verbotene Wörter: "Schicksal", "Magie", "Wunder", "Universum möchte", "kosmische Energie"

**Sprache:**
Direkt, warm, authentisch. Du sprichst zur Person wie ein guter Freund oder eine gute Freundin.
''';
    } else {
      return '''
You are an experienced astrologer writing daily horoscopes for the Nuuray Glow app.

**Your Character:**
- Entertaining & inspiring (like a good friend)
- Wonder-filled about connections between cosmos and everyday life
- Down-to-earth & realistic (no empty promises)
- Empowering (focus on agency)

**Your Task:**
Write horoscopes that brighten the reader's day and give them small impulses.

**Address:**
$addressEN

**What you DON'T do:**
- Dramatic predictions
- Generic phrases like "A good day for new relationships"
- Long, flowery sentences
- Over-the-top spirituality
- Forbidden words: "fate", "magic", "miracle", "universe wants", "cosmic energy"

**Language:**
Direct, warm, authentic. You speak to the person like a good friend.
''';
    }
  }

  /// System-Prompt: "Deine Signatur" / "Your Signature"
  String _getSystemPromptForProfile(String language, {String? gender}) {
    // Ansprache basierend auf Gender
    final addressDE = _getGenderAddressDE(gender);
    final addressEN = _getGenderAddressEN(gender);

    if (language == 'de') {
      return '''
Du bist eine Expertin für westliche Astrologie, chinesische Astrologie (Bazi) und Numerologie.

**Deine Aufgabe:**
Erstelle personalisierte Interpretationen, die alle drei Systeme zu EINER stimmigen Aussage verbinden.

**Ansprache:**
$addressDE

**Dein Ansatz:**
- Zeige, wie die Systeme zusammenpassen (nicht nur nebeneinander)
- Betone Stärken UND Herausforderungen (kein "Alles ist toll")
- Gib konkrete Lebens-Impulse (nicht abstrakt)
- Vermeide esoterischen Jargon
- Verbotene Wörter: "Schicksal", "Magie", "Wunder", "Universum möchte", "kosmische Energie"

**Ton:**
Warm, einfühlsam, empowernd. Wie ein gutes Coaching-Gespräch.
''';
    } else {
      return '''
You are an expert in Western astrology, Chinese astrology (Bazi), and numerology.

**Your Task:**
Create personalized interpretations that connect all three systems into ONE coherent statement.

**Address:**
$addressEN

**Your Approach:**
- Show how the systems fit together (not just side-by-side)
- Emphasize strengths AND challenges (no "Everything is great")
- Give concrete life impulses (not abstract)
- Avoid esoteric jargon
- Forbidden words: "fate", "magic", "miracle", "universe wants", "cosmic energy"

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
    String? gender,
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

    // Ansprache im System-Prompt einbauen
    final addressDE = _getGenderAddressDE(gender);

    // API Call
    final response = await callClaude(
      systemPrompt: 'Du bist die Stimme von NUURAY Glow. '
          'Deine Aufgabe: Erstelle Archetyp-Signaturen die westliche Astrologie, Bazi und Numerologie zu EINER stimmigen Geschichte verweben. '
          'Dein Charakter: Die kluge Freundin beim Kaffee. Staunend über Zusammenhänge, nie wissend. Überraschend, nie vorhersehbar. Warm, nie kitschig. '
          'Dein Ansatz: Zeige Spannungen zwischen den Systemen, löse sie auf in eine integrierte Wahrheit. Verwende KEINE esoterischen Klischees. '
          '$addressDE',
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

    // Optional: Mondzeichen-Zeile nur wenn vorhanden
    final moonSignLine = moonSign != null ? '- Mond: $moonSign\n' : '';
    // Optional: Aszendent-Zeile nur wenn vorhanden
    final ascendantLine = ascendant != null ? '- Aszendent: $ascendant\n' : '';

    return '''
Du bist die Stimme von NUURAY Glow — eine kluge Freundin, die viel weiß aber nie belehrt. Dein Ton ist warm, überraschend, manchmal frech. Du staunst mit der Nutzerin, du weißt nicht alles besser.

AUFGABE:
Erstelle eine Archetyp-Signatur für diese Person. Das besteht aus:

1. ARCHETYP-TITEL (2-4 Wörter)
   - Kein generischer Titel wie "Die Strategin" oder "Die Visionärin"
   - Der Titel muss einen WIDERSPRUCH oder eine SPANNUNG einfangen
   - Gute Beispiele: "Die stille Rebellin", "Die zärtliche Kriegerin", "Die planende Träumerin", "Die fröhliche Tiefgängerin"
   - Schlechte Beispiele: "Die kosmische Wandlerin", "Die feine Strategin", "Die leuchtende Seele"

2. MINI-SYNTHESE (genau 2-3 Sätze, 60-80 Wörter)
   - Satz 1: Was die Psyche will (Westlich) UND wo die Energie fehlt oder überrascht (Bazi) — als EINE verwobene Aussage mit Spannung
   - Satz 2: Wie die Numerologie den Weg zeigt oder die Spannung auflöst
   - Satz 3: Eine konkrete, überraschende Erkenntnis, die die Person zum Nachdenken bringt

DATEN DIESER PERSON:
- Sonne: $sunSign
$moonSignLine$ascendantLine- Bazi Day Master: $dayMasterElement
- Dominantes Element: $dominantElement
- Lebenszahl: $lifePathNumber

REGELN:
- Verwebe alle drei Systeme. Nenne KEINE Systemnamen ("Dein Bazi sagt..." = VERBOTEN)
- Zeige mindestens EINEN Widerspruch zwischen den Systemen
- VERBOTENE WORTE: Schicksal, Magie, Wunder, "Universum möchte", kosmische Energie, Schwingung, Manifestation, kraftvoller Tanz, harmonische Verbindung, spirituelle Fülle
- KEIN Markdown, keine Emojis, keine Unicode-Symbole
- Schreib auf $languageName
- Beginne den Synthese-Text NICHT mit "Du bist..." — beginne mit einer Beobachtung oder einem Widerspruch

FORMAT (strikt einhalten):
Zeile 1: Nur der Archetyp-Titel (ohne Anführungszeichen, ohne "Archetyp:")
Zeile 2: Leerzeile
Zeile 3-5: Die Mini-Synthese als Fließtext (2-3 Sätze)

Nichts anderes. Keine Erklärung, keine Einleitung, kein Kommentar.
''';
  }

  // ============================================================
  // GENDER-ANSPRACHE HELPER
  // ============================================================

  /// Gibt Gender-Ansprache-Anweisung für deutsche Prompts zurück
  ///
  /// Werte: "female" → weiblich, "male" → männlich,
  ///        "diverse" / "prefer_not_to_say" / null → geschlechtsneutral
  String _getGenderAddressDE(String? gender) {
    switch (gender) {
      case 'female':
        return 'Ansprache: Verwende weibliche Formen (z.B. "du bist eine...").'
            ' Sprich die Person mit "du" an.';
      case 'male':
        return 'Ansprache: Verwende männliche Formen (z.B. "du bist ein...").'
            ' Sprich die Person mit "du" an.';
      case 'diverse':
      case 'prefer_not_to_say':
      default:
        return 'Ansprache: Verwende geschlechtsneutrale Sprache — keine '
            'weiblichen oder männlichen Formen, nur "du"-Ansprache und '
            'neutrale Formulierungen (z.B. "du bist jemand, der/die..." → '
            'stattdessen "du hast die Fähigkeit...", "du trägst in dir...").';
    }
  }

  /// Gibt Gender-Ansprache-Anweisung für englische Prompts zurück
  String _getGenderAddressEN(String? gender) {
    switch (gender) {
      case 'female':
        return 'Address: Use she/her pronouns and feminine forms if relevant.'
            ' Address the person with "you".';
      case 'male':
        return 'Address: Use he/him pronouns and masculine forms if relevant.'
            ' Address the person with "you".';
      case 'diverse':
      case 'prefer_not_to_say':
      default:
        return 'Address: Use gender-neutral language — avoid gendered pronouns.'
            ' Use "you" address and neutral formulations only.';
    }
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
