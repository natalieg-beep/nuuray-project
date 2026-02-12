# Archetyp-Titel Analyse — Wo kommt "Die feine Strategin" her?

> **Datum:** 2026-02-10
> **Problem:** Alter Archetyp-Titel wird angezeigt, aber neuer Prompt generiert bereits Titel + Synthese zusammen

---

## 🔍 Aktuelle Situation

### Was wird angezeigt:

**Im Home Screen (ArchetypeHeader Widget):**
```
✨ Dein Archetyp

Die feine Strategin          ← ALTE KOMBINATION (Name + Adjektiv)

"Deine feurige Schütze..."   ← ALTE SYNTHESE aus DB
```

---

## 🏗️ Architektur — Wie der Titel aktuell entsteht

### 1. **Datenfluss:**

```
BirthChart.lifePathNumber (z.B. 8)
    ↓
ArchetypeNames.getNameKey(8)
    ↓
nameKey = "strategist"
    ↓
_getLocalizedName(nameKey)
    ↓
"Die Strategin"
```

```
BirthChart.dayMasterStem (z.B. "Xin")
    ↓
BaziAdjectives.getAdjectiveKey("Xin")
    ↓
adjectiveKey = "refined"
    ↓
_getLocalizedAdjective(adjectiveKey)
    ↓
"feine"
```

```
"Die Strategin" + "feine"
    ↓
"Die feine Strategin"  ← KOMPONIERT IM UI
```

### 2. **Wo wird der Titel gebaut?**

**File:** `apps/glow/lib/src/features/home/widgets/archetype_header.dart`

**Zeile 39-45:**
```dart
// Lokalisiere Name + Adjektiv
final archetypeName = _getLocalizedName(l10n, archetype.nameKey);
final baziAdjective = _getLocalizedAdjective(l10n, archetype.adjectiveKey);

// Kombiniere: "Die Strategin" + "feine" = "Die feine Strategin"
final nameWithoutArticle = archetypeName.replaceFirst('Die ', '');
final fullTitle = 'Die $baziAdjective $nameWithoutArticle';
```

**Angezeigt als:**
```dart
Text(
  fullTitle,  // "Die feine Strategin"
  style: theme.textTheme.headlineSmall?.copyWith(
    color: const Color(0xFF2C2416),
    fontWeight: FontWeight.bold,
  ),
),
```

---

## 🎯 Was der NEUE Prompt macht

### Claude API generiert jetzt BEIDES in einem Response:

**Zeile 1:** Archetyp-Titel (z.B. "Die großzügige Perfektionistin")
**Zeile 2:** Leerzeile
**Zeile 3-5:** Mini-Synthese (2-3 Sätze)

**Beispiel-Output:**
```
Die großzügige Perfektionistin

Alles in dir will nach vorne — Schütze-Feuer, Löwe-Aszendent, eine 8 als Lebensweg. Aber dein Yin-Metall arbeitet anders: leise, präzise, mit dem Skalpell statt mit der Axt. Dein Waage-Mond verrät das Geheimnis: Du willst nicht nur gewinnen, du willst, dass es dabei schön aussieht.
```

### Wo wird das gespeichert?

**File:** `apps/glow/lib/src/features/signature/services/archetype_signature_service.dart`

**Zeile 126-143:**
```dart
// 4. Generiere Signatur-Satz via Claude API
final signatureText = await _claudeService.generateArchetypeSignature(
  archetypeName: archetypeName,  // "Die Strategin" (ALT, wird nicht mehr genutzt!)
  baziAdjective: baziAdjective,  // "feine" (ALT, wird nicht mehr genutzt!)
  lifePathNumber: birthChart.lifePathNumber!,
  sunSign: sunSignName,
  moonSign: moonSignName,
  ascendant: ascendantName,
  dayMasterElement: dayMasterElement,
  dominantElement: dominantElement,
  language: language,
);

// 5. Speichere GESAMTEN Response in Datenbank
await _supabase.from('profiles').update({
  'signature_text': signatureText,  // ← TITEL + SYNTHESE zusammen!
}).eq('id', userId);
```

**In der DB (`profiles.signature_text`):**
```
Die großzügige Perfektionistin

Alles in dir will nach vorne — Schütze-Feuer...
```

---

## ❌ Das Problem

### Was aktuell passiert:

1. **Neue Signatur wird generiert** (Titel + Synthese zusammen) ✅
2. **Wird in DB gespeichert** (`profiles.signature_text`) ✅
3. **ABER:** UI zeigt IMMER NOCH die alte Kombination:
   - Titel: Aus `Archetype.nameKey` + `Archetype.adjectiveKey` komponiert ❌
   - Synthese: Aus `Archetype.signatureText` gelesen ❌

### Konkret:

**UI baut Titel so:**
```dart
final fullTitle = 'Die $baziAdjective $nameWithoutArticle';
// = "Die feine Strategin"
```

**UI zeigt Synthese so:**
```dart
Text(archetype.signatureText!)
// = Gesamter DB-Inhalt (Titel + Synthese)
```

**Ergebnis:**
```
Die feine Strategin  ← ALTE Kombination aus nameKey + adjectiveKey

Die großzügige Perfektionistin  ← NEUE Titel (aus signatureText)

Alles in dir will nach vorne...  ← NEUE Synthese (aus signatureText)
```

**→ Der Titel wird DOPPELT angezeigt!**
- Einmal: Komponiert aus nameKey + adjectiveKey (ALT)
- Nochmal: In signatureText enthalten (NEU)

---

## ✅ Die Lösung

### Option 1: **Parse `signature_text` und extrahiere Titel** (EMPFOHLEN)

**Änderungen in `archetype_header.dart`:**

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);

  // NEU: Parse Titel aus signature_text (erste Zeile)
  String displayTitle;
  String displaySynthesis;

  if (archetype.hasSignature) {
    final lines = archetype.signatureText!.split('\n');
    displayTitle = lines.first.trim();  // Zeile 1 = Titel

    // Zeile 3+ = Synthese (Zeile 2 ist leer)
    displaySynthesis = lines.skip(2).join('\n').trim();
  } else {
    // Fallback: Alte Kombination (für User ohne neue Signatur)
    final archetypeName = _getLocalizedName(l10n, archetype.nameKey);
    final baziAdjective = _getLocalizedAdjective(l10n, archetype.adjectiveKey);
    final nameWithoutArticle = archetypeName.replaceFirst('Die ', '');
    displayTitle = 'Die $baziAdjective $nameWithoutArticle';
    displaySynthesis = l10n.archetypeNoSignature;
  }

  return GestureDetector(
    onTap: onTap,
    child: Container(
      // ... Container Styling ...
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + "Dein Archetyp"
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                l10n.archetypeSectionTitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF8B7355),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // NEU: Titel aus signature_text
          Text(
            displayTitle,  // "Die großzügige Perfektionistin"
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF2C2416),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // NEU: Nur Synthese (ohne Titel)
          Text(
            displaySynthesis,  // "Alles in dir will nach vorne..."
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF2C2416).withOpacity(0.8),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),

          // Tap-Hint
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n.archetypeTapForDetails,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8B7355),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
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
```

**Vorteile:**
- ✅ Funktioniert sofort nach Regenerierung
- ✅ Fallback für alte User (ohne neue Signatur)
- ✅ Kein DB-Schema-Change nötig
- ✅ Einzige Änderung in UI-Widget

**Nachteile:**
- ⚠️ Parsing-Logik in UI (nicht ideal)
- ⚠️ Abhängig von Claude-Output-Format (erste Zeile = Titel)

---

### Option 2: **Trenne Titel + Synthese in separate DB-Felder** (SAUBER, aber aufwändiger)

**DB-Migration:**
```sql
ALTER TABLE profiles
ADD COLUMN archetype_title TEXT,
ADD COLUMN archetype_synthesis TEXT;

-- Alte signature_text splitten (einmalig)
UPDATE profiles
SET
  archetype_title = split_part(signature_text, E'\n', 1),
  archetype_synthesis = substring(signature_text from position(E'\n\n' in signature_text) + 2);
```

**Code-Änderungen:**

1. `UserProfile` Model erweitern:
```dart
final String? archetypeTitle;
final String? archetypeSynthesis;
```

2. `Archetype` Model erweitern:
```dart
final String? title;        // "Die großzügige Perfektionistin"
final String? synthesis;    // "Alles in dir will nach vorne..."
```

3. `archetype_signature_service.dart` splitten:
```dart
// Parse Claude-Response
final lines = signatureText.split('\n');
final title = lines.first.trim();
final synthesis = lines.skip(2).join('\n').trim();

// Speichere separat
await _supabase.from('profiles').update({
  'archetype_title': title,
  'archetype_synthesis': synthesis,
}).eq('id', userId);
```

4. `archetype_header.dart` anpassen:
```dart
Text(archetype.title!)  // Direkt aus DB
```

**Vorteile:**
- ✅ Saubere Architektur (Separation of Concerns)
- ✅ Kein Parsing in UI nötig
- ✅ Einfacher zu testen

**Nachteile:**
- ❌ DB-Migration erforderlich
- ❌ Mehr Code-Änderungen (Model, Service, UI)
- ❌ Aufwändiger

---

### Option 3: **Entferne `nameKey` + `adjectiveKey` komplett** (RADIKAL)

**Idee:** Claude generiert ALLES, wir brauchen keine hardcoded Mappings mehr.

**Änderungen:**
- `Archetype` Model: Entferne `nameKey`, `adjectiveKey`
- `archetype_header.dart`: Nutze nur `signatureText` (parse Titel raus)
- `ArchetypeNames` + `BaziAdjectives`: Können weg (nur noch für alte User)

**Vorteile:**
- ✅ Simplest possible design
- ✅ Volle Flexibilität für Claude (keine Constraints)

**Nachteile:**
- ❌ Breaking Change für bestehende User
- ❌ Fallback-Logik nötig für alte Signaturen
- ❌ Größere Refactoring-Aufwand

---

## 🎯 Empfehlung

### **Option 1 + Cleanup später**

**Sofort (5 Min):**
1. Ändere `archetype_header.dart`:
   - Parse `signature_text`: Zeile 1 = Titel, Zeile 3+ = Synthese
   - Fallback für User ohne neue Signatur (alte Kombination)

**Später (Optional):**
2. DB-Migration: Separate Felder (`archetype_title`, `archetype_synthesis`)
3. Code-Cleanup: Entferne Parsing-Logik aus UI

---

## 📋 Sofort-Fix — Schritt-für-Schritt

### 1. Ändere `archetype_header.dart` (Zeile 30-100)

**Ersetze:**
```dart
// Lokalisiere Name + Adjektiv
final archetypeName = _getLocalizedName(l10n, archetype.nameKey);
final baziAdjective = _getLocalizedAdjective(l10n, archetype.adjectiveKey);

// Kombiniere
final nameWithoutArticle = archetypeName.replaceFirst('Die ', '');
final fullTitle = 'Die $baziAdjective $nameWithoutArticle';
```

**Durch:**
```dart
// Parse Titel aus signature_text (erste Zeile)
String displayTitle;
String displaySynthesis;

if (archetype.hasSignature) {
  final lines = archetype.signatureText!.split('\n');
  displayTitle = lines.first.trim();  // Zeile 1 = Titel

  // Zeile 3+ = Synthese (Zeile 2 ist leer)
  final synthesisLines = lines.skip(2).where((line) => line.trim().isNotEmpty);
  displaySynthesis = synthesisLines.join(' ').trim();
} else {
  // Fallback: Alte Kombination
  final archetypeName = _getLocalizedName(l10n, archetype.nameKey);
  final baziAdjective = _getLocalizedAdjective(l10n, archetype.adjectiveKey);
  final nameWithoutArticle = archetypeName.replaceFirst('Die ', '');
  displayTitle = 'Die $baziAdjective $nameWithoutArticle';
  displaySynthesis = l10n.archetypeNoSignature;
}
```

**Und verwende:**
```dart
// Archetyp-Name (groß)
Text(
  displayTitle,  // "Die großzügige Perfektionistin"
  style: theme.textTheme.headlineSmall?.copyWith(
    color: const Color(0xFF2C2416),
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 12),

// Signatur-Satz (kursiv, weicher)
Text(
  displaySynthesis,  // "Alles in dir will nach vorne..."
  style: theme.textTheme.bodyMedium?.copyWith(
    color: const Color(0xFF2C2416).withOpacity(0.8),
    fontStyle: FontStyle.italic,
    height: 1.5,
  ),
),
```

### 2. Teste

1. Profile Edit → Beliebiges Feld ändern → Speichern
2. Warte 2-3 Sekunden (Claude API Call)
3. Home Screen: Prüfe Archetyp-Header
4. **Erwartung:**
   - Titel: "Die großzügige Perfektionistin" (NEU aus Claude)
   - Synthese: "Alles in dir will nach vorne..." (ohne Titel-Duplikat)

### 3. Falls Fehler

- Prüfe DB: `SELECT signature_text FROM profiles WHERE id = 'xxx'`
- Prüfe Format: Ist Zeile 1 = Titel, Zeile 2 = leer, Zeile 3+ = Synthese?
- Prüfe Parsing: `print(lines)` vor `.first.trim()`

---

## 💾 Datenbank-Status

**Aktuell (`profiles` Tabelle):**
```
signature_text (TEXT, nullable)
```

**Inhalt (nach Neugeneration):**
```
Die großzügige Perfektionistin

Alles in dir will nach vorne — Schütze-Feuer, Löwe-Aszendent, eine 8 als Lebensweg. Aber dein Yin-Metall arbeitet anders: leise, präzise, mit dem Skalpell statt mit der Axt.
```

**→ KEIN separates Feld für Titel nötig (aktuell)**

---

## 🔧 Alternativen für später

### Wenn du Option 2 umsetzen willst (separate Felder):

**Migration:**
```sql
-- File: supabase/migrations/20260210_split_archetype_title.sql

ALTER TABLE profiles
ADD COLUMN archetype_title TEXT,
ADD COLUMN archetype_synthesis TEXT;

-- Einmaliges Splitting für bestehende Signaturen
UPDATE profiles
SET
  archetype_title = CASE
    WHEN signature_text IS NOT NULL
    THEN split_part(signature_text, E'\n', 1)
    ELSE NULL
  END,
  archetype_synthesis = CASE
    WHEN signature_text LIKE E'%\n\n%'
    THEN substring(signature_text from position(E'\n\n' in signature_text) + 2)
    ELSE NULL
  END
WHERE signature_text IS NOT NULL;

-- Optional: Entferne alte signature_text Spalte (nach Verifikation)
-- ALTER TABLE profiles DROP COLUMN signature_text;
```

**Code-Änderungen:** (später)

---

## 📊 Zusammenfassung

| Was | Wo | Status |
|-----|----|--------|
| **Titel wird komponiert** | `archetype_header.dart` Zeile 39-45 | ❌ ALT (muss weg) |
| **Titel + Synthese generiert** | `claude_api_service.dart` | ✅ NEU (funktioniert) |
| **Gespeichert in DB** | `profiles.signature_text` | ✅ NEU (zusammen) |
| **UI zeigt beides** | `archetype_header.dart` | ❌ DOPPELT (muss gefixt werden) |

**Fix:** Parse `signature_text` → Zeile 1 = Titel, Zeile 3+ = Synthese

---

**Letzte Aktualisierung:** 2026-02-10
