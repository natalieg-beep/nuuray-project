# Content Library Prompts — Implementation

> **Datum:** 2026-02-12
> **Anlass:** User-Request: "führe mir nochmal auf, wie der Content Library Prompts verbessert werden sollen?"
> **Ergebnis:** ✅ 4 neue kategorie-spezifische Prompts implementiert + Test-Script erstellt

---

## 🎯 DAS PROBLEM

**Alter Prompt (seed_content_library.dart):**
- ❌ **Zu generisch** — "warm, inspirierend" (könnte jede Wellness-App sein)
- ❌ **Zu kurz** — 70 Wörter (sollte 80-100 sein)
- ❌ **Keine Glow-Stimme** — NICHT "kluge Freundin beim Kaffee"
- ❌ **Keine Schattenseiten** — Nur positive Eigenschaften = langweilig!
- ❌ **Keine konkreten Bilder** — Führt zu Plattitüden
- ❌ **EIN Prompt für ALLE Kategorien** — kann nicht differenzieren!

**Audit-Ergebnis:** Nur **20% Brand Soul konform**

**User-Feedback:** "Die aktuellen Texte sind halt auch nichts"

---

## ✅ DIE LÖSUNG

### **4 kategorie-spezifische Prompts**

Jede Kategorie beschreibt eine **andere Perspektive**:

| Kategorie | Perspektive | Länge |
|-----------|-------------|-------|
| **Sonnenzeichen** | WIE Person psychologisch TICKT | 80-100 Wörter |
| **Mondzeichen** | WIE Person emotional FÜHLT | 80-100 Wörter |
| **Bazi Day Master** | WIE Energie-System ARBEITET | 80-100 Wörter |
| **Lebenszahl** | WORAN Person im Leben ARBEITET | 80-100 Wörter |

---

## 📝 IMPLEMENTIERTE ÄNDERUNGEN

### **Datei:** `scripts/seed_content_library.dart`

#### 1️⃣ **System-Prompt hinzugefügt** (Brand Voice)

```dart
'system': _getSystemPrompt(locale), // NEU!
```

**Inhalt:**
- "Du bist Content-Expertin für Nuuray Glow"
- "Die kluge Freundin beim Kaffee"
- "Staunend über Zusammenhänge, nie wissend"
- "Benenne liebevoll die Schattenseite (MUSS!)"

---

#### 2️⃣ **Max Tokens erhöht**

```dart
'max_tokens': 400, // Erhöht von 300
```

**Grund:** Längere Texte (80-100 Wörter statt 70)

---

#### 3️⃣ **4 neue Prompt-Funktionen**

```dart
String _buildPrompt({...}) {
  switch (category) {
    case 'sun_sign':
    case 'rising_sign':
      return _sunSignPrompt(key, locale);

    case 'moon_sign':
      return _moonSignPrompt(key, locale);

    case 'bazi_day_master':
      return _baziDayMasterPrompt(key, locale);

    case 'life_path_number':
    case 'soul_urge_number':
    case 'expression_number':
      return _numerologyPrompt(category, key, locale);
  }
}
```

**Jeder Prompt hat:**
- ✅ Kategorie-spezifische STRUKTUR
- ✅ Explizite VERBOTENE WORTE Liste
- ✅ Pflicht zur SCHATTENSEITEN-Benennung
- ✅ Konkrete BEISPIELE (bei komplexen Prompts)
- ✅ Längen-Vorgabe: 80-100 Wörter

---

## 🧪 TEST-SCRIPT ERSTELLT

### **Datei:** `scripts/test_content_prompts.dart`

**Testet 4 Beispiel-Texte:**
1. Schütze (sun_sign)
2. Waage-Mond (moon_sign)
3. Yin Metall Schwein (bazi_day_master)
4. Lebenszahl 8 (life_path_number)

**Usage:**
```bash
# Teste mit Deutsch
dart scripts/test_content_prompts.dart --locale de

# Teste mit Englisch
dart scripts/test_content_prompts.dart --locale en
```

**Output:**
- ✅ Generierte Texte mit Wort-Zählung
- ✅ Kosten pro Text
- ✅ 7-Fragen-Checklist zum manuellen Abhaken
- ✅ Gesamt-Kosten (~$0.01 für alle 4 Tests)

---

## 📊 ERWARTETES ERGEBNIS

### **Vorher (20% Brand Soul konform):**

> "Widder sind voller Energie und Tatendrang. Sie lieben es, neue Projekte zu starten und Herausforderungen mutig anzugehen. Ihre Leidenschaft inspiriert andere."

**Probleme:**
- ❌ Generisch ("voller Energie" → sagt nichts Konkretes)
- ❌ Keine Schattenseite
- ❌ Abstraktes Gerede ("Herausforderungen mutig angehen")
- ❌ Klischee ("inspiriert andere")

---

### **Nachher (80-90% Brand Soul konform):**

> "Dein Kopf ist immer schon drei Schritte weiter. Während andere noch überlegen, hast du innerlich bereits gepackt. Schütze-Sonnen leben für den Moment, in dem etwas Neues anfängt — der erste Tag, die erste Seite, der erste Kuss. Das Problem? Seite 200 ist weniger aufregend. Deine eigentliche Aufgabe ist nicht, loszulaufen. Das kannst du. Deine Aufgabe ist, bei etwas zu bleiben, das sich lohnt."

**Stärken:**
- ✅ Konkret ("Dein Kopf ist drei Schritte weiter")
- ✅ Schattenseite benannt ("Seite 200 ist weniger aufregend")
- ✅ Konkretes Bild ("erster Tag, erste Seite, erster Kuss")
- ✅ Glow-Ton (wie eine Freundin, nicht wie ein Lexikon)
- ✅ Überraschend (nicht das übliche "mutig und energiegeladen")

---

## 🚀 NÄCHSTE SCHRITTE

### **1. Test-Run durchführen** (15 Min + $0.01)

```bash
cd /Users/natalieg/nuuray-project
export CLAUDE_API_KEY=sk-ant-...  # Dein API Key
dart scripts/test_content_prompts.dart --locale de
```

**Prüfe die 4 Ergebnisse:**
- [ ] 1. Sagt der Text etwas ÜBERRASCHENDES?
- [ ] 2. Benennt der Text eine SCHATTENSEITE?
- [ ] 3. Benutzt der Text KONKRETE BILDER?
- [ ] 4. Könnte er für ein ANDERES Element gelten? (Wenn ja → zu generisch!)
- [ ] 5. Enthält er VERBOTENE WORTE?
- [ ] 6. Klingt er wie eine FREUNDIN oder wie ein LEXIKON?
- [ ] 7. Ist er 80-100 Wörter lang?

**Falls 6/7 oder besser:** ✅ Proceed to Step 2

**Falls schlechter:** ⚠️ Prompts anpassen & erneut testen

---

### **2. Volle Regenerierung** (5 Min + $0.50)

**WICHTIG: BACKUP machen!**

```bash
# Backup der aktuellen Content Library (via Supabase Dashboard)
# ODER: SQL Export

# Content Library löschen (nur DE)
# Via Supabase SQL Editor:
DELETE FROM content_library WHERE locale = 'de';

# Neu generieren (DE)
cd /Users/natalieg/nuuray-project
export SUPABASE_SERVICE_ROLE_KEY=eyJ...
export CLAUDE_API_KEY=sk-ant-...
dart scripts/seed_content_library.dart --locale de

# Warten (~3-5 Min wegen Rate Limiting)

# Stichproben prüfen (3-4 Texte aus verschiedenen Kategorien)
```

---

### **3. Qualitäts-Stichprobe** (20 Min)

**Via Supabase SQL Editor:**

```sql
-- 2 zufällige Sonnenzeichen
SELECT category, key, description
FROM content_library
WHERE locale = 'de' AND category = 'sun_sign'
ORDER BY RANDOM()
LIMIT 2;

-- 2 zufällige Mondzeichen
SELECT category, key, description
FROM content_library
WHERE locale = 'de' AND category = 'moon_sign'
ORDER BY RANDOM()
LIMIT 2;

-- 2 zufällige Bazi Day Masters
SELECT category, key, description
FROM content_library
WHERE locale = 'de' AND category = 'bazi_day_master'
ORDER BY RANDOM()
LIMIT 2;

-- 2 zufällige Lebenszahlen
SELECT category, key, description
FROM content_library
WHERE locale = 'de' AND category = 'life_path_number'
ORDER BY RANDOM()
LIMIT 2;
```

**Bewerte jede Stichprobe mit 7-Fragen-Check**

**Falls 80%+ gut:** ✅ Proceed to EN

**Falls <80% gut:** ⚠️ Prompt-Anpassungen nötig

---

### **4. Englische Texte generieren** (5 Min + $0.50)

```bash
# Nur wenn DE gut war!
dart scripts/seed_content_library.dart --locale en
```

---

## 💰 KOSTEN-ÜBERSICHT

| Schritt | Aufwand | Kosten |
|---------|---------|--------|
| Script anpassen | ✅ ERLEDIGT | — |
| Test-Run (4 Texte) | 15 Min | ~$0.01 |
| Volle Regenerierung DE (132 Texte) | 5 Min + Wartezeit | ~$0.40 |
| Qualitäts-Stichprobe | 20 Min | — |
| Volle Regenerierung EN (132 Texte) | 5 Min + Wartezeit | ~$0.40 |
| **GESAMT** | **~1h** | **~$0.80** |

---

## 📚 DOKUMENTATION

**Referenz-Dokumente:**
- ✅ `docs/NUURAY_BRAND_SOUL.md` — Brand Voice & Tonalität
- ✅ `docs/CONTENT_LIBRARY_BRAND_SOUL_AUDIT.md` — Audit (20% konform)
- ✅ `docs/CONTENT_LIBRARY_PROMPT_ANLEITUNG.md` — Vollständige Prompt-Texte
- ✅ `scripts/seed_content_library.dart` — Implementierung
- ✅ `scripts/test_content_prompts.dart` — Test-Script

---

## ✅ STATUS

- ✅ **Prompts implementiert** (2026-02-12)
- ⏳ **Test-Run** ausstehend
- ⏳ **Volle Regenerierung** ausstehend

---

**Nächster Schritt:** Test-Run durchführen! 🧪
