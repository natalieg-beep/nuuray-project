import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Generiert Content Library Einträge für Bazi Jahr/Monat/Stunde Säulen
///
/// Day Master haben wir bereits (60 Texte).
/// Jetzt: 3 × 60 = 180 neue Texte für Jahr, Monat, Stunde
///
/// Kosten: ~$0.54 (nur DE), ~$1.08 (DE+EN)

void main(List<String> args) async {
  final locale = args.isNotEmpty ? args[0] : 'de';

  print('🐉 Bazi Pillars Content Generator');
  print('   Locale: $locale');
  print('   Generating: 180 texts (Jahr + Monat + Stunde)');
  print('');

  final apiKey = Platform.environment['ANTHROPIC_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ ANTHROPIC_API_KEY nicht gesetzt!');
    exit(1);
  }

  final supabaseUrl = 'https://ykkayjbplutdodummcte.supabase.co';
  final supabaseKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'] ??
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl'
      'ra2F5amJwbHV0ZG9kdW1tY3RlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MDMxMjg3MiwiZXhwIjoyMDg1ODg4ODcyfQ.3r_n0v-5yWiweUpALI5mJuPM_Td_tBNhuiQ20EqOKOY';

  // 10 Stems × 12 Branches = 60 Kombinationen
  final stems = [
    'yang_wood', 'yin_wood',
    'yang_fire', 'yin_fire',
    'yang_earth', 'yin_earth',
    'yang_metal', 'yin_metal',
    'yang_water', 'yin_water',
  ];

  final branches = [
    'rat', 'ox', 'tiger', 'rabbit', 'dragon', 'snake',
    'horse', 'goat', 'monkey', 'rooster', 'dog', 'pig',
  ];

  final categories = ['bazi_year_pillar', 'bazi_month_pillar', 'bazi_hour_pillar'];

  int totalGenerated = 0;
  int totalCost = 0;

  for (final category in categories) {
    print('📊 Generiere $category...');

    for (final stem in stems) {
      for (final branch in branches) {
        final key = '${stem}_$branch';

        // Prüfe ob schon vorhanden
        final checkUrl = '$supabaseUrl/rest/v1/content_library?category=eq.$category&key=eq.$key&locale=eq.$locale&select=id';
        final checkResponse = await http.get(
          Uri.parse(checkUrl),
          headers: {
            'apikey': supabaseKey,
            'Authorization': 'Bearer $supabaseKey',
          },
        );

        if (checkResponse.statusCode == 200) {
          final existing = json.decode(checkResponse.body) as List;
          if (existing.isNotEmpty) {
            print('   ⏭️  $key ($category) bereits vorhanden');
            continue;
          }
        }

        // Generiere Text
        final description = await _generateDescription(
          apiKey: apiKey,
          category: category,
          key: key,
          locale: locale,
        );

        if (description == null) {
          print('   ❌ Fehler bei $key ($category)');
          continue;
        }

        // Generiere Titel (z.B. "Jia (Yang Wood) Ratte")
        final parts = key.split('_');
        final polarityPart = parts[0];
        final elementPart = parts[1];
        final branchPart = parts[2];
        final stemName = _getStemName(polarityPart, elementPart);
        final branchName = _getBranchName(branchPart, locale);
        final title = '$stemName $branchName';

        // Speichere in Supabase
        final insertUrl = '$supabaseUrl/rest/v1/content_library';
        final insertResponse = await http.post(
          Uri.parse(insertUrl),
          headers: {
            'apikey': supabaseKey,
            'Authorization': 'Bearer $supabaseKey',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal',
          },
          body: json.encode({
            'category': category,
            'key': key,
            'locale': locale,
            'title': title,
            'description': description,
          }),
        );

        if (insertResponse.statusCode == 201) {
          totalGenerated++;
          print('   ✅ $key ($category) generiert ($totalGenerated/180)');
        } else {
          print('   ❌ Fehler beim Speichern: ${insertResponse.body}');
        }

        // Rate Limiting: 50 requests/min
        await Future.delayed(const Duration(milliseconds: 1200));
      }
    }

    print('');
  }

  print('');
  print('🎉 Fertig!');
  print('   Generiert: $totalGenerated Texte');
  print('   Geschätzte Kosten: ~\$${(totalGenerated * 0.003).toStringAsFixed(2)}');
}

Future<String?> _generateDescription({
  required String apiKey,
  required String category,
  required String key,
  required String locale,
}) async {
  final prompt = _buildPrompt(category: category, key: key, locale: locale);

  try {
    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: json.encode({
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

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final text = data['content'][0]['text'] as String;
      return text.trim();
    } else {
      print('   API Error: ${response.statusCode} - ${response.body}');
      return null;
    }
  } catch (e) {
    print('   Exception: $e');
    return null;
  }
}

String _buildPrompt({
  required String category,
  required String key,
  required String locale,
}) {
  // Parse key: "yang_water_dog" → Yang Water (Ren), Dog
  final parts = key.split('_');
  final polarity = parts[0]; // yang/yin
  final element = parts[1];  // wood/fire/earth/metal/water
  final branch = parts[2];   // rat/ox/tiger/etc

  final stemName = _getStemName(polarity, element);
  final branchName = _getBranchName(branch, locale);
  final elementDE = _getElementDE(element);

  if (category == 'bazi_year_pillar') {
    return _yearPillarPrompt(stemName, branchName, elementDE, polarity, locale);
  } else if (category == 'bazi_month_pillar') {
    return _monthPillarPrompt(stemName, branchName, elementDE, polarity, locale);
  } else {
    return _hourPillarPrompt(stemName, branchName, elementDE, polarity, locale);
  }
}

String _yearPillarPrompt(String stem, String branch, String element, String polarity, String locale) {
  if (locale == 'de') {
    return '''
Schreibe eine Bazi Jahr-Säulen Beschreibung für: $stem $branch.

**Kontext:**
Die Jahr-Säule repräsentiert:
- Familiäre Wurzeln & Ahnenenergie
- Frühe Prägung (0-15 Jahre)
- Öffentliches Image & Reputation
- Wie andere dich wahrnehmen

**Deine Aufgabe:**
Beschreibe die Jahr-Säule "$stem $branch" in 80-100 Wörtern.

**Stil:**
- Konkret, nicht abstrakt ("Du wurdest in eine Familie geboren, die..." statt "Energie der Wurzeln")
- Schattenseiten einbeziehen (jede Energie hat Licht UND Schatten)
- Warmherzig, empowernd
- KEINE Floskeln: "kosmisch", "Universum", "Sterne sagen"

**Beispiel-Struktur:**
1. Familiäre Prägung (1-2 Sätze)
2. Öffentliches Image (1-2 Sätze)
3. Frühe Lebensjahre (1 Satz)
4. Spannungsfeld/Schatten (1 Satz)

Schreibe NUR den Text, keine Einleitung.
''';
  } else {
    return '''
Write a Bazi Year Pillar description for: $stem $branch.

**Context:**
The Year Pillar represents:
- Ancestral roots & family energy
- Early life imprint (0-15 years)
- Public image & reputation
- How others perceive you

**Your task:**
Describe the Year Pillar "$stem $branch" in 80-100 words.

**Style:**
- Concrete, not abstract ("You were born into a family that..." instead of "energy of roots")
- Include shadow sides (every energy has light AND shadow)
- Warm, empowering
- NO clichés: "cosmic", "universe", "stars say"

**Example structure:**
1. Family imprint (1-2 sentences)
2. Public image (1-2 sentences)
3. Early life years (1 sentence)
4. Tension/shadow (1 sentence)

Write ONLY the text, no introduction.
''';
  }
}

String _monthPillarPrompt(String stem, String branch, String element, String polarity, String locale) {
  if (locale == 'de') {
    return '''
Schreibe eine Bazi Monat-Säulen Beschreibung für: $stem $branch.

**Kontext:**
Die Monat-Säule repräsentiert:
- Karriere & berufliche Identität
- Eltern-Beziehung (besonders Mutter)
- Mittlere Lebensphase (15-30 Jahre)
- Wie du deine Ziele verfolgst

**Deine Aufgabe:**
Beschreibe die Monat-Säule "$stem $branch" in 80-100 Wörtern.

**Stil:**
- Konkret, nicht abstrakt ("Deine Karriere gedeiht, wenn..." statt "Energie der Arbeit")
- Schattenseiten einbeziehen (jede Energie hat Licht UND Schatten)
- Warmherzig, empowernd
- KEINE Floskeln: "kosmisch", "Universum", "Sterne sagen"

**Beispiel-Struktur:**
1. Karriere-Ansatz (1-2 Sätze)
2. Eltern-Dynamik (1 Satz)
3. Ziel-Verfolgung (1-2 Sätze)
4. Spannungsfeld/Schatten (1 Satz)

Schreibe NUR den Text, keine Einleitung.
''';
  } else {
    return '''
Write a Bazi Month Pillar description for: $stem $branch.

**Context:**
The Month Pillar represents:
- Career & professional identity
- Parent relationship (especially mother)
- Middle life phase (15-30 years)
- How you pursue goals

**Your task:**
Describe the Month Pillar "$stem $branch" in 80-100 words.

**Style:**
- Concrete, not abstract ("Your career thrives when..." instead of "energy of work")
- Include shadow sides (every energy has light AND shadow)
- Warm, empowering
- NO clichés: "cosmic", "universe", "stars say"

**Example structure:**
1. Career approach (1-2 sentences)
2. Parent dynamic (1 sentence)
3. Goal pursuit (1-2 sentences)
4. Tension/shadow (1 sentence)

Write ONLY the text, no introduction.
''';
  }
}

String _hourPillarPrompt(String stem, String branch, String element, String polarity, String locale) {
  if (locale == 'de') {
    return '''
Schreibe eine Bazi Stunden-Säulen Beschreibung für: $stem $branch.

**Kontext:**
Die Stunden-Säule repräsentiert:
- Kinder & Vermächtnis
- Späte Lebensjahre (60+ Jahre)
- Wie du die Welt prägst
- Was nach dir bleibt

**Deine Aufgabe:**
Beschreibe die Stunden-Säule "$stem $branch" in 80-100 Wörtern.

**Stil:**
- Konkret, nicht abstrakt ("Dein Vermächtnis wird sein..." statt "Energie der Zukunft")
- Schattenseiten einbeziehen (jede Energie hat Licht UND Schatten)
- Warmherzig, empowernd
- KEINE Floskeln: "kosmisch", "Universum", "Sterne sagen"

**Beispiel-Struktur:**
1. Beziehung zu Kindern/Nachwuchs (1-2 Sätze)
2. Vermächtnis (1-2 Sätze)
3. Späte Lebensjahre (1 Satz)
4. Spannungsfeld/Schatten (1 Satz)

Schreibe NUR den Text, keine Einleitung.
''';
  } else {
    return '''
Write a Bazi Hour Pillar description for: $stem $branch.

**Context:**
The Hour Pillar represents:
- Children & legacy
- Late life years (60+ years)
- How you shape the world
- What remains after you

**Your task:**
Describe the Hour Pillar "$stem $branch" in 80-100 words.

**Style:**
- Concrete, not abstract ("Your legacy will be..." instead of "energy of future")
- Include shadow sides (every energy has light AND shadow)
- Warm, empowering
- NO clichés: "cosmic", "universe", "stars say"

**Example structure:**
1. Relationship to children/descendants (1-2 sentences)
2. Legacy (1-2 sentences)
3. Late life years (1 sentence)
4. Tension/shadow (1 sentence)

Write ONLY the text, no introduction.
''';
  }
}

String _getStemName(String polarity, String element) {
  final map = {
    'yang_wood': 'Jia (Yang Wood)',
    'yin_wood': 'Yi (Yin Wood)',
    'yang_fire': 'Bing (Yang Fire)',
    'yin_fire': 'Ding (Yin Fire)',
    'yang_earth': 'Wu (Yang Earth)',
    'yin_earth': 'Ji (Yin Earth)',
    'yang_metal': 'Geng (Yang Metal)',
    'yin_metal': 'Xin (Yin Metal)',
    'yang_water': 'Ren (Yang Water)',
    'yin_water': 'Gui (Yin Water)',
  };
  return map['${polarity}_$element'] ?? '';
}

String _getBranchName(String branch, String locale) {
  if (locale == 'de') {
    const map = {
      'rat': 'Ratte', 'ox': 'Ochse', 'tiger': 'Tiger', 'rabbit': 'Hase',
      'dragon': 'Drache', 'snake': 'Schlange', 'horse': 'Pferd', 'goat': 'Ziege',
      'monkey': 'Affe', 'rooster': 'Hahn', 'dog': 'Hund', 'pig': 'Schwein',
    };
    return map[branch] ?? branch;
  } else {
    const map = {
      'rat': 'Rat', 'ox': 'Ox', 'tiger': 'Tiger', 'rabbit': 'Rabbit',
      'dragon': 'Dragon', 'snake': 'Snake', 'horse': 'Horse', 'goat': 'Goat',
      'monkey': 'Monkey', 'rooster': 'Rooster', 'dog': 'Dog', 'pig': 'Pig',
    };
    return map[branch] ?? branch;
  }
}

String _getElementDE(String element) {
  const map = {
    'wood': 'Holz',
    'fire': 'Feuer',
    'earth': 'Erde',
    'metal': 'Metall',
    'water': 'Wasser',
  };
  return map[element] ?? element;
}
