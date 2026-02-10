# Konzept: Signatur-Inhalte (Freemium + Premium)

> **Reihenfolge:** Dieses Konzept kommt NACH der Umsetzung von:
> 1. ✅ Bottom Navigation (konzept-bottom-nav-signatur.md, Teil 1)
> 2. ✅ Signatur Screen Struktur (konzept-bottom-nav-signatur.md, Teil 2)
>
> Erst wenn die Shell und der Screen stehen, füllen wir die Inhalte.
> Lies CLAUDE.md und docs/PROJECT_BRIEF.md für Kontext.

---

## Überblick: Zwei Content-Schichten

Der Signatur Screen hat zwei grundlegend verschiedene Content-Typen:

| Schicht | Für wen | Wie generiert | Wann generiert | Wo gespeichert |
|---------|---------|---------------|----------------|----------------|
| **Freemium** | Alle User | Statisch, pro Zeichen/Element/Zahl | Einmalig vorab (Seed) | Supabase-Tabelle oder JSON-Asset in der App |
| **Premium** | Zahlende User | Personalisiert pro Userin, ein Claude-Call | Einmalig beim ersten Öffnen des Premium-Bereichs | Supabase, gecacht pro User |

**Prinzip:** Freemium-Texte sind wie ein Lexikon – jede Schütze-Frau liest den gleichen Schütze-Text. Premium-Texte sind wie ein Brief an die Nutzerin – sie beziehen sich auf ihre einzigartige Kombination.

---

## Schicht 1: Freemium – Die statische Bibliothek

### Was wird gebraucht?

Für jede mögliche Position ein kurzer, gut geschriebener Text im Glow-Ton (neugierig, staunend, lebendig). Nicht personalisiert, aber ansprechend genug, dass man mehr will.

### Textlängen

- **Pro Position: 3-4 Sätze, ca. 60-80 Wörter**
- Ton: Glow (wie eine kluge Freundin, die dir beim Kaffee spannende Dinge erzählt)
- Keine Fachbegriffe ohne Erklärung
- Immer empowernd, nie bewertend

### Textbibliothek – Vollständige Liste

**Westliche Astrologie:**

| Kategorie | Anzahl Texte | Beispiel-Key |
|-----------|-------------|--------------|
| Sonnenzeichen | 12 | `sun_aries`, `sun_taurus`, ... `sun_pisces` |
| Mondzeichen | 12 | `moon_aries`, `moon_taurus`, ... `moon_pisces` |
| Aszendent | 12 | `asc_aries`, `asc_taurus`, ... `asc_pisces` |
| Element | 4 | `element_fire`, `element_earth`, `element_air`, `element_water` |

Gesamt Western: **40 Texte**

**Bazi (Chinesische Astrologie):**

| Kategorie | Anzahl Texte | Beispiel-Key |
|-----------|-------------|--------------|
| Day Master (10 Heavenly Stems) | 10 | `dm_jia`, `dm_yi`, ... `dm_gui` |
| Dominantes Element | 5 | `bazi_element_wood`, `bazi_element_fire`, ... `bazi_element_water` |
| Tierzeichen (12 Earthly Branches) | 12 | `animal_rat`, `animal_ox`, ... `animal_pig` |

Gesamt Bazi: **27 Texte**

**Numerologie:**

| Kategorie | Anzahl Texte | Beispiel-Key |
|-----------|-------------|--------------|
| Lebenszahl (1-9 + 11, 22, 33) | 12 | `lifepath_1`, ... `lifepath_9`, `lifepath_11`, `lifepath_22`, `lifepath_33` |
| Ausdruckszahl (1-9 + 11, 22, 33) | 12 | `expression_1`, ... `expression_33` |
| Seelenzahl (1-9 + 11, 22, 33) | 12 | `soul_1`, ... `soul_33` |
| Challenge-Zahlen (0-9) | 10 | `challenge_0`, ... `challenge_9` |
| Karmic Lessons (1-9) | 9 | `karmic_1`, ... `karmic_9` |
| Bridge-Zahlen (0-9) | 10 | `bridge_0`, ... `bridge_9` |

Gesamt Numerologie: **65 Texte**

### Gesamtumfang

**132 Texte × 2 Sprachen (DE + EN) = 264 Texte**

### Wie werden sie erstellt?

Diese Texte werden **einmalig vorab mit Claude generiert** – als Batch, nicht zur Laufzeit. Ablauf:

1. Ein Prompt-Template pro Kategorie erstellen (z.B. "Beschreibe das Sonnenzeichen {zeichen} im Glow-Ton, 3-4 Sätze, ca. 70 Wörter")
2. Alle Texte in einem oder wenigen API-Calls generieren lassen
3. Manuell gegenlesen und bei Bedarf anpassen (Natalie kennt die Materie)
4. In Supabase seeden oder als JSON-Asset in die App packen

**Kosten:** Einmalig ca. $3-5 für alle 264 Texte. Kein laufender Aufwand.

### Speicherung

**Empfehlung: Supabase-Tabelle `content_library`**

| Spalte | Typ | Beispiel |
|--------|-----|---------|
| `id` | uuid | auto |
| `category` | text | `sun_sign`, `moon_sign`, `day_master`, `life_path`, ... |
| `key` | text | `sagittarius`, `jia`, `8`, ... |
| `locale` | text | `de`, `en` |
| `title` | text | `Schütze`, `Sagittarius` |
| `short_description` | text | Der 3-4 Sätze Freemium-Text |
| `keywords` | text[] | `["Feuer", "Abenteuer", "Freiheit"]` (optional, für spätere Features) |

**RLS:** Leserechte für alle authentifizierten User. Kein User-bezogener Zugriff nötig.

**Alternative:** Wenn wir offline-Fähigkeit priorisieren, können die Texte auch als JSON-Asset direkt in der App liegen (`assets/content/de/sun_signs.json`). Vorteil: Kein Netzwerk nötig. Nachteil: App-Update nötig um Texte zu ändern.

→ **Empfehlung für MVP: Supabase**, damit Natalie Texte korrigieren kann ohne App-Update.

---

## Schicht 2: Premium – Personalisiert pro Userin

### Das Prinzip: Ein Call, alle Texte

Wenn eine Premium-Userin zum ersten Mal den Signatur Screen öffnet, passiert Folgendes:

1. App prüft: Hat diese Userin schon personalisierte Texte? → Supabase-Tabelle `premium_signature_content` checken
2. Wenn nein: **Ein einziger Claude API Call** mit allen Chart-Daten der Userin
3. Claude gibt ein strukturiertes JSON zurück mit allen Texten auf einmal
4. JSON wird in Supabase gespeichert (gecacht)
5. Ab jetzt: Kein weiterer API-Call mehr nötig, Texte kommen aus dem Cache

### Warum ein einziger Call statt mehrerer?

- **Kostenvorteil:** Der System-Prompt (ca. 300 Tokens) wird nur 1× geschickt statt 4-6×
- **Konsistenz:** Claude schreibt die Synthese, während es die Einzeltexte noch "im Kopf" hat. Keine Widersprüche, keine Wiederholungen.
- **Einfachheit:** Eine Edge Function, ein Prompt, ein Response, ein DB-Write.

### Was der Call generiert

Claude bekommt die Chart-Daten der Userin und generiert alle Premium-Texte als JSON:

**Input an Claude (die Chart-Daten):**
- Sonnenzeichen + Grad
- Mondzeichen + Grad
- Aszendent + Grad (falls vorhanden)
- Day Master + Earthly Branch
- Vier Säulen (Jahr, Monat, Tag, Stunde)
- Dominantes Element
- Lebenszahl
- Ausdruckszahl (falls vorhanden)
- Seelenzahl (falls vorhanden)
- Challenge-Zahlen
- Karmic Lessons
- Bridges
- Sprache der Nutzerin

**Output von Claude (strukturiertes JSON):**

```
{
  "western": {
    "sun_detailed": "...",        ← 1-2 Absätze (~200 Wörter)
    "moon_detailed": "...",       ← 1-2 Absätze (~200 Wörter)
    "ascendant_detailed": "...",  ← 1-2 Absätze (~200 Wörter), null wenn kein Aszendent
    "sun_moon_dynamic": "..."     ← Wie Sonne und Mond zusammenwirken (~150 Wörter)
  },
  "bazi": {
    "day_master_detailed": "...", ← 1-2 Absätze (~200 Wörter)
    "element_analysis": "...",    ← Elementverteilung erklärt (~150 Wörter)
    "pillars_overview": "..."     ← Wie die 4 Säulen zusammenwirken (~150 Wörter)
  },
  "numerology": {
    "life_path_detailed": "...",  ← 1 Absatz (~150 Wörter)
    "expression_detailed": "...", ← 1 Absatz (~150 Wörter), null wenn kein Name
    "soul_detailed": "...",       ← 1 Absatz (~100 Wörter), null wenn kein Name
    "challenges_detailed": "...", ← Alle 4 Challenges erklärt (~200 Wörter)
    "karmic_bridges": "..."       ← Karmic Lessons + Bridges erklärt (~150 Wörter)
  },
  "synthesis": "..."              ← DIE große Synthese (~400-600 Wörter)
}
```

### Textlängen Premium

| Bereich | Textlänge | Wörter ca. |
|---------|-----------|------------|
| Einzelpositionen (Sonne, Mond, Aszendent, Day Master) | 1-2 Absätze | je ~200 |
| Interaktionen (Sonne+Mond, Säulen-Zusammenspiel) | 1 Absatz | je ~150 |
| Numerologie-Positionen | 1 Absatz | je ~100-150 |
| **Kosmische Synthese** | 3-5 Absätze | **~400-600** |
| **Gesamt pro Userin** | | **~2.000-2.500 Wörter** |

### Kosten pro Userin

| Posten | Tokens (ca.) |
|--------|-------------|
| System-Prompt (Ton, Format, Anweisungen) | ~500 |
| User-Prompt (Chart-Daten) | ~300 |
| **Input gesamt** | **~800** |
| Output (alle Texte als JSON) | ~3.000-3.500 |
| **Output gesamt** | **~3.500** |

**Kosten mit Claude Sonnet:** ca. $0,03-0,04 pro Userin, einmalig.

| Premium-Userinnen | Einmalige Kosten |
|-------------------|-----------------|
| 100 | ~$3-4 |
| 1.000 | ~$30-40 |
| 10.000 | ~$300-400 |
| 100.000 | ~$3.000-4.000 |

Danach: $0 laufend für diese Texte, weil sie gecacht sind.

### Speicherung

**Supabase-Tabelle `premium_signature_content`:**

| Spalte | Typ | Beschreibung |
|--------|-----|-------------|
| `id` | uuid | auto |
| `user_id` | uuid | FK zu users, unique |
| `locale` | text | `de` oder `en` |
| `western_sun` | text | Ausführlicher Sonnen-Text |
| `western_moon` | text | Ausführlicher Mond-Text |
| `western_ascendant` | text | Ausführlicher Aszendent-Text (nullable) |
| `western_dynamic` | text | Sonne+Mond Zusammenspiel |
| `bazi_day_master` | text | Ausführlicher Day-Master-Text |
| `bazi_elements` | text | Elementanalyse |
| `bazi_pillars` | text | Säulen-Übersicht |
| `numerology_life_path` | text | Ausführliche Lebenszahl |
| `numerology_expression` | text | Ausführliche Ausdruckszahl (nullable) |
| `numerology_soul` | text | Ausführliche Seelenzahl (nullable) |
| `numerology_challenges` | text | Challenges erklärt |
| `numerology_karmic_bridges` | text | Karmic Lessons + Bridges |
| `synthesis` | text | Die große Synthese |
| `generated_at` | timestamptz | Wann generiert |
| `model_version` | text | z.B. `claude-sonnet-4-20250514` (für spätere Regenerierung) |

**RLS:** User sieht nur eigene Zeile (`auth.uid() = user_id`).

**Alternative:** Statt vieler Spalten ein einziges `content` JSONB-Feld. Einfacher in der Migration, flexibler wenn sich die Struktur ändert. → **Empfehlung: JSONB für MVP**, einzelne Spalten nur wenn wir gezielt suchen/filtern müssen.

### Regenerierung

Wenn Claude ein neues Modell bekommt oder Natalie die Prompts verbessert, können Premium-Texte regeneriert werden:
- `model_version` tracken
- Edge Function: "Regeneriere alle Texte die mit Modell X generiert wurden"
- Userin sieht automatisch die neuen Texte beim nächsten Öffnen

---

## Die Mini-Synthese (Archetyp-Bereich, für alle User)

Die Mini-Synthese im Hero-Bereich ist ein Sonderfall – sie ist personalisiert, aber für alle User sichtbar (Freemium).

### Wie sie generiert wird

- **Wann:** Beim Onboarding, direkt nachdem der Archetyp-Titel generiert wird
- **Wo:** Im gleichen API-Call wie der Archetyp-Titel (kein Extra-Call)
- **Was:** Ein einziger Satz der alle drei Systeme verbindet
- **Länge:** Max. 30-40 Wörter, ein Satz
- **Beispiel:** "Deine feurige Schütze-Seele schmiedet mit der feinen Klarheit des Yin-Metalls goldene Träume, während der Lebenspfad 8 dich zu wahrem Wohlstand und innerer Fülle führt."

### Speicherung

Neues Feld in `signature_profiles`:

| Spalte | Typ | Beschreibung |
|--------|-----|-------------|
| `mini_synthesis` | text | Der Ein-Satz-Teaser (personalisiert) |

Falls `signature_profiles` den Archetyp-Titel schon speichert, wird `mini_synthesis` einfach als Spalte ergänzt. → **DB-Migration nötig.**

---

## Prompt-Architektur

### Prompt-Templates (Ablageort: `packages/nuuray_api/lib/src/prompts/`)

Es werden drei Prompt-Templates gebraucht:

**1. `onboarding_archetype.txt`** (existiert vermutlich schon teilweise)
- Generiert: Archetyp-Titel + Mini-Synthese
- Wird aufgerufen: Beim Onboarding
- Anpassung: Mini-Synthese als zusätzliches Feld im JSON-Output

**2. `freemium_content_seed.txt`** (einmaliges Seed-Script)
- Generiert: Alle 132 statischen Texte pro Sprache
- Wird aufgerufen: Einmalig als Seed, nie zur Laufzeit
- Kann als Batch laufen (z.B. 12 Sonnenzeichen in einem Call)

**3. `premium_signature.txt`** (Laufzeit, pro Userin)
- Generiert: Alle Premium-Texte + Synthese als JSON
- Wird aufgerufen: Einmalig pro Premium-Userin
- Enthält: Glow-Ton-Anweisungen, JSON-Format-Vorgabe, Chart-Daten als Variablen

### Ton-Anweisungen im System-Prompt (für alle drei Templates)

Der Glow-Ton muss im System-Prompt klar definiert sein:
- Schreibe wie eine kluge Freundin, die beim Kaffee spannende Dinge erzählt
- Neugierig, staunend, lebendig – nie belehrend oder esoterisch-schwurbelig
- Empowernd: Jede Eigenschaft hat eine Stärke, auch vermeintliche Schwächen
- Direkte Ansprache mit "du"
- Keine Aufzählungen mit Spiegelstrichen im Fließtext
- Keine Floskeln wie "die Sterne sagen" oder "das Universum will"

---

## Ablauf in der App (User-Perspektive)

### Free-Userin öffnet Signatur Screen:

1. Hero: Archetyp-Titel + Mini-Synthese (personalisiert, aus `signature_profiles`)
2. Western-Card aufklappen → Kurztext zu ihrem Sonnenzeichen (aus `content_library`)
3. Bazi-Card aufklappen → Kurztext zu ihrem Day Master (aus `content_library`)
4. Numerologie-Card aufklappen → Kurztext zur Lebenszahl (aus `content_library`)
5. Unten: "Deine Kosmische Synthese" → Titel sichtbar + CTA "Deine Synthese entdecken"

### Premium-Userin öffnet Signatur Screen zum ersten Mal:

1. Hero: Archetyp-Titel + Mini-Synthese (identisch mit Free)
2. Western-Card aufklappen → Ladeindikator (Skeleton/Shimmer) → Ausführlicher personalisierter Text erscheint
3. Bazi-Card, Numerologie-Card → gleich
4. Unten: Kosmische Synthese → Ladeindikator → Vollständiger Synthese-Text
5. **Im Hintergrund:** Ein einziger API-Call generiert alles, Ergebnis wird gecacht

### Premium-Userin öffnet Signatur Screen danach:

1. Alles kommt sofort aus dem Cache (Supabase) – kein API-Call, kein Laden
2. Identische Darstellung wie beim ersten Mal, nur schneller

---

## Edge Function: `generate-premium-signature`

### Aufgabe
- Nimmt `user_id` entgegen
- Lädt Chart-Daten aus `birth_charts` + `signature_profiles`
- Prüft ob `premium_signature_content` schon existiert → wenn ja, abbrechen
- Sendet einen Claude API Call mit dem `premium_signature.txt` Template
- Parst das JSON-Ergebnis
- Speichert in `premium_signature_content`
- Gibt Erfolg/Fehler zurück

### Aufruf
- **Trigger:** Premium-Userin öffnet Signatur Screen UND hat noch keinen gecachten Content
- **Nicht als Cron-Job** – nur on-demand, weil wir nicht wissen wer Premium wird
- **Timeout:** Claude braucht für 2.500 Wörter ca. 10-15 Sekunden → Edge Function Timeout entsprechend setzen

### Fehlerbehandlung
- Claude-Call fehlgeschlagen → Retry einmal, dann Fehlermeldung in der App
- App zeigt in dem Fall die Freemium-Texte als Fallback (besser als gar nichts)
- Fehler loggen für Monitoring

---

## Umsetzungsreihenfolge

### Schritt 1: Freemium-Bibliothek erstellen
1. Prompt-Template für Content-Seed schreiben (`freemium_content_seed.txt`)
2. Alle 132 Texte × 2 Sprachen generieren (Batch)
3. Natalie reviewed und korrigiert die Texte
4. Supabase-Tabelle `content_library` anlegen (Migration)
5. Texte seeden
6. App: Signatur Screen zeigt Freemium-Texte aus `content_library`

### Schritt 2: Mini-Synthese
1. Feld `mini_synthesis` in `signature_profiles` ergänzen (Migration)
2. Onboarding-Prompt anpassen: Mini-Synthese als zusätzliches Feld
3. Bestehende User: Mini-Synthese nachträglich generieren (einmaliges Script)
4. Hero-Sektion im Signatur Screen zeigt Mini-Synthese

### Schritt 3: Premium-Content
1. Supabase-Tabelle `premium_signature_content` anlegen (Migration)
2. Prompt-Template `premium_signature.txt` schreiben
3. Edge Function `generate-premium-signature` implementieren
4. App: Premium-Erkennung + API-Call-Trigger + Caching-Logik
5. Signatur Screen: Zwischen Freemium- und Premium-Texten unterscheiden
6. Ladeindikator während der Generierung
7. Fallback auf Freemium-Texte bei Fehler

### Was NICHT in diesem Schritt:
- ❌ Premium-Gating / In-App Purchase Logik (eigenes Feature)
- ❌ Regenerierung bei Modell-Updates (Backlog)
- ❌ A/B-Testing verschiedener Prompt-Varianten (Backlog)
- ❌ Offline-Caching der Premium-Texte in der App (Backlog, ggf. mit Drift)

---

## Zusammenfassung Kosten

| Posten | Kosten | Frequenz |
|--------|--------|----------|
| Freemium-Bibliothek (264 Texte) | ~$3-5 | Einmalig |
| Mini-Synthese pro Userin | ~$0,005 (Teil des Onboarding-Calls) | Einmalig pro User |
| Premium-Texte pro Userin | ~$0,03-0,04 | Einmalig pro Premium-User |
| **Laufende Kosten für Signatur-Content** | **$0** | **Alles gecacht** |
