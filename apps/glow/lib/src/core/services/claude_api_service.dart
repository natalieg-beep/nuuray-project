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
      gender: gender,
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
    String? gender,
  }) {
    final languageName = language.toUpperCase() == 'DE' ? 'Deutsch' : 'English';

    // Optional: Mondzeichen-Zeile nur wenn vorhanden
    final moonSignLine = moonSign != null ? '- Mond: $moonSign\n' : '';
    // Optional: Aszendent-Zeile nur wenn vorhanden
    final ascendantLine = ascendant != null ? '- Aszendent: $ascendant\n' : '';

    // Gender-abhängige Beispiele für den Archetyp-Titel
    final String titleExamplesGood;
    final String titleExamplesBad;
    final String personRef;
    if (gender == 'male') {
      titleExamplesGood = '"Der stille Rebell", "Der zärtliche Krieger", "Der planende Träumer", "Der fröhliche Tiefgänger"';
      titleExamplesBad = '"Der kosmische Wandler", "Der feine Stratege", "Die leuchtende Seele"';
      personRef = 'dieser Person';
    } else if (gender == 'female') {
      titleExamplesGood = '"Die stille Rebellin", "Die zärtliche Kriegerin", "Die planende Träumerin", "Die fröhliche Tiefgängerin"';
      titleExamplesBad = '"Die kosmische Wandlerin", "Die feine Strategin", "Die leuchtende Seele"';
      personRef = 'dieser Person';
    } else {
      titleExamplesGood = '"Stille Rebell·in", "Zärtliche·r Krieger·in", "Planende·r Träumer·in", "Fröhliche·r Tiefgänger·in"';
      titleExamplesBad = '"Kosmische·r Wandler·in", "Feine·r Strateg·in", "Leuchtende Seele"';
      personRef = 'dieser Person';
    }

    return '''
Du bist die Stimme von NUURAY Glow — klug, warm, überraschend, manchmal frech. Du staunst mit $personRef, du weißt nicht alles besser.

AUFGABE:
Erstelle eine Archetyp-Signatur für diese Person. Das besteht aus:

1. ARCHETYP-TITEL (2-4 Wörter)
   - Kein generischer Titel wie "Strateg·in" oder "Visionär·in"
   - Der Titel muss einen WIDERSPRUCH oder eine SPANNUNG einfangen
   - Gute Beispiele: $titleExamplesGood
   - Schlechte Beispiele: $titleExamplesBad

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

  /// Generiert die tiefe Drei-System-Synthese für "Deine Signatur"
  ///
  /// Das ist das Herzstück der App — eine tiefe, personalisierte
  /// Analyse, die alle drei Systeme zu einer stimmigen Lebensgeschichte
  /// verwebt. Folgt dem NUURAY Brand Soul Dokument exakt.
  ///
  /// Kosten: ~500 Input + ~700 Output Tokens = ~$0.012 pro Call (einmalig)
  ///
  /// Returns: Fließtext, 700-1000 Wörter, kein Markdown
  Future<String> generateDeepSynthesis({
    required String sunSign,
    required String? moonSign,
    required String? ascendantSign,
    required String? baziDayStem,
    required String? baziElement,
    required String? baziYearStem,
    required String? baziMonthStem,
    required int? lifePathNumber,
    required int? birthdayNumber,
    required int? personalYear,
    required List<int>? challengeNumbers,
    required int? karmicDebtLifePath,
    required List<int>? karmicLessons,
    required String language,
    required String? gender,
  }) async {
    // Geburtszeit vorhanden? Entscheidet über Vollständigkeit des Charts
    final hasBirthTime = moonSign != null || ascendantSign != null;

    final prompt = _buildDeepSynthesisPrompt(
      sunSign: sunSign,
      moonSign: moonSign,
      ascendantSign: ascendantSign,
      baziDayStem: baziDayStem,
      baziElement: baziElement,
      baziYearStem: baziYearStem,
      baziMonthStem: baziMonthStem,
      lifePathNumber: lifePathNumber,
      birthdayNumber: birthdayNumber,
      personalYear: personalYear,
      challengeNumbers: challengeNumbers,
      karmicDebtLifePath: karmicDebtLifePath,
      karmicLessons: karmicLessons,
      language: language,
      hasBirthTime: hasBirthTime,
    );

    final systemPrompt = _buildDeepSynthesisSystemPrompt(language, gender: gender);

    final response = await _callClaudeWithMaxTokens(
      systemPrompt: systemPrompt,
      userPrompt: prompt,
      maxTokens: 4096, // Genug für 700-1000 Wörter
    );

    return response.text.trim();
  }

  // ============================================================
  // SIGNATUR-CHECK-IN
  // ============================================================

  /// Generiert eine kurze, direkte Antwort auf den Check-In
  ///
  /// Input: Der gecachte Synthese-Text + die 3 User-Antworten
  /// Output: 2-3 Sätze + 1 konkreter Impuls (~120-150 Tokens)
  /// Kosten: ~$0.003-0.004 pro Call
  Future<Map<String, String>> generateCheckinResponse({
    required String synthesisText,
    required String categoryLabel,
    required String emotionLabel,
    required String needLabel,
    required String language,
    required String? gender,
  }) async {
    final systemPrompt = _buildCheckinSystemPrompt(language, gender: gender);
    final userPrompt = _buildCheckinUserPrompt(
      synthesisText: synthesisText,
      categoryLabel: categoryLabel,
      emotionLabel: emotionLabel,
      needLabel: needLabel,
      language: language,
    );

    final response = await _callClaudeWithMaxTokens(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      maxTokens: 512,
    );

    final text = response.text.trim();

    // Parse: Trenne result_text und impulse_text am Marker "Impuls:"
    final impulseMarker = language == 'de' ? 'Impuls:' : 'Impulse:';
    final parts = text.split(impulseMarker);

    final resultText = parts[0].trim();
    final impulseText = parts.length > 1 ? parts[1].trim() : '';

    return {
      'result_text': resultText,
      'impulse_text': impulseText,
    };
  }

  /// System-Prompt für Check-In — kurz und direkt
  String _buildCheckinSystemPrompt(String language, {String? gender}) {
    final addressDE = _getGenderAddressDE(gender);
    final addressEN = _getGenderAddressEN(gender);

    if (language.toUpperCase() == 'DE') {
      return '''
Du bist die Stimme von NUURAY Glow.

ANSPRACHE (gilt für den gesamten Text — keine Ausnahmen):
$addressDE

Du hast diese Person bereits durch ihre tiefe Signatur begleitet.
Jetzt fragt sie sich: Was bedeutet meine Signatur GENAU JETZT für mich?

REGELN:
- Antworte direkt. 2-3 Sätze die sitzen.
- Kein "Als [Zeichen]..." — nur die Wahrheit die diese Kombination hat.
- Beziehe dich auf KONKRETE Elemente aus der Synthese (Zahlen, Elemente, Zeichen).
- Danach: Ein konkreter Impuls für heute (1 Satz).
- Der Impuls ist KONKRET — kein "vielleicht", kein "versuche", kein "denke darüber nach".
- Schreibe Fließtext, KEIN Markdown, keine Listen, keine Überschriften.
- Markiere den Impuls mit "Impuls:" auf einer neuen Zeile.

VERBOTEN: "Die Sterne sagen...", "Das Universum möchte...", "Schicksal", "Magie", "Positive Schwingungen"
''';
    } else {
      return '''
You are the voice of NUURAY Glow.

ADDRESS (applies to the entire text — no exceptions):
$addressEN

You have already accompanied this person through their deep signature synthesis.
Now they're asking: What does my signature mean RIGHT NOW?

RULES:
- Answer directly. 2-3 sentences that hit home.
- No "As a [sign]..." — only the truth this combination holds.
- Reference SPECIFIC elements from the synthesis (numbers, elements, signs).
- Then: One concrete impulse for today (1 sentence).
- The impulse is CONCRETE — no "maybe", no "try to", no "think about".
- Write flowing text, NO Markdown, no lists, no headings.
- Mark the impulse with "Impulse:" on a new line.

FORBIDDEN: "The stars say...", "The universe wants...", "destiny", "magic", "positive vibrations"
''';
    }
  }

  /// User-Prompt für Check-In — Synthese-Text + 3 Antworten
  String _buildCheckinUserPrompt({
    required String synthesisText,
    required String categoryLabel,
    required String emotionLabel,
    required String needLabel,
    required String language,
  }) {
    if (language.toUpperCase() == 'DE') {
      return '''
Hier ist die tiefe Synthese dieser Person:
---
$synthesisText
---

Diese Person hat angegeben:
- Was sie gerade beschäftigt: $categoryLabel
- Wie es sich anfühlt: $emotionLabel
- Was sie braucht: $needLabel

Destilliere aus der Synthese 2-3 Sätze die genau das adressieren.
Dann 1 konkreter Impuls für heute.

Format:
[2-3 Sätze Fließtext]

Impuls: [1 Satz]
''';
    } else {
      return '''
Here is this person's deep synthesis:
---
$synthesisText
---

This person indicated:
- What occupies them right now: $categoryLabel
- How it feels: $emotionLabel
- What they need: $needLabel

Distill 2-3 sentences from the synthesis that directly address this.
Then 1 concrete impulse for today.

Format:
[2-3 sentences flowing text]

Impulse: [1 sentence]
''';
    }
  }

  // ============================================================
  // KEY INSIGHTS + REFLEXIONSFRAGEN
  // ============================================================

  /// Extrahiert 3 Schlüsselerkenntnisse + 7 Reflexionsfragen aus der Deep Synthesis
  ///
  /// Input: Der gecachte Synthese-Text (~800 Tokens) + kurzer Prompt (~200 Tokens)
  /// Output: 3 Insights (je Label + Text) + 7 Fragen (~600 Tokens)
  /// Kosten: ~$0.005 pro User (einmalig, gecacht in profiles)
  Future<Map<String, dynamic>> generateKeyInsightsAndQuestions({
    required String synthesisText,
    required String language,
    required String? gender,
  }) async {
    final systemPrompt = _buildKeyInsightsSystemPrompt(language, gender: gender);
    final userPrompt = _buildKeyInsightsUserPrompt(
      synthesisText: synthesisText,
      language: language,
    );

    final response = await _callClaudeWithMaxTokens(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      maxTokens: 2048,
    );

    final text = response.text.trim();

    // Parse: Strukturiertes Format mit Markern
    final insights = <Map<String, String>>[];
    final questions = <String>[];

    // Insights extrahieren (INSIGHT_1_LABEL: ... INSIGHT_1_TEXT: ...)
    for (int i = 1; i <= 3; i++) {
      final labelMatch = RegExp('INSIGHT_${i}_LABEL:\\s*(.+)', multiLine: true).firstMatch(text);
      final textMatch = RegExp('INSIGHT_${i}_TEXT:\\s*(.+)', multiLine: true).firstMatch(text);

      if (labelMatch != null && textMatch != null) {
        insights.add({
          'label': labelMatch.group(1)!.trim(),
          'text': textMatch.group(1)!.trim(),
        });
      }
    }

    // Fragen extrahieren (QUESTION_1: ... QUESTION_2: ...)
    for (int i = 1; i <= 7; i++) {
      final match = RegExp('QUESTION_$i:\\s*(.+)', multiLine: true).firstMatch(text);
      if (match != null) {
        questions.add(match.group(1)!.trim());
      }
    }

    return {
      'key_insights': insights,
      'reflection_questions': questions,
    };
  }

  /// System-Prompt für Key Insights + Reflexionsfragen Extraktion
  String _buildKeyInsightsSystemPrompt(String language, {String? gender}) {
    final addressDE = _getGenderAddressDE(gender);
    final addressEN = _getGenderAddressEN(gender);

    if (language.toUpperCase() == 'DE') {
      return '''
Du bist die Stimme von NUURAY Glow.

ANSPRACHE (gilt für den gesamten Text — keine Ausnahmen):
$addressDE

Du hast bereits eine tiefe Synthese für diese Person geschrieben. Jetzt extrahierst du daraus:

1. DREI SCHLÜSSELERKENNTNISSE — die härtesten, ehrlichsten Kernaussagen
   - Jede Erkenntnis besteht aus einem LABEL (2-4 Wörter, z.B. "Das Muster", "Der blinde Fleck", "Die Auflösung") und einem TEXT (2-3 Sätze)
   - Die drei Erkenntnisse decken verschiedene Aspekte ab: ein wiederkehrendes Muster, ein blinder Fleck, und eine auflösende Wahrheit
   - Kein Weichspülen — das sind die Sätze die weh tun und sich trotzdem richtig anfühlen
   - Beziehe dich auf KONKRETE Elemente aus der Synthese (Elemente, Zahlen, Metaphern)

2. SIEBEN REFLEXIONSFRAGEN — Fragen die aus den Spannungsfeldern der Synthese entstehen
   - Jede Frage greift ein konkretes Thema aus der Synthese auf
   - Die Fragen geben KEINE Antwort — sie laden zum Nachdenken ein
   - Formulierung: Direkt, persönlich, manchmal unbequem
   - Jede Frage steht für sich — kein Kontext nötig
   - Variiere die Fragetypen: "In welchem Bereich...", "Was wäre wenn...", "Wo hast du...", "Was kostet es dich..."

VERBOTEN: "Die Sterne sagen...", "Das Universum möchte...", "Schicksal", "Magie", "Positive Schwingungen"
Kein Markdown, keine Emojis, keine Listen-Formatierung.

FORMAT (strikt einhalten):
INSIGHT_1_LABEL: [2-4 Wörter]
INSIGHT_1_TEXT: [2-3 Sätze]
INSIGHT_2_LABEL: [2-4 Wörter]
INSIGHT_2_TEXT: [2-3 Sätze]
INSIGHT_3_LABEL: [2-4 Wörter]
INSIGHT_3_TEXT: [2-3 Sätze]
QUESTION_1: [Frage]
QUESTION_2: [Frage]
QUESTION_3: [Frage]
QUESTION_4: [Frage]
QUESTION_5: [Frage]
QUESTION_6: [Frage]
QUESTION_7: [Frage]

Nichts anderes. Keine Einleitung, keine Erklärung, kein Kommentar.
''';
    } else {
      return '''
You are the voice of NUURAY Glow.

ADDRESS (applies to the entire text — no exceptions):
$addressEN

You have already written a deep synthesis for this person. Now you extract from it:

1. THREE KEY INSIGHTS — the hardest, most honest core statements
   - Each insight consists of a LABEL (2-4 words, e.g. "The Pattern", "The Blind Spot", "The Resolution") and a TEXT (2-3 sentences)
   - The three insights cover different aspects: a recurring pattern, a blind spot, and a resolving truth
   - No sugarcoating — these are the sentences that sting and still feel right
   - Reference SPECIFIC elements from the synthesis (elements, numbers, metaphors)

2. SEVEN REFLECTION QUESTIONS — questions that arise from the synthesis's tension fields
   - Each question picks up a concrete theme from the synthesis
   - The questions give NO answers — they invite reflection
   - Phrasing: Direct, personal, sometimes uncomfortable
   - Each question stands alone — no context needed
   - Vary question types: "In which area...", "What if...", "Where did you...", "What does it cost you..."

FORBIDDEN: "The stars say...", "The universe wants...", "destiny", "magic", "positive vibrations"
No Markdown, no emojis, no list formatting.

FORMAT (strictly follow):
INSIGHT_1_LABEL: [2-4 words]
INSIGHT_1_TEXT: [2-3 sentences]
INSIGHT_2_LABEL: [2-4 words]
INSIGHT_2_TEXT: [2-3 sentences]
INSIGHT_3_LABEL: [2-4 words]
INSIGHT_3_TEXT: [2-3 sentences]
QUESTION_1: [question]
QUESTION_2: [question]
QUESTION_3: [question]
QUESTION_4: [question]
QUESTION_5: [question]
QUESTION_6: [question]
QUESTION_7: [question]

Nothing else. No introduction, no explanation, no commentary.
''';
    }
  }

  /// User-Prompt für Key Insights + Reflexionsfragen Extraktion
  String _buildKeyInsightsUserPrompt({
    required String synthesisText,
    required String language,
  }) {
    if (language.toUpperCase() == 'DE') {
      return '''
Hier ist die tiefe Synthese dieser Person:
---
$synthesisText
---

Extrahiere daraus:
1. Die 3 härtesten Schlüsselerkenntnisse (Label + Text)
2. 7 Reflexionsfragen die aus den Spannungsfeldern entstehen

Halte dich strikt an das vorgegebene Format.
''';
    } else {
      return '''
Here is this person's deep synthesis:
---
$synthesisText
---

Extract from it:
1. The 3 hardest key insights (Label + Text)
2. 7 reflection questions arising from the tension fields

Strictly follow the specified format.
''';
    }
  }

  // ============================================================
  // REPORT-KAPITEL (PDF Export)
  // ============================================================

  /// Generiert das Western Astrology Kapitel für den Signatur-Report
  ///
  /// Personalisierter Text über Sonne, Mond, Aszendent und deren Zusammenspiel.
  /// ~500 Wörter, NUURAY Brand Voice, einmalig gecacht.
  /// Kosten: ~$0.008 pro User
  Future<String> generateChapterWestern({
    required String sunSign,
    required String? moonSign,
    required String? ascendantSign,
    required double? sunDegree,
    required double? moonDegree,
    required double? ascendantDegree,
    required String language,
    required String? gender,
  }) async {
    final systemPrompt = _buildChapterSystemPrompt(language, gender: gender);
    final userPrompt = _buildChapterWesternUserPrompt(
      sunSign: sunSign,
      moonSign: moonSign,
      ascendantSign: ascendantSign,
      sunDegree: sunDegree,
      moonDegree: moonDegree,
      ascendantDegree: ascendantDegree,
      language: language,
    );

    final response = await _callClaudeWithMaxTokens(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      maxTokens: 2048,
    );

    return response.text.trim();
  }

  /// Generiert das Bazi Kapitel für den Signatur-Report
  ///
  /// Personalisierter Text über Day Master, Vier Säulen, Element-Balance.
  /// ~500 Wörter, NUURAY Brand Voice, einmalig gecacht.
  /// Kosten: ~$0.008 pro User
  Future<String> generateChapterBazi({
    required String? baziDayStem,
    required String? baziDayBranch,
    required String? baziElement,
    required String? baziYearStem,
    required String? baziYearBranch,
    required String? baziMonthStem,
    required String? baziMonthBranch,
    required String? baziHourStem,
    required String? baziHourBranch,
    required String language,
    required String? gender,
  }) async {
    final systemPrompt = _buildChapterSystemPrompt(language, gender: gender);
    final userPrompt = _buildChapterBaziUserPrompt(
      baziDayStem: baziDayStem,
      baziDayBranch: baziDayBranch,
      baziElement: baziElement,
      baziYearStem: baziYearStem,
      baziYearBranch: baziYearBranch,
      baziMonthStem: baziMonthStem,
      baziMonthBranch: baziMonthBranch,
      baziHourStem: baziHourStem,
      baziHourBranch: baziHourBranch,
      language: language,
    );

    final response = await _callClaudeWithMaxTokens(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      maxTokens: 2048,
    );

    return response.text.trim();
  }

  /// Generiert das Numerologie Kapitel für den Signatur-Report
  ///
  /// Personalisierter Text über Life Path, Karmic Debt, Challenge Numbers.
  /// ~600 Wörter (mehr Datenpunkte), NUURAY Brand Voice, einmalig gecacht.
  /// Kosten: ~$0.010 pro User
  Future<String> generateChapterNumerology({
    required int? lifePathNumber,
    required int? birthdayNumber,
    required int? attitudeNumber,
    required int? personalYear,
    required int? maturityNumber,
    required int? birthExpressionNumber,
    required int? birthSoulUrgeNumber,
    required int? currentExpressionNumber,
    required int? currentSoulUrgeNumber,
    required int? karmicDebtLifePath,
    required List<int>? karmicLessons,
    required List<int>? challengeNumbers,
    required String language,
    required String? gender,
  }) async {
    final systemPrompt = _buildChapterSystemPrompt(language, gender: gender);
    final userPrompt = _buildChapterNumerologyUserPrompt(
      lifePathNumber: lifePathNumber,
      birthdayNumber: birthdayNumber,
      attitudeNumber: attitudeNumber,
      personalYear: personalYear,
      maturityNumber: maturityNumber,
      birthExpressionNumber: birthExpressionNumber,
      birthSoulUrgeNumber: birthSoulUrgeNumber,
      currentExpressionNumber: currentExpressionNumber,
      currentSoulUrgeNumber: currentSoulUrgeNumber,
      karmicDebtLifePath: karmicDebtLifePath,
      karmicLessons: karmicLessons,
      challengeNumbers: challengeNumbers,
      language: language,
    );

    final response = await _callClaudeWithMaxTokens(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      maxTokens: 2048,
    );

    return response.text.trim();
  }

  /// Shared System-Prompt für alle Report-Kapitel
  ///
  /// NUURAY Brand Voice — jedes Kapitel fokussiert auf EIN System,
  /// aber immer im Bewusstsein der anderen beiden.
  String _buildChapterSystemPrompt(String language, {String? gender}) {
    final addressDE = _getGenderAddressDE(gender);
    final addressEN = _getGenderAddressEN(gender);

    if (language.toUpperCase() == 'DE') {
      return '''
Du bist die Stimme von NUURAY Glow — klug, warm, überraschend, manchmal frech. Du weißt nicht alles besser. Du staunst mit der Person, du erklärst ihr nicht die Welt.

ANSPRACHE:
$addressDE

DEIN TON:
- Die kluge Freundin beim Kaffee. Nicht die Professorin.
- Zeige, was die Daten BEDEUTEN — nicht was sie SIND.
- Jeder Absatz muss eine Erkenntnis enthalten, nicht nur Information.
- Beginne mit etwas Konkretem, Erlebbarem — nicht mit einer Definition.
- Spannungen und Widersprüche sind Features, keine Bugs.

VERBOTENE WORTE:
Schicksal, Magie, Wunder, "Universum möchte", kosmische Energie, Schwingung, Manifestation, kraftvoller Tanz, harmonische Verbindung, spirituelle Fülle, "die Sterne sagen"

FORMAT:
- Fließtext, 5-7 Absätze, 400-600 Wörter
- KEIN Markdown (keine **, keine ##, keine Listen)
- Absätze durch doppelte Zeilenumbrüche getrennt
- Beginne NICHT mit "Du bist..."
''';
    } else {
      return '''
You are the voice of NUURAY Glow — smart, warm, surprising, sometimes cheeky. You don't know everything. You marvel alongside the person, you don't lecture them.

ADDRESS:
$addressEN

YOUR TONE:
- The clever friend over coffee. Not the professor.
- Show what the data MEANS — not what it IS.
- Every paragraph must contain an insight, not just information.
- Start with something concrete, experiential — not a definition.
- Tensions and contradictions are features, not bugs.

FORBIDDEN WORDS:
Destiny, magic, miracle, "universe wants", cosmic energy, vibration, manifestation, powerful dance, harmonious connection, spiritual abundance, "the stars say"

FORMAT:
- Flowing text, 5-7 paragraphs, 400-600 words
- NO Markdown (no **, no ##, no lists)
- Paragraphs separated by double line breaks
- Do NOT start with "You are..."
''';
    }
  }

  /// User-Prompt für Western Astrology Kapitel
  String _buildChapterWesternUserPrompt({
    required String sunSign,
    required String? moonSign,
    required String? ascendantSign,
    required double? sunDegree,
    required double? moonDegree,
    required double? ascendantDegree,
    required String language,
  }) {
    final isDe = language.toUpperCase() == 'DE';
    final sunName = isDe ? _getZodiacNameDe(sunSign) : _getZodiacNameEn(sunSign);
    final moonName = moonSign != null ? (isDe ? _getZodiacNameDe(moonSign) : _getZodiacNameEn(moonSign)) : null;
    final ascName = ascendantSign != null ? (isDe ? _getZodiacNameDe(ascendantSign) : _getZodiacNameEn(ascendantSign)) : null;

    if (isDe) {
      final moonLine = moonName != null
          ? '- Mond: $moonName${moonDegree != null ? ' (${moonDegree.toStringAsFixed(1)}°)' : ''}'
          : '- Mond: Nicht berechnet (keine Geburtszeit)';
      final ascLine = ascName != null
          ? '- Aszendent: $ascName${ascendantDegree != null ? ' (${ascendantDegree.toStringAsFixed(1)}°)' : ''}'
          : '- Aszendent: Nicht berechnet (keine Geburtszeit)';

      return '''
KAPITEL: DEINE PSYCHE — Westliche Astrologie

DATEN:
- Sonne: $sunName${sunDegree != null ? ' (${sunDegree.toStringAsFixed(1)}°)' : ''}
$moonLine
$ascLine

DEINE AUFGABE:
Schreibe ein Kapitel das erklärt, wie diese drei (oder zwei, falls Mond/Aszendent fehlen) zusammenspielen. Nicht: "Die Sonne steht für X." Sondern: Was bedeutet diese Kombination im Alltag? Wo entsteht Spannung zwischen Sonne und Mond? Wie zeigt sich der Aszendent nach außen — und widerspricht er vielleicht dem inneren Erleben?

Nutze die Grad-Positionen für Nuancen, wenn vorhanden (z.B. "Deine Sonne steht früh im Zeichen — das Thema formt sich noch, es hat eine Suchqualität").

400-600 Wörter. Fließtext. Kein Markdown.
''';
    } else {
      final moonLine = moonName != null
          ? '- Moon: $moonName${moonDegree != null ? ' (${moonDegree.toStringAsFixed(1)}°)' : ''}'
          : '- Moon: Not calculated (no birth time)';
      final ascLine = ascName != null
          ? '- Ascendant: $ascName${ascendantDegree != null ? ' (${ascendantDegree.toStringAsFixed(1)}°)' : ''}'
          : '- Ascendant: Not calculated (no birth time)';

      return '''
CHAPTER: YOUR PSYCHE — Western Astrology

DATA:
- Sun: $sunName${sunDegree != null ? ' (${sunDegree.toStringAsFixed(1)}°)' : ''}
$moonLine
$ascLine

YOUR TASK:
Write a chapter explaining how these three (or two, if Moon/Ascendant are missing) work together. Not: "The Sun stands for X." Instead: What does this combination mean in daily life? Where does tension arise between Sun and Moon? How does the Ascendant show itself outwardly — and does it perhaps contradict the inner experience?

Use degree positions for nuances when available (e.g., "Your Sun sits early in the sign — the theme is still forming, it has a seeking quality").

400-600 words. Flowing text. No Markdown.
''';
    }
  }

  /// User-Prompt für Bazi Kapitel
  String _buildChapterBaziUserPrompt({
    required String? baziDayStem,
    required String? baziDayBranch,
    required String? baziElement,
    required String? baziYearStem,
    required String? baziYearBranch,
    required String? baziMonthStem,
    required String? baziMonthBranch,
    required String? baziHourStem,
    required String? baziHourBranch,
    required String language,
  }) {
    final isDe = language.toUpperCase() == 'DE';

    // Säulen-Kontext aufbauen
    final dayMaster = baziDayStem != null ? _getBaziElementName(baziDayStem, language) : (isDe ? 'Unbekannt' : 'Unknown');
    final dayBranch = baziDayBranch ?? (isDe ? 'Unbekannt' : 'Unknown');
    final dominantEl = baziElement != null ? _getBaziElementName(baziElement, language) : null;

    final yearLine = baziYearStem != null
        ? '${_getBaziElementName(baziYearStem, language)} / ${baziYearBranch ?? "?"}'
        : (isDe ? 'Nicht verfügbar' : 'Not available');
    final monthLine = baziMonthStem != null
        ? '${_getBaziElementName(baziMonthStem, language)} / ${baziMonthBranch ?? "?"}'
        : (isDe ? 'Nicht verfügbar' : 'Not available');
    final hourLine = baziHourStem != null
        ? '${_getBaziElementName(baziHourStem, language)} / ${baziHourBranch ?? "?"}'
        : (isDe ? 'Nicht verfügbar (keine Geburtszeit)' : 'Not available (no birth time)');

    if (isDe) {
      return '''
KAPITEL: DEINE ENERGIE — Bazi (Die Vier Säulen)

DATEN:
- Day Master: $dayMaster / $dayBranch
${dominantEl != null ? '- Dominantes Element: $dominantEl' : ''}
- Jahr-Säule: $yearLine
- Monat-Säule: $monthLine
- Stunden-Säule: $hourLine

DEINE AUFGABE:
Schreibe ein Kapitel über die Bazi-Persönlichkeit dieser Person. Der Day Master ist der Kern — wer diese Person in ihrem Element IST. Erkläre es nicht akademisch, sondern erlebbar.

Zeige: Wie tankt diese Person Energie auf? Was zehrt sie aus? Wie geht sie an Entscheidungen ran? Wo liegt das natürliche Talent (Monats-Säule = Karriere) — und wo das familiäre Erbe (Jahres-Säule)?

Erkläre die Element-Dynamik: Wenn jemand z.B. Yang-Holz Day Master ist mit viel Metall im Chart — dann wird das Holz "beschnitten". Was bedeutet das im Alltag?

400-600 Wörter. Fließtext. Kein Markdown.
''';
    } else {
      return '''
CHAPTER: YOUR ENERGY — Bazi (The Four Pillars)

DATA:
- Day Master: $dayMaster / $dayBranch
${dominantEl != null ? '- Dominant Element: $dominantEl' : ''}
- Year Pillar: $yearLine
- Month Pillar: $monthLine
- Hour Pillar: $hourLine

YOUR TASK:
Write a chapter about this person's Bazi personality. The Day Master is the core — who this person IS in their element. Don't explain it academically, make it experiential.

Show: How does this person recharge? What drains them? How do they approach decisions? Where does their natural talent lie (Month Pillar = career) — and where is the family heritage (Year Pillar)?

Explain the element dynamics: If someone is e.g. Yang Wood Day Master with lots of Metal in their chart — the Wood gets "pruned." What does that mean in everyday life?

400-600 words. Flowing text. No Markdown.
''';
    }
  }

  /// User-Prompt für Numerologie Kapitel
  String _buildChapterNumerologyUserPrompt({
    required int? lifePathNumber,
    required int? birthdayNumber,
    required int? attitudeNumber,
    required int? personalYear,
    required int? maturityNumber,
    required int? birthExpressionNumber,
    required int? birthSoulUrgeNumber,
    required int? currentExpressionNumber,
    required int? currentSoulUrgeNumber,
    required int? karmicDebtLifePath,
    required List<int>? karmicLessons,
    required List<int>? challengeNumbers,
    required String language,
  }) {
    final isDe = language.toUpperCase() == 'DE';

    // Kern-Zahlen
    final coreLines = <String>[];
    if (lifePathNumber != null) coreLines.add('${isDe ? "Lebenszahl" : "Life Path"}: $lifePathNumber');
    if (birthdayNumber != null) coreLines.add('${isDe ? "Geburtstags-Zahl" : "Birthday Number"}: $birthdayNumber');
    if (attitudeNumber != null) coreLines.add('${isDe ? "Attitüde-Zahl" : "Attitude Number"}: $attitudeNumber');
    final currentYear = DateTime.now().year;
    if (personalYear != null) coreLines.add('${isDe ? "Persönliches Jahr $currentYear" : "Personal Year $currentYear"}: $personalYear');
    if (maturityNumber != null) coreLines.add('${isDe ? "Reife-Zahl" : "Maturity Number"}: $maturityNumber');

    // Name Energies
    final nameLines = <String>[];
    if (birthExpressionNumber != null) nameLines.add('${isDe ? "Geburtsname Expression" : "Birth Name Expression"}: $birthExpressionNumber');
    if (birthSoulUrgeNumber != null) nameLines.add('${isDe ? "Geburtsname Seele" : "Birth Name Soul Urge"}: $birthSoulUrgeNumber');
    if (currentExpressionNumber != null) nameLines.add('${isDe ? "Aktueller Name Expression" : "Current Name Expression"}: $currentExpressionNumber');
    if (currentSoulUrgeNumber != null) nameLines.add('${isDe ? "Aktueller Name Seele" : "Current Name Soul Urge"}: $currentSoulUrgeNumber');

    // Erweitert
    final advancedLines = <String>[];
    if (karmicDebtLifePath != null) advancedLines.add('${isDe ? "Karmische Schuld" : "Karmic Debt"}: $karmicDebtLifePath');
    if (karmicLessons != null && karmicLessons.isNotEmpty) {
      advancedLines.add('${isDe ? "Karmische Lektionen" : "Karmic Lessons"}: ${karmicLessons.join(", ")}');
    }
    if (challengeNumbers != null && challengeNumbers.isNotEmpty) {
      advancedLines.add('${isDe ? "Herausforderungs-Zahlen" : "Challenge Numbers"}: ${challengeNumbers.join(", ")}');
    }

    if (isDe) {
      return '''
KAPITEL: DEIN SEELENWEG — Numerologie

KERN-ZAHLEN:
${coreLines.isNotEmpty ? coreLines.map((l) => '- $l').join('\n') : '- (Keine Kern-Zahlen verfügbar)'}

NAME-ENERGIEN:
${nameLines.isNotEmpty ? nameLines.map((l) => '- $l').join('\n') : '- (Keine Name-Energien verfügbar)'}

ERWEITERT:
${advancedLines.isNotEmpty ? advancedLines.map((l) => '- $l').join('\n') : '- (Keine erweiterten Daten)'}

DEINE AUFGABE:
Schreibe ein Kapitel über den numerologischen Seelenweg dieser Person. Die Lebenszahl ist der rote Faden — aber erst im Zusammenspiel mit den anderen Zahlen wird es interessant.

Zeige: Was will die Seele lernen (Life Path)? Was bringt die Person natürlich mit (Expression)? Was sehnt sie sich im Stillen (Soul Urge)? Wo sitzt die karmische Schuld — und wie zeigt sie sich im Alltag?

Wenn sich Geburtsnamen-Energie und aktuelle-Namen-Energie unterscheiden: Erkläre was die Namensänderung energetisch verschoben hat.

Die Challenge Numbers zeigen Wachstumsfelder — nicht Defizite. Die Karmischen Lektionen zeigen was in diesem Leben nachgeholt werden will.

500-700 Wörter. Fließtext. Kein Markdown.
''';
    } else {
      return '''
CHAPTER: YOUR SOUL PATH — Numerology

CORE NUMBERS:
${coreLines.isNotEmpty ? coreLines.map((l) => '- $l').join('\n') : '- (No core numbers available)'}

NAME ENERGIES:
${nameLines.isNotEmpty ? nameLines.map((l) => '- $l').join('\n') : '- (No name energies available)'}

ADVANCED:
${advancedLines.isNotEmpty ? advancedLines.map((l) => '- $l').join('\n') : '- (No advanced data)'}

YOUR TASK:
Write a chapter about this person's numerological soul path. The Life Path is the thread — but it only gets interesting when combined with the other numbers.

Show: What does the soul want to learn (Life Path)? What does the person naturally bring (Expression)? What do they quietly long for (Soul Urge)? Where does karmic debt sit — and how does it show up in daily life?

If birth name energy and current name energy differ: Explain what the name change shifted energetically.

The Challenge Numbers show growth fields — not deficits. The Karmic Lessons show what wants to be caught up on in this life.

500-700 words. Flowing text. No Markdown.
''';
    }
  }

  /// API Call mit konfigurierbaren max_tokens
  Future<ClaudeResponse> _callClaudeWithMaxTokens({
    required String systemPrompt,
    required String userPrompt,
    required int maxTokens,
  }) async {
    final url = Uri.parse('$baseUrl/messages');

    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    };

    final body = jsonEncode({
      'model': model,
      'max_tokens': maxTokens,
      'system': systemPrompt,
      'messages': [
        {
          'role': 'user',
          'content': userPrompt,
        }
      ],
    });

    final httpResponse = await http.post(url, headers: headers, body: body);

    if (httpResponse.statusCode == 200) {
      final data = jsonDecode(httpResponse.body);
      return ClaudeResponse.fromJson(data);
    } else {
      String errorDetail = httpResponse.body;
      try {
        final errorData = jsonDecode(httpResponse.body);
        errorDetail = errorData['error']?['message'] ?? httpResponse.body;
      } catch (_) {}
      throw ClaudeApiException(
        'Claude API Error: ${httpResponse.statusCode}',
        errorDetail,
      );
    }
  }

  /// System-Prompt für Deep Synthesis — 3-Spannungsfelder-Methode
  ///
  /// Neue Architektur: Statt 5-Schritt-Bogen jetzt 3 vollständig
  /// durchgearbeitete Spannungsfelder mit Kausallogik.
  /// Jedes System erklärt das nächste — kein Aufzählen, nur Verweben.
  String _buildDeepSynthesisSystemPrompt(String language, {String? gender}) {
    final addressDE = _getGenderAddressDE(gender);
    final addressEN = _getGenderAddressEN(gender);

    if (language.toUpperCase() == 'DE') {
      return '''
Du bist die Stimme von NUURAY Glow — klug, warm, überraschend, manchmal frech. Du weißt nicht alles besser.

ANSPRACHE (gilt für den gesamten Text — keine Ausnahmen):
$addressDE

DIE DREI LINSEN (deine Grundphilosophie):
Westliche Astrologie zeigt die PSYCHE — wie jemand denkt, fühlt, was diese Person will.
Bazi zeigt die ENERGIE — was das System wirklich leisten kann, wo Kraft fließt und wo sie fehlt.
Numerologie zeigt den SEELENWEG — wozu diese Person wirklich hier ist, was sie lernen soll.

Diese drei Ebenen erklären sich gegenseitig. Das ist der Kern deiner Arbeit.

DEINE SCHREIBMETHODE — 3 SPANNUNGSFELDER:

Die Synthese besteht aus drei vollständig durchgearbeiteten Spannungsfeldern, nicht aus einer Aufzählung von Fakten. Jedes Spannungsfeld hat diese innere Logik:

1. Beginne mit einem erlebbaren Moment ("Du kennst das, wenn...", "Es gibt diese Situation...")
2. Zeige was die Psyche (Westlich) will oder fürchtet
3. Erkläre KAUSAL wie die Bazi-Energie das verstärkt, bremst oder in eine unerwartete Richtung lenkt
4. Zeige wie die Numerologie die tiefere Wahrheit dahinter benennt — nicht als drittes System, sondern als Erklärung WARUM die Spannung existiert
5. Löse auf: Was ist die integrierte Erkenntnis aus dieser Spannung?

KAUSALE VERBINDUNGEN SIND PFLICHT:
Nicht: "Deine Sonne ist X. Dein Day Master ist Y. Deine Lebenszahl ist Z."
Sondern: "...und genau deshalb...", "...was erklärt, warum du...", "...das ist kein Zufall, denn...", "...weil dein [Element/Zahl] gleichzeitig..."

DIE SYSTEME SIND VERBUNDEN — NICHT PARALLEL:
System A erklärt warum System B so wirkt wie es wirkt.
System B zeigt die Grenze dessen, was System A erreichen kann.
System C benennt warum diese Spannung kein Fehler ist, sondern der Weg.

SCHATTENSEITEN SIND PFLICHT — KEIN WEICHSPÜLEN:
Jeder Mensch hat Muster die ihn ausbremsen. Diese gehören in den Text — nicht als Kritik, sondern als ehrliche Beobachtung.
- Jedes Spannungsfeld muss den konkreten PREIS benennen den diese Kombination hat: Was kostet dich das? Wo sabotierst du dich selbst?
- Nicht: "Das kann manchmal eine Herausforderung sein" → das ist Euphemismus
- Sondern: "Du weißt selbst wie oft du...", "Das erklärt warum du in [Situation] immer wieder...", "Dieser Zug kostet dich..."
- Der unbequeme Satz steht NICHT am Ende — er steht mitten im Spannungsfeld und wird dann aufgelöst
- Verhältnis: 40% Stärke, 40% ehrlicher Preis/Schatten, 20% Auflösung
- Niemand soll das lesen und denken "alles toll bei mir" — sie sollen denken "woher weiß das die App?"

STRUKTUR DES TEXTES:
- Einstieg (1 Absatz): Eine einzige überraschende Kernbeobachtung — kein "Du bist...", sondern ein Widerspruch oder eine unerwartete Wahrheit
- Spannungsfeld 1 (2-3 Absätze): Psyche trifft Energie — was will der Geist, was kann die Hardware — und was kostet diese Spannung konkret?
- Spannungsfeld 2 (2-3 Absätze): Energie trifft Seelenweg — was kann das System leisten, wozu ist es bestimmt — und wo läuft es trotzdem gegen eine Wand?
- Spannungsfeld 3 (2-3 Absätze): Der tiefste Widerspruch — die Stelle wo alle drei Systeme auf dasselbe Muster zeigen, das gleichzeitig Stärke und blinder Fleck ist
- Synthese (1 Absatz): Die eine Wahrheit die alle drei verbindet — keine neuen Infos, nur die ehrliche Auflösung
- Impuls (1-2 Sätze): Eine Frage die sitzt — nicht beruhigend, sondern weiterführend

QUALITÄTSREGELN:
- Systemnamen sparsam — maximal einmal pro Absatz, nie zwei hintereinander
- Nie drei Systeme in einem Satz aufzählen
- Jeder Absatz kausal mit dem nächsten verbunden
- Länge: 900-1200 Wörter
- Kein Markdown, keine Emojis, keine Überschriften, keine Listen — nur Fließtext

VERBOTENE WORTE: Schicksal, Magie, Wunder, "Universum möchte", kosmische Energie, positive Schwingungen, Manifestation, Segnung, Heilung, Lichtarbeit
VERBOTENE MUSTER: "Die Sterne sagen...", "Dein Bazi sagt...", "Die Numerologie zeigt...", alles klingt nur positiv, keine Reibung
VERBOTEN: Text der nach dem Lesen kein Unbehagen hinterlässt — ein guter Text tut ein bisschen weh und fühlt sich trotzdem richtig an

ZEITBEZUG:
Beim Persönlichen Jahr IMMER die Jahreszahl nennen: "in deinem persönlichen Jahr 6 (2026)" — der User muss wissen, auf welches Jahr sich das bezieht.
Ansonsten keine festen Jahreszahlen. "Aktuell", "in dieser Phase" statt konkreter Jahreszahlen.
''';
    } else {
      return '''
You are the voice of NUURAY Glow — clever, warm, surprising, sometimes blunt. You don't claim to know everything.

ADDRESS (applies to the entire text — no exceptions):
$addressEN

THE THREE LENSES (your core philosophy):
Western Astrology shows the PSYCHE — how someone thinks, feels, what this person wants.
Bazi shows the ENERGY — what the system can truly deliver, where power flows and where it's missing.
Numerology shows the SOUL PATH — what this person is really here for, what they need to learn.

These three levels explain each other. That is the core of your work.

YOUR WRITING METHOD — 3 TENSION FIELDS:

The synthesis consists of three fully developed tension fields, not a list of facts. Each tension field has this inner logic:

1. Begin with a lived moment ("You know that feeling when...", "There's this situation...")
2. Show what the psyche (Western) wants or fears
3. Explain CAUSALLY how the Bazi energy amplifies, brakes, or redirects this in an unexpected direction
4. Show how Numerology names the deeper truth behind it — not as a third system, but as an explanation of WHY the tension exists
5. Resolve: What is the integrated insight from this tension?

CAUSAL CONNECTIONS ARE MANDATORY:
Not: "Your Sun is X. Your Day Master is Y. Your Life Path is Z."
But: "...and that's exactly why...", "...which explains why you...", "...this is no coincidence, because...", "...because your [element/number] simultaneously..."

THE SYSTEMS ARE CONNECTED — NOT PARALLEL:
System A explains why System B works the way it does.
System B shows the limit of what System A can achieve.
System C names why this tension is not a flaw, but the path.

SHADOW SIDES ARE MANDATORY — NO SUGARCOATING:
Every person has patterns that hold them back. These belong in the text — not as criticism, but as honest observation.
- Every tension field must name the concrete PRICE this combination carries: What does it cost you? Where do you sabotage yourself?
- Not: "This can sometimes be a challenge" → that's a euphemism
- But: "You know yourself how often you...", "This explains why in [situation] you always...", "This pull costs you..."
- The uncomfortable sentence does NOT come at the end — it sits in the middle of the tension field and is then resolved
- Ratio: 40% strength, 40% honest price/shadow, 20% resolution
- Nobody should read this and think "everything's great with me" — they should think "how does this app know that?"

TEXT STRUCTURE:
- Opening (1 paragraph): One single surprising core observation — not "You are...", but a contradiction or unexpected truth
- Tension Field 1 (2-3 paragraphs): Psyche meets Energy — what does the mind want, what can the hardware deliver — and what does this tension concretely cost?
- Tension Field 2 (2-3 paragraphs): Energy meets Soul Path — what can the system achieve, what is it meant for — and where does it still run into a wall?
- Tension Field 3 (2-3 paragraphs): The deepest contradiction — where all three systems point to the same pattern that is simultaneously strength and blind spot
- Synthesis (1 paragraph): The one truth connecting all three — no new information, only the honest resolution
- Impulse (1-2 sentences): A question that lands — not comforting, but forward-pointing

QUALITY RULES:
- System names sparingly — maximum once per paragraph, never two in a row
- Never list three systems in one sentence
- Every paragraph causally connected to the next
- Length: 900-1200 words
- No Markdown, no emojis, no headings, no bullet points — flowing text only

FORBIDDEN WORDS: fate, magic, miracle, "universe wants", cosmic energy, positive vibrations, manifestation, blessing, healing, lightwork
FORBIDDEN PATTERNS: "The stars say...", "Your Bazi says...", "Numerology shows...", everything sounds only positive, no friction
FORBIDDEN: Text that leaves no discomfort after reading — a good text stings a little and still feels right

TIME REFERENCES:
For Personal Year ALWAYS include the year: "in your personal year 6 (2026)" — the user needs to know which year this refers to.
Otherwise no fixed years. "Currently", "in this phase" instead of specific years.
''';
    }
  }

  /// User-Prompt für Deep Synthesis — alle Daten dieser Person
  String _buildDeepSynthesisPrompt({
    required String sunSign,
    required String? moonSign,
    required String? ascendantSign,
    required String? baziDayStem,
    required String? baziElement,
    required String? baziYearStem,
    required String? baziMonthStem,
    required int? lifePathNumber,
    required int? birthdayNumber,
    required int? personalYear,
    required List<int>? challengeNumbers,
    required int? karmicDebtLifePath,
    required List<int>? karmicLessons,
    required String language,
    bool hasBirthTime = true,
  }) {
    // Bazi-Elemente aufbereiten
    final baziContext = _buildBaziContext(baziDayStem, baziElement, baziYearStem, baziMonthStem, language);
    // Numerologie-Kontext aufbereiten
    final numerologyContext = _buildNumerologyContext(
      lifePathNumber, birthdayNumber, personalYear,
      challengeNumbers, karmicDebtLifePath, karmicLessons, language,
    );

    // Hinweis für fehlende Geburtszeit
    final birthTimeNoteDE = hasBirthTime
        ? ''
        : '\nHINWEIS DATENVOLLSTÄNDIGKEIT: Für diese Person liegt keine Geburtszeit vor. '
          'Mondzeichen, Aszendent und Bazi-Stundensäule sind daher nicht berechenbar. '
          'Arbeite ausschließlich mit den vorhandenen Daten. '
          'Erwähne diese Lücke NICHT im Text — schreibe, was die vorhandenen Daten zeigen, '
          'ohne auf fehlende Informationen hinzuweisen.\n';

    final birthTimeNoteEN = hasBirthTime
        ? ''
        : '\nDATA COMPLETENESS NOTE: No birth time is available for this person. '
          'Moon sign, ascendant, and Bazi hour pillar cannot be calculated. '
          'Work exclusively with the available data. '
          'Do NOT mention this gap in the text — write about what the existing data shows, '
          'without referring to missing information.\n';

    if (language.toUpperCase() == 'DE') {
      return '''
Schreibe die tiefe Synthese für diese Person.
$birthTimeNoteDE
IHRE SIGNATUR:

Psyche (Westliche Astrologie):
- Sonne: ${_getZodiacNameDe(sunSign)}${moonSign != null ? '\n- Mond: ${_getZodiacNameDe(moonSign)}' : ''}${ascendantSign != null ? '\n- Aszendent: ${_getZodiacNameDe(ascendantSign)}' : ''}

Energie (Bazi):
$baziContext

Seelenweg (Numerologie):
$numerologyContext

DEINE AUFGABE:
Schreibe die drei Spannungsfelder dieser Person. Nicht nebeneinander — kausal verbunden. Jedes System erklärt das nächste. Zeige warum diese Person ist wie sie ist, nicht nur was sie ist.

Beginne nicht mit "Du bist..." — beginne mit einer erlebbaren Situation, einem Widerspruch, einem Moment den diese Person kennt.

900-1200 Wörter. Kein Markdown. Nur Fließtext.
''';
    } else {
      return '''
Write the deep synthesis for this person.
$birthTimeNoteEN
THEIR SIGNATURE:

Psyche (Western Astrology):
- Sun: ${_getZodiacNameEn(sunSign)}${moonSign != null ? '\n- Moon: ${_getZodiacNameEn(moonSign)}' : ''}${ascendantSign != null ? '\n- Ascendant: ${_getZodiacNameEn(ascendantSign)}' : ''}

Energy (Bazi):
$baziContext

Soul Path (Numerology):
$numerologyContext

YOUR TASK:
Write the three tension fields of this person. Not side by side — causally connected. Each system explains the next. Show WHY this person is the way they are, not just WHAT they are.

Do not start with "You are..." — start with a lived situation, a contradiction, a moment this person knows.

900-1200 words. No Markdown. Flowing text only.
''';
    }
  }

  /// Baut den Bazi-Kontext-Block für den Prompt
  String _buildBaziContext(
    String? dayStem,
    String? dominantElement,
    String? yearStem,
    String? monthStem,
    String language,
  ) {
    final isDe = language.toUpperCase() == 'DE';
    final lines = <String>[];

    if (dayStem != null) {
      final dayMasterLabel = isDe ? '- Day Master (wer du bist)' : '- Day Master (who you are)';
      lines.add('$dayMasterLabel: ${_getBaziElementName(dayStem, language)}');
    }
    if (dominantElement != null) {
      final domLabel = isDe ? '- Dominantes Element (Hauptenergie)' : '- Dominant Element (main energy)';
      lines.add('$domLabel: ${_getBaziElementName(dominantElement, language)}');
    }
    if (yearStem != null) {
      final yearLabel = isDe ? '- Jahr-Säule (Ressourcen, Erbe)' : '- Year Pillar (resources, heritage)';
      lines.add('$yearLabel: ${_getBaziElementName(yearStem, language)}');
    }
    if (monthStem != null) {
      final monthLabel = isDe ? '- Monat-Säule (Karriere, Ausdruck)' : '- Month Pillar (career, expression)';
      lines.add('$monthLabel: ${_getBaziElementName(monthStem, language)}');
    }

    if (lines.isEmpty) {
      return isDe ? '(Keine Bazi-Daten verfügbar)' : '(No Bazi data available)';
    }

    return lines.join('\n');
  }

  /// Baut den Numerologie-Kontext-Block für den Prompt
  String _buildNumerologyContext(
    int? lifePathNumber,
    int? birthdayNumber,
    int? personalYear,
    List<int>? challengeNumbers,
    int? karmicDebtLifePath,
    List<int>? karmicLessons,
    String language,
  ) {
    final isDe = language.toUpperCase() == 'DE';
    final lines = <String>[];

    final currentYear = DateTime.now().year;

    if (lifePathNumber != null) {
      final label = isDe ? '- Lebenszahl (Seelenweg, lebenslang)' : '- Life Path (soul journey, lifelong)';
      lines.add('$label: $lifePathNumber');
    }
    if (birthdayNumber != null) {
      final label = isDe ? '- Geburtstagszahl (natürliche Gabe)' : '- Birthday Number (natural gift)';
      lines.add('$label: $birthdayNumber');
    }
    if (personalYear != null) {
      final label = isDe
          ? '- Persönliches Jahr $currentYear (aktuelle Jahresenergie)'
          : '- Personal Year $currentYear (current year energy)';
      lines.add('$label: $personalYear');
    }
    if (challengeNumbers != null && challengeNumbers.isNotEmpty) {
      final label = isDe ? '- Herausforderungszahlen (Wachstumsthemen)' : '- Challenge Numbers (growth themes)';
      lines.add('$label: ${challengeNumbers.take(4).join(', ')}');
    }
    if (karmicDebtLifePath != null && karmicDebtLifePath > 0) {
      final label = isDe ? '- Karmische Schuld (alte Lernaufgabe)' : '- Karmic Debt (old learning task)';
      lines.add('$label: $karmicDebtLifePath');
    }
    if (karmicLessons != null && karmicLessons.isNotEmpty) {
      final label = isDe ? '- Karmische Lektionen (fehlende Energie)' : '- Karmic Lessons (missing energy)';
      lines.add('$label: ${karmicLessons.take(5).join(', ')}');
    }

    if (lines.isEmpty) {
      return isDe ? '(Keine Numerologie-Daten verfügbar)' : '(No numerology data available)';
    }

    return lines.join('\n');
  }

  /// Englischer Sternzeichen-Name
  String _getZodiacNameEn(String zodiacSign) {
    const names = {
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
    return names[zodiacSign] ?? zodiacSign;
  }

  /// Bazi-Element-Name (bereits in ArchetypeSignatureService vorhanden, hier dupliziert für Unabhängigkeit)
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
        'Holz': 'Wood',
        'Feuer': 'Fire',
        'Erde': 'Earth',
        'Metall': 'Metal',
        'Wasser': 'Water',
      };
      return elementsEN[stem] ?? stem;
    }
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
