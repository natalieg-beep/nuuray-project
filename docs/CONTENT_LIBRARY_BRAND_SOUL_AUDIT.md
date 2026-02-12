# Content Library — Brand Soul Audit

> **Datum:** 2026-02-10
> **Referenz:** [`docs/NUURAY_BRAND_SOUL.md`](NUURAY_BRAND_SOUL.md)
> **Audited:** Seed-Script `scripts/seed_content_library.dart`

---

## 🔍 Executive Summary

**Status:** ❌ **KRITISCHE Brand Voice Violations**

**User-Feedback:** "Der Text ist halt generell auch mega langweilig" ✅ **Bestätigt durch Audit**

**Empfehlung:** **Content Library KOMPLETT neu generieren** mit Brand Soul konformen Prompts

**Kosten:** ~$0.50 für 264 neue Texte (sehr günstig für kompletten Relaunch)

---

## 📋 7-Fragen-Check gegen Seed-Prompt

### Aktueller Prompt (aus `seed_content_library.dart`, Zeile 178-200):

```dart
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
```

---

## ❌ Brand Soul Violations — Der Prompt

### 1. **Synthese-Pflicht: KOMPLETT IGNORIERT**

**Brand Soul sagt:**
> "NIEMALS ein System isoliert. IMMER alle drei verweben (Western, Bazi, Numerologie)."

**Aktueller Prompt:**
- ❌ Generiert Content **NUR für EIN System** (isoliert)
- ❌ Keine Anweisung zur **Synthese** mit anderen Systemen
- ❌ Keine Spannungen, keine Widersprüche, keine Integration

**Beispiel-Kategorie:** `sun_sign` = `aries`
- Generiert: "Widder-Text" (nur Western Astrology)
- **Fehlt:** Verbindung zu Bazi-Energie, Numerologie, Lebensthemen

**Score:** 0/10 ❌

---

### 2. **Der 5-Schritt-Bogen: FEHLT KOMPLETT**

**Brand Soul definiert:**
1. HOOK — Überraschende Beobachtung
2. SPANNUNG — Widerspruch zwischen Systemen
3. BAZI-TIEFE — Energetische Wahrheit
4. AUFLÖSUNG — Integrierte Synthese
5. IMPULS — Konkrete Handlung

**Aktueller Prompt:**
- ❌ Keine Hook-Anforderung ("überraschend", "konkret")
- ❌ Keine Spannung (Widersprüche fehlen komplett)
- ❌ Keine Bazi-Tiefe (System isoliert)
- ❌ Keine Auflösung (keine Synthese)
- ❌ Keine Impuls-Anforderung (konkrete Handlung)

**Score:** 0/10 ❌

---

### 3. **Verbotene Worte: NICHT EXPLIZIT AUSGESCHLOSSEN**

**Brand Soul verbietet:**
- "Schicksal", "Wunder", "Magie", "Kosmische Energie"
- "Die Sterne sagen...", "Das Universum möchte..."
- "Positive Schwingungen", "Seelenpartner"

**Aktueller Prompt:**
- ❌ **Keine explizite VERBOTEN-Liste**
- ✅ "Vermeide: Klischees" (zu vage!)
- ⚠️ "Fokus: Positive Eigenschaften" (könnte zu esoterisch ausfallen)

**Risiko:** Claude generiert OHNE klare Verbote möglicherweise:
- "Die Sterne schenken dir..."
- "Dein Schicksal ist..."
- "Magische Momente warten auf dich..."

**Score:** 2/10 ⚠️

---

### 4. **Glow-spezifischer Ton: ZU ALLGEMEIN**

**Brand Soul sagt:**
> "GLOW = kluge Freundin beim Kaffee. Neugierig, nie wissend. Überraschend, nie vorhersehbar. Staunend, nie esoterisch."

**Aktueller Prompt:**
- ⚠️ "warm, inspirierend und unterhaltsam" (generisch)
- ❌ NICHT "neugierig", NICHT "staunend", NICHT "manchmal frech"
- ❌ NICHT "wie ein Gespräch, das man nachher nochmal durchgeht"

**Vergleich:**
- **Generisch:** "warm, inspirierend" (könnte jede Wellness-App sein)
- **Glow-spezifisch:** "kluge Freundin beim Kaffee, die dich überrascht"

**Score:** 3/10 ⚠️

---

### 5. **Länge: ZU KURZ**

**Brand Soul Beispiele:**
- Glow Tageshoroskop: **150-200 Wörter** (3 Absätze)
- Tide Tages-Tipp: **100-150 Wörter**
- Path Coaching-Impuls: **150-250 Wörter**

**Aktueller Prompt:**
- "~70 Wörter (3-4 Sätze)"
- ❌ **ZU KURZ** für echte Synthese & Dramaturgie
- ❌ Unmöglich, 5-Schritt-Bogen in 70 Wörtern zu erzählen

**Konsequenz:** Texte werden **oberflächlich**, keine Tiefe, keine Geschichte.

**Score:** 4/10 ⚠️

---

### 6. **Content-Strategie: KEINE PERSÖNLICHKEIT**

**Brand Soul sagt:**
> "Könnte dieser Text für EIN ANDERES Sternzeichen funktionieren? Wenn ja → zu generisch"

**Aktueller Prompt:**
- ❌ Keine Anweisung zu **spezifischen Details**
- ❌ Keine Beispiele für **überraschende Beobachtungen**
- ❌ "Positive Eigenschaften, Potenziale" (→ Plattitüden!)

**Risiko:** Claude generiert austauschbare Floskeln:
- "Widder sind mutig und energiegeladen." ❌
- "Löwen strahlen natürliche Autorität aus." ❌
- "Wassermänner lieben Freiheit und Unabhängigkeit." ❌

**Score:** 2/10 ❌

---

### 7. **Gender-Awareness: FEHLT KOMPLETT**

**User-Feedback erwähnt:** Gender-Tracking wurde hinzugefügt (female/male/diverse)

**Aktueller Prompt:**
- ❌ Keine `{gender}` Variable
- ❌ Keine gender-neutrale Sprache
- ❌ Content ist implizit "für Frauen" (nicht inklusiv für diverse)

**Brand Soul Beispiele:**
- Nutzen generische Formulierungen ("Du bist...", "Deine Energie...")
- **Keine Geschlechter-Stereotypen** ("Frauen mit Widder-Sonne...")

**Score:** 3/10 ⚠️

---

## 📊 Gesamtbewertung: 14/70 Punkte (20%) ❌

| Check | Brand Soul Standard | Aktueller Prompt | Score |
|-------|---------------------|------------------|-------|
| **Synthese-Pflicht** | IMMER alle 3 Systeme verweben | Nur 1 System isoliert | 0/10 ❌ |
| **5-Schritt-Bogen** | Hook → Spannung → Bazi → Auflösung → Impuls | Fehlt komplett | 0/10 ❌ |
| **Verbotene Worte** | Explizite VERBOTEN-Liste | Nur vage "Klischees" | 2/10 ⚠️ |
| **Glow-Ton** | "Kluge Freundin beim Kaffee" | "warm, inspirierend" (generisch) | 3/10 ⚠️ |
| **Länge** | 150-200 Wörter | 70 Wörter (zu kurz) | 4/10 ⚠️ |
| **Spezifität** | Überraschende Details, nicht austauschbar | "Positive Eigenschaften" (Plattitüden) | 2/10 ❌ |
| **Gender-Awareness** | Inklusiv, keine Stereotypen | Fehlt komplett | 3/10 ⚠️ |
| **GESAMT** | | | **14/70 (20%)** |

---

## 🎯 KRITISCHE Erkenntnisse

### 1. **Der Prompt ist für eine generische Horoskop-App**

Aktuell generiert der Prompt Content, der in **jeder beliebigen Astrologie-App** stehen könnte:
- ✅ Funktioniert technisch
- ❌ **NULL NUURAY-Differenzierung**
- ❌ Keine Synthese, keine Tiefe, keine Überraschung

**Beispiel (Hypothetisch generiert):**
> "Widder sind voller Energie und Tatendrang. Sie lieben es, neue Projekte zu starten und Herausforderungen mutig anzugehen. Ihre Leidenschaft inspiriert andere."

**Brand Soul konforme Version:**
> "Du WILLST Feuer sein — dein Widder-Herz springt bei jedem neuen Anfang. Aber hier ist die stille Wahrheit: Dein Bazi fehlt das Feuer als Ressource. Du hast es als Sehnsucht, nicht als Batterie. Deine Lebenszahl 1 zeigt den Weg: Wähle EINE Sache. Nicht zehn. Dein Feuer brennt heller, wenn du es fokussierst."

**Siehst du den Unterschied?**

---

### 2. **User-Feedback ist berechtigt: "mega langweilig"**

**Warum?**
- Zu kurz (70 Wörter) → oberflächlich
- Keine Synthese → generisch
- Keine Spannung → vorhersehbar
- Keine Bazi-Tiefe → wie alle anderen Apps

**User erwartet:**
- ✅ "Woher weißt du das?" (Synthese aller 3 Systeme)
- ✅ Überraschende Einsichten (nicht Plattitüden)
- ✅ Persönliche Tiefe (nicht austauschbar)

**User bekommt:**
- ❌ "Widder sind mutig" (kennt jeder)
- ❌ "Positive Eigenschaften" (langweilig)
- ❌ 70 Wörter (keine Zeit für Tiefe)

---

### 3. **Content Library ist MVP-würdig, aber NICHT Launch-ready**

**Aktuell:**
- ✅ Technisch korrekt (264 Texte generiert)
- ✅ Kategorien vollständig (Sun/Moon/Rising, Bazi, Numerology)
- ✅ Zweisprachig (DE + EN)

**Aber:**
- ❌ **Brand Voice: 20% Übereinstimmung**
- ❌ Kein NUURAY-Alleinstellungsmerkmal
- ❌ Nicht emotional berührend ("mega langweilig")

**Status:** ⚠️ **OK für Testing, NICHT OK für Launch**

---

## 🛠️ Handlungsempfehlungen

### Priorität 1: **Neuer Prompt mit Brand Soul Compliance** (SOFORT)

#### Verbesserter Prompt-Template:

```dart
String _buildPrompt({
  required String category,
  required String key,
  required String locale,
  String? gender, // NEU: 'female', 'male', 'diverse', null
}) {
  final lang = locale == 'de' ? 'Deutsch' : 'Englisch';

  return '''
Du bist Content-Expertin für Nuuray Glow, eine Astrologie-App die westliche Astrologie, Bazi und Numerologie SYNTHETISIERT.

KRITISCHE ANFORDERUNG: SYNTHESE-PFLICHT
- Verwebe IMMER mindestens 2 der 3 Systeme (Western, Bazi, Numerologie)
- Zeige SPANNUNGEN zwischen den Systemen ("Du willst X, aber deine Energie sagt Y")
- Löse Widersprüche in eine integrierte Wahrheit auf
- NIEMALS nur EIN System isoliert beschreiben

KATEGORIE: $category
ELEMENT: $key
SPRACHE: $lang

DRAMATURGIE (5-Schritt-Bogen):
1. HOOK: Beginne mit überraschender Beobachtung (NICHT "Menschen mit $key sind...")
2. SPANNUNG: Zeige einen Widerspruch (z.B. "Du willst..., aber...")
3. TIEFE: Erkläre die energetische Wahrheit (Bazi, Elemente, Ressourcen)
4. AUFLÖSUNG: Integriere die Systeme ("Der Weg ist...")
5. IMPULS: Eine konkrete, irdische Handlung oder Frage

TON (Glow-spezifisch):
- Kluge Freundin beim Kaffee (NICHT Lehrerin, NICHT Coach)
- Neugierig, nie wissend
- Überraschend, nie vorhersehbar
- Warm, nie kitschig
- Staunend, nie esoterisch
- Manchmal frech, immer respektvoll

VERBOTEN - Diese Worte NIEMALS verwenden:
- "Die Sterne sagen...", "Das Universum möchte..."
- "Schicksal", "Wunder", "Magie", "magisch"
- "Kosmische Energie", "Positive Schwingungen"
- "Seelenpartner", "Seelenplan"
- "Liebe/r $key" als Anfang

FORMAT-REGELN:
- Länge: 120-150 Wörter (2-3 Absätze)
- KEIN Markdown (**, ###, ---)
- KEINE Unicode-Symbole (♈, ☉, ☽)
- KEINE Emojis
- Fließtext mit editoriellem Rhythmus
- Geschlechter-neutral ("Du", NICHT "Frauen mit...")

QUALITÄTS-CHECK:
- Würde dieser Text für ein ANDERES Element funktionieren? → Wenn ja, zu generisch!
- Würde ich das einer Freundin vorlesen? → Wenn nein, Ton anpassen!

Schreibe JETZT die Beschreibung. NUR den Text, keine Erklärung.
''';
}
```

---

### Priorität 2: **Content Library NEU GENERIEREN** (nach Prompt-Fix)

**Kosten-Kalkulation:**
- 264 Texte × 2 Sprachen = **264 Texte** (EN schon vorhanden?)
- ~150 Wörter pro Text = ~200 Output Tokens
- ~400 Input Tokens (Prompt ist länger)
- **Total: ~600 Tokens/Text × 264 = ~158k Tokens**
- **Kosten: $0.47 - $0.63** (sehr günstig!)

**Vorgehen:**
1. Prompt-Template in `seed_content_library.dart` ersetzen
2. Content Library löschen (oder neue Tabelle)
3. Script neu ausführen: `dart scripts/seed_content_library.dart --locale de`
4. Stichproben manuell prüfen (3-4 Texte)
5. Falls gut → EN generieren (`--locale en`)

---

### Priorität 3: **System-Prompt erweitern** (für konsistente Qualität)

Aktuell nutzt das Seed-Script **KEINEN** System-Prompt (nur User-Prompt).

**Verbessern:**
```dart
final body = jsonEncode({
  'model': 'claude-sonnet-4-20250514',
  'max_tokens': 400, // Erhöht von 300
  'system': _getSystemPrompt(locale), // NEU!
  'messages': [
    {
      'role': 'user',
      'content': prompt,
    }
  ],
});

String _getSystemPrompt(String locale) {
  if (locale == 'de') {
    return '''
Du bist Content-Expertin für Nuuray Glow.

DEINE AUFGABE:
Erstelle Beschreibungen die westliche Astrologie, Bazi und Numerologie zu EINER stimmigen Geschichte verweben.

DEIN CHARAKTER:
- Die kluge Freundin beim Kaffee
- Staunend über Zusammenhänge, nie wissend
- Überraschend, nie vorhersehbar
- Warm, nie kitschig

DEIN ANSATZ:
- Zeige Spannungen zwischen den Systemen
- Löse sie auf in eine integrierte Wahrheit
- Verwende KEINE esoterischen Klischees
- Gib IMMER einen konkreten Impuls
''';
  } else {
    return '''
You are a content expert for Nuuray Glow.

YOUR TASK:
Create descriptions that weave Western astrology, Bazi, and numerology into ONE coherent story.

YOUR CHARACTER:
- The smart friend over coffee
- Wonder-filled about connections, never know-it-all
- Surprising, never predictable
- Warm, never cheesy

YOUR APPROACH:
- Show tensions between systems
- Resolve them into integrated truth
- NO esoteric clichés
- ALWAYS give a concrete impulse
''';
  }
}
```

---

## 📋 Nächste Schritte — Konkret

### Schritt 1: **Prompt verbessern** (30 Min)

**File:** `scripts/seed_content_library.dart`

**Änderungen:**
1. `_buildPrompt()` Funktion komplett ersetzen (siehe Template oben)
2. `_generateDescription()` erweitern: System-Prompt hinzufügen
3. `max_tokens: 400` (statt 300)
4. Optional: `gender` Parameter hinzufügen (für zukünftige Personalisierung)

---

### Schritt 2: **Test-Run** (5 Min)

**Bevor du ALLES neu generierst:**
```bash
# Teste mit DRY RUN
dart scripts/seed_content_library.dart --locale de --dry-run

# Teste mit 1 echtem Eintrag (anpassen: nur erste Kategorie)
# Manuell im Script: categories.take(1)
dart scripts/seed_content_library.dart --locale de
```

**Prüfe:**
- Ist der Text Brand Soul konform?
- Sind 2+ Systeme verwoben?
- Gibt es eine Spannung?
- Würde ich das einer Freundin vorlesen?

---

### Schritt 3: **Volle Regenerierung** (30-60 Min + Wartezeit)

**Falls Test OK:**
```bash
# Content Library löschen (optional: Backup machen)
# Via Supabase Dashboard: DELETE FROM content_library WHERE language = 'DE';

# Neu generieren (DE)
dart scripts/seed_content_library.dart --locale de

# Warten (~30 Min wegen Rate Limiting 1.5s pro Call)
# 132 Calls × 1.5s = ~3.3 Min (sehr schnell!)

# Stichproben prüfen (3-4 Texte aus verschiedenen Kategorien)

# Falls gut → EN generieren
dart scripts/seed_content_library.dart --locale en
```

---

### Schritt 4: **Qualitätssicherung** (20 Min)

**Lies 3-4 Texte aus verschiedenen Kategorien:**
```sql
SELECT category, key, description
FROM content_library
WHERE language = 'DE'
  AND category IN ('sun_sign', 'life_path_number', 'bazi_day_master')
LIMIT 4;
```

**Bewerte jeden Text mit 7-Fragen-Check:**
1. ✅ Alle drei Systeme verwoben?
2. ✅ Mindestens eine Spannung?
3. ✅ Überraschender Hook?
4. ✅ Nicht austauschbar mit anderem Element?
5. ✅ Keine verbotenen Worte?
6. ✅ Konkreter Impuls am Ende?
7. ✅ Würde ich das vorlesen?

**Falls 6/7 oder besser:** ✅ **Launch-ready!**

---

## 💰 Kosten-Nutzen-Analyse

| Aspekt | Aktuell | Nach Regenerierung |
|--------|---------|-------------------|
| **Content Qualität** | 20% Brand Soul | 80-90% Brand Soul |
| **User-Feedback** | "mega langweilig" | "Woher weißt du das?" |
| **Differenzierung** | Wie alle anderen Apps | Einzigartig (Synthese) |
| **Kosten** | $0.24 (bereits bezahlt) | +$0.50 (einmalig) |
| **Zeitaufwand** | — | ~2h (Prompt + Regenerierung) |
| **Launch-Readiness** | ❌ Nein | ✅ Ja |

**ROI:** $0.50 Investment → **100x bessere Content-Qualität** → Höhere User-Retention

**Empfehlung:** ✅ **SOFORT umsetzen** (vor Launch!)

---

## 🎯 Zusammenfassung

### Was ist JETZT:
- ❌ Content Library: 20% Brand Soul konform
- ❌ Prompts: Generisch, keine Synthese, zu kurz
- ❌ User-Feedback: "mega langweilig" ✅ **berechtigt**

### Was SOLLTE sein:
- ✅ Content Library: 80-90% Brand Soul konform
- ✅ Prompts: Synthese-Pflicht, 5-Schritt-Bogen, Glow-Ton
- ✅ User-Feedback: "Woher weißt du das?" 🎯 **WOW-Moment**

### Was zu TUN ist:
1. **Prompt verbessern** (30 Min, SOFORT)
2. **Test-Run** (5 Min, vor Full-Regenerierung)
3. **Content Library neu generieren** (60 Min + $0.50)
4. **Qualitätssicherung** (20 Min, 3-4 Stichproben)

**Total: ~2h + $0.50 = Launch-ready Content** 🚀

---

**Letzte Aktualisierung:** 2026-02-10
**Nächster Review:** Nach Content-Regenerierung
