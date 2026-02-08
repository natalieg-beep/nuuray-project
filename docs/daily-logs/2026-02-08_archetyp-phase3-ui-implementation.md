# 🎨 Archetyp-System Phase 3: UI Components — 2026-02-08

## 📋 Ziel

Implementierung der UI-Komponenten für das Archetyp-System auf dem Home Screen:
- **ArchetypeHeader**: Zeigt Archetyp-Name + Bazi-Adjektiv + Signatur-Text
- **MiniSystemWidgets**: 3 kompakte Cards (Western / Bazi / Numerologie)
- Integration auf Home Screen

---

## ✅ Erfolgreich implementiert

### 1. ArchetypeHeader Widget
**Datei:** `apps/glow/lib/src/features/home/widgets/archetype_header.dart`

**Features:**
- Gold/Champagner Gradient-Hintergrund
- Zeigt: "✨ Dein Archetyp"
- **Titel:** Kombiniert Bazi-Adjektiv + Archetyp-Name
  - Beispiel: "Die feine Strategin"
  - Adjektive OHNE Artikel (werden dynamisch kombiniert)
- **Signatur-Text:** Claude API generierter Text (kursiv)
- **Placeholder:** Falls kein Text: "Tippe hier, um deine persönliche Signatur zu erstellen"
- Tap-Hint: "Tippe für Details zu deiner einzigartigen Signatur →"

**Lokalisierung:**
- Switch-basiert für Archetyp-Namen (12 Archetypen)
- Switch-basiert für Bazi-Adjektive (10 Adjektive)
- Deutsch & Englisch

**Bug-Fixes:**
- ❌ Vorher: "Die Die feine Strategin" (doppelter Artikel)
- ✅ Jetzt: "Die feine Strategin"
- Lösung: `archetypeName.replaceFirst('Die ', '')` → dann `'Die $baziAdjective $nameWithoutArticle'`

---

### 2. MiniSystemWidgets
**Datei:** `apps/glow/lib/src/features/home/widgets/mini_system_widgets.dart`

**Features:**
- 3 Mini-Cards in einer Row
- **Western Card:**
  - Icon: ☀️
  - Titel: "Westlich"
  - Subtitle: Lokalisiertes Sternzeichen (z.B. "Schütze")
- **Bazi Card:**
  - Icon: 🔥
  - Titel: "Bazi Daymaster"
  - Subtitle: Day Master Stem + Branch (z.B. "Xin-Schwein")
- **Numerologie Card:**
  - Icon: 🔢
  - Titel: "Numerologie"
  - Subtitle: "Lebenspfad X" (z.B. "Lebenspfad 8")

**Lokalisierung:**
- `_getLocalizedZodiacSign()`: 12 Sternzeichen (Deutsch/Englisch)
- `_getLocalizedBaziBranch()`: 12 chinesische Tierzeichen (Deutsch/Englisch)
- `isGerman = l10n.localeName.startsWith('de')`

**Bug-Fixes:**
- ❌ Vorher: "sagittarius" (Englisch)
- ✅ Jetzt: "Schütze" (Deutsch)
- ❌ Vorher: "Xin" (nur Stem, nichtssagend)
- ✅ Jetzt: "Xin-Schwein" (Stem + Branch)
- ❌ Vorher: "LP 8" (Abkürzung)
- ✅ Jetzt: "Lebenspfad 8" (ausgeschrieben)

---

### 3. Claude API Prompt Verbesserungen
**Datei:** `apps/glow/lib/src/core/services/claude_api_service.dart`

**Problem:**
Der generierte Text erwähnte nur Western Astrology (Schütze, Waage, Löwe), aber NICHT Bazi und Numerologie.

**Lösung:**
- **Life Path Number** wird jetzt an Claude API übergeben
- **Prompt explizit erweitert:**
  - "KRITISCH - Diese drei Begriffe MÜSSEN im Text vorkommen:"
  - 1. Sternzeichen (z.B. Schütze)
  - 2. Bazi Element (z.B. Yin-Metall)
  - 3. Lebenspfad-Zahl (z.B. 8)
- **Beispiel-Text** im Prompt zeigt gewünschtes Format
- **Mond/Aszendent** werden NICHT mehr erwähnt (zu viel Info)
- Max. Zeichen: 280 (vorher 200)

**Änderungen:**
```dart
// Neu: lifePathNumber Parameter hinzugefügt
Future<String> generateArchetypeSignature({
  required String archetypeName,
  required String baziAdjective,
  required int lifePathNumber,  // ← NEU
  required String sunSign,
  // ...
})
```

**Prompt-Template (Auszug):**
```
**Sternzeichen:** $sunSign
**Bazi Day Master:** $dayMasterElement
**Lebenspfad:** $lifePathNumber

KRITISCH - Diese drei Begriffe MÜSSEN im Text vorkommen:
1. Sternzeichen: $sunSign
2. Bazi Element: $dayMasterElement
3. Lebenspfad-Zahl: $lifePathNumber

Beispiel (Deutsch): "Deine feurige Schütze-Natur tanzt mit der
kristallklaren Präzision des Yin-Metalls durch die Weiten des Lebens,
während die Kraft der Acht den Weg zu wahrer Fülle weist."
```

---

### 4. i18n Fixes
**Dateien:** `packages/nuuray_ui/lib/src/l10n/app_de.arb`, `app_en.arb`

**Änderungen:**
- `"signatureWesternTitle": "Westlich"` (vorher: "Western")
- Bazi-Adjektive OHNE Artikel:
  - ❌ `"baziAdjectiveRefined": "Die feine"`
  - ✅ `"baziAdjectiveRefined": "feine"`
  - Grund: Wird dynamisch mit Artikel kombiniert

---

### 5. Home Screen Integration
**Datei:** `apps/glow/lib/src/features/home/screens/home_screen.dart`

**Änderungen:**
- `_buildArchetypeSection()` erstellt Archetyp aus BirthChart + UserProfile
- Section platziert nach Greeting, vor Daily Energy Card
- Lädt `signatureText` aus UserProfile

**Code:**
```dart
Widget _buildArchetypeSection(BuildContext context, WidgetRef ref, UserProfile profile) {
  final signatureAsync = ref.watch(signatureProvider);

  return signatureAsync.when(
    data: (birthChart) {
      if (birthChart == null) return const SizedBox.shrink();

      final archetype = Archetype.fromBirthChart(
        lifePathNumber: birthChart.lifePathNumber ?? 1,
        dayMasterStem: birthChart.baziDayStem ?? 'Jia',
        signatureText: profile.signatureText, // Aus DB geladen
      );

      return Column([
        ArchetypeHeader(archetype: archetype, onTap: ...),
        MiniSystemWidgets(birthChart: birthChart, ...),
      ]);
    },
    // ...
  );
}
```

---

## ❌ Gescheitert: Auto-Regenerierung beim Login

**Ziel:** Wenn `signature_text = NULL` ist, automatisch neu generieren beim Login.

**Versuchte Ansätze:**
1. ✗ `addPostFrameCallback` im `build()` → wird nicht konsistent aufgerufen
2. ✗ `ref.listenManual` im `initState` → funktioniert nicht mit `ConsumerStatefulWidget`

**Problem:**
- Zu komplex für den Nutzen
- Flutter State Management macht es schwierig
- Provider-Invalidierung führt zu Rebuild-Loops

**Workaround (funktioniert):**
```sql
-- User in Supabase löschen
DELETE FROM auth.users WHERE id = 'user-id';
DELETE FROM profiles WHERE id = 'user-id';
DELETE FROM birth_charts WHERE user_id = 'user-id';

-- Dann: Neu registrieren → Signatur wird mit neuem Prompt generiert
```

**TODO für später:**
- Implementiere "Signatur regenerieren" Button in Settings
- Oder: Supabase Function triggered bei `signature_text = NULL` on profile read

---

## 🐛 Alle Bug-Fixes

### 1. "Die Die feine Strategin"
**Ursache:** Adjektive hatten bereits Artikel ("Die feine"), wurden dann nochmal kombiniert mit Namen ("Die Strategin")

**Fix:**
- i18n: Adjektive OHNE Artikel
- Header: Dynamische Kombination

### 2. "sagittarius" statt "Schütze"
**Ursache:** Sternzeichen-Key wurde direkt angezeigt

**Fix:** `_getLocalizedZodiacSign()` mit Switch für alle 12 Zeichen

### 3. "Xin" statt "Xin-Schwein"
**Ursache:** Nur `baziDayStem` wurde angezeigt, nicht `baziDayBranch`

**Fix:**
```dart
final baziDayMaster = '$baziStem-$baziBranch';
// z.B. "Xin-Schwein"
```

### 4. "LP 8" statt "Lebenspfad 8"
**Ursache:** Abkürzung hardcoded

**Fix:**
```dart
final lifePathText = isGerman
  ? 'Lebenspfad ${birthChart.lifePathNumber}'
  : 'Life Path ${birthChart.lifePathNumber}';
```

### 5. Signatur-Text nur Western Astrology
**Ursache:** Life Path Number wurde nicht an Claude API übergeben

**Fix:**
- Parameter hinzugefügt
- Prompt erweitert mit expliziter Anforderung

### 6. Sprach-Vergleiche case-sensitive
**Ursache:** `language == 'DE'` aber UserProfile hat `'de'`

**Fix:** `language.toUpperCase() == 'DE'` in allen Services

---

## 📊 Statistik

**Dateien erstellt:** 2
- `archetype_header.dart`
- `mini_system_widgets.dart`

**Dateien geändert:** 6
- `home_screen.dart`
- `claude_api_service.dart`
- `archetype_signature_service.dart`
- `app_de.arb`
- `app_en.arb`
- `archetype_signature_prompt.dart`

**Lines of Code:** ~450 Zeilen (neu + geändert)

**Bugs gefunden:** 6
**Bugs gefixt:** 6

**Session-Dauer:** ~3 Stunden
**Frustration-Level:** 8/10 (Auto-Regenerierung gescheitert)

---

## 🎯 Ergebnis

### Was funktioniert:
✅ Archetyp-Header zeigt korrekt: "Die feine Strategin"
✅ Mini-Widgets zeigen: "Schütze" / "Xin-Schwein" / "Lebenspfad 8"
✅ Signatur-Text erwähnt alle 3 Systeme (Sternzeichen, Bazi, Numerologie)
✅ Deutscher Text bei deutscher Sprache
✅ Alle Lokalisierungen korrekt

### Was nicht funktioniert:
❌ Auto-Regenerierung beim Login (wenn signature_text = NULL)

### Workaround:
✅ User löschen + neu registrieren → Signatur wird generiert

---

## 📸 Finale UI

```
┌─────────────────────────────────────────────┐
│ ✨ Dein Archetyp                             │
│                                             │
│ Die feine Strategin                         │
│                                             │
│ Deine feurige Schütze-Natur tanzt mit der  │
│ kristallklaren Präzision des Yin-Metalls   │
│ durch die Weiten des Lebens, während die   │
│ Kraft der Acht den Weg zu wahrer Fülle     │
│ weist.                                      │
│                                             │
│      Tippe für Details zu deiner... →       │
└─────────────────────────────────────────────┘

┌──────────┬──────────────┬──────────────┐
│  ☀️      │     🔥       │     🔢       │
│ Westlich │ Bazi         │ Numerologie  │
│          │ Daymaster    │              │
│ Schütze  │ Xin-Schwein  │ Lebenspfad 8 │
└──────────┴──────────────┴──────────────┘
```

---

**Datum:** 2026-02-08
**Status:** Phase 3 abgeschlossen (mit Einschränkungen)
**Next Steps:** Settings-Button für manuelle Signatur-Regenerierung
