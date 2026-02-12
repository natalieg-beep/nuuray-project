#!/usr/bin/env dart

/// Content Library Prompt Test Script
///
/// Generiert 4 Beispiel-Texte zum Testen der neuen Prompts:
/// 1. Schütze (sun_sign)
/// 2. Waage-Mond (moon_sign)
/// 3. Yin Metall Schwein (bazi_day_master)
/// 4. Lebenszahl 8 (life_path_number)
///
/// Usage:
///   dart scripts/test_content_prompts.dart [--locale de|en]

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Konfiguration
const claudeApiUrl = 'https://api.anthropic.com/v1/messages';

void main(List<String> args) async {
  // .env Datei laden
  _loadEnvFile();

  // Args parsen
  final locale = args.contains('--locale')
      ? args[args.indexOf('--locale') + 1]
      : 'de';

  print('🧪 NUURAY Content Library — Prompt Test');
  print('Locale: $locale');
  print('');

  // Env-Variablen prüfen
  final claudeKey = Platform.environment['ANTHROPIC_API_KEY'] ?? Platform.environment['CLAUDE_API_KEY'];

  if (claudeKey == null) {
    print('❌ Fehler: CLAUDE_API_KEY muss gesetzt sein.');
    print('');
    print('Beispiel:');
    print('  export CLAUDE_API_KEY=sk-ant-...');
    print('  dart scripts/test_content_prompts.dart');
    exit(1);
  }

  // Test-Kategorien
  final tests = [
    TestCase('sun_sign', 'sagittarius', 'Schütze', 1),
    TestCase('moon_sign', 'libra', 'Waage-Mond', 2),
    TestCase('bazi_day_master', 'yin_metal_pig', 'Yin Metall Schwein', 3),
    TestCase('life_path_number', '8', 'Lebenszahl 8', 4),
  ];

  double totalCost = 0.0;

  for (final test in tests) {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('TEST ${test.number}: ${test.title}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('');

    try {
      final result = await _generateDescription(
        category: test.category,
        key: test.key,
        locale: locale,
        claudeKey: claudeKey,
      );

      print('📝 GENERIERTER TEXT:');
      print('');
      print(result.description);
      print('');
      print('📊 STATISTIK:');
      print('   Wörter: ${result.description.split(' ').length}');
      print('   Zeichen: ${result.description.length}');
      print('   Kosten: ~\$${result.cost.toStringAsFixed(4)}');
      print('');

      totalCost += result.cost;

      // 7-Fragen-Check
      print('✅ 7-FRAGEN-CHECK:');
      print('   [ ] 1. Sagt der Text etwas ÜBERRASCHENDES?');
      print('   [ ] 2. Benennt der Text eine SCHATTENSEITE?');
      print('   [ ] 3. Benutzt der Text KONKRETE BILDER?');
      print('   [ ] 4. Könnte er für ein ANDERES Element gelten? (Wenn ja → zu generisch!)');
      print('   [ ] 5. Enthält er VERBOTENE WORTE?');
      print('   [ ] 6. Klingt er wie eine FREUNDIN oder wie ein LEXIKON?');
      print('   [ ] 7. Ist er 80-100 Wörter lang?');
      print('');

      // Pause zwischen Requests
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      print('❌ FEHLER: $e');
      print('');
    }
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✨ TEST ABGESCHLOSSEN');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('');
  print('📊 GESAMT-KOSTEN: ~\$${totalCost.toStringAsFixed(4)}');
  print('');
  print('📝 NÄCHSTE SCHRITTE:');
  print('   1. Prüfe die 4 generierten Texte gegen den 7-Fragen-Check');
  print('   2. Falls OK: Volle Regenerierung mit seed_content_library.dart');
  print('   3. Falls NICHT OK: Prompts anpassen und erneut testen');
}

/// Generiert Beschreibung mit Claude API
Future<GenerationResult> _generateDescription({
  required String category,
  required String key,
  required String locale,
  required String claudeKey,
}) async {
  // Import prompt functions from seed_content_library.dart
  // (Für diesen Test: Inline kopiert)
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
      'max_tokens': 400,
      'system': _getSystemPrompt(locale),
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

// System-Prompt (kopiert aus seed_content_library.dart)
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

// Prompt-Builder (vereinfachte Version für Test)
String _buildPrompt({
  required String category,
  required String key,
  required String locale,
}) {
  switch (category) {
    case 'sun_sign':
      return _sunSignPrompt(key, locale);
    case 'moon_sign':
      return _moonSignPrompt(key, locale);
    case 'bazi_day_master':
      return _baziDayMasterPrompt(key, locale);
    case 'life_path_number':
      return _numerologyPrompt(category, key, locale);
    default:
      throw Exception('Unknown category: $category');
  }
}

// Sonnenzeichen-Prompt
String _sunSignPrompt(String signName, String locale) {
  if (locale == 'de') {
    return '''
AUFGABE:
Schreibe einen Beschreibungstext für das Sonnenzeichen $signName.

LÄNGE: 80-100 Wörter.

STRUKTUR:
- Konkretes Verhaltensmuster
- Was treibt an, was wird vermieden
- Schattenseite (liebevoll)
- Warum das auch Stärke ist

VERBOTEN: "natürliche Gabe", "wunderbar", "unerschütterlich", "inspirierst andere", "kosmisch", "Universum", "Seele"

WICHTIG: Schattenseite MUSS benannt werden!

Nur Text, keine Erklärung.
''';
  } else {
    return '''
TASK:
Write description for sun sign $signName.

LENGTH: 80-100 words.

STRUCTURE:
- Concrete behavior pattern
- What drives, what is avoided
- Shadow side (lovingly)
- Why this is also strength

FORBIDDEN: "natural gift", "wonderful", "unshakeable", "inspire others", "cosmic", "universe", "soul"

IMPORTANT: Shadow side MUST be named!

Only text, no explanation.
''';
  }
}

// Mondzeichen-Prompt
String _moonSignPrompt(String signName, String locale) {
  if (locale == 'de') {
    return '''
AUFGABE:
Schreibe Beschreibung für Mond in $signName.

LÄNGE: 80-100 Wörter.

FOKUS: Emotionales Innenleben (nicht Persönlichkeit!)
- Wie Person innerlich FÜHLT
- Was emotional BRAUCHT
- Wann überreagiert/verschließt sich
- Was emotional einzigartig macht

VERBOTEN: "tiefe Sehnsucht", "natürliches Gespür", "emotionale Intelligenz", "friedvolle Atmosphäre", "kosmisch"

Nur Text, keine Erklärung.
''';
  } else {
    return '''
TASK:
Write description for moon in $signName.

LENGTH: 80-100 words.

FOCUS: Emotional inner life (not personality!)
- How person feels INTERNALLY
- What emotionally NEEDS
- When overreacts/shuts down
- What makes emotionally unique

FORBIDDEN: "deep longing", "natural intuition", "emotional intelligence", "peaceful atmosphere", "cosmic"

Only text, no explanation.
''';
  }
}

// Bazi Day Master Prompt
String _baziDayMasterPrompt(String dayMasterName, String locale) {
  if (locale == 'de') {
    return '''
AUFGABE:
Schreibe Beschreibung für Bazi Day Master $dayMasterName.

LÄNGE: 80-100 Wörter.

FOKUS: Energetische FUNKTIONSWEISE (nicht Charakter!)
- Bild/Vergleich (z.B. Yin-Metall = Uhrmacherin)
- Wie Energie im Alltag zeigt
- Wann aus Balance kippt
- Was braucht um optimal zu funktionieren

VERBOTEN: "seltene Kombination", "authentisch", "sanfte Stärke", "kosmisch", "spirituell"

Nur Text, keine Erklärung.
''';
  } else {
    return '''
TASK:
Write description for Bazi Day Master $dayMasterName.

LENGTH: 80-100 words.

FOCUS: Energetic FUNCTIONING (not character!)
- Image/comparison (e.g. Yin Metal = watchmaker)
- How energy shows in daily life
- When gets out of balance
- What needs to function optimally

FORBIDDEN: "rare combination", "authentic", "gentle strength", "cosmic", "spiritual"

Only text, no explanation.
''';
  }
}

// Numerologie-Prompt
String _numerologyPrompt(String category, String number, String locale) {
  if (locale == 'de') {
    return '''
AUFGABE:
Schreibe Beschreibung für Lebenszahl $number.

LÄNGE: 80-100 Wörter.

FOKUS: Lebensweg-THEMA (nicht Talent!)
- Das EINE Thema
- Wie zeigt sich konkret
- Die FALLE (jede Stärke hat eine)
- Die Aufgabe (nicht "Bestimmung"!)

VERBOTEN: "Führungskraft", "wunderbare Gabe", "Visionen manifestieren", "Bestimmung", "Manifestation"

Nur Text, keine Erklärung.
''';
  } else {
    return '''
TASK:
Write description for Life Path Number $number.

LENGTH: 80-100 words.

FOCUS: Life path THEME (not talent!)
- The ONE theme
- How shows concretely
- The TRAP (every strength has one)
- The task (not "destiny"!)

FORBIDDEN: "leadership", "wonderful gift", "manifest visions", "destiny", "manifestation"

Only text, no explanation.
''';
  }
}

/// Lädt .env Datei
void _loadEnvFile() {
  try {
    final envFile = File('apps/glow/.env');
    if (!envFile.existsSync()) return;

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
    // Ignoriere Fehler
  }
}

class TestCase {
  const TestCase(this.category, this.key, this.title, this.number);
  final String category;
  final String key;
  final String title;
  final int number;
}

class GenerationResult {
  const GenerationResult({required this.description, required this.cost});
  final String description;
  final double cost;
}
