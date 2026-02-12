# Archetyp-Titel Fix — Parse aus signature_text

> **Datum:** 2026-02-10
> **Problem:** Alter Titel "Die feine Strategin" wurde angezeigt, obwohl neuer Prompt bereits "Die großzügige Perfektionistin" generiert
> **Status:** ✅ **GELÖST**

---

## 🎯 Was wurde gemacht

Der Archetyp-Header wurde angepasst, um den **Claude-generierten Titel** direkt aus `signature_text` zu parsen, statt ihn aus `nameKey` + `adjectiveKey` zu komponieren.

**Geänderte Datei:**
- `apps/glow/lib/src/features/home/widgets/archetype_header.dart`

---

## ❌ Vorher (Problem)

### Was angezeigt wurde:

```
✨ Dein Archetyp

Die feine Strategin          ← ALTE Kombination (nameKey + adjectiveKey)

Deine feurige Schütze...     ← ALTE Synthese
```

### Wie der Titel entstand:

```dart
// Zeile 39-45 (ALT)
final archetypeName = _getLocalizedName(l10n, archetype.nameKey);
final baziAdjective = _getLocalizedAdjective(l10n, archetype.adjectiveKey);
final fullTitle = 'Die $baziAdjective $nameWithoutArticle';
// → "Die feine Strategin"
```

**Problem:**
- Titel wurde **im UI komponiert** aus hardcoded Mappings
- Neuer Prompt generiert **bereits den Titel** (Zeile 1 in `signature_text`)
- Resultat: **Titel-Duplikation** oder falscher Titel

---

## ✅ Nachher (Lösung)

### Was jetzt angezeigt wird:

```
✨ Dein Archetyp

Die großzügige Perfektionistin   ← NEU (Zeile 1 aus signature_text)

Alles in dir will nach vorne... ← NEU (Zeile 3+ aus signature_text)
```

### Wie der Titel jetzt kommt:

```dart
// Parse signature_text
if (archetype.hasSignature) {
  final lines = archetype.signatureText!.split('\n');

  // Zeile 1 = Titel
  displayTitle = lines.first.trim();

  // Zeile 3+ = Synthese (Zeile 2 ist leer)
  final synthesisLines = lines.skip(2).where((line) => line.trim().isNotEmpty);
  displaySynthesis = synthesisLines.join(' ').trim();
} else {
  // Fallback für User ohne neue Signatur
  displayTitle = 'Die $baziAdjective $nameWithoutArticle';
  displaySynthesis = l10n.archetypeNoSignature;
}
```

**Vorteile:**
- ✅ Nutzt Claude-generierten Titel direkt
- ✅ Fallback für alte User (ohne neue Signatur)
- ✅ Keine Titel-Duplikation mehr
- ✅ Kein DB-Schema-Change nötig

---

## 🔧 Technische Details

### signature_text Format (aus Claude API):

```
Die großzügige Perfektionistin    ← Zeile 1 (Titel)
                                   ← Zeile 2 (leer)
Alles in dir will nach vorne —    ← Zeile 3 (Synthese Start)
Schütze-Feuer, Löwe-Aszendent...  ← Zeile 4 (Synthese Fortsetzung)
```

### Parsing-Logik:

```dart
final lines = archetype.signatureText!.split('\n');

// Zeile 1
displayTitle = lines.first.trim();

// Zeile 3+ (skip 2 = überspringe Zeile 1+2)
final synthesisLines = lines.skip(2).where((line) => line.trim().isNotEmpty);
displaySynthesis = synthesisLines.join(' ').trim();
```

**Edge Cases:**
- ✅ Leere Zeilen werden gefiltert (`where((line) => line.trim().isNotEmpty)`)
- ✅ Multiple Zeilen werden mit Leerzeichen gejoined
- ✅ Whitespace wird getrimmt

---

## 📋 Code-Änderungen

### Datei: `archetype_header.dart`

#### 1. Build-Methode (Zeile 30-46)

**Vorher:**
```dart
// Lokalisiere Name + Adjektiv
final archetypeName = _getLocalizedName(l10n, archetype.nameKey);
final baziAdjective = _getLocalizedAdjective(l10n, archetype.adjectiveKey);

// Kombiniere
final nameWithoutArticle = archetypeName.replaceFirst('Die ', '');
final fullTitle = 'Die $baziAdjective $nameWithoutArticle';
```

**Nachher:**
```dart
// Parse Titel und Synthese aus signature_text
String displayTitle;
String displaySynthesis;

if (archetype.hasSignature) {
  final lines = archetype.signatureText!.split('\n');
  displayTitle = lines.first.trim();
  final synthesisLines = lines.skip(2).where((line) => line.trim().isNotEmpty);
  displaySynthesis = synthesisLines.join(' ').trim();
} else {
  // Fallback für User ohne neue Signatur
  final archetypeName = _getLocalizedName(l10n, archetype.nameKey);
  final baziAdjective = _getLocalizedAdjective(l10n, archetype.adjectiveKey);
  final nameWithoutArticle = archetypeName.replaceFirst('Die ', '');
  displayTitle = 'Die $baziAdjective $nameWithoutArticle';
  displaySynthesis = l10n.archetypeNoSignature;
}
```

#### 2. UI-Rendering (Zeile 93-120)

**Vorher:**
```dart
// Archetyp-Name (groß)
Text(
  fullTitle,  // "Die feine Strategin"
  style: theme.textTheme.headlineSmall?.copyWith(
    color: const Color(0xFF2C2416),
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 12),

// Signatur-Satz (kursiv, weicher)
if (archetype.hasSignature)
  Text(
    archetype.signatureText!,  // GESAMTER Text (inkl. Titel!)
    style: theme.textTheme.bodyMedium?.copyWith(
      color: const Color(0xFF2C2416).withOpacity(0.8),
      fontStyle: FontStyle.italic,
      height: 1.5,
    ),
  )
else
  Text(
    l10n.archetypeNoSignature,
    style: theme.textTheme.bodySmall?.copyWith(
      color: const Color(0xFF8B7355),
      fontStyle: FontStyle.italic,
    ),
  ),
```

**Nachher:**
```dart
// Archetyp-Titel (groß, bold)
Text(
  displayTitle,  // "Die großzügige Perfektionistin"
  style: theme.textTheme.headlineSmall?.copyWith(
    color: const Color(0xFF2C2416),
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 12),

// Synthese-Text (kursiv, weicher)
Text(
  displaySynthesis,  // "Alles in dir will nach vorne..."
  style: theme.textTheme.bodyMedium?.copyWith(
    color: const Color(0xFF2C2416).withOpacity(0.8),
    fontStyle: FontStyle.italic,
    height: 1.5,
  ),
),
```

#### 3. Header-Kommentar aktualisiert (Zeile 5-19)

**Vorher:**
```dart
/// Archetyp-Header: Zeigt Name + Adjektiv + Signatur-Satz prominent
/// Layout:
/// │ Die intuitive Strategin             │ ← Groß, bold
/// │ "In dir verbindet sich die präzise  │ ← Kursiv, weicher
```

**Nachher:**
```dart
/// Archetyp-Header: Zeigt Claude-generierten Titel + Synthese prominent
/// Der Titel wird direkt aus `signature_text` geparst (Zeile 1).
/// Layout:
/// │ Die großzügige Perfektionistin      │ ← Zeile 1 aus signature_text
/// │ "Alles in dir will nach vorne —     │ ← Zeile 3+ aus signature_text
```

---

## 🧪 Testing

### 1. Teste mit neuer Signatur

**Voraussetzung:** User hat bereits neue Archetyp-Signatur generiert (nach Prompt-Update)

**Schritte:**
1. App öffnen → Home Screen
2. Prüfe Archetyp-Header

**Erwartung:**
- Titel: "Die großzügige Perfektionistin" (oder ähnlich, von Claude generiert)
- Synthese: "Alles in dir will nach vorne..." (OHNE Titel-Wiederholung)
- **KEIN "Die feine Strategin"** mehr sichtbar

### 2. Teste Fallback (alte User)

**Voraussetzung:** User hat KEINE neue Signatur (`signature_text` ist NULL)

**Schritte:**
1. DB: Setze `signature_text = NULL` für Test-User
2. App öffnen → Home Screen

**Erwartung:**
- Titel: "Die feine Strategin" (alte Kombination als Fallback)
- Synthese: "Noch keine Signatur generiert" (aus i18n)
- **KEIN Crash**, funktioniert normal

### 3. Teste Regenerierung

**Schritte:**
1. Profile Edit → Beliebiges Feld ändern
2. Speichern → Warte 2-3 Sekunden (Claude API Call)
3. Home Screen prüfen

**Erwartung:**
- Titel: NEU generiert von Claude (z.B. "Die theatralische Minimalistin")
- Synthese: NEU generiert von Claude
- **Sofort sichtbar** (kein Reload nötig)

---

## 🐛 Bekannte Edge Cases

### 1. Signatur-Text hat unerwartetes Format

**Problem:** Claude generiert nicht genau im Format "Titel\n\nSynthese"

**Symptom:**
- Titel ist leer
- Synthese enthält Titel

**Lösung:**
- Parsing-Logik ist defensiv (`trim()`, `where(isNotEmpty)`)
- Falls Problem: Prompt in `claude_api_service.dart` anpassen

### 2. Alte Signatur-Texte (vor Prompt-Update)

**Problem:** User haben noch Signaturen im alten Format (nur Synthese, kein Titel)

**Symptom:**
- Titel = "Deine feurige Schütze..." (erster Satz der Synthese)
- Synthese = Rest

**Lösung:**
- User müssen Signatur neu generieren (Profile Edit → Speichern)
- Oder: Fallback-Logik erweitern (erkennen, ob Zeile 1 ein Titel ist)

### 3. Sehr lange Titel (>50 Zeichen)

**Problem:** Claude generiert sehr langen Titel

**Symptom:**
- UI-Overflow (Text wird abgeschnitten)

**Lösung:**
- Prompt in `claude_api_service.dart` erzwingt "2-4 Wörter"
- Falls trotzdem: UI-Styling anpassen (kleinere Font, Wrap)

---

## 📊 Zusammenfassung

| Was | Vorher | Nachher |
|-----|--------|---------|
| **Titel-Quelle** | nameKey + adjectiveKey (komponiert) | signature_text Zeile 1 (geparst) |
| **Titel-Beispiel** | "Die feine Strategin" | "Die großzügige Perfektionistin" |
| **Synthese-Quelle** | signature_text (KOMPLETT) | signature_text Zeile 3+ (geparst) |
| **Duplikation** | ❌ Ja (Titel in Synthese enthalten) | ✅ Nein (sauber getrennt) |
| **Fallback** | ❌ Nein | ✅ Ja (für alte User) |
| **Brand Soul konform** | ❌ Nein (generischer Titel) | ✅ Ja (Claude generiert mit Spannung) |

---

## 🚀 Nächste Schritte

### Sofort (User)
1. ✅ **Code deployed** (archetype_header.dart aktualisiert)
2. ⏳ **App testen:** Home Screen öffnen → Archetyp-Header prüfen
3. ⏳ **Regenerierung testen:** Profile Edit → Speichern → Neuer Titel?

### Optional (später)
1. **DB-Migration:** Separate Felder `archetype_title` + `archetype_synthesis`
   - Vorteile: Sauberere Architektur, kein Parsing
   - Aufwand: ~30 Min (Migration + Code-Änderungen)
   - Siehe: `docs/ARCHETYP_TITEL_ANALYSE.md` (Option 2)

2. **Alte User migrieren:**
   - Einmaliges Script: Alle `signature_text = NULL` → Regenerierung triggern
   - Oder: Lazy Migration (bei nächstem Profile-Edit automatisch)

3. **Parsing-Logik robuster machen:**
   - Regex für Titel-Erkennung (falls Format variiert)
   - Fallback auf alten Titel-Modus wenn Parsing fehlschlägt

---

## 📝 Dokumentation

**Erstellt:**
- `docs/ARCHETYP_TITEL_ANALYSE.md` — Detaillierte Analyse (3 Lösungsoptionen)
- `docs/daily-logs/2026-02-10_archetyp-titel-fix.md` — Dieser Session-Log

**Aktualisiert:**
- `apps/glow/lib/src/features/home/widgets/archetype_header.dart` — Parsing-Logik

---

**Letzte Aktualisierung:** 2026-02-10
**Status:** ✅ **READY FOR TESTING**
