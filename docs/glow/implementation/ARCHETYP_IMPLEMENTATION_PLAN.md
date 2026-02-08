# ARCHETYP-SYSTEM — Implementierungsplan

> **Ziel:** Archetyp-System (Name + Farbe + Signatur-Satz) auf Home Screen integrieren
> **Basis:** `docs/architecture/ARCHETYP_SYSTEM.md`
> **Status:** Plan erstellt, bereit für Implementierung

---

## 📋 Übersicht

Das Archetyp-System fügt eine **persönliche Identität** über dem bestehenden "Deine Signatur" Dashboard hinzu:

```
Home Screen (neue Hierarchie):
┌─────────────────────────────────────┐
│ Guten Tag, Natalie                  │
├─────────────────────────────────────┤
│ ✨ Die entschlossene Strategin      │ ← NEU: Archetyp-Header
│ "In dir verbindet sich..."          │ ← NEU: Signatur-Satz (Claude)
│                                     │
│ [☀️ Western] [🔥 Bazi] [🔢 Numero] │ ← NEU: 3 Mini-Widgets
├─────────────────────────────────────┤
│ ── Tagesenergie ──                  │ ← Bestehendes UI
│ ── Dein Tageshoroskop ──            │
└─────────────────────────────────────┘
```

**Komponenten:**
1. **Archetyp-Name:** Hardcoded Mapping (Lebenszahl → Name)
2. **Bazi-Adjektiv:** Hardcoded Mapping (Day Master → Adjektiv)
3. **Signatur-Satz:** Claude API (einmalig generiert, in DB gecacht)
4. **3 Mini-Widgets:** Kompakte System-Übersicht (tappbar → Detail-Seite)

---

## 🗂️ Implementierungs-Reihenfolge

### Phase 1: Datenbank & Models (Foundation)
**Dauer:** ~2-3 Stunden

1. **DB-Migration:** `signature_text` Feld zu `profiles` Tabelle
2. **Archetyp-Enums/Maps:** Hardcoded Mappings in `nuuray_core`
3. **Archetype Model:** Neue Klasse mit `name`, `adjective`, `signatureText`
4. **i18n:** ARB-Keys für alle Namen + Adjektive (DE + EN)

### Phase 2: API & Service-Logik (Backend)
**Dauer:** ~3-4 Stunden

5. **Prompt-Template:** Signatur-Satz Prompt in `nuuray_api`
6. **ClaudeApiService:** `generateArchetypeSignature()` Methode
7. **SignatureService:** Integration (Signatur generieren + cachen)
8. **Onboarding-Integration:** Nach Chart-Berechnung → Signatur generieren

### Phase 3: UI-Komponenten (Frontend)
**Dauer:** ~4-5 Stunden

9. **ArchetypeHeader Widget:** Name + Adjektiv + Signatur-Satz
10. **MiniSystemWidgets:** 3 kompakte Cards (Western/Bazi/Numerologie)
11. **Home Screen Refactoring:** Neue Hierarchie einbauen
12. **Navigation:** Mini-Widgets → Detail-Seiten verlinken

### Phase 4: Testing & Polish
**Dauer:** ~2-3 Stunden

13. **Visuelles Testing:** App starten, Archetyp-Header prüfen
14. **Edge Cases:** Fehlende Daten (kein Signatur-Satz), Loading States
15. **Dokumentation:** TODO.md + Session-Log aktualisieren

**Total: ~11-15 Stunden** (ca. 2-3 Arbeitstage)

---

## 📦 Phase 1: Datenbank & Models

### 1.1 DB-Migration: `signature_text` Feld

**Datei:** `supabase/migrations/005_add_signature_text.sql` (NEUE MIGRATION!)

```sql
-- Migration: Archetyp Signatur-Satz Feld zu profiles hinzufügen
-- Erstellt: 2026-02-08

ALTER TABLE profiles
ADD COLUMN signature_text TEXT NULL;

COMMENT ON COLUMN profiles.signature_text IS
'Personalisierter Archetyp-Signatur-Satz (Claude API generiert, gecacht)';
```

**RLS:** Keine neue Policy nötig (durch bestehende `auth.uid() = id` abgedeckt)

**Deployment:**
```bash
cd /Users/natalieg/nuuray-project
supabase db push
```

**Verifikation:**
```sql
-- In Supabase Dashboard SQL Editor:
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'profiles' AND column_name = 'signature_text';
```

---

### 1.2 Archetyp-Mapping in `nuuray_core`

**Datei:** `packages/nuuray_core/lib/src/models/archetype/archetype_mappings.dart` (NEU!)

```dart
/// Archetyp-Namen (Lebenszahl → Name)
/// Basis: docs/architecture/ARCHETYP_SYSTEM.md Punkt 3
class ArchetypeNames {
  static const Map<int, String> names = {
    1: 'pioneer',        // Die Pionierin / The Pioneer
    2: 'diplomat',       // Die Diplomatin / The Diplomat
    3: 'creative',       // Die Kreative / The Creative
    4: 'architect',      // Die Architektin / The Architect
    5: 'adventurer',     // Die Abenteurerin / The Adventurer
    6: 'mentor',         // Die Mentorin / The Mentor
    7: 'seeker',         // Die Sucherin / The Seeker
    8: 'strategist',     // Die Strategin / The Strategist
    9: 'humanitarian',   // Die Humanistin / The Humanitarian
    11: 'visionary',     // Die Visionärin / The Visionary
    22: 'master_builder',// Die Baumeisterin / The Master Builder
    33: 'healer',        // Die Heilerin / The Healer
  };

  /// Get archetype name key for i18n
  static String getNameKey(int lifePathNumber) {
    return names[lifePathNumber] ?? 'unknown';
  }
}

/// Bazi-Adjektive (Day Master → Adjektiv)
/// Basis: docs/architecture/ARCHETYP_SYSTEM.md Punkt 4
class BaziAdjectives {
  static const Map<String, String> adjectives = {
    'Jia': 'steadfast',      // Yang-Holz: Die standfeste
    'Yi': 'adaptable',       // Yin-Holz: Die anpassungsfähige
    'Bing': 'radiant',       // Yang-Feuer: Die strahlende
    'Ding': 'perceptive',    // Yin-Feuer: Die feinfühlige
    'Wu': 'grounded',        // Yang-Erde: Die beständige
    'Ji': 'nurturing',       // Yin-Erde: Die nährende
    'Geng': 'resolute',      // Yang-Metall: Die entschlossene
    'Xin': 'refined',        // Yin-Metall: Die feine
    'Ren': 'flowing',        // Yang-Wasser: Die fließende
    'Gui': 'intuitive',      // Yin-Wasser: Die intuitive
  };

  /// Get adjective key for i18n
  static String getAdjectiveKey(String dayMasterStem) {
    return adjectives[dayMasterStem] ?? 'unknown';
  }
}
```

**Export:** In `packages/nuuray_core/lib/nuuray_core.dart` hinzufügen:
```dart
export 'src/models/archetype/archetype_mappings.dart';
```

---

### 1.3 Archetype Model

**Datei:** `packages/nuuray_core/lib/src/models/archetype/archetype.dart` (NEU!)

```dart
import 'package:equatable/equatable.dart';

/// Archetyp-Model: Kombination aus Name, Adjektiv und Signatur-Satz
class Archetype extends Equatable {
  /// Archetyp-Name Key (z.B. "strategist" für i18n-Lookup)
  final String nameKey;

  /// Bazi-Adjektiv Key (z.B. "intuitive" für i18n-Lookup)
  final String adjectiveKey;

  /// Claude-generierter Signatur-Satz (2-3 Sätze, ~150-200 Zeichen)
  final String? signatureText;

  /// Lebenszahl (1-9, 11, 22, 33) - für Debugging
  final int lifePathNumber;

  /// Day Master Stem (z.B. "Gui") - für Debugging
  final String dayMasterStem;

  const Archetype({
    required this.nameKey,
    required this.adjectiveKey,
    this.signatureText,
    required this.lifePathNumber,
    required this.dayMasterStem,
  });

  /// Factory: Erstelle Archetyp aus BirthChart
  factory Archetype.fromBirthChart({
    required int lifePathNumber,
    required String dayMasterStem,
    String? signatureText,
  }) {
    return Archetype(
      nameKey: ArchetypeNames.getNameKey(lifePathNumber),
      adjectiveKey: BaziAdjectives.getAdjectiveKey(dayMasterStem),
      signatureText: signatureText,
      lifePathNumber: lifePathNumber,
      dayMasterStem: dayMasterStem,
    );
  }

  /// Hat einen Signatur-Satz?
  bool get hasSignature => signatureText != null && signatureText!.isNotEmpty;

  @override
  List<Object?> get props => [
        nameKey,
        adjectiveKey,
        signatureText,
        lifePathNumber,
        dayMasterStem,
      ];

  /// CopyWith für Updates
  Archetype copyWith({
    String? nameKey,
    String? adjectiveKey,
    String? signatureText,
    int? lifePathNumber,
    String? dayMasterStem,
  }) {
    return Archetype(
      nameKey: nameKey ?? this.nameKey,
      adjectiveKey: adjectiveKey ?? this.adjectiveKey,
      signatureText: signatureText ?? this.signatureText,
      lifePathNumber: lifePathNumber ?? this.lifePathNumber,
      dayMasterStem: dayMasterStem ?? this.dayMasterStem,
    );
  }
}
```

**Export:** In `packages/nuuray_core/lib/nuuray_core.dart`:
```dart
export 'src/models/archetype/archetype.dart';
```

---

### 1.4 i18n: ARB-Keys für Archetypen

**Dateien:**
- `packages/nuuray_ui/lib/src/l10n/app_de.arb` (ERWEITERN)
- `packages/nuuray_ui/lib/src/l10n/app_en.arb` (ERWEITERN)

**Neue Keys in `app_de.arb`:**

```json
{
  "_comment_archetype": "=== ARCHETYP-SYSTEM ===",

  "archetypeSectionTitle": "Dein Archetyp",
  "@archetypeSectionTitle": {
    "description": "Überschrift für Archetyp-Bereich auf Home Screen"
  },

  "_comment_archetype_names": "Archetyp-Namen (12 Lebenszahlen)",
  "archetypePioneer": "Die Pionierin",
  "archetypeDiplomat": "Die Diplomatin",
  "archetypeCreative": "Die Kreative",
  "archetypeArchitect": "Die Architektin",
  "archetypeAdventurer": "Die Abenteurerin",
  "archetypeMentor": "Die Mentorin",
  "archetypeSeeker": "Die Sucherin",
  "archetypeStrategist": "Die Strategin",
  "archetypeHumanitarian": "Die Humanistin",
  "archetypeVisionary": "Die Visionärin",
  "archetypeMasterBuilder": "Die Baumeisterin",
  "archetypeHealer": "Die Heilerin",

  "_comment_bazi_adjectives": "Bazi-Adjektive (10 Day Master)",
  "baziAdjectiveSteadfast": "Die standfeste",
  "baziAdjectiveAdaptable": "Die anpassungsfähige",
  "baziAdjectiveRadiant": "Die strahlende",
  "baziAdjectivePerceptive": "Die feinfühlige",
  "baziAdjectiveGrounded": "Die beständige",
  "baziAdjectiveNurturing": "Die nährende",
  "baziAdjectiveResolute": "Die entschlossene",
  "baziAdjectiveRefined": "Die feine",
  "baziAdjectiveFlowing": "Die fließende",
  "baziAdjectiveIntuitive": "Die intuitive",

  "_comment_archetype_ui": "Archetyp UI-Texte",
  "archetypeLoadingSignature": "Deine Signatur wird erstellt...",
  "archetypeNoSignature": "Tippe hier, um deine persönliche Signatur zu erstellen",
  "archetypeTapForDetails": "Tippe für Details zu deiner einzigartigen Signatur"
}
```

**Neue Keys in `app_en.arb`:**

```json
{
  "_comment_archetype": "=== ARCHETYPE SYSTEM ===",

  "archetypeSectionTitle": "Your Archetype",
  "archetypePioneer": "The Pioneer",
  "archetypeDiplomat": "The Diplomat",
  "archetypeCreative": "The Creative",
  "archetypeArchitect": "The Architect",
  "archetypeAdventurer": "The Adventurer",
  "archetypeMentor": "The Mentor",
  "archetypeSeeker": "The Seeker",
  "archetypeStrategist": "The Strategist",
  "archetypeHumanitarian": "The Humanitarian",
  "archetypeVisionary": "The Visionary",
  "archetypeMasterBuilder": "The Master Builder",
  "archetypeHealer": "The Healer",

  "baziAdjectiveSteadfast": "The steadfast",
  "baziAdjectiveAdaptable": "The adaptable",
  "baziAdjectiveRadiant": "The radiant",
  "baziAdjectivePerceptive": "The perceptive",
  "baziAdjectiveGrounded": "The grounded",
  "baziAdjectiveNurturing": "The nurturing",
  "baziAdjectiveResolute": "The resolute",
  "baziAdjectiveRefined": "The refined",
  "baziAdjectiveFlowing": "The flowing",
  "baziAdjectiveIntuitive": "The intuitive",

  "archetypeLoadingSignature": "Creating your signature...",
  "archetypeNoSignature": "Tap here to create your personal signature",
  "archetypeTapForDetails": "Tap for details about your unique signature"
}
```

**Regeneration:**
```bash
cd /Users/natalieg/nuuray-project/packages/nuuray_ui
flutter gen-l10n
```

---

## 📦 Phase 2: API & Service-Logik

### 2.1 Prompt-Template für Signatur-Satz

**Datei:** `apps/glow/lib/src/core/services/prompts/archetype_signature_prompt.dart` (NEU!)

```dart
/// Prompt-Template für Archetyp-Signatur-Satz
/// Basis: docs/architecture/ARCHETYP_SYSTEM.md Punkt 5
class ArchetypeSignaturePrompt {
  /// Generiere System-Prompt für Signatur-Satz
  static String generatePrompt({
    required String archetypeName,
    required String baziAdjective,
    required String sunSign,
    String? moonSign,
    String? ascendant,
    required String dayMasterElement,
    required String dominantElement,
    required String language, // 'DE' oder 'EN'
  }) {
    final languageName = language == 'DE' ? 'Deutsch' : 'English';

    return '''
Du bist der Texter für Nuuray Glow, eine Astrologie-App für Frauen.

Erstelle einen persönlichen Signatur-Satz (2-3 Sätze, max. 200 Zeichen)
für folgendes Profil:

Archetyp: $archetypeName
Bazi-Energie: $baziAdjective ($dayMasterElement)
Sonnenzeichen: $sunSign
${moonSign != null ? 'Mondzeichen: $moonSign' : ''}
${ascendant != null ? 'Aszendent: $ascendant' : ''}
Dominantes Element: $dominantElement

Regeln:
- Verwebe alle drei Systeme zu EINEM stimmigen Satz — keine Auflistung.
- Ton: Warm, staunend, wie eine kluge Freundin die etwas Besonderes entdeckt hat.
- Beginne NICHT mit "Du bist" — das steht bereits darüber als Archetyp-Name.
- Verwende keine Fachbegriffe (kein "Day Master", kein "Bazi", kein "Lebenszahl").
- Sprache: $languageName
- Gib NUR den Signatur-Satz zurück, keine Erklärung, kein Intro.
''';
  }
}
```

---

### 2.2 ClaudeApiService: `generateArchetypeSignature()`

**Datei:** `apps/glow/lib/src/core/services/claude_api_service.dart` (ERWEITERN!)

**Neue Methode hinzufügen:**

```dart
/// Generiere Archetyp-Signatur-Satz (einmalig, gecacht)
/// Kosten: ~$0.001 pro Call (200 Input + 80 Output Tokens)
Future<String> generateArchetypeSignature({
  required String archetypeName,
  required String baziAdjective,
  required String sunSign,
  String? moonSign,
  String? ascendant,
  required String dayMasterElement,
  required String dominantElement,
  required String language,
}) async {
  try {
    final prompt = ArchetypeSignaturePrompt.generatePrompt(
      archetypeName: archetypeName,
      baziAdjective: baziAdjective,
      sunSign: sunSign,
      moonSign: moonSign,
      ascendant: ascendant,
      dayMasterElement: dayMasterElement,
      dominantElement: dominantElement,
      language: language,
    );

    final response = await _client.sendMessage(
      [Message(role: 'user', content: prompt)],
    );

    final text = response.content.first.text?.trim() ?? '';

    // Token Usage Tracking
    final inputTokens = response.usage.inputTokens;
    final outputTokens = response.usage.outputTokens;
    log('Archetyp-Signatur generiert: $inputTokens input + $outputTokens output tokens');

    return text;
  } catch (e) {
    log('Fehler bei Archetyp-Signatur-Generierung: $e');
    rethrow;
  }
}
```

---

### 2.3 SignatureService: Integration

**Datei:** `apps/glow/lib/src/features/signature/services/signature_service.dart` (ERWEITERN!)

**Neue Methode hinzufügen:**

```dart
import 'package:nuuray_core/nuuray_core.dart';
import '../../../core/services/claude_api_service.dart';

/// Generiere und cache Archetyp-Signatur-Satz
Future<String> generateAndCacheArchetypeSignature({
  required String userId,
  required BirthChart birthChart,
  required String language,
}) async {
  try {
    // 1. Prüfe ob Signatur bereits existiert
    final profile = await _supabase
        .from('profiles')
        .select('signature_text')
        .eq('id', userId)
        .single();

    final existingSignature = profile['signature_text'] as String?;
    if (existingSignature != null && existingSignature.isNotEmpty) {
      log('Archetyp-Signatur bereits gecacht');
      return existingSignature;
    }

    // 2. Extrahiere Daten aus BirthChart
    final lifePathNumber = birthChart.numerology.lifePathNumber;
    final dayMasterStem = birthChart.bazi.dayMasterStem;

    // 3. Erstelle Archetyp
    final archetype = Archetype.fromBirthChart(
      lifePathNumber: lifePathNumber,
      dayMasterStem: dayMasterStem,
    );

    // 4. Hole lokalisierte Texte (für Prompt)
    final archetypeName = _getLocalizedArchetypeName(archetype.nameKey, language);
    final baziAdjective = _getLocalizedBaziAdjective(archetype.adjectiveKey, language);
    final sunSign = birthChart.western.sunSign.toString();
    final moonSign = birthChart.western.moonSign?.toString();
    final ascendant = birthChart.western.ascendantSign?.toString();
    final dayMasterElement = birthChart.bazi.dayMasterElement;
    final dominantElement = birthChart.bazi.dominantElement;

    // 5. Generiere Signatur-Satz mit Claude API
    final claudeService = ClaudeApiService();
    final signatureText = await claudeService.generateArchetypeSignature(
      archetypeName: archetypeName,
      baziAdjective: baziAdjective,
      sunSign: sunSign,
      moonSign: moonSign,
      ascendant: ascendant,
      dayMasterElement: dayMasterElement,
      dominantElement: dominantElement,
      language: language,
    );

    // 6. Speichere in Datenbank
    await _supabase.from('profiles').update({
      'signature_text': signatureText,
    }).eq('id', userId);

    log('Archetyp-Signatur generiert und gecacht');
    return signatureText;
  } catch (e) {
    log('Fehler bei Archetyp-Signatur-Generierung: $e');
    rethrow;
  }
}

/// Hilfsmethode: Hole lokalisierten Archetyp-Namen
String _getLocalizedArchetypeName(String nameKey, String language) {
  // TODO: Integration mit AppLocalizations
  // Für jetzt: Simple Map
  final namesDE = {
    'strategist': 'Die Strategin',
    'visionary': 'Die Visionärin',
    // ... alle 12 Namen
  };
  final namesEN = {
    'strategist': 'The Strategist',
    'visionary': 'The Visionary',
    // ... alle 12 Namen
  };
  return language == 'DE' ? namesDE[nameKey]! : namesEN[nameKey]!;
}

/// Hilfsmethode: Hole lokalisiertes Bazi-Adjektiv
String _getLocalizedBaziAdjective(String adjectiveKey, String language) {
  final adjectivesDE = {
    'intuitive': 'Die intuitive',
    'resolute': 'Die entschlossene',
    // ... alle 10 Adjektive
  };
  final adjectivesEN = {
    'intuitive': 'The intuitive',
    'resolute': 'The resolute',
    // ... alle 10 Adjektive
  };
  return language == 'DE' ? adjectivesDE[adjectiveKey]! : adjectivesEN[adjectiveKey]!;
}
```

---

### 2.4 Onboarding-Integration

**Datei:** `apps/glow/lib/src/features/onboarding/screens/onboarding_birthdata_combined_screen.dart` (ERWEITERN!)

**Nach Chart-Berechnung → Signatur generieren:**

```dart
// Nach BirthChart-Berechnung (Zeile ~250):
final birthChart = await birthChartService.calculateAndSaveBirthChart(userId);

// NEU: Generiere Archetyp-Signatur
final signatureService = SignatureService();
try {
  await signatureService.generateAndCacheArchetypeSignature(
    userId: userId,
    birthChart: birthChart,
    language: userProfile.language ?? 'DE',
  );
  log('Archetyp-Signatur erfolgreich erstellt');
} catch (e) {
  log('Archetyp-Signatur konnte nicht erstellt werden: $e');
  // Nicht blockieren - Signatur kann später generiert werden
}
```

---

## 📦 Phase 3: UI-Komponenten

### 3.1 ArchetypeHeader Widget

**Datei:** `apps/glow/lib/src/features/home/widgets/archetype_header.dart` (NEU!)

```dart
import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ArchetypeHeader extends StatelessWidget {
  final Archetype archetype;
  final VoidCallback onTap;

  const ArchetypeHeader({
    Key? key,
    required this.archetype,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Lokalisiere Name + Adjektiv
    final archetypeName = _getLocalizedName(l10n, archetype.nameKey);
    final baziAdjective = _getLocalizedAdjective(l10n, archetype.adjectiveKey);
    final fullTitle = '$baziAdjective $archetypeName';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD4AF37), // Gold
              Color(0xFFF5E6D3), // Champagner
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + "Dein Archetyp"
            Row(
              children: [
                Text(
                  '✨',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(width: 8),
                Text(
                  l10n.archetypeSectionTitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Color(0xFF8B7355), // Bronze
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Archetyp-Name (groß)
            Text(
              fullTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Color(0xFF2C2416), // Dunkelbraun
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),

            // Signatur-Satz (kursiv, weicher)
            if (archetype.hasSignature)
              Text(
                archetype.signatureText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Color(0xFF2C2416).withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              )
            else
              Text(
                l10n.archetypeNoSignature,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Color(0xFF8B7355),
                  fontStyle: FontStyle.italic,
                ),
              ),

            // Tap-Hint
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  l10n.archetypeTapForDetails,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Color(0xFF8B7355),
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xFF8B7355),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Lokalisiere Archetyp-Namen
  String _getLocalizedName(AppLocalizations l10n, String nameKey) {
    switch (nameKey) {
      case 'pioneer': return l10n.archetypePioneer;
      case 'diplomat': return l10n.archetypeDiplomat;
      case 'creative': return l10n.archetypeCreative;
      case 'architect': return l10n.archetypeArchitect;
      case 'adventurer': return l10n.archetypeAdventurer;
      case 'mentor': return l10n.archetypeMentor;
      case 'seeker': return l10n.archetypeSeeker;
      case 'strategist': return l10n.archetypeStrategist;
      case 'humanitarian': return l10n.archetypeHumanitarian;
      case 'visionary': return l10n.archetypeVisionary;
      case 'master_builder': return l10n.archetypeMasterBuilder;
      case 'healer': return l10n.archetypeHealer;
      default: return nameKey;
    }
  }

  /// Lokalisiere Bazi-Adjektive
  String _getLocalizedAdjective(AppLocalizations l10n, String adjectiveKey) {
    switch (adjectiveKey) {
      case 'steadfast': return l10n.baziAdjectiveSteadfast;
      case 'adaptable': return l10n.baziAdjectiveAdaptable;
      case 'radiant': return l10n.baziAdjectiveRadiant;
      case 'perceptive': return l10n.baziAdjectivePerceptive;
      case 'grounded': return l10n.baziAdjectiveGrounded;
      case 'nurturing': return l10n.baziAdjectiveNurturing;
      case 'resolute': return l10n.baziAdjectiveResolute;
      case 'refined': return l10n.baziAdjectiveRefined;
      case 'flowing': return l10n.baziAdjectiveFlowing;
      case 'intuitive': return l10n.baziAdjectiveIntuitive;
      default: return adjectiveKey;
    }
  }
}
```

---

### 3.2 Mini-System-Widgets

**Datei:** `apps/glow/lib/src/features/home/widgets/mini_system_widgets.dart` (NEU!)

```dart
import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Drei kompakte System-Cards (Western / Bazi / Numerologie)
class MiniSystemWidgets extends StatelessWidget {
  final BirthChart birthChart;
  final VoidCallback onWesternTap;
  final VoidCallback onBaziTap;
  final VoidCallback onNumerologyTap;

  const MiniSystemWidgets({
    Key? key,
    required this.birthChart,
    required this.onWesternTap,
    required this.onBaziTap,
    required this.onNumerologyTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _MiniCard(
              icon: '☀️',
              title: 'Western',
              subtitle: birthChart.western.sunSign.symbol,
              onTap: onWesternTap,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _MiniCard(
              icon: '🔥',
              title: 'Bazi',
              subtitle: birthChart.bazi.dayMasterStem,
              onTap: onBaziTap,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _MiniCard(
              icon: '🔢',
              title: 'Numerologie',
              subtitle: 'LP ${birthChart.numerology.lifePathNumber}',
              onTap: onNumerologyTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MiniCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFFF5E6D3), // Champagner
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon
            Text(
              icon,
              style: TextStyle(fontSize: 28),
            ),
            SizedBox(height: 8),

            // Title
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Color(0xFF8B7355), // Bronze
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),

            // Subtitle
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Color(0xFF2C2416), // Dunkelbraun
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 3.3 Home Screen Refactoring

**Datei:** `apps/glow/lib/src/features/home/screens/home_screen.dart` (ANPASSEN!)

**Neue Hierarchie:**

```dart
// Im build() der HomeScreen, NACH dem Greeting-Header:

// 1. Lade BirthChart + Profil
final signatureAsync = ref.watch(signatureProvider);
final profileAsync = ref.watch(currentUserProfileProvider);

// 2. Archetyp-Header (NEU!)
signatureAsync.when(
  data: (birthChart) {
    if (birthChart == null) {
      return SizedBox.shrink();
    }

    // Erstelle Archetyp aus BirthChart
    final archetype = Archetype.fromBirthChart(
      lifePathNumber: birthChart.numerology.lifePathNumber,
      dayMasterStem: birthChart.bazi.dayMasterStem,
      signatureText: profileAsync.value?.signatureText, // Aus Profile laden!
    );

    return Column(
      children: [
        // Archetyp-Header
        ArchetypeHeader(
          archetype: archetype,
          onTap: () {
            // Navigate zu Signature Dashboard
            context.go('/signature');
          },
        ),

        // 3 Mini-Widgets
        MiniSystemWidgets(
          birthChart: birthChart,
          onWesternTap: () => context.go('/signature?tab=western'),
          onBaziTap: () => context.go('/signature?tab=bazi'),
          onNumerologyTap: () => context.go('/signature?tab=numerology'),
        ),
      ],
    );
  },
  loading: () => ShimmerPlaceholder(),
  error: (err, stack) => ErrorCard(error: err),
),

// 3. Bestehende UI (Tagesenergie, Horoskop, etc.) - BLEIBT UNVERÄNDERT
```

**Wichtig:**
- `signatureText` aus `UserProfile` laden (nicht aus `BirthChart`!)
- Provider: `currentUserProfileProvider` muss `signatureText` Feld laden

---

### 3.4 UserProfile Model erweitern

**Datei:** `packages/nuuray_core/lib/src/models/user_profile.dart` (ERWEITERN!)

**Neues Feld hinzufügen:**

```dart
class UserProfile extends Equatable {
  // ... bestehende Felder ...

  /// Archetyp-Signatur-Satz (Claude API generiert, gecacht)
  final String? signatureText;

  const UserProfile({
    // ... bestehende Parameter ...
    this.signatureText,
  });

  // factory UserProfile.fromJson(Map<String, dynamic> json) {
  //   return UserProfile(
  //     // ... bestehende Mappings ...
  //     signatureText: json['signature_text'] as String?,
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     // ... bestehende Mappings ...
  //     'signature_text': signatureText,
  //   };
  // }

  // copyWith() auch erweitern!
}
```

---

## 📦 Phase 4: Testing & Polish

### 4.1 Visuelles Testing

**Checkliste:**

- [ ] App starten: `cd apps/glow && flutter run`
- [ ] Login mit Test-Account: `natalie.guenes.tr@gmail.com`
- [ ] Home Screen öffnen
- [ ] **Archetyp-Header prüfen:**
  - [ ] Name + Adjektiv angezeigt (z.B. "Die intuitive Visionärin")
  - [ ] Signatur-Satz angezeigt (Claude-Text)
  - [ ] Gold-Gradient sichtbar
  - [ ] Tap → navigiert zu Signature Dashboard
- [ ] **Mini-Widgets prüfen:**
  - [ ] Drei Cards nebeneinander (Western / Bazi / Numerologie)
  - [ ] Icons + Daten korrekt
  - [ ] Tap auf Western → öffnet Western Detail
  - [ ] Tap auf Bazi → öffnet Bazi Detail
  - [ ] Tap auf Numerologie → öffnet Numerologie Detail

### 4.2 Edge Cases

**Testen:**

1. **Kein Signatur-Satz:**
   - DB: `signature_text` auf `NULL` setzen
   - Erwartung: "Tippe hier, um deine persönliche Signatur zu erstellen"
   - Tap → generiert Signatur on-demand

2. **Fehlende Geburtsdaten:**
   - User ohne Geburtszeit (kein Aszendent)
   - Erwartung: Prompt funktioniert trotzdem (Aszendent-Zeile entfällt)

3. **Sprach-Wechsel:**
   - In Settings Sprache auf EN umstellen
   - Erwartung: Archetyp-Name + Adjektiv auf Englisch
   - Signatur-Satz: Bleibt in alter Sprache (bis neu generiert)

4. **Loading States:**
   - Slow Network simulieren
   - Erwartung: Shimmer-Placeholder während Laden

### 4.3 Dokumentation

**Dateien aktualisieren:**

1. **TODO.md:**
   - ✅ Archetyp-System implementiert
   - Neue Section: "Archetyp-System (FERTIG)"

2. **Session-Log erstellen:**
   - `docs/daily-logs/2026-02-08_archetyp-system.md`
   - Was wurde gemacht?
   - Learnings?
   - Screenshots?

3. **GLOW_SPEC_V2.md:**
   - Archetyp-System als implementiert markieren

---

## 📊 Zusammenfassung

### Was wird gebaut?

| Komponente | Dateien | Status |
|------------|---------|--------|
| **DB-Migration** | `005_add_signature_text.sql` | TODO |
| **Archetyp-Mappings** | `archetype_mappings.dart` | TODO |
| **Archetype Model** | `archetype.dart` | TODO |
| **i18n Keys** | `app_de.arb`, `app_en.arb` | TODO |
| **Prompt-Template** | `archetype_signature_prompt.dart` | TODO |
| **Claude API Methode** | `claude_api_service.dart` (erweitern) | TODO |
| **Service Integration** | `signature_service.dart` (erweitern) | TODO |
| **Onboarding Hook** | `onboarding_birthdata_combined_screen.dart` | TODO |
| **ArchetypeHeader Widget** | `archetype_header.dart` | TODO |
| **MiniSystemWidgets** | `mini_system_widgets.dart` | TODO |
| **Home Screen Update** | `home_screen.dart` | TODO |
| **UserProfile Model** | `user_profile.dart` | TODO |

**Total: 12 Dateien** (4 neu, 8 erweitert)

### Zeitschätzung

- **Phase 1 (Foundation):** 2-3h
- **Phase 2 (Backend):** 3-4h
- **Phase 3 (Frontend):** 4-5h
- **Phase 4 (Testing):** 2-3h

**Total: 11-15 Stunden** (2-3 Arbeitstage)

### Kosten

- **Claude API:** ~$0.001 pro Signatur-Satz
- **Bei 100 Nutzern:** ~$0.10 total (vernachlässigbar!)

---

## ✅ Nächste Schritte

**Bereit für Implementierung?**

1. **DB-Migration deployen** (5 Min)
2. **Phase 1 abarbeiten** (Models + i18n)
3. **Phase 2 abarbeiten** (API + Service)
4. **Phase 3 abarbeiten** (UI)
5. **Testing** (visuell prüfen)

**Fragen vor Start?** 😊
