# NUURAY Content-Strategie — Klare Aufstellung

> **Erstellt:** 2026-02-12
> **Für:** Neue Claude Chats (damit keine Verwirrung entsteht!)
> **Kontext:** Es gab Verwirrung darüber, was "Archetyp-System" bedeutet vs. "Content Library"

---

## 🎯 DIE ZWEI VERSCHIEDENEN CONTENT-TYPEN

### 1️⃣ **ARCHETYP-SIGNATUR** (Individuell, Claude-generiert, gespeichert)

**Was ist das?**
- **EIN personalisierter Text pro User** (Titel + 2-3 Sätze)
- Wird **einmalig via Claude API generiert** beim ersten Login oder bei Profil-Änderungen
- Wird in `profiles.signature_text` **dauerhaft gespeichert** (nicht neu generiert bei jedem Öffnen!)
- Erscheint prominent auf dem **Home Screen** (goldene Hero-Card)

**Beispiel:**
```
Die großzügige Perfektionistin

Alles in dir will nach vorne — Schütze-Feuer, Löwe-Aszendent, eine 8 als
Lebensweg. Aber dein Yin-Metall arbeitet anders: leise, präzise, mit dem
Skalpell statt mit der Axt. Dein Waage-Mond verrät das Geheimnis: Du willst
nicht nur gewinnen, du willst, dass es dabei schön aussieht.
```

**Technische Details:**
- **Prompt-File:** `apps/glow/lib/src/core/services/prompts/archetype_signature_prompt.dart`
- **Service:** `ArchetypeSignatureService` (generiert via Claude API)
- **Kosten:** ~$0.001 pro User (einmalig!)
- **Datenbank:** `profiles.signature_text` (TEXT, nullable)
- **UI-Widget:** `ArchetypeHeader` auf Home Screen

**Status:** ✅ **IMPLEMENTIERT** (aber Prompt könnte besser sein — siehe `ARCHETYP_PROMPT_ANLEITUNG.md`)

---

### 2️⃣ **CONTENT LIBRARY** (Statisch, vorberechnet, gecacht)

**Was ist das?**
- **264 statische Beschreibungstexte** für einzelne astrologische Elemente
- Werden **EINMALIG via Script generiert** (nicht pro User!)
- In Supabase-Tabelle `content_library` gespeichert
- Erscheinen in den **expandable Cards** auf dem Signatur-Screen

**Kategorien:**
| Kategorie | Anzahl | Beispiel-Key | Beispiel-Titel |
|-----------|--------|--------------|----------------|
| `sun_sign` | 12 | `sagittarius` | Schütze |
| `moon_sign` | 12 | `libra` | Waage-Mond |
| `rising_sign` | 12 | `leo` | Löwe-Aszendent |
| `bazi_day_master` | 60 | `yin_metal_pig` | Yin Metall Schwein |
| `life_path_number` | 12 | `8` | Lebenszahl 8 |
| `soul_urge_number` | 12 | `11` | Seelenwunsch 11 |
| `expression_number` | 12 | `6` | Ausdruckszahl 6 |
| **GESAMT** | **132** | × 2 Sprachen = **264 Texte** |

**Beispiel (Schütze-Sonne):**
```
Dein Kopf ist immer schon drei Schritte weiter. Während andere noch
überlegen, hast du innerlich bereits gepackt. Schütze-Sonnen leben für
den Moment, in dem etwas Neues anfängt — der erste Tag, die erste Seite,
der erste Kuss. Das Problem? Seite 200 ist weniger aufregend. Deine
eigentliche Aufgabe ist nicht, loszulaufen. Das kannst du. Deine Aufgabe
ist, bei etwas zu bleiben, das sich lohnt.
```

**Technische Details:**
- **Script:** `scripts/seed_content_library.dart`
- **Service:** `ContentLibraryService` (lädt aus Supabase + In-Memory Cache)
- **Kosten:** ~$0.50 für alle 264 Texte (einmalig!)
- **Datenbank:** `content_library` Tabelle (category, key, locale, title, description)
- **UI-Widget:** Expandable Cards in `WesternAstrologyCard`, `BaziCard`, `NumerologyCard`

**Status:** 🟡 **TEILWEISE** — 132 DE Texte existieren, aber:
- ❌ Bazi Day Master Texte fehlen noch (60 Texte)
- ❌ Erweiterte Numerologie fehlt (Birthday, Attitude, Maturity, etc.)
- ⚠️ **Prompt-Qualität: 20% Brand Soul konform** (siehe Audit-Dokument)

---

## 📊 VERGLEICH: Archetyp vs. Content Library

| Aspekt | Archetyp-Signatur | Content Library |
|--------|-------------------|-----------------|
| **Zweck** | Personalisierte Synthese ALLER 3 Systeme | Isolierte Beschreibung EINES Elements |
| **Generierung** | Pro User, on-demand | Einmalig für alle User |
| **Synthese** | ✅ JA — verwebt Western + Bazi + Numerologie | ❌ NEIN — nur ein System (z.B. nur Sonnenzeichen) |
| **Speicherort** | `profiles.signature_text` | `content_library` Tabelle |
| **UI-Position** | Home Screen Hero-Card (prominent!) | Signatur Screen Cards (Details) |
| **Länge** | 2-3 Sätze (~60-80 Wörter) | 80-100 Wörter |
| **Kosten** | $0.001 × Anzahl User | $0.50 einmalig (alle Texte) |
| **Updates** | Nur bei Profil-Änderungen | Nur bei Content-Relaunch |
| **Beispiel** | "Die großzügige Perfektionistin — Alles in dir will nach vorne..." | "Dein Kopf ist immer schon drei Schritte weiter..." (Schütze-Beschreibung) |

---

## ⚠️ HÄUFIGE MISSVERSTÄNDNISSE (BITTE VERMEIDEN!)

### ❌ FALSCH:
> "Wir müssen 12 Archetypen mit Detail-Screens bauen (Die Strategin, Die Pionierin, etc.)"

### ✅ RICHTIG:
> "Der Archetyp ist die INDIVIDUELL GENERIERTE Synthese (z.B. 'Die großzügige Perfektionistin'). Jede Nutzerin hat ihren eigenen Titel, nicht 1 von 12 vordefinierten."

---

### ❌ FALSCH:
> "Content Library soll alle 3 Systeme synthetisieren wie der Archetyp"

### ✅ RICHTIG:
> "Content Library beschreibt ISOLIERT einzelne Elemente (nur Schütze, nur Waage-Mond, nur Lebenszahl 8). Das ist korrekt! Aber die Texte müssen trotzdem die Glow-Stimme haben (konkret, überraschend, mit Schattenseiten)."

---

### ❌ FALSCH:
> "Archetyp-Signatur wird jedes Mal neu generiert beim Home Screen Öffnen"

### ✅ RICHTIG:
> "Archetyp-Signatur wird EINMAL generiert und in der DB gespeichert. Nur bei expliziter Regenerierung (z.B. Profil-Änderung) wird sie neu erstellt."

---

## 🎯 WAS IST AKTUELL ZU TUN?

### Priorität 1: **Content Library Prompts überarbeiten** ⚠️
**Problem:** Aktuelle Texte sind "mega langweilig" (User-Feedback)
**Grund:** Prompt ist generisch, keine Glow-Stimme, keine Überraschungen
**Lösung:** 4 neue Prompts (siehe `CONTENT_LIBRARY_PROMPT_ANLEITUNG.md`)
**Aufwand:** 1-2h + $0.50 für Neu-Generierung

**Dokumente:**
- ✅ `docs/CONTENT_LIBRARY_BRAND_SOUL_AUDIT.md` — Audit zeigt 20% Brand Soul Konformität
- ✅ `docs/CONTENT_LIBRARY_PROMPT_ANLEITUNG.md` — 4 neue Prompts ready to implement
- ⏳ `scripts/seed_content_library.dart` — muss angepasst werden

---

### Priorität 2: **Fehlende Content Library Texte generieren** 🆕
**Problem:** Bazi Day Master + Erweiterte Numerologie fehlen komplett
**Aufwand:** Nach Prompt-Fix: Script erweitern + generieren (~334 neue Texte)
**Kosten:** ~$5 für alle fehlenden Texte

**Fehlende Kategorien:**
- ❌ Bazi Day Master (60 Texte × 2 Sprachen = 120)
- ❌ Birthday Numbers (31 × 2 = 62)
- ❌ Attitude Numbers (10 × 2 = 20)
- ❌ Maturity Numbers (12 × 2 = 24)
- ❌ Personal Year (9 × 2 = 18)
- ❌ Personality Numbers (12 × 2 = 24)
- ❌ Karmic Debt (4 × 2 = 8)
- ❌ Challenge Numbers (10 × 2 = 20)
- ❌ Karmic Lessons (9 × 2 = 18)
- ❌ Bridge Numbers (10 × 2 = 20)

**WICHTIG:** Erst Prompts fixen (Prio 1), DANN neue Texte generieren!

---

### Priorität 3: **Archetyp-Signatur Prompt verbessern** 🔧
**Problem:** Aktueller Prompt produziert Texte wie "verschmilzt zu einem kraftvollen Tanz"
**Grund:** Zu vage, keine klaren Regeln für Widersprüche/Spannungen
**Lösung:** Neuer Prompt (siehe `ARCHETYP_PROMPT_ANLEITUNG.md`)
**Aufwand:** 30 Min (nur Prompt-String ersetzen)

**Dokumente:**
- ✅ `docs/ARCHETYP_PROMPT_ANLEITUNG.md` — Neuer Prompt ready to implement
- ⏳ `apps/glow/lib/src/core/services/prompts/archetype_signature_prompt.dart` — muss angepasst werden

**ACHTUNG:** Dieser Prompt generiert **individuellen Content pro User**. Bestehende User behalten alte Signaturen, nur neue User oder Regenerierungen nutzen den neuen Prompt.

---

## 📚 RELEVANTE DOKUMENTATION

### Brand Voice & Qualität:
- **`docs/NUURAY_BRAND_SOUL.md`** ⭐ **PFLICHTLEKTÜRE** für alle Content-Arbeiten
- **`docs/CONTENT_LIBRARY_BRAND_SOUL_AUDIT.md`** — Audit der aktuellen Texte (Ergebnis: 20% konform)
- **`docs/CONTENT_REVIEW_BRAND_SOUL.md`** — Content-Review gegen Brand Voice

### Prompt-Anleitungen:
- **`docs/ARCHETYP_PROMPT_ANLEITUNG.md`** — Archetyp-Signatur Prompt überarbeiten
- **`docs/CONTENT_LIBRARY_PROMPT_ANLEITUNG.md`** — Content Library 4 neue Prompts

### Implementierung:
- **`docs/glow/implementation/CLAUDE_API_IMPLEMENTATION.md`** — Claude API Integration
- **`docs/architecture/ARCHETYP_SYSTEM.md`** ⚠️ TEILWEISE VERALTET (siehe Warning-Banner)

### Status & Roadmap:
- **`docs/glow/MVP_VS_POST_LAUNCH_V2.md`** — Launch-Strategie (4-5 Monate)
- **`TODO.md`** — Aktuelle Aufgabenliste

---

## 🚀 ZUSAMMENFASSUNG FÜR NEUE CLAUDE CHATS

**Wenn ein neuer Claude Chat fragt: "Was ist der Archetyp?"**

Antwort:
> Der **Archetyp** ist die **individuell generierte Synthese** aller drei Systeme (Western, Bazi, Numerologie) für eine spezifische Nutzerin. Es ist KEIN vordefiniertes System mit 12 Archetypen-Namen.
>
> Jede Nutzerin bekommt via Claude API einen einzigartigen Titel + Synthese-Text (z.B. "Die großzügige Perfektionistin — Alles in dir will nach vorne..."). Dieser wird in `profiles.signature_text` gespeichert und auf dem Home Screen angezeigt.
>
> Das ist NICHT zu verwechseln mit der **Content Library** (264 statische Texte für einzelne Elemente wie "Schütze", "Waage-Mond", etc.).

---

**Letzte Aktualisierung:** 2026-02-12
**Nächste Review:** Nach Content Library Prompt-Fix
