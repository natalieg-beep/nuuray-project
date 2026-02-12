#!/usr/bin/env dart

/// Seed ONLY NEW Numerology Categories
///
/// Generiert nur die fehlenden Kategorien:
/// - personality_number (12)
/// - birthday_number (31)
/// - attitude_number (12)
/// - personal_year (9)
/// - maturity_number (12)
/// - display_name_number (12)
/// - karmic_debt (4)
/// - challenge_number (12)
/// - karmic_lesson (9)
/// - bridge_number (9)
///
/// Total: 122 neue Texte

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Konfiguration
const claudeApiUrl = 'https://api.anthropic.com/v1/messages';

void main(List<String> args) async {
  // Env-Variablen prüfen
  final claudeKey = Platform.environment['ANTHROPIC_API_KEY'];
  final supabaseKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  final supabaseUrl = Platform.environment['SUPABASE_URL'] ?? 'https://ykkayjbplutdodummcte.supabase.co';

  if (claudeKey == null || supabaseKey == null) {
    print('❌ Fehler: ANTHROPIC_API_KEY und SUPABASE_SERVICE_ROLE_KEY müssen gesetzt sein.');
    exit(1);
  }

  final locale = args.contains('--locale') ? args[args.indexOf('--locale') + 1] : 'de';

  print('🌟 NUURAY — Neue Numerologie-Kategorien');
  print('Locale: $locale');
  print('');

  final categories = _getNewCategories();
  print('📊 Insgesamt ${categories.length} neue Einträge zu generieren\n');

  double totalCost = 0.0;
  int successCount = 0;

  for (final entry in categories) {
    print('🔄 ${entry.category} → ${entry.key} ($locale)...');

    try {
      // Text generieren via Claude API
      final result = await _generateWithClaude(
        category: entry.category,
        key: entry.key,
        locale: locale,
        claudeApiKey: claudeKey,
      );

      // In Supabase speichern (UPSERT)
      await _saveToSupabase(
        category: entry.category,
        key: entry.key,
        locale: locale,
        title: entry.title,
        description: result.description,
        supabaseUrl: supabaseUrl,
        supabaseKey: supabaseKey,
      );

      totalCost += result.cost;
      successCount++;
      print('   ✅ Gespeichert (~${result.cost.toStringAsFixed(4)}\$)\n');
    } catch (e) {
      print('   ❌ Fehler: $e\n');
    }
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✨ FERTIG');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('');
  print('📊 Erfolgreich generiert: $successCount/${categories.length}');
  print('💰 Gesamt-Kosten: ~${totalCost.toStringAsFixed(2)}\$');
}

/// Generiert Text via Claude API
Future<GenerationResult> _generateWithClaude({
  required String category,
  required String key,
  required String locale,
  required String claudeApiKey,
}) async {
  final systemPrompt = _getSystemPrompt(locale);
  final userPrompt = _buildPrompt(category: category, key: key, locale: locale);

  final response = await http.post(
    Uri.parse(claudeApiUrl),
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': claudeApiKey,
      'anthropic-version': '2023-06-01',
    },
    body: jsonEncode({
      'model': 'claude-sonnet-4-20250514',
      'max_tokens': 400,
      'system': systemPrompt,
      'messages': [
        {'role': 'user', 'content': userPrompt}
      ],
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Claude API Error: ${response.statusCode} ${response.body}');
  }

  final data = jsonDecode(response.body);
  final description = data['content'][0]['text'].toString().trim();
  final tokensUsed = data['usage']['input_tokens'] + data['usage']['output_tokens'];
  final cost = tokensUsed * 0.000003;

  return GenerationResult(description: description, cost: cost);
}

/// Speichert in Supabase (UPSERT)
Future<void> _saveToSupabase({
  required String category,
  required String key,
  required String locale,
  required String title,
  required String description,
  required String supabaseUrl,
  required String supabaseKey,
}) async {
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

  if (response.statusCode == 409) {
    // Fallback: UPDATE
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

String _getSystemPrompt(String locale) {
  if (locale == 'de') {
    return '''
Du bist Content-Expertin für Nuuray Glow.

DEINE AUFGABE:
Erstelle Beschreibungen für einzelne astrologische Elemente (Numerologie-Zahlen).

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
Create descriptions for individual astrological elements (Numerology numbers).

YOUR CHARACTER:
- The smart friend over coffee
- Amazed by connections, never knowing
- Surprising, never predictable
- Warm, never cheesy

YOUR APPROACH:
- Show concrete behaviors, not abstract adjectives
- Lovingly name the shadow side (every text MUST show a weakness!)
- Use NO esoteric clichés
- Always give a concrete impulse or surprising insight
''';
  }
}

String _buildPrompt({required String category, required String key, required String locale}) {
  switch (category) {
    case 'personality_number':
    case 'birthday_number':
    case 'attitude_number':
    case 'personal_year':
    case 'maturity_number':
    case 'display_name_number':
      return _numerologyPrompt(category, key, locale);
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

String _numerologyPrompt(String category, String number, String locale) {
  final categoryName = {
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
Write a description for $categoryName $number.

LENGTH: 80-100 words.

STRUCTURE (flowing text):
- Opening: Concrete everyday example showing this number
- Core: Central tension or question with this number
- Shadow: The trap (with example: "Then X happens")
- Conclusion: What you'll keep working on

FORBIDDEN:
"leadership", "gift", "destiny", "manifestation", "inspiring", "masterful", "universe", "cosmic", "spiritual world"

IMPORTANT: Write like a friend who knows you WELL. Not like a coach.

Only text, no explanation.
''';
  }
}

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
Write description for Karmic Debt $number.

LENGTH: 80-100 words.

STRUCTURE (flowing text):
- Opening: The PATTERN that repeats (concrete everyday example)
- Core: Why does this keep happening?
- Shadow: What happens if you DON'T learn?
- Conclusion: The breakthrough

FORBIDDEN:
"past lives", "resolve karma", "spiritual debt", "cosmic justice", "destiny"

Only text, no explanation.
''';
  }
}

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
Write description for Challenge $number.

LENGTH: 80-100 words.

STRUCTURE (flowing text):
- Opening: What's hard for you? (concrete example)
- Core: Why is this a challenge?
- Shadow: What happens if you give up?
- Conclusion: What does mastery look like?

FORBIDDEN:
"natural gift", "talent", "destiny", "growth"

Only text, no explanation.
''';
  }
}

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
Write description for Karmic Lesson $number.

LENGTH: 80-100 words.

STRUCTURE (flowing text):
- Opening: What's missing for you? (concrete example)
- Core: How does this gap show in daily life?
- Shadow: What happens if you ignore the lesson?
- Conclusion: How do you fill the gap?

FORBIDDEN:
"spiritual lesson", "soul", "cosmic", "resolve karma", "destiny"

Only text, no explanation.
''';
  }
}

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
Write description for Bridge Number $number.

LENGTH: 80-100 words.

STRUCTURE (flowing text):
- Opening: The tension between two parts of you (concrete example)
- Core: How do you mediate between both?
- Shadow: What happens if the bridge breaks?
- Conclusion: How do you use the bridge as strength?

FORBIDDEN:
"find balance", "harmony", "bring into alignment", "spiritual connection", "cosmic"

Only text, no explanation.
''';
  }
}

/// NUR die neuen Kategorien
List<CategoryEntry> _getNewCategories() {
  return [
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
