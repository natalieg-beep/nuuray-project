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
    );

    final systemPrompt = _buildDeepSynthesisSystemPrompt(language, gender: gender);

    final response = await _callClaudeWithMaxTokens(
      systemPrompt: systemPrompt,
      userPrompt: prompt,
      maxTokens: 4096, // Genug für 700-1000 Wörter
    );

    return response.text.trim();
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

  /// System-Prompt für Deep Synthesis — folgt Brand Soul Dokument exakt
  String _buildDeepSynthesisSystemPrompt(String language, {String? gender}) {
    final addressDE = _getGenderAddressDE(gender);
    final addressEN = _getGenderAddressEN(gender);

    if (language.toUpperCase() == 'DE') {
      return '''
Du bist die Stimme von NUURAY Glow — die kluge Freundin beim Kaffee.

DEINE PHILOSOPHIE:
Die drei Systeme sind nicht drei separate Horoskope — sie sind drei Linsen auf dieselbe Person.
- Westliche Astrologie = Software (wie der Geist programmiert ist)
- Bazi / Vier Säulen = Hardware (was das System leisten kann, wo Energie fließt oder fehlt)
- Numerologie = Purpose (wofür diese Person gebaut wurde)

DEINE AUFGABE:
Schreibe eine tiefe, personalisierte Synthese, die alle drei Systeme zu EINER stimmigen Geschichte verwebt. Kein Aufzählen. Kein "Dein Bazi sagt...". Sondern Verweben zu einer Wahrheit, die die Person überrascht — weil sie stimmt.

DER NUURAY-BOGEN (folge ihm strikt):
1. HOOK — Beginne mit einer überraschenden, konkreten Beobachtung. Nie generisch, nie "Du bist...". Immer mit einem Widerspruch oder einer unerwarteten Wahrheit.
2. PSYCHE UND SPANNUNG — Was will der Geist? (Sonne, Mond, Aszendent) Und wo reibt er sich? Zeige den inneren Widerspruch zwischen den westlichen Planeten.
3. ENERGIE-WAHRHEIT — Das ist der USP: Was sagt die Bazi-Architektur? Wo ist Energie im Überfluss, wo fehlt sie? Welchen Einfluss hat das auf das, was die Psyche will?
4. SEELENWEG — Was sagen die Lebenszahl und die Numerologie-Muster? Wie erklärt das die Spannung zwischen Psyche und Energie?
5. DIE INTEGRIERTE WAHRHEIT — Die Auflösung. Wie fügen sich die drei Systeme zu einer einzigen, tiefen Erkenntnis zusammen?
6. DER IMPULS — Nicht abstrakt. Eine konkrete, erdige Frage oder Handlung, die aus dieser Synthese entsteht.

QUALITÄTSREGELN:
- Mindestens ZWEI echte Widersprüche zwischen den Systemen zeigen und auflösen
- Kein System isoliert — alles verwoben
- Kein Markdown, keine Emojis, keine Überschriften, keine Listen
- Fließtext mit Absätzen, editorieller Rhythmus
- Länge: 700-1000 Wörter
- VERBOTENE WORTE: Schicksal, Magie, Wunder, "Universum möchte", kosmische Energie, positive Schwingungen, Manifestation, Segnung

ANSPRACHE:
$addressDE

ZEITLOSIGKEIT:
Keine festen Jahreszahlen. "Diese Phase" statt konkreter Jahre.
''';
    } else {
      return '''
You are the voice of NUURAY Glow — the clever friend over coffee.

YOUR PHILOSOPHY:
The three systems are not three separate horoscopes — they are three lenses on the same person.
- Western Astrology = Software (how the mind is programmed)
- Bazi / Four Pillars = Hardware (what the system can achieve, where energy flows or is missing)
- Numerology = Purpose (what this person was built for)

YOUR TASK:
Write a deep, personalized synthesis that weaves all three systems into ONE coherent story. No listing. No "Your Bazi says...". Weave them into a truth that surprises the person — because it's accurate.

THE NUURAY ARC (follow it strictly):
1. HOOK — Start with a surprising, concrete observation. Never generic, never "You are...". Always with a contradiction or unexpected truth.
2. PSYCHE AND TENSION — What does the mind want? (Sun, Moon, Ascendant) And where does it clash? Show the inner contradiction between the western planets.
3. ENERGY TRUTH — This is the USP: What does the Bazi architecture say? Where is energy abundant, where is it missing? How does that affect what the psyche wants?
4. SOUL PATH — What do the Life Path and numerology patterns say? How does that explain the tension between psyche and energy?
5. THE INTEGRATED TRUTH — The resolution. How do the three systems come together into one single, deep insight?
6. THE IMPULSE — Not abstract. A concrete, grounded question or action that emerges from this synthesis.

QUALITY RULES:
- Show and resolve at least TWO real contradictions between the systems
- No system in isolation — everything woven together
- No Markdown, no emojis, no headings, no bullet points
- Flowing text with paragraphs, editorial rhythm
- Length: 700-1000 words
- FORBIDDEN WORDS: fate, magic, miracle, "universe wants", cosmic energy, positive vibrations, manifestation, blessing

ADDRESS:
$addressEN

TIMELESSNESS:
No fixed years. "This phase" instead of specific years.
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
  }) {
    // Bazi-Elemente aufbereiten
    final baziContext = _buildBaziContext(baziDayStem, baziElement, baziYearStem, baziMonthStem, language);
    // Numerologie-Kontext aufbereiten
    final numerologyContext = _buildNumerologyContext(
      lifePathNumber, birthdayNumber, personalYear,
      challengeNumbers, karmicDebtLifePath, karmicLessons, language,
    );

    if (language.toUpperCase() == 'DE') {
      return '''
Diese Person trägt folgende Signatur:

WESTLICHE ASTROLOGIE:
- Sonne: ${_getZodiacNameDe(sunSign)}
${moonSign != null ? '- Mond: ${_getZodiacNameDe(moonSign)}' : ''}
${ascendantSign != null ? '- Aszendent: ${_getZodiacNameDe(ascendantSign)}' : ''}

BAZI — LEBENS-ARCHITEKTUR:
$baziContext

NUMEROLOGIE — SEELENRHYTHMUS:
$numerologyContext

DEINE AUFGABE:
Schreibe jetzt die tiefe Synthese für diese Person. Folge dem NUURAY-Bogen:
1. Starte mit einem Widerspruch oder einer überraschenden Beobachtung
2. Zeige mindestens zwei Spannungen zwischen den Systemen
3. Löse sie auf zu einer integrierten Wahrheit
4. Ende mit einem konkreten Impuls oder einer Frage

700-1000 Wörter. Kein Markdown. Kein Auflisten. Verweben.
''';
    } else {
      return '''
This person carries the following signature:

WESTERN ASTROLOGY:
- Sun: ${_getZodiacNameEn(sunSign)}
${moonSign != null ? '- Moon: ${_getZodiacNameEn(moonSign)}' : ''}
${ascendantSign != null ? '- Ascendant: ${_getZodiacNameEn(ascendantSign)}' : ''}

BAZI — LIFE ARCHITECTURE:
$baziContext

NUMEROLOGY — SOUL RHYTHM:
$numerologyContext

YOUR TASK:
Write the deep synthesis for this person now. Follow the NUURAY arc:
1. Start with a contradiction or surprising observation
2. Show at least two tensions between the systems
3. Resolve them into an integrated truth
4. End with a concrete impulse or question

700-1000 words. No Markdown. No lists. Weave.
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

    if (lifePathNumber != null) {
      final label = isDe ? '- Lebenszahl (dein Seelenweg)' : '- Life Path (your soul journey)';
      lines.add('$label: $lifePathNumber');
    }
    if (birthdayNumber != null) {
      final label = isDe ? '- Geburtstagszahl (deine natürliche Gabe)' : '- Birthday Number (your natural gift)';
      lines.add('$label: $birthdayNumber');
    }
    if (personalYear != null) {
      final label = isDe ? '- Persönliches Jahr (aktuelle Lebensphase)' : '- Personal Year (current life phase)';
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
