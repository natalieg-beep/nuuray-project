#!/usr/bin/env dart

/// Content Library Seed Script
///
/// Generiert alle 264 Freemium-Texte mit Claude API und speichert sie in Supabase.
///
/// Usage:
///   dart scripts/seed_content_library.dart [--locale de|en] [--dry-run]
///
/// Kosten: ~$3-5 für 264 Texte (einmalig)

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Konfiguration
const supabaseUrl = 'https://ykkayjbplutdodummcte.supabase.co';
const claudeApiUrl = 'https://api.anthropic.com/v1/messages';

void main(List<String> args) async {
  // .env Datei laden (falls vorhanden)
  _loadEnvFile();

  // Args parsen
  final locale = args.contains('--locale')
      ? args[args.indexOf('--locale') + 1]
      : 'de';
  final dryRun = args.contains('--dry-run');

  print('🌟 NUURAY Content Library Seed');
  print('Locale: $locale');
  print('Dry Run: $dryRun');
  print('');

  // Env-Variablen prüfen
  final supabaseKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  final claudeKey = Platform.environment['ANTHROPIC_API_KEY'] ?? Platform.environment['CLAUDE_API_KEY'];

  if (supabaseKey == null || claudeKey == null) {
    print('❌ Fehler: SUPABASE_SERVICE_ROLE_KEY und CLAUDE_API_KEY müssen gesetzt sein.');
    print('');
    print('Beispiel:');
    print('  export SUPABASE_SERVICE_ROLE_KEY=eyJ...');
    print('  export CLAUDE_API_KEY=sk-ant-...');
    print('  dart scripts/seed_content_library.dart');
    exit(1);
  }

  // Alle Keys definieren
  final categories = _getAllCategories();

  print('📊 Insgesamt ${categories.length} Einträge zu generieren\n');

  int success = 0;
  int failed = 0;
  double totalCost = 0.0;

  for (final category in categories) {
    print('🔄 ${category.category} → ${category.key} ($locale)...');

    if (dryRun) {
      print('   [DRY RUN] Überspringe...\n');
      continue;
    }

    try {
      // Claude API Call
      final result = await _generateDescription(
        category: category.category,
        key: category.key,
        locale: locale,
        claudeKey: claudeKey,
      );

      // In Supabase speichern
      await _saveToSupabase(
        category: category.category,
        key: category.key,
        locale: locale,
        title: category.title,
        description: result.description,
        supabaseUrl: supabaseUrl,
        supabaseKey: supabaseKey,
      );

      totalCost += result.cost;
      success++;
      print('   ✅ Gespeichert (~${result.cost.toStringAsFixed(4)}\$)\n');

      // Rate Limiting (Claude API: 50 req/min)
      await Future.delayed(Duration(milliseconds: 1500));
    } catch (e) {
      failed++;
      print('   ❌ Fehler: $e\n');
    }
  }

  print('');
  print('✨ Fertig!');
  print('   Erfolg: $success');
  print('   Fehler: $failed');
  print('   Kosten: ~\$${totalCost.toStringAsFixed(2)}');
}

/// Generiert Beschreibung mit Claude API
Future<GenerationResult> _generateDescription({
  required String category,
  required String key,
  required String locale,
  required String claudeKey,
}) async {
  final prompt = _buildPrompt(category: category, key: key, locale: locale);

  final response = await http.post(
    Uri.parse(claudeApiUrl),
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': claudeKey,
      'anthropic-version': '2023-06-01',
    },
    body: jsonEncode({
      'model': 'claude-sonnet-4-20250514',
      'max_tokens': 400, // Erhöht von 300 für längere Texte (80-100 Wörter)
      'system': _getSystemPrompt(locale), // NEU: System-Prompt für Brand Voice
      'messages': [
        {
          'role': 'user',
          'content': prompt,
        }
      ],
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Claude API Error: ${response.statusCode} ${response.body}');
  }

  final data = jsonDecode(response.body);
  final description = data['content'][0]['text'] as String;
  final tokensUsed = data['usage']['input_tokens'] + data['usage']['output_tokens'];
  final cost = tokensUsed * 0.000003; // ~$3/million tokens (Sonnet 4)

  return GenerationResult(description: description, cost: cost);
}

/// Speichert in Supabase (UPSERT: Update wenn existiert, Insert wenn nicht)
Future<void> _saveToSupabase({
  required String category,
  required String key,
  required String locale,
  required String title,
  required String description,
  required String supabaseUrl,
  required String supabaseKey,
}) async {
  // UPSERT mit Supabase REST API
  // Docs: https://supabase.com/docs/reference/javascript/upsert
  final response = await http.post(
    Uri.parse('$supabaseUrl/rest/v1/content_library'),
    headers: {
      'Content-Type': 'application/json',
      'apikey': supabaseKey,
      'Authorization': 'Bearer $supabaseKey',
      'Prefer': 'resolution=merge-duplicates',
    },
    body: jsonEncode({
      'category': category,
      'key': key,
      'locale': locale,
      'title': title,
      'description': description,
    }),
  );

  // 201 = Created (neu), 200 = OK (updated), 409 = Conflict (dann manuell updaten)
  if (response.statusCode == 409) {
    // Fallback: UPDATE via PATCH
    final updateResponse = await http.patch(
      Uri.parse('$supabaseUrl/rest/v1/content_library?category=eq.$category&key=eq.$key&locale=eq.$locale'),
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
      }),
    );

    if (updateResponse.statusCode != 204 && updateResponse.statusCode != 200) {
      throw Exception('Supabase UPDATE Error: ${updateResponse.statusCode} ${updateResponse.body}');
    }
  } else if (response.statusCode != 201 && response.statusCode != 200) {
    throw Exception('Supabase Error: ${response.statusCode} ${response.body}');
  }
}

/// System-Prompt für Brand Voice (neu: 2026-02-12)
String _getSystemPrompt(String locale) {
  if (locale == 'de') {
    return '''
Du bist Content-Expertin für Nuuray Glow.

DEINE AUFGABE:
Erstelle Beschreibungen für einzelne astrologische Elemente (Sonnenzeichen, Mondzeichen, Bazi Day Master, Lebenszahlen).

DEIN CHARAKTER:
- Die kluge Freundin beim Kaffee
- Staunend über Zusammenhänge, nie wissend
- Überraschend, nie vorhersehbar
- Warm, nie kitschig

DEIN ANSATZ:
- Zeige konkrete Verhaltensweisen, keine abstrakten Adjektive
- Benenne liebevoll die Schattenseite (jeder Text MUSS eine Schwäche zeigen!)
- Verwende KEINE esoterischen Klischees
- Gib immer einen konkreten Impuls oder eine überraschende Erkenntnis
''';
  } else {
    return '''
You are a content expert for Nuuray Glow.

YOUR TASK:
Create descriptions for individual astrological elements (sun signs, moon signs, Bazi day masters, life path numbers).

YOUR CHARACTER:
- The smart friend over coffee
- Wonder-filled about connections, never know-it-all
- Surprising, never predictable
- Warm, never cheesy

YOUR APPROACH:
- Show concrete behaviors, not abstract adjectives
- Lovingly name the shadow side (every text MUST show a weakness!)
- NO esoteric clichés
- Always give a concrete impulse or surprising insight
''';
  }
}

/// Prompt-Builder (neu: 4 kategorie-spezifische Prompts)
String _buildPrompt({
  required String category,
  required String key,
  required String locale,
}) {
  // Wähle den richtigen Prompt basierend auf der Kategorie
  switch (category) {
    case 'sun_sign':
    case 'rising_sign': // Aszendent nutzt gleichen Prompt wie Sonnenzeichen
      return _sunSignPrompt(key, locale);

    case 'moon_sign':
      return _moonSignPrompt(key, locale);

    case 'bazi_day_master':
      return _baziDayMasterPrompt(key, locale);

    // Kern-Numerologie (Lebenswege & Zahlen)
    case 'life_path_number':
    case 'soul_urge_number':
    case 'expression_number':
    case 'personality_number':
    case 'birthday_number':
    case 'attitude_number':
    case 'personal_year':
    case 'maturity_number':
    case 'display_name_number':
      return _numerologyPrompt(category, key, locale);

    // Erweiterte Numerologie (Karma & Herausforderungen)
    case 'karmic_debt':
      return _karmicDebtPrompt(key, locale);
    case 'challenge_number':
      return _challengeNumberPrompt(key, locale);
    case 'karmic_lesson':
      return _karmicLessonPrompt(key, locale);
    case 'bridge_number':
      return _bridgeNumberPrompt(key, locale);

    default:
      throw Exception('Unknown category: $category');
  }
}

/// Prompt 1: Sonnenzeichen (psychologisches Ticken)
String _sunSignPrompt(String signName, String locale) {
  if (locale == 'de') {
    return '''
AUFGABE:
Schreibe einen Beschreibungstext für das Sonnenzeichen $signName.
Dieser Text erscheint isoliert in einer expandable Card. Er beschreibt, WIE diese Person psychologisch tickt.

LÄNGE: 80-100 Wörter. Nicht mehr.

STRUKTUR (als Textfluss, keine Überschriften):
- Eröffnung: Ein konkretes, überraschendes Verhaltensmuster (nicht "Du bist mutig" sondern "Du sagst Ja bevor du nachdenkst")
- Kern: Was diese Person ANTREIBT und was sie VERMEIDET
- Schatten: Eine ehrliche, liebevolle Benennung der Schwäche
- Schluss: Ein Satz der zeigt, warum genau das auch ihre Stärke ist

VERBOTEN:
"natürliche Gabe", "wunderbar", "unerschütterlich", "inspirierst andere", "unstillbare Neugier", "Funken in dir", "kosmisch", "Universum", "Seele", "spirituell"

WICHTIG: Jeder Text MUSS eine Schattenseite benennen (liebevoll, nicht brutal)

Gib NUR den Text aus, keine Erklärung.
''';
  } else {
    return '''
TASK:
Write a description text for the sun sign $signName.
This text appears isolated in an expandable card. It describes HOW this person ticks psychologically.

LENGTH: 80-100 words. No more.

STRUCTURE (as flowing text, no headings):
- Opening: A concrete, surprising behavior pattern (not "You are brave" but "You say yes before you think")
- Core: What drives this person and what they AVOID
- Shadow: An honest, loving naming of the weakness
- Conclusion: A sentence showing why exactly this is also their strength

FORBIDDEN:
"natural gift", "wonderful", "unshakeable", "inspire others", "insatiable curiosity", "spark within you", "cosmic", "universe", "soul", "spiritual"

IMPORTANT: Every text MUST name a shadow side (lovingly, not brutally)

Give ONLY the text, no explanation.
''';
  }
}

/// Prompt 2: Mondzeichen (emotionales Innenleben)
String _moonSignPrompt(String signName, String locale) {
  if (locale == 'de') {
    return '''
AUFGABE:
Schreibe einen Beschreibungstext für den Mond in $signName.
Das Mondzeichen beschreibt das EMOTIONALE INNENLEBEN — nicht die Persönlichkeit (das ist die Sonne), sondern was die Person FÜHLT, BRAUCHT und WIE SIE LIEBT.

LÄNGE: 80-100 Wörter. Nicht mehr.

STRUKTUR (als Textfluss):
- Eröffnung: Wie sich diese Person INNERLICH fühlt (oft anders als sie nach außen wirkt!)
- Kern: Was diese Person emotional BRAUCHT um sich sicher zu fühlen
- Schatten: Wann sie emotional überreagiert oder sich verschließt
- Schluss: Was sie emotional einzigartig macht

VERBOTEN:
"tiefe Sehnsucht", "natürliches Gespür", "emotionale Intelligenz", "wundervolle Vermittlerin", "friedvolle Atmosphäre", "Harmonie und Schönheit", "kosmisch", "spirituell"

WICHTIG: Der Text muss sich DEUTLICH vom Sonnenzeichen unterscheiden (Fokus: Gefühle vs. Persönlichkeit)

Gib NUR den Text aus, keine Erklärung.
''';
  } else {
    return '''
TASK:
Write a description text for the moon in $signName.
The moon sign describes the EMOTIONAL INNER LIFE — not the personality (that's the sun), but what the person FEELS, NEEDS and HOW THEY LOVE.

LENGTH: 80-100 words. No more.

STRUCTURE (as flowing text):
- Opening: How this person feels INTERNALLY (often different from how they appear!)
- Core: What this person emotionally NEEDS to feel secure
- Shadow: When they emotionally overreact or shut down
- Conclusion: What makes them emotionally unique

FORBIDDEN:
"deep longing", "natural intuition", "emotional intelligence", "wonderful mediator", "peaceful atmosphere", "harmony and beauty", "cosmic", "spiritual"

IMPORTANT: Text must be CLEARLY different from sun sign (focus: feelings vs. personality)

Give ONLY the text, no explanation.
''';
  }
}

/// Prompt 3: Bazi Day Master (energetische Konstitution)
String _baziDayMasterPrompt(String dayMasterName, String locale) {
  if (locale == 'de') {
    return '''
AUFGABE:
Schreibe einen Beschreibungstext für den Bazi Day Master $dayMasterName.
Der Day Master beschreibt die ENERGETISCHE KONSTITUTION — nicht wer die Person psychologisch ist, sondern WIE IHR SYSTEM ARBEITET. Wie ein Motor: Was ist der Treibstoff, was überhitzt, was fehlt.

LÄNGE: 80-100 Wörter. Nicht mehr.

STRUKTUR (als Textfluss):
- Eröffnung: Ein Bild oder Vergleich der diese Energie greifbar macht (z.B. Yin-Metall = Uhrmacherin, Yang-Holz = großer Baum)
- Kern: Wie diese Energie sich im Alltag zeigt — Tempo, Arbeitsweise, Umgang mit Stress
- Schatten: Wann diese Energie aus der Balance kippt
- Schluss: Was diese Energie braucht um optimal zu funktionieren

VERBOTEN:
"seltene Kombination", "authentisch", "kostbares Silber das durch Erfahrungen seinen Glanz erhält", "sanfte Stärke", "kosmisch", "spirituell", "Weisheit"

WICHTIG: Beschreibe FUNKTIONSWEISE, nicht Charaktereigenschaften (das ist der Unterschied zu Western Astrology)

Gib NUR den Text aus, keine Erklärung.
''';
  } else {
    return '''
TASK:
Write a description text for the Bazi Day Master $dayMasterName.
The Day Master describes the ENERGETIC CONSTITUTION — not who the person is psychologically, but HOW THEIR SYSTEM WORKS. Like an engine: What's the fuel, what overheats, what's missing.

LENGTH: 80-100 words. No more.

STRUCTURE (as flowing text):
- Opening: An image or comparison that makes this energy tangible (e.g. Yin Metal = watchmaker, Yang Wood = large tree)
- Core: How this energy shows in daily life — pace, work style, stress handling
- Shadow: When this energy gets out of balance
- Conclusion: What this energy needs to function optimally

FORBIDDEN:
"rare combination", "authentic", "precious silver that gains its shine through experiences", "gentle strength", "cosmic", "spiritual", "wisdom"

IMPORTANT: Describe FUNCTIONING, not character traits (that's the difference to Western Astrology)

Give ONLY the text, no explanation.
''';
  }
}

/// Prompt 4: Numerologie (Lebensweg-Thema)
String _numerologyPrompt(String category, String number, String locale) {
  // Map category zu lesbarem Namen
  final categoryName = {
    'life_path_number': locale == 'de' ? 'Lebenszahl' : 'Life Path Number',
    'soul_urge_number': locale == 'de' ? 'Seelenwunsch-Zahl' : 'Soul Urge Number',
    'expression_number': locale == 'de' ? 'Ausdruckszahl' : 'Expression Number',
    'personality_number': locale == 'de' ? 'Persönlichkeitszahl' : 'Personality Number',
    'birthday_number': locale == 'de' ? 'Geburtstagszahl' : 'Birthday Number',
    'attitude_number': locale == 'de' ? 'Haltungszahl' : 'Attitude Number',
    'personal_year': locale == 'de' ? 'Persönliches Jahr' : 'Personal Year',
    'maturity_number': locale == 'de' ? 'Reifezahl' : 'Maturity Number',
    'display_name_number': locale == 'de' ? 'Rufnamenzahl' : 'Display Name Number',
  }[category] ?? category;

  if (locale == 'de') {
    return '''
AUFGABE:
Schreibe einen Beschreibungstext für die $categoryName $number.

LÄNGE: 80-100 Wörter.

STRUKTUR (als Textfluss, keine Überschriften):
- Eröffnung: Ein konkretes Alltagsbeispiel, wie sich diese Zahl zeigt
- Kern: Die zentrale Spannung oder Frage, die mit dieser Zahl kommt
- Schatten: Die Falle (mit Beispiel: "Dann passiert X")
- Schluss: Woran du immer wieder arbeiten wirst

BEISPIELE für Konkretheit:
❌ "Du hast Führungsqualitäten" → ✅ "Im Meeting übernimmst du automatisch das Wort"
❌ "Du bist spirituell" → ✅ "Du spürst, wenn etwas nicht stimmt, bevor andere es aussprechen"

VERBOTEN:
"Führungskraft", "Gabe", "Bestimmung", "Manifestation", "inspirierend", "meisterhaft", "Universum", "kosmisch", "spirituelle Welt"

WICHTIG: Schreibe wie eine Freundin, die dich GUT kennt. Nicht wie ein Coach.

Nur Text, keine Erklärung.
''';
  } else {
    return '''
TASK:
Write a description text for the $categoryName $number.
This number describes an overarching THEME or PATTERN in life. What this person will work on again and again.

LENGTH: 80-100 words. No more.

STRUCTURE (as flowing text):
- Opening: The ONE word or theme that runs through this number
- Core: How this shows concretely — in relationships, work, daily life
- Shadow: The trap of this number (every strength has a trap)
- Conclusion: The task — not "your destiny" but "what you keep running into until you learn it"

FORBIDDEN:
"leadership", "wonderful gift", "manifest visions into reality", "material and spiritual worlds", "inspiring", "masterful", "destiny", "manifestation"

IMPORTANT: The number describes a TASK, not a talent. Name the TRAP honestly.

Give ONLY the text, no explanation.
''';
  }
}

/// Prompt 5: Karmische Schuld (Karmic Debt)
String _karmicDebtPrompt(String number, String locale) {
  if (locale == 'de') {
    return '''
AUFGABE:
Schreibe einen Beschreibungstext für die Karmische Schuld $number.

Karmische Schuld bedeutet: Eine alte Rechnung aus vergangenen Leben (oder Familienmustern), die sich in DIESEM Leben als wiederkehrendes Stolperstein-Muster zeigt.

LÄNGE: 80-100 Wörter.

STRUKTUR (als Textfluss, keine Überschriften):
- Eröffnung: Das MUSTER, das sich wiederholt (konkretes Beispiel aus dem Alltag)
- Kern: Warum passiert das immer wieder? Was soll gelernt werden?
- Schatten: Was passiert, wenn du NICHT lernst?
- Schluss: Der Durchbruch — wie du die Schuld auflöst

VERBOTEN:
"vergangene Leben", "Karma auflösen", "spirituelle Schuld", "kosmische Gerechtigkeit", "Bestimmung"

WICHTIG: Schreibe wie eine Freundin, die ein Muster in deinem Leben beobachtet hat. Nicht esoterisch!

Nur Text, keine Erklärung.
''';
  } else {
    return '''
TASK:
Write a description for Karmic Debt $number.

Karmic Debt means: An old pattern that keeps repeating in THIS life as a stumbling block.

LENGTH: 80-100 words.

STRUCTURE (flowing text):
- Opening: The PATTERN that repeats (concrete everyday example)
- Core: Why does this keep happening? What should be learned?
- Shadow: What happens if you DON'T learn?
- Conclusion: The breakthrough — how to resolve the debt

FORBIDDEN:
"past lives", "resolve karma", "spiritual debt", "cosmic justice", "destiny"

IMPORTANT: Write like a friend who has observed a pattern in your life. Not esoteric!

Only text, no explanation.
''';
  }
}

/// Prompt 6: Challenge Number (Herausforderung)
String _challengeNumberPrompt(String number, String locale) {
  if (locale == 'de') {
    return '''
AUFGABE:
Schreibe einen Beschreibungstext für die Herausforderung $number.

Challenges sind die ÜBUNGEN des Lebens — Fähigkeiten, die du NICHT von Natur aus hast, sondern durch Erfahrung entwickeln musst.

LÄNGE: 80-100 Wörter.

STRUKTUR (als Textfluss):
- Eröffnung: Was fällt dir schwer? (konkretes Beispiel)
- Kern: Warum ist das eine Herausforderung für dich?
- Schatten: Was passiert, wenn du aufgibst?
- Schluss: Wie sieht Meisterschaft aus?

VERBOTEN:
"natürliche Gabe", "Talent", "Bestimmung", "Wachstum", "Entwicklung"

WICHTIG: Eine Challenge ist etwas, das NICHT leicht fällt. Sei ehrlich!

Nur Text, keine Erklärung.
''';
  } else {
    return '''
TASK:
Write a description for Challenge $number.

Challenges are life's EXERCISES — skills you DON'T naturally have, but must develop through experience.

LENGTH: 80-100 words.

STRUCTURE (flowing text):
- Opening: What's hard for you? (concrete example)
- Core: Why is this a challenge for you?
- Shadow: What happens if you give up?
- Conclusion: What does mastery look like?

FORBIDDEN:
"natural gift", "talent", "destiny", "growth", "development"

IMPORTANT: A challenge is something that's NOT easy. Be honest!

Only text, no explanation.
''';
  }
}

/// Prompt 7: Karmic Lesson (Karmische Lektion)
String _karmicLessonPrompt(String number, String locale) {
  if (locale == 'de') {
    return '''
AUFGABE:
Schreibe einen Beschreibungstext für die Karmische Lektion $number.

Karmische Lektionen sind FEHLENDE Energien — Zahlen, die in deinem Namen NICHT vorkommen. Du musst sie dir bewusst erarbeiten.

LÄNGE: 80-100 Wörter.

STRUKTUR (als Textfluss):
- Eröffnung: Was fehlt dir? (konkretes Beispiel)
- Kern: Wie zeigt sich diese Lücke im Alltag?
- Schatten: Was passiert, wenn du die Lektion ignorierst?
- Schluss: Wie füllst du die Lücke?

VERBOTEN:
"spirituelle Lektion", "Seele", "kosmisch", "Karma auflösen", "Bestimmung"

WICHTIG: Eine fehlende Zahl bedeutet: Du musst bewusst kompensieren. Sei konkret!

Nur Text, keine Erklärung.
''';
  } else {
    return '''
TASK:
Write a description for Karmic Lesson $number.

Karmic Lessons are MISSING energies — numbers that DON'T appear in your name. You must consciously develop them.

LENGTH: 80-100 words.

STRUCTURE (flowing text):
- Opening: What's missing for you? (concrete example)
- Core: How does this gap show in daily life?
- Shadow: What happens if you ignore the lesson?
- Conclusion: How do you fill the gap?

FORBIDDEN:
"spiritual lesson", "soul", "cosmic", "resolve karma", "destiny"

IMPORTANT: A missing number means: You must consciously compensate. Be concrete!

Only text, no explanation.
''';
  }
}

/// Prompt 8: Bridge Number (Brückenzahl)
String _bridgeNumberPrompt(String number, String locale) {
  if (locale == 'de') {
    return '''
AUFGABE:
Schreibe einen Beschreibungstext für die Brückenzahl $number.

Bridges verbinden zwei VERSCHIEDENE Energien in dir — z.B. Lebensweg und Ausdruck. Die Brücke zeigt, WIE du zwischen beiden vermittelst.

LÄNGE: 80-100 Wörter.

STRUKTUR (als Textfluss):
- Eröffnung: Die Spannung zwischen zwei Teilen von dir (konkretes Beispiel)
- Kern: Wie vermittelst du zwischen beiden?
- Schatten: Was passiert, wenn die Brücke bricht?
- Schluss: Wie nutzt du die Brücke als Stärke?

VERBOTEN:
"Balance finden", "Harmonie", "in Einklang bringen", "spirituelle Verbindung", "kosmisch"

WICHTIG: Eine Brücke ist ARBEIT. Zeige die Spannung!

Nur Text, keine Erklärung.
''';
  } else {
    return '''
TASK:
Write a description for Bridge Number $number.

Bridges connect two DIFFERENT energies within you — e.g. Life Path and Expression. The bridge shows HOW you mediate between both.

LENGTH: 80-100 words.

STRUCTURE (flowing text):
- Opening: The tension between two parts of you (concrete example)
- Core: How do you mediate between both?
- Shadow: What happens if the bridge breaks?
- Conclusion: How do you use the bridge as strength?

FORBIDDEN:
"find balance", "harmony", "bring into alignment", "spiritual connection", "cosmic"

IMPORTANT: A bridge is WORK. Show the tension!

Only text, no explanation.
''';
  }
}

/// Alle Kategorien & Keys
List<CategoryEntry> _getAllCategories() {
  return [
    // Western Astrology - Sun Signs (12)
    CategoryEntry('sun_sign', 'aries', 'Widder'),
    CategoryEntry('sun_sign', 'taurus', 'Stier'),
    CategoryEntry('sun_sign', 'gemini', 'Zwillinge'),
    CategoryEntry('sun_sign', 'cancer', 'Krebs'),
    CategoryEntry('sun_sign', 'leo', 'Löwe'),
    CategoryEntry('sun_sign', 'virgo', 'Jungfrau'),
    CategoryEntry('sun_sign', 'libra', 'Waage'),
    CategoryEntry('sun_sign', 'scorpio', 'Skorpion'),
    CategoryEntry('sun_sign', 'sagittarius', 'Schütze'),
    CategoryEntry('sun_sign', 'capricorn', 'Steinbock'),
    CategoryEntry('sun_sign', 'aquarius', 'Wassermann'),
    CategoryEntry('sun_sign', 'pisces', 'Fische'),

    // Moon Signs (12) - gleiche Keys
    CategoryEntry('moon_sign', 'aries', 'Widder-Mond'),
    CategoryEntry('moon_sign', 'taurus', 'Stier-Mond'),
    CategoryEntry('moon_sign', 'gemini', 'Zwillinge-Mond'),
    CategoryEntry('moon_sign', 'cancer', 'Krebs-Mond'),
    CategoryEntry('moon_sign', 'leo', 'Löwe-Mond'),
    CategoryEntry('moon_sign', 'virgo', 'Jungfrau-Mond'),
    CategoryEntry('moon_sign', 'libra', 'Waage-Mond'),
    CategoryEntry('moon_sign', 'scorpio', 'Skorpion-Mond'),
    CategoryEntry('moon_sign', 'sagittarius', 'Schütze-Mond'),
    CategoryEntry('moon_sign', 'capricorn', 'Steinbock-Mond'),
    CategoryEntry('moon_sign', 'aquarius', 'Wassermann-Mond'),
    CategoryEntry('moon_sign', 'pisces', 'Fische-Mond'),

    // Rising Signs (12) - gleiche Keys
    CategoryEntry('rising_sign', 'aries', 'Widder-Aszendent'),
    CategoryEntry('rising_sign', 'taurus', 'Stier-Aszendent'),
    CategoryEntry('rising_sign', 'gemini', 'Zwillinge-Aszendent'),
    CategoryEntry('rising_sign', 'cancer', 'Krebs-Aszendent'),
    CategoryEntry('rising_sign', 'leo', 'Löwe-Aszendent'),
    CategoryEntry('rising_sign', 'virgo', 'Jungfrau-Aszendent'),
    CategoryEntry('rising_sign', 'libra', 'Waage-Aszendent'),
    CategoryEntry('rising_sign', 'scorpio', 'Skorpion-Aszendent'),
    CategoryEntry('rising_sign', 'sagittarius', 'Schütze-Aszendent'),
    CategoryEntry('rising_sign', 'capricorn', 'Steinbock-Aszendent'),
    CategoryEntry('rising_sign', 'aquarius', 'Wassermann-Aszendent'),
    CategoryEntry('rising_sign', 'pisces', 'Fische-Aszendent'),

    // Numerology - Life Path Numbers (1-9, 11, 22, 33) = 12
    CategoryEntry('life_path_number', '1', 'Lebenszahl 1'),
    CategoryEntry('life_path_number', '2', 'Lebenszahl 2'),
    CategoryEntry('life_path_number', '3', 'Lebenszahl 3'),
    CategoryEntry('life_path_number', '4', 'Lebenszahl 4'),
    CategoryEntry('life_path_number', '5', 'Lebenszahl 5'),
    CategoryEntry('life_path_number', '6', 'Lebenszahl 6'),
    CategoryEntry('life_path_number', '7', 'Lebenszahl 7'),
    CategoryEntry('life_path_number', '8', 'Lebenszahl 8'),
    CategoryEntry('life_path_number', '9', 'Lebenszahl 9'),
    CategoryEntry('life_path_number', '11', 'Meisterzahl 11'),
    CategoryEntry('life_path_number', '22', 'Meisterzahl 22'),
    CategoryEntry('life_path_number', '33', 'Meisterzahl 33'),

    // Bazi Day Masters (ALLE 60 Kombinationen)
    // Yang Wood (甲)
    CategoryEntry('bazi_day_master', 'yang_wood_rat', 'Yang Holz Ratte'),
    CategoryEntry('bazi_day_master', 'yang_wood_tiger', 'Yang Holz Tiger'),
    CategoryEntry('bazi_day_master', 'yang_wood_dragon', 'Yang Holz Drache'),
    CategoryEntry('bazi_day_master', 'yang_wood_horse', 'Yang Holz Pferd'),
    CategoryEntry('bazi_day_master', 'yang_wood_monkey', 'Yang Holz Affe'),
    CategoryEntry('bazi_day_master', 'yang_wood_dog', 'Yang Holz Hund'),

    // Yin Wood (乙)
    CategoryEntry('bazi_day_master', 'yin_wood_ox', 'Yin Holz Büffel'),
    CategoryEntry('bazi_day_master', 'yin_wood_rabbit', 'Yin Holz Hase'),
    CategoryEntry('bazi_day_master', 'yin_wood_snake', 'Yin Holz Schlange'),
    CategoryEntry('bazi_day_master', 'yin_wood_goat', 'Yin Holz Ziege'),
    CategoryEntry('bazi_day_master', 'yin_wood_rooster', 'Yin Holz Hahn'),
    CategoryEntry('bazi_day_master', 'yin_wood_pig', 'Yin Holz Schwein'),

    // Yang Fire (丙)
    CategoryEntry('bazi_day_master', 'yang_fire_rat', 'Yang Feuer Ratte'),
    CategoryEntry('bazi_day_master', 'yang_fire_tiger', 'Yang Feuer Tiger'),
    CategoryEntry('bazi_day_master', 'yang_fire_dragon', 'Yang Feuer Drache'),
    CategoryEntry('bazi_day_master', 'yang_fire_horse', 'Yang Feuer Pferd'),
    CategoryEntry('bazi_day_master', 'yang_fire_monkey', 'Yang Feuer Affe'),
    CategoryEntry('bazi_day_master', 'yang_fire_dog', 'Yang Feuer Hund'),

    // Yin Fire (丁)
    CategoryEntry('bazi_day_master', 'yin_fire_ox', 'Yin Feuer Büffel'),
    CategoryEntry('bazi_day_master', 'yin_fire_rabbit', 'Yin Feuer Hase'),
    CategoryEntry('bazi_day_master', 'yin_fire_snake', 'Yin Feuer Schlange'),
    CategoryEntry('bazi_day_master', 'yin_fire_goat', 'Yin Feuer Ziege'),
    CategoryEntry('bazi_day_master', 'yin_fire_rooster', 'Yin Feuer Hahn'),
    CategoryEntry('bazi_day_master', 'yin_fire_pig', 'Yin Feuer Schwein'),

    // Yang Earth (戊)
    CategoryEntry('bazi_day_master', 'yang_earth_rat', 'Yang Erde Ratte'),
    CategoryEntry('bazi_day_master', 'yang_earth_tiger', 'Yang Erde Tiger'),
    CategoryEntry('bazi_day_master', 'yang_earth_dragon', 'Yang Erde Drache'),
    CategoryEntry('bazi_day_master', 'yang_earth_horse', 'Yang Erde Pferd'),
    CategoryEntry('bazi_day_master', 'yang_earth_monkey', 'Yang Erde Affe'),
    CategoryEntry('bazi_day_master', 'yang_earth_dog', 'Yang Erde Hund'),

    // Yin Earth (己)
    CategoryEntry('bazi_day_master', 'yin_earth_ox', 'Yin Erde Büffel'),
    CategoryEntry('bazi_day_master', 'yin_earth_rabbit', 'Yin Erde Hase'),
    CategoryEntry('bazi_day_master', 'yin_earth_snake', 'Yin Erde Schlange'),
    CategoryEntry('bazi_day_master', 'yin_earth_goat', 'Yin Erde Ziege'),
    CategoryEntry('bazi_day_master', 'yin_earth_rooster', 'Yin Erde Hahn'),
    CategoryEntry('bazi_day_master', 'yin_earth_pig', 'Yin Erde Schwein'),

    // Yang Metal (庚)
    CategoryEntry('bazi_day_master', 'yang_metal_rat', 'Yang Metall Ratte'),
    CategoryEntry('bazi_day_master', 'yang_metal_tiger', 'Yang Metall Tiger'),
    CategoryEntry('bazi_day_master', 'yang_metal_dragon', 'Yang Metall Drache'),
    CategoryEntry('bazi_day_master', 'yang_metal_horse', 'Yang Metall Pferd'),
    CategoryEntry('bazi_day_master', 'yang_metal_monkey', 'Yang Metall Affe'),
    CategoryEntry('bazi_day_master', 'yang_metal_dog', 'Yang Metall Hund'),

    // Yin Metal (辛)
    CategoryEntry('bazi_day_master', 'yin_metal_ox', 'Yin Metall Büffel'),
    CategoryEntry('bazi_day_master', 'yin_metal_rabbit', 'Yin Metall Hase'),
    CategoryEntry('bazi_day_master', 'yin_metal_snake', 'Yin Metall Schlange'),
    CategoryEntry('bazi_day_master', 'yin_metal_goat', 'Yin Metall Ziege'),
    CategoryEntry('bazi_day_master', 'yin_metal_rooster', 'Yin Metall Hahn'),
    CategoryEntry('bazi_day_master', 'yin_metal_pig', 'Yin Metall Schwein'),

    // Yang Water (壬)
    CategoryEntry('bazi_day_master', 'yang_water_rat', 'Yang Wasser Ratte'),
    CategoryEntry('bazi_day_master', 'yang_water_tiger', 'Yang Wasser Tiger'),
    CategoryEntry('bazi_day_master', 'yang_water_dragon', 'Yang Wasser Drache'),
    CategoryEntry('bazi_day_master', 'yang_water_horse', 'Yang Wasser Pferd'),
    CategoryEntry('bazi_day_master', 'yang_water_monkey', 'Yang Wasser Affe'),
    CategoryEntry('bazi_day_master', 'yang_water_dog', 'Yang Wasser Hund'),

    // Yin Water (癸)
    CategoryEntry('bazi_day_master', 'yin_water_ox', 'Yin Wasser Büffel'),
    CategoryEntry('bazi_day_master', 'yin_water_rabbit', 'Yin Wasser Hase'),
    CategoryEntry('bazi_day_master', 'yin_water_snake', 'Yin Wasser Schlange'),
    CategoryEntry('bazi_day_master', 'yin_water_goat', 'Yin Wasser Ziege'),
    CategoryEntry('bazi_day_master', 'yin_water_rooster', 'Yin Wasser Hahn'),
    CategoryEntry('bazi_day_master', 'yin_water_pig', 'Yin Wasser Schwein'),

    // Soul Urge Numbers (1-9, 11, 22, 33)
    CategoryEntry('soul_urge_number', '1', 'Seelenwunsch 1'),
    CategoryEntry('soul_urge_number', '2', 'Seelenwunsch 2'),
    CategoryEntry('soul_urge_number', '3', 'Seelenwunsch 3'),
    CategoryEntry('soul_urge_number', '4', 'Seelenwunsch 4'),
    CategoryEntry('soul_urge_number', '5', 'Seelenwunsch 5'),
    CategoryEntry('soul_urge_number', '6', 'Seelenwunsch 6'),
    CategoryEntry('soul_urge_number', '7', 'Seelenwunsch 7'),
    CategoryEntry('soul_urge_number', '8', 'Seelenwunsch 8'),
    CategoryEntry('soul_urge_number', '9', 'Seelenwunsch 9'),
    CategoryEntry('soul_urge_number', '11', 'Seelenwunsch 11'),
    CategoryEntry('soul_urge_number', '22', 'Seelenwunsch 22'),
    CategoryEntry('soul_urge_number', '33', 'Seelenwunsch 33'),

    // Expression Numbers (1-9, 11, 22, 33)
    CategoryEntry('expression_number', '1', 'Ausdruckszahl 1'),
    CategoryEntry('expression_number', '2', 'Ausdruckszahl 2'),
    CategoryEntry('expression_number', '3', 'Ausdruckszahl 3'),
    CategoryEntry('expression_number', '4', 'Ausdruckszahl 4'),
    CategoryEntry('expression_number', '5', 'Ausdruckszahl 5'),
    CategoryEntry('expression_number', '6', 'Ausdruckszahl 6'),
    CategoryEntry('expression_number', '7', 'Ausdruckszahl 7'),
    CategoryEntry('expression_number', '8', 'Ausdruckszahl 8'),
    CategoryEntry('expression_number', '9', 'Ausdruckszahl 9'),
    CategoryEntry('expression_number', '11', 'Ausdruckszahl 11'),
    CategoryEntry('expression_number', '22', 'Ausdruckszahl 22'),
    CategoryEntry('expression_number', '33', 'Ausdruckszahl 33'),

    // Personality Numbers (1-9, 11, 22, 33)
    CategoryEntry('personality_number', '1', 'Persönlichkeitszahl 1'),
    CategoryEntry('personality_number', '2', 'Persönlichkeitszahl 2'),
    CategoryEntry('personality_number', '3', 'Persönlichkeitszahl 3'),
    CategoryEntry('personality_number', '4', 'Persönlichkeitszahl 4'),
    CategoryEntry('personality_number', '5', 'Persönlichkeitszahl 5'),
    CategoryEntry('personality_number', '6', 'Persönlichkeitszahl 6'),
    CategoryEntry('personality_number', '7', 'Persönlichkeitszahl 7'),
    CategoryEntry('personality_number', '8', 'Persönlichkeitszahl 8'),
    CategoryEntry('personality_number', '9', 'Persönlichkeitszahl 9'),
    CategoryEntry('personality_number', '11', 'Persönlichkeitszahl 11'),
    CategoryEntry('personality_number', '22', 'Persönlichkeitszahl 22'),
    CategoryEntry('personality_number', '33', 'Persönlichkeitszahl 33'),

    // Birthday Numbers (1-31)
    ...List.generate(31, (i) => CategoryEntry('birthday_number', '${i + 1}', 'Geburtstagszahl ${i + 1}')),

    // Attitude Numbers (1-9, 11, 22, 33)
    CategoryEntry('attitude_number', '1', 'Haltungszahl 1'),
    CategoryEntry('attitude_number', '2', 'Haltungszahl 2'),
    CategoryEntry('attitude_number', '3', 'Haltungszahl 3'),
    CategoryEntry('attitude_number', '4', 'Haltungszahl 4'),
    CategoryEntry('attitude_number', '5', 'Haltungszahl 5'),
    CategoryEntry('attitude_number', '6', 'Haltungszahl 6'),
    CategoryEntry('attitude_number', '7', 'Haltungszahl 7'),
    CategoryEntry('attitude_number', '8', 'Haltungszahl 8'),
    CategoryEntry('attitude_number', '9', 'Haltungszahl 9'),
    CategoryEntry('attitude_number', '11', 'Haltungszahl 11'),
    CategoryEntry('attitude_number', '22', 'Haltungszahl 22'),
    CategoryEntry('attitude_number', '33', 'Haltungszahl 33'),

    // Personal Year (1-9)
    CategoryEntry('personal_year', '1', 'Persönliches Jahr 1'),
    CategoryEntry('personal_year', '2', 'Persönliches Jahr 2'),
    CategoryEntry('personal_year', '3', 'Persönliches Jahr 3'),
    CategoryEntry('personal_year', '4', 'Persönliches Jahr 4'),
    CategoryEntry('personal_year', '5', 'Persönliches Jahr 5'),
    CategoryEntry('personal_year', '6', 'Persönliches Jahr 6'),
    CategoryEntry('personal_year', '7', 'Persönliches Jahr 7'),
    CategoryEntry('personal_year', '8', 'Persönliches Jahr 8'),
    CategoryEntry('personal_year', '9', 'Persönliches Jahr 9'),

    // Maturity Numbers (1-9, 11, 22, 33)
    CategoryEntry('maturity_number', '1', 'Reifezahl 1'),
    CategoryEntry('maturity_number', '2', 'Reifezahl 2'),
    CategoryEntry('maturity_number', '3', 'Reifezahl 3'),
    CategoryEntry('maturity_number', '4', 'Reifezahl 4'),
    CategoryEntry('maturity_number', '5', 'Reifezahl 5'),
    CategoryEntry('maturity_number', '6', 'Reifezahl 6'),
    CategoryEntry('maturity_number', '7', 'Reifezahl 7'),
    CategoryEntry('maturity_number', '8', 'Reifezahl 8'),
    CategoryEntry('maturity_number', '9', 'Reifezahl 9'),
    CategoryEntry('maturity_number', '11', 'Reifezahl 11'),
    CategoryEntry('maturity_number', '22', 'Reifezahl 22'),
    CategoryEntry('maturity_number', '33', 'Reifezahl 33'),

    // Display Name Numbers (1-9, 11, 22, 33)
    CategoryEntry('display_name_number', '1', 'Rufnamenzahl 1'),
    CategoryEntry('display_name_number', '2', 'Rufnamenzahl 2'),
    CategoryEntry('display_name_number', '3', 'Rufnamenzahl 3'),
    CategoryEntry('display_name_number', '4', 'Rufnamenzahl 4'),
    CategoryEntry('display_name_number', '5', 'Rufnamenzahl 5'),
    CategoryEntry('display_name_number', '6', 'Rufnamenzahl 6'),
    CategoryEntry('display_name_number', '7', 'Rufnamenzahl 7'),
    CategoryEntry('display_name_number', '8', 'Rufnamenzahl 8'),
    CategoryEntry('display_name_number', '9', 'Rufnamenzahl 9'),
    CategoryEntry('display_name_number', '11', 'Rufnamenzahl 11'),
    CategoryEntry('display_name_number', '22', 'Rufnamenzahl 22'),
    CategoryEntry('display_name_number', '33', 'Rufnamenzahl 33'),

    // Karmic Debt Numbers (13, 14, 16, 19)
    CategoryEntry('karmic_debt', '13', 'Karmische Schuld 13'),
    CategoryEntry('karmic_debt', '14', 'Karmische Schuld 14'),
    CategoryEntry('karmic_debt', '16', 'Karmische Schuld 16'),
    CategoryEntry('karmic_debt', '19', 'Karmische Schuld 19'),

    // Challenge Numbers (0-9, 11, 22)
    CategoryEntry('challenge_number', '0', 'Herausforderung 0'),
    CategoryEntry('challenge_number', '1', 'Herausforderung 1'),
    CategoryEntry('challenge_number', '2', 'Herausforderung 2'),
    CategoryEntry('challenge_number', '3', 'Herausforderung 3'),
    CategoryEntry('challenge_number', '4', 'Herausforderung 4'),
    CategoryEntry('challenge_number', '5', 'Herausforderung 5'),
    CategoryEntry('challenge_number', '6', 'Herausforderung 6'),
    CategoryEntry('challenge_number', '7', 'Herausforderung 7'),
    CategoryEntry('challenge_number', '8', 'Herausforderung 8'),
    CategoryEntry('challenge_number', '9', 'Herausforderung 9'),
    CategoryEntry('challenge_number', '11', 'Herausforderung 11'),
    CategoryEntry('challenge_number', '22', 'Herausforderung 22'),

    // Karmic Lessons (1-9)
    CategoryEntry('karmic_lesson', '1', 'Karmische Lektion 1'),
    CategoryEntry('karmic_lesson', '2', 'Karmische Lektion 2'),
    CategoryEntry('karmic_lesson', '3', 'Karmische Lektion 3'),
    CategoryEntry('karmic_lesson', '4', 'Karmische Lektion 4'),
    CategoryEntry('karmic_lesson', '5', 'Karmische Lektion 5'),
    CategoryEntry('karmic_lesson', '6', 'Karmische Lektion 6'),
    CategoryEntry('karmic_lesson', '7', 'Karmische Lektion 7'),
    CategoryEntry('karmic_lesson', '8', 'Karmische Lektion 8'),
    CategoryEntry('karmic_lesson', '9', 'Karmische Lektion 9'),

    // Bridge Numbers (1-9)
    CategoryEntry('bridge_number', '1', 'Brücke 1'),
    CategoryEntry('bridge_number', '2', 'Brücke 2'),
    CategoryEntry('bridge_number', '3', 'Brücke 3'),
    CategoryEntry('bridge_number', '4', 'Brücke 4'),
    CategoryEntry('bridge_number', '5', 'Brücke 5'),
    CategoryEntry('bridge_number', '6', 'Brücke 6'),
    CategoryEntry('bridge_number', '7', 'Brücke 7'),
    CategoryEntry('bridge_number', '8', 'Brücke 8'),
    CategoryEntry('bridge_number', '9', 'Brücke 9'),
  ];
}

class CategoryEntry {
  const CategoryEntry(this.category, this.key, this.title);
  final String category;
  final String key;
  final String title;
}

class GenerationResult {
  const GenerationResult({required this.description, required this.cost});
  final String description;
  final double cost;
}

/// Lädt .env Datei in Umgebungsvariablen
void _loadEnvFile() {
  try {
    final envFile = File('apps/glow/.env');
    if (!envFile.existsSync()) {
      return;
    }

    final lines = envFile.readAsLinesSync();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      final parts = trimmed.split('=');
      if (parts.length >= 2) {
        final key = parts[0].trim();
        final value = parts.sublist(1).join('=').trim();
        Platform.environment[key] = value;
      }
    }
  } catch (e) {
    // Ignoriere Fehler beim Laden
  }
}
