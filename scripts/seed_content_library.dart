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
      'max_tokens': 300,
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

/// Speichert in Supabase
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

  if (response.statusCode != 201) {
    throw Exception('Supabase Error: ${response.statusCode} ${response.body}');
  }
}

/// Prompt-Builder
String _buildPrompt({
  required String category,
  required String key,
  required String locale,
}) {
  final lang = locale == 'de' ? 'Deutsch' : 'Englisch';
  final tone = locale == 'de'
      ? 'warm, inspirierend und unterhaltsam'
      : 'warm, inspiring and entertaining';

  return '''
Schreibe eine kurze Beschreibung für $key in der Kategorie $category.

Anforderungen:
- Sprache: $lang
- Länge: ~70 Wörter (3-4 Sätze)
- Ton: $tone
- Zielgruppe: Frauen, die sich für Astrologie & Selbstreflexion interessieren
- Fokus: Positive Eigenschaften, Potenziale, inspirierende Aspekte
- Vermeide: Klischees, Negatives, Vorhersagen

Nur die Beschreibung zurückgeben, kein Titel, keine Formatierung.
''';
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

    // Bazi Day Masters (Top 10 häufigste) - Placeholder, kann erweitert werden
    CategoryEntry('bazi_day_master', 'yang_wood_rat', 'Yang Holz Ratte'),
    CategoryEntry('bazi_day_master', 'yin_wood_ox', 'Yin Holz Büffel'),
    CategoryEntry('bazi_day_master', 'yang_fire_tiger', 'Yang Feuer Tiger'),
    CategoryEntry('bazi_day_master', 'yin_fire_rabbit', 'Yin Feuer Hase'),
    CategoryEntry('bazi_day_master', 'yang_earth_dragon', 'Yang Erde Drache'),
    CategoryEntry('bazi_day_master', 'yin_earth_snake', 'Yin Erde Schlange'),
    CategoryEntry('bazi_day_master', 'yang_metal_horse', 'Yang Metall Pferd'),
    CategoryEntry('bazi_day_master', 'yin_metal_goat', 'Yin Metall Ziege'),
    CategoryEntry('bazi_day_master', 'yang_water_monkey', 'Yang Wasser Affe'),
    CategoryEntry('bazi_day_master', 'yin_water_pig', 'Yin Wasser Schwein'),
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
