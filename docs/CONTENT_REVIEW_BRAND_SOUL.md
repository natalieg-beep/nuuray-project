# Content Review gegen Brand Soul Guidelines

> **Datum:** 2026-02-10
> **Referenz:** [`docs/NUURAY_BRAND_SOUL.md`](NUURAY_BRAND_SOUL.md)

---

## 🎯 Review-Ergebnis: Prompt-Templates

### ✅ Was bereits KORREKT ist:

#### 1. Archetyp-Signatur Prompt (`archetype_signature_prompt.dart`)
- ✅ Synthese-Ansatz ("Verwebe alle drei Systeme")
- ✅ Ton: "Warm, staunend"
- ✅ Vermeidet "Du bist..."
- ✅ Keine Fachbegriffe im Output

#### 2. Daily Horoscope Prompt (`claude_api_service.dart`)
- ✅ Ton: "Unterhaltsam, staunend, inspirierend (wie eine gute Freundin)"
- ✅ Verbietet generische Floskeln
- ✅ Direkte Ansprache ("Du")
- ✅ Fokus auf Handlungsfähigkeit

#### 3. System Prompts
- ✅ Charakter-Definition: "kluge Freundin", "empowernd"
- ✅ Verbietet: "Dramatische Vorhersagen", "übertriebene Spiritualität"

---

## ⚠️ Was FEHLT / ANPASSEN

### 1. KRITISCH: Verbotene Worte fehlen in Prompts

**Brand Soul verbietet explizit:**
- "Die Sterne sagen..."
- "Das Universum möchte..."
- "Schicksal"
- "Wunder"
- "Magie / magisch"
- "Kosmische Energie"
- "Positive Schwingungen"
- "Seelenpartner"

**Problem:** Diese Verbote sind NICHT explizit in den System-Prompts aufgeführt.

**Fix:** Erweitere System-Prompts um VERBOTENE-WORTE-Sektion:

```dart
**VERBOTEN - Diese Worte NIEMALS verwenden:**
- "Die Sterne sagen...", "Das Universum möchte..."
- "Schicksal", "Wunder", "Magie", "magisch"
- "Kosmische Energie", "Positive Schwingungen"
- "Seelenpartner", "Seelenplan"
- Kein "Liebe/r [Sternzeichen]" als Anfang
```

---

### 2. SYNTHESE-PFLICHT nicht explizit genug

**Brand Soul Regel:**
> "NIEMALS ein System isoliert. IMMER alle drei verweben."

**Aktueller Daily Horoscope Prompt:**
- ❌ Erwähnt nur "Tagesenergie, Handlungsempfehlungen, emotionale Insights"
- ❌ Keine Anweisung zur **Bazi-Integration** oder **Numerologie**

**Problem:** Daily Horoscope ist generisch (nur Western Astrology), nutzt nicht die NUURAY-Differenzierung.

**Fix:** Erweitere `_buildDailyHoroscopePrompt()`:

```dart
**Synthese-Pflicht (KRITISCH):**
- Verwebe IMMER: Westliche Astrologie + Bazi + Numerologie
- Zeige Spannungen zwischen den Systemen
- Beispiel: "Dein Schütze-Feuer will expandieren, aber dein Yin-Wasser Day Master braucht heute Ruhe."
- NIEMALS nur westliche Astrologie isoliert erwähnen
```

**ABER:** Für Tageshoroskope brauchen wir **user-spezifische Daten** (Bazi, Numerologie), nicht nur Sternzeichen.
→ **TODO:** Entscheiden, ob Daily Horoscope generisch (nur Sternzeichen) oder personalisiert (mit Chart-Daten)

---

### 3. Der 5-Schritt-Bogen fehlt

**Brand Soul definiert:**
1. HOOK — Überraschende Beobachtung
2. SPANNUNG — Widerspruch zwischen Systemen
3. BAZI-TIEFE — Energetische Wahrheit
4. AUFLÖSUNG — Integrierte Synthese
5. IMPULS — Konkrete Handlung

**Aktueller Prompt:**
- ❌ Keine strukturelle Anweisung für diesen Bogen
- ✅ Erwähnt "Handlungsempfehlungen" (= Impuls), aber keine Hook/Spannung/Auflösung

**Fix:** Erweitere System-Prompt um dramaturgische Struktur:

```dart
**Dramaturgie (5-Schritt-Bogen):**
1. Hook: Beginne mit überraschender Beobachtung (NICHT "Heute ist ein guter Tag...")
2. Spannung: Zeige den Widerspruch ("Dein Kopf will X, aber dein Bauch sagt Y")
3. Bazi-Tiefe: Erkläre die energetische Wahrheit dahinter
4. Auflösung: Integriere die Systeme zu einer Handlungsempfehlung
5. Impuls: Eine konkrete, irdische Handlung
```

---

### 4. Ton-Modifikatoren zu allgemein

**Brand Soul unterscheidet:**
- **Glow:** "Kluge Freundin beim Kaffee" — überraschend, lebendig, manchmal frech
- **Tide:** "Achtsame Begleiterin" — rhythmisch, körperbewusst, nie klinisch
- **Path:** "Weise Mentorin" — fragend, entlarvend aber liebevoll

**Aktueller Prompt:**
- ✅ Erwähnt "wie eine gute Freundin"
- ❌ NICHT spezifisch genug für Glow-Charakter ("manchmal frech", "staunend")

**Fix:** Verwende exakten Wortlaut aus Brand Soul:

```dart
**Dein Charakter (GLOW-spezifisch):**
- Die kluge Freundin beim Kaffee
- Neugierig, nie wissend
- Überraschend, nie vorhersehbar
- Warm, nie kitschig
- Staunend, nie esoterisch
```

---

### 5. Unicode-Symbole & Markdown nicht explizit verboten

**Brand Soul verbietet:**
- Keine astrologischen Unicode (♈♉♊ oder ☉☽♀)
- Kein Markdown (\*\*, ###, ---) in generiertem Content
- Keine Emojis

**Aktueller Prompt:**
- ❌ Keine explizite Regel gegen Unicode/Markdown

**Fix:**

```dart
**Format-Regeln:**
- KEIN Markdown (**, ###, ---)
- KEINE Unicode-Symbole (♈, ☉, ☽)
- KEINE Emojis
- Nur Fließtext mit editoriellem Rhythmus
```

---

## 📋 Action Items — Prompt-Updates

### Priorität 1: Sofort (Breaking Changes)

1. **System-Prompt: Verbotene Worte hinzufügen**
   - File: `claude_api_service.dart` → `_getSystemPromptForHoroscope()`
   - Sektion einfügen: "VERBOTEN - Diese Worte NIEMALS verwenden"

2. **Archetyp-Signatur: Verbotene Worte ergänzen**
   - File: `archetype_signature_prompt.dart`
   - Aktuell fehlt: Liste verbotener Worte

3. **Format-Regeln hinzufügen (Unicode, Markdown, Emojis)**
   - Alle Prompts: Explizite Format-Sektion

---

### Priorität 2: Strategie klären (Design-Entscheidung)

4. **Daily Horoscope: Generisch vs. Personalisiert?**
   - **Option A (Aktuell):** Generisch pro Sternzeichen (KEINE Bazi/Numerologie)
     - ✅ Günstiger (12 Texte/Tag statt 100+ User)
     - ❌ Verletzt Brand Soul Synthese-Pflicht
   - **Option B (Brand Soul):** Personalisiert mit user-spezifischer Synthese
     - ✅ Erfüllt Brand Soul (alle 3 Systeme)
     - ❌ Teurer (~$0.02 pro User/Tag)
   - **Option C (Hybrid):** Basis-Horoskop (generisch) + Personalisierungsschicht (kurz)
     - ✅ Kosten-Balance
     - ✅ Erfüllt Brand Soul teilweise

   **Empfehlung:** Option C — siehe `docs/deployment/HOROSCOPE_STRATEGY.md`

---

### Priorität 3: Enhancement (Nice-to-Have)

5. **5-Schritt-Bogen in Prompts integrieren**
   - Hook → Spannung → Bazi-Tiefe → Auflösung → Impuls
   - File: `_getSystemPromptForHoroscope()`

6. **Glow-spezifischen Ton schärfen**
   - Exakten Wortlaut aus Brand Soul übernehmen
   - "Manchmal frech", "Staunend, nie esoterisch"

---

## 🧪 Content Library prüfen

### Nächster Schritt: Bestehenden Content bewerten

**Aufgabe:** Lies 3-4 Beispiel-Texte aus `content_library` Tabelle und bewerte nach:

1. ✅/❌ Alle drei Systeme verwoben (nicht aufgelistet)?
2. ✅/❌ Mindestens eine Spannung/ein Widerspruch?
3. ✅/❌ Beginnt mit etwas Überraschendem?
4. ✅/❌ Könnte für ein ANDERES Sternzeichen funktionieren? (Wenn ja → zu generisch)
5. ✅/❌ Enthält verbotene Worte/Muster?
6. ✅/❌ Konkreter Impuls oder Frage am Ende?
7. ✅/❌ Würde ich das einer Freundin vorlesen?

**Beispiel-Query:**

```sql
SELECT * FROM content_library
WHERE category = 'sun_sign' AND language = 'DE'
LIMIT 3;
```

**Wenn Content gegen Brand Soul verstößt:**
→ Neu generieren mit verbesserten Prompts (Kosten: ~$0.24 für alle 264 Texte)

---

## 📊 Zusammenfassung

| Check | Status | Action |
|-------|--------|--------|
| Verbotene Worte in Prompts | ❌ Fehlt | Sofort hinzufügen |
| Synthese-Pflicht (Tageshoroskop) | ⚠️ Unklar | Strategie klären (A/B/C) |
| 5-Schritt-Bogen | ❌ Nicht strukturiert | Prompt erweitern |
| Format-Regeln (Unicode/Markdown) | ❌ Fehlt | Prompt erweitern |
| Glow-spezifischer Ton | ⚠️ Zu allgemein | Wortlaut aus Brand Soul |
| Content Library Check | ⏳ TODO | 3-4 Texte manuell prüfen |

---

**Letzte Aktualisierung:** 2026-02-10
