# 🌙 NUURAY GLOW — Claude Context Briefing

> **Zweck:** Schnell-Onboarding für neue Claude-Sessions. Copy-Paste diesen Text in den Chat, um Claude sofort auf den aktuellen Stand zu bringen.

---

## 📋 Projekt-Essentials

**NUURAY Glow** ist eine Flutter-App für personalisierte Horoskope durch **Synthese von Westlicher Astrologie, Bazi (Chinesische Astrologie) und Numerologie**.

- **Tech-Stack:** Flutter (iOS/Android/Web), Supabase (PostgreSQL + Auth + RLS), Claude API (Sonnet 4.5)
- **State Management:** Riverpod
- **i18n:** 100% Deutsch + Englisch parallel (ARB-Dateien)
- **Solo-Entwicklerin:** Pragmatismus > Perfektion, KISS-Prinzip

---

## 🎯 Aktueller Status (2026-02-10)

### ✅ Vollständig Implementiert

**Core Features:**
- ✅ Supabase Email Authentication (Login, Signup, Password Reset)
- ✅ **2-Schritte Onboarding:**
  - Schritt 1: 4 Name-Felder (Rufname, Vornamen, Geburtsname, Nachname)
  - Schritt 2: Geburtsdaten kombiniert (Datum + Zeit + Ort)
  - Schritt 3: Gender-Tracking (neu, noch nicht deployed)
- ✅ LIVE Google Places Autocomplete für Geburtsort (+ Koordinaten + Timezone)
- ✅ **"Deine Signatur" Dashboard** (inline auf Home Screen + Detail-Screen)
- ✅ Bottom Navigation (4 Tabs: Home, Signatur, Mond, Insights)
- ✅ Profile Edit Screen mit Auto-Regenerierung (kein Logout nötig!)
- ✅ Language Switcher (DE 🇩🇪 / EN 🇬🇧) mit Supabase-Sync

**Geburtsdaten-Engine (Cosmic Profile):**
- ✅ **Western Astrology:** Sonnenzeichen, Mondzeichen, Aszendent (mit Graden)
- ✅ **Bazi (Vier Säulen):** Jahr/Monat/Tag/Stunde, Day Master, Element-Balance
- ✅ **Numerologie (erweitert):**
  - Kern: Life Path, Birthday, Attitude, Personal Year, Maturity
  - Dual-Energy: Birth Energy (Geburtsname) + Current Energy (aktueller Name)
  - Erweitert: Karmic Debt, Challenge Numbers (4 Phasen), Karmic Lessons, Bridge Numbers
  - Display Name Number (Rufnamen-Numerologie)

**Claude API Integration:**
- ✅ `ClaudeApiService` mit Token-Usage Tracking
- ✅ Model: `claude-sonnet-4-20250514` (~$0.02-0.05 pro Call)
- ✅ Archetyp-Signatur On-Demand Generierung
- ✅ Tageshoroskop-Template (noch nicht deployed)

**Content-Strategie (neu 2026-02-10):**
- ✅ **Content Library** (Supabase-Tabelle) mit 264 Texten (132 DE + 132 EN)
- ✅ Kategorien: Sun Signs, Moon Signs, Bazi Day Masters, Life Path Numbers
- ✅ `ContentLibraryService` mit In-Memory Caching
- ✅ Seed-Script: `scripts/seed_content_library.dart` (Kosten: ~$0.24 für alle Texte)

### ⏳ Vorbereitet, nicht aktiviert

- ⏳ Tageshoroskop-Screen (UI vorhanden, aber nur Placeholder-Content)
- ⏳ Mondphasen-Kalender
- ⏳ Partner-Check
- ⏳ Edge Functions (Phase 2: Cron Job für Pre-Generated Content)

### ❌ Noch nicht umgesetzt

- ❌ In-App Purchases (Apple StoreKit / Google Play Billing)
- ❌ Push-Notifications (Firebase Cloud Messaging)
- ❌ Apple Sign-In / Google Sign-In
- ❌ PDF-Reports
- ❌ Dark Mode

---

## 🔧 Wichtige Entscheidungen & Learnings

### Onboarding: 3 Schritte → 2 Schritte (+ Gender)
- **Grund:** Schnellerer UX, Numerologie braucht vollständige Namen für Dual-Energy System
- **Dual-Energy:** Birth Energy (Geburtsname) vs. Current Energy (aktueller Name nach Heirat)

### Numerologie-Berechnung: Methode B
- **Methode A:** Pro Namensteil reduzieren, dann addieren
- **Methode B:** Alle Buchstaben addieren, einmal reduzieren ← **gewählt**
- **Grund:** Erhält Meisterzahlen (11, 22, 33), spirituell wichtiger

### Tageshoroskop-Strategie: Pre-Generated → On-Demand Phase 1
- **Phase 1 (MVP):** On-Demand Generation (~$10-15/Monat)
- **Phase 2 (bei 1000+ User):** Cron Job um 4:00 UTC für alle 12 Sternzeichen
- **Grund:** Kosteneffizienz (Pay-per-Use vs. $15/Monat Cron)

### Profile Edit: Sofort-Regenerierung
1. Lösche Chart + Signatur aus DB
2. Invalidiere Provider
3. Warte 500ms
4. Lade Chart synchron
5. Generiere Archetyp-Signatur neu via Claude
6. Final Invalidation
- **Ergebnis:** Alles sofort aktualisiert, kein Logout nötig!

### Aszendent-Berechnung: UTC-Problem behoben
- **Problem:** Aszendent war falsch (zeigte Zwillinge statt Krebs)
- **Root Cause:** Falsche UTC-Konvertierung in `_calculateJulianDay()`
- **Lösung:** Lokale Zeit verwenden (Geburtszeit ist IMMER lokal gemeint)
- **Ergebnis:** 100% korrekt nach "Astronomical Algorithms" (Jean Meeus)

---

## 📊 Datenbank-Schema (Supabase)

### `profiles` Tabelle
```sql
-- Name-Felder
display_name TEXT (Rufname)
full_first_names TEXT (Alle Vornamen)
birth_name TEXT (Geburtsname / Mädchenname)
last_name TEXT (Aktueller Nachname)

-- Geburtsdaten
birth_date DATE
birth_time TIME (optional)
birth_place TEXT
birth_latitude FLOAT
birth_longitude FLOAT
birth_timezone TEXT (z.B. "Europe/Berlin")

-- Meta
language TEXT ('de' | 'en')
gender TEXT ('female' | 'male' | 'other' | NULL)
premium_status BOOLEAN
premium_until TIMESTAMP
```

### `birth_charts` Tabelle
```sql
-- Western Astrology
sun_sign, sun_degree, moon_sign, moon_degree, ascendant_sign, ascendant_degree

-- Bazi (4 Säulen)
bazi_year_stem, bazi_year_branch, bazi_month_stem, bazi_month_branch,
bazi_day_stem, bazi_day_branch, bazi_hour_stem, bazi_hour_branch,
bazi_element, bazi_day_stem (Day Master)

-- Numerologie (Kern)
life_path_number, birthday_number, attitude_number, personal_year_number, maturity_number

-- Numerologie (Dual-Energy)
birth_expression_number, birth_soul_urge_number, birth_personality_number,
current_expression_number, current_soul_urge_number, current_personality_number

-- Numerologie (Erweitert)
karmic_debt_numbers TEXT[] (z.B. ['13', '19'])
challenge_numbers TEXT[] (4 Phasen)
karmic_lessons TEXT[] (fehlende Zahlen)
bridge_numbers TEXT[] (Life Path ↔ Expression)
display_name_number TEXT (Rufnamen-Numerologie)

-- Claude API
signature_text TEXT (Archetyp-Signatur von Claude generiert)
```

### `content_library` Tabelle (neu 2026-02-10)
```sql
category TEXT ('sun_sign', 'moon_sign', 'bazi_day_master', 'life_path_number')
key TEXT ('aries', 'yang_wood_rat', '11', etc.)
locale TEXT ('de', 'en')
title TEXT
description TEXT (~70 Wörter)
```

**RLS:** Alle Tabellen haben Row Level Security aktiviert. User sehen nur ihre eigenen Daten (`auth.uid() = user_id`).

---

## 🎨 UI/UX — Screens & Navigation

### Bottom Navigation (4 Tabs)
1. **Home:** Dashboard mit Mini-Widgets (Tagesenergie, Horoskop, Signature-Preview)
2. **Signatur:** "Deine Signatur" Detail-Screen (5 Sektionen)
3. **Mond:** Placeholder (später: Mondphasen-Kalender)
4. **Insights:** Placeholder (später: Partner-Check, Wochen-/Monatsübersicht)

### "Deine Signatur" Screen (5 Sektionen)
1. **Hero Section:** Archetyp-Titel + Mini-Synthese (Claude-generiert)
2. **Western Astrology Card:** Sonne/Mond/Aszendent mit Graden
3. **Bazi Card:** Vier Säulen, Day Master, Element Balance
4. **Numerologie Card (Erweitert):**
   - Kern-Zahlen: Life Path, Birthday, Attitude, Personal Year, Maturity
   - Name Energies: Birth Energy (expandable), Current Energy (expandable)
   - Erweiterte Numerologie: Karmic Debt, Challenge Numbers, Karmic Lessons, Bridge Numbers
5. **Premium Synthesis Section:** CTA + Feature-Liste

### Settings Screen
- Language Switcher (DE 🇩🇪 / EN 🇬🇧) mit visuellen Chips
- Premium Status (UI vorhanden, Subscriptions noch nicht implementiert)
- Profile Edit (inline Form-Felder mit Auto-Regenerierung)
- Account Actions (Logout, Delete Account)

---

## 🤖 Claude API — Prompt-Architektur

### System-Prompt (Glow)
```
Du bist eine charmante, kluge Astrologin. Dein Stil ist warm, überraschend, nie langweilig.
Vermeidest Klischees. Beginne nicht mit "Liebe/r {sternzeichen}" sondern mit konkreter, überraschender Beobachtung.
```

### Template: Daily Horoscope
```
Variablen: {sternzeichen}, {mondphase}, {mondzeichen}, {tagesenergie}, {element}, {sprache}
Länge: 150-200 Wörter
Format: Fließtext, ein Absatz, keine Floskeln
```

### Template: Signature Interpretation
```
Variablen: {sun_sign}, {moon_sign}, {ascendant}, {bazi_day_master}, {life_path_number}, {sprache}
Länge: 80-120 Wörter (Mini-Synthese für Hero Section)
Format: Archetyp-Titel + 2-3 Sätze
```

**Kosten (aktuell):**
- On-Demand Archetyp-Signatur: ~$0.03 pro User
- Tageshoroskop (On-Demand Phase 1): ~$0.02 pro Abruf
- Content Library Seed: $0.24 einmalig (264 Texte)

---

## 📂 Projekt-Struktur

```
apps/glow/
├── lib/src/
│   ├── core/
│   │   ├── navigation/app_router.dart (ShellRoute für Bottom Nav)
│   │   ├── providers/ (Riverpod: userProfile, signature, language)
│   │   ├── services/ (ClaudeApiService, GeocodingService)
│   │   └── widgets/ (ScaffoldWithNavBar, ExpandableCard)
│   ├── features/
│   │   ├── auth/ (Login, Signup, Password Reset)
│   │   ├── onboarding/ (2 Schritte: Name, Geburtsdaten + Gender)
│   │   ├── home/ (Dashboard)
│   │   ├── signature/ (Detail-Screen)
│   │   ├── moon/ (Placeholder)
│   │   ├── insights/ (Placeholder)
│   │   └── settings/ (Language, Premium, Profile Edit)
│   └── main.dart

packages/
├── nuuray_core/ (Models, Calculators, i18n)
│   ├── models/ (UserProfile, BirthChart, ZodiacSign)
│   ├── calculators/ (Western, Bazi, Numerology)
│   └── l10n/ (zodiac_names.dart)
├── nuuray_api/ (Services, Repositories, Prompts)
│   ├── services/ (ClaudeApiService, ContentLibraryService, GeocodingService)
│   ├── prompts/ (prompt_templates.dart)
│   └── repositories/ (ProfileRepository, ContentRepository)
└── nuuray_ui/ (Theme, Shared Widgets)
    ├── theme/ (AppColors, Typography, Spacing)
    └── l10n/ (app_de.arb, app_en.arb mit 260+ Strings)
```

---

## 🚀 Nächste Schritte (TODO)

### Diese Woche (MVP-Finalisierung)
1. ✅ Gender Tracking (Migration + Onboarding Screen) — erledigt 2026-02-10
2. ✅ Content Library (264 Texte generiert) — erledigt 2026-02-10
3. ⏳ Supabase Migrationen deployen (Gender, Content Library)
4. ⏳ Content-Seed ausführen (264 Texte in Prod)
5. ⏳ Content Library in UI integrieren (Western, Bazi, Numerologie Sections)
6. ⏳ Mini-Synthese in Onboarding generieren + speichern
7. ⏳ Tageshoroskop-Screen mit echter Content Library

### Nächste Woche (Testing & Polish)
8. Vollständiger User-Flow Test (Auth → Onboarding → Home → Signatur → Settings)
9. i18n Testing (DE/EN Language Switching)
10. Web Platform Testing (Chrome, Firefox)
11. Performance Optimization (Network Tab prüfen)

### Danach (Premium & Monetarisierung)
12. In-App Purchase Setup
13. Premium-Gating Logic
14. Edge Functions Deployment (Phase 2: Pre-Generated Content)

---

## 💬 Wichtige Konventionen

### Entwicklungssprache
- **Code-Kommentare, Commit-Messages, Docs:** Deutsch
- **Variablennamen, Klassen, Funktionen:** Englisch (Flutter/Dart-Konvention)
- **UI-Texte:** Deutsch & Englisch gleichzeitig (ARB-Dateien)

### Git-Konventionen
- Commits: Deutsch, Format: `feat: Tageshoroskop-Ansicht hinzugefügt`
- Prefixes: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `test:`
- Main-Branch: `main` (immer deploybar)

### Code-Stil
- **Analyse:** `flutter_lints` (strict)
- **Immutable Models:** `freezed` oder `equatable`
- **Logging:** `log()` aus `dart:developer`, nie `print()`
- **Error-Handling:** Result-Typen (eigenes `Result<T, E>` oder `dartz Either`)

---

## 📚 Wichtige Dokumente

| Dokument | Zweck |
|----------|-------|
| [`docs/README.md`](docs/README.md) | Dokumentations-Hub mit Navigation |
| [`docs/glow/GLOW_SPEC_V2.md`](docs/glow/GLOW_SPEC_V2.md) | Aktuelle Glow-Spezifikation |
| [`docs/architecture/PROJECT_BRIEF.md`](docs/architecture/PROJECT_BRIEF.md) | Vollständige Architektur (alle 3 Apps) |
| [`TODO.md`](TODO.md) | Aktuelle Aufgabenliste |
| [`CLAUDE.md`](CLAUDE.md) | Projektanweisung (du bist hier) |
| [`docs/daily-logs/`](docs/daily-logs/) | 38+ Session-Logs (neueste: 2026-02-10) |

---

## 🎯 Status-Zusammenfassung

**GLOW MVP ist ~80% fertig und produktionsreif für Early-Adopter Testing.**

**Was funktioniert:**
- ✅ Vollständiger Auth-Flow
- ✅ Onboarding mit Geocoding + Timezone
- ✅ Geburtsdaten-Engine (Western, Bazi, Numerologie)
- ✅ "Deine Signatur" Dashboard mit 5 Sektionen
- ✅ Profile Edit mit Auto-Regenerierung
- ✅ i18n (DE/EN) mit Language Switcher
- ✅ Content Library (264 Texte)

**Was fehlt:**
- ⏳ Tageshoroskop-Screen mit echtem Content
- ⏳ Mondphasen-Kalender
- ⏳ Partner-Check
- ❌ In-App Purchases
- ❌ Push-Notifications

**Kosten (MVP):** ~$25-30/Monat (Claude API + Supabase + Google Places)

---

**🔍 Fragen? Überprüfe:**
1. [`docs/README.md`](docs/README.md) → Dokumentations-Hub
2. [`TODO.md`](TODO.md) → Aktuelle Aufgaben
3. [`docs/daily-logs/`](docs/daily-logs/) → Neueste Session-Logs

---

**🚀 Ready to code!**
