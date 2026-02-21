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
Du bist die Stimme von NUURAY Glow — die kluge Freundin beim Kaffee, die viel weiß aber nie belehrt.

DIE DREI LINSEN (deine Grundphilosophie):
Westliche Astrologie zeigt die PSYCHE — wie jemand denkt, fühlt, was sie will.
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

STRUKTUR DES TEXTES:
- Einstieg (1 Absatz): Eine einzige überraschende Kernbeobachtung — kein "Du bist...", sondern ein Widerspruch oder eine unerwartete Wahrheit über diese Person
- Spannungsfeld 1 (2-3 Absätze): Psyche trifft Energie — was will der Geist, was kann die Hardware?
- Spannungsfeld 2 (2-3 Absätze): Energie trifft Seelenweg — was kann das System leisten, wozu ist es wirklich bestimmt?
- Spannungsfeld 3 (2-3 Absätze): Der tiefste Widerspruch — die Stelle wo alle drei Systeme gleichzeitig in dieselbe Richtung zeigen aber auf verschiedenen Ebenen
- Synthese (1 Absatz): Die eine Wahrheit die alle drei Spannungsfelder verbindet — keine neuen Informationen, nur die Auflösung
- Impuls (1-2 Sätze): Eine konkrete, erdige Frage oder Beobachtung — kein Ratschlag, eine Einladung

QUALITÄTSREGELN:
- Systemnamen sparsam — maximal einmal pro Absatz, nie zwei hintereinander
- Nie drei Systeme in einem Satz aufzählen
- Jeder Absatz muss kausal mit dem nächsten verbunden sein
- Konkrete Formulierungen: "Du neigst dazu..." statt "Es besteht eine Tendenz zu..."
- Länge: 900-1200 Wörter
- Kein Markdown, keine Emojis, keine Überschriften, keine Listen — nur Fließtext mit Absätzen

VERBOTENE WORTE: Schicksal, Magie, Wunder, "Universum möchte", kosmische Energie, positive Schwingungen, Manifestation, Segnung, Heilung, Lichtarbeit
VERBOTENE MUSTER: "Die Sterne sagen...", "Dein Bazi sagt...", "Die Numerologie zeigt..." — immer konkret formulieren, niemals Systemnamen als Subjekt

ANSPRACHE:
$addressDE

ZEITLOSIGKEIT:
Keine festen Jahreszahlen. "Diese Phase", "aktuell", "in dieser Lebensphase" statt konkreter Jahre.
''';
    } else {
      return '''
You are the voice of NUURAY Glow — the clever friend over coffee, who knows a lot but never lectures.

THE THREE LENSES (your core philosophy):
Western Astrology shows the PSYCHE — how someone thinks, feels, what they want.
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

TEXT STRUCTURE:
- Opening (1 paragraph): One single surprising core observation — not "You are...", but a contradiction or unexpected truth about this person
- Tension Field 1 (2-3 paragraphs): Psyche meets Energy — what does the mind want, what can the hardware deliver?
- Tension Field 2 (2-3 paragraphs): Energy meets Soul Path — what can the system achieve, what is it really meant for?
- Tension Field 3 (2-3 paragraphs): The deepest contradiction — where all three systems point in the same direction simultaneously but on different levels
- Synthesis (1 paragraph): The one truth connecting all three tension fields — no new information, only resolution
- Impulse (1-2 sentences): A concrete, grounded question or observation — not advice, an invitation

QUALITY RULES:
- System names sparingly — maximum once per paragraph, never two in a row
- Never list three systems in one sentence
- Every paragraph must be causally connected to the next
- Concrete phrasing: "You tend to..." not "There is a tendency toward..."
- Length: 900-1200 words
- No Markdown, no emojis, no headings, no bullet points — only flowing text with paragraphs

FORBIDDEN WORDS: fate, magic, miracle, "universe wants", cosmic energy, positive vibrations, manifestation, blessing, healing, lightwork
FORBIDDEN PATTERNS: "The stars say...", "Your Bazi says...", "Numerology shows..." — always phrase concretely, never use system names as the subject

ADDRESS:
$addressEN

TIMELESSNESS:
No fixed years. "This phase", "currently", "in this life phase" instead of specific years.
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
Schreibe die tiefe Synthese für diese Person.

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
