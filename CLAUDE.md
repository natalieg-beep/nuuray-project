# NUURAY — Projektanweisung

> **📚 Vollständige Dokumentation:**
> - **START HIER:** [`docs/README.md`](docs/README.md) — Dokumentations-Hub mit Navigation zu allen Docs
> - 🌙 **[`docs/NUURAY_BRAND_SOUL.md`](docs/NUURAY_BRAND_SOUL.md)** — ⭐ PFLICHTLEKTÜRE für Claude API Prompts, Content-Generierung & UI-Texte
> - [`docs/glow/GLOW_SPEC_V2.md`](docs/glow/GLOW_SPEC_V2.md) — ✨ AKTUELLE Glow-Spezifikation (3-Schritte Onboarding)
> - [`docs/glow/GLOW_REPORTS_OTP.md`](docs/glow/GLOW_REPORTS_OTP.md) — 📊 Reports & OTPs (alle 10 Reports)
> - [`docs/glow/MVP_VS_POST_LAUNCH_V2.md`](docs/glow/MVP_VS_POST_LAUNCH_V2.md) — 🚀 Launch-Ready Roadmap (4-5 Monate)
> - [`docs/CLAUDE_BRIEFING_CONTENT_STRATEGY.md`](docs/CLAUDE_BRIEFING_CONTENT_STRATEGY.md) — 🎯 Archetyp vs. Content Library (Klarstellung)
> - [`docs/glow/SPEC_CHANGELOG.md`](docs/glow/SPEC_CHANGELOG.md) — Konzeptionelle Änderungen
> - [`docs/architecture/PROJECT_BRIEF.md`](docs/architecture/PROJECT_BRIEF.md) — Vollständige Architektur (alle 3 Apps)
> - [`docs/daily-logs/2026-02-12_content-strategy-klarstellung.md`](docs/daily-logs/2026-02-12_content-strategy-klarstellung.md) — Neueste Session (Content-Strategie)
> - [`TODO.md`](TODO.md) — Aktuelle Aufgabenliste

---

## Was ist NUURAY?

NUURAY (arabisch *nur* = Licht + türkisch *ay* = Mond → "Mondlicht") ist eine Markenfamilie aus drei eigenständigen Apps für Frauen. Alle drei teilen sich ein gemeinsames Backend, werden aber sequenziell entwickelt.

| App | Zweck | Status |
|-----|-------|--------|
| **Nuuray Glow** | Horoskope, Tagesenergien, Mondphasen, Partner-Check | 🔨 In Entwicklung (Phase 1) |
| **Nuuray Tide** | Zyklustracking + Mondphasen, Stimmungsprognose | ⏳ Geplant (Phase 3) |
| **Nuuray Path** | Coaching-Journey, Reflexion, Journaling | ⏳ Geplant (Phase 4) |

## Wer entwickelt?

Solo-Entwicklerin. Kein Team. Jede Entscheidung muss pragmatisch und wartbar sein. Lieber einfach und funktionierend als overengineered.

## Tech Stack

| Bereich | Technologie | Hinweise |
|---------|-------------|----------|
| Frontend | **Flutter** | iOS + Android + Web aus einer Codebase |
| Backend | **Supabase** | PostgreSQL, Auth, Edge Functions, Storage, Realtime |
| AI | **Claude API** (Anthropic) | Personalisierte Texte, Horoskope, Coaching |
| Payments | **In-App Purchases** | Apple StoreKit + Google Play Billing |
| State Management | **Riverpod** | Provider-basiert, testbar |
| Routing | **GoRouter** | Deklarativ, Deep-Linking |
| i18n | **flutter_localizations + ARB** | Deutsch & Englisch gleichzeitig |
| HTTP | **dio** | Interceptors, Retry, Logging |
| Local Storage | **shared_preferences + drift** | Einstellungen + lokaler Cache |

## Projektstruktur

```
nuuray-project/
├── CLAUDE.md              ← Du bist hier
├── apps/
│   ├── glow/              ← Nuuray Glow (Flutter-App)
│   ├── tide/              ← Nuuray Tide (Flutter-App, später)
│   └── path/              ← Nuuray Path (Flutter-App, später)
├── packages/
│   ├── nuuray_core/       ← Shared: Models, Services, Utils
│   ├── nuuray_api/        ← Shared: Supabase Client, Claude API, Mondphasen
│   └── nuuray_ui/         ← Shared: Theme, Widgets, i18n
├── supabase/
│   ├── migrations/        ← SQL-Migrationen (versioniert)
│   ├── functions/         ← Edge Functions (Deno/TypeScript)
│   └── seed/              ← Seed-Daten
└── docs/                  ← Projekt-Dokumentation
```

## Wichtige Dokumente

| Datei | Inhalt | Wann relevant |
|-------|--------|---------------|
| [`docs/NUURAY_BRAND_SOUL.md`](docs/NUURAY_BRAND_SOUL.md) | 🌙 **Markenstimme, Tonalität, Synthese-Philosophie, Prompt-Regeln** | **Bei JEDEM Claude API Prompt, bei Content-Generierung, bei UI-Texten** |
| [`docs/README.md`](docs/README.md) | Dokumentations-Hub mit Navigation | Orientierung im Projekt |
| [`docs/glow/GLOW_SPEC_V2.md`](docs/glow/GLOW_SPEC_V2.md) | Vollständige Glow-Spezifikation | Feature-Entwicklung für Glow |
| [`docs/architecture/PROJECT_BRIEF.md`](docs/architecture/PROJECT_BRIEF.md) | Architektur aller 3 Apps | Technische Entscheidungen |
| [`TODO.md`](TODO.md) | Aktuelle Aufgabenliste | Entwicklungs-Status |

## Architektur-Regeln

### Shared Packages
- **Alles was zwei oder mehr Apps brauchen, gehört in `packages/`.**
- `nuuray_core`: Datenmodelle, Business-Logik, Berechnungen (Astrologie, Mondphasen, Numerologie).
- `nuuray_api`: Supabase-Client, Claude API Service, API-Abstraktion. Keine UI.
- `nuuray_ui`: Theme (Farben, Typografie, Spacing), Shared Widgets, i18n-Dateien.
- Apps importieren Packages über `path`-Dependencies in `pubspec.yaml`.

### App-spezifisch
- Jede App hat ihren eigenen Charakter (Farben, Ton), aber basiert auf dem Shared Theme.
- Glow: Warm, golden, unterhaltsam. Tide: Rosé, fließend, achtsam. Path: Blau, klar, reflektiert.
- Features die nur eine App braucht, bleiben in der App.

### Datenfluss
```
User öffnet App
  → Supabase Auth (shared)
  → User-Profil laden (shared)
  → Geburtsdaten-Engine berechnet Chart (nuuray_core)
  → Tages-Energie berechnen (nuuray_core)
  → Claude API: Personalisierter Text generieren (nuuray_api)
  → UI rendern (App-spezifisch + nuuray_ui)
```

## Sprache & i18n

- **Entwicklungssprache: Deutsch.** Code-Kommentare, Commit-Messages, Docs auf Deutsch.
- **Variablennamen, Klassen, Funktionen: Englisch.** Das ist Flutter/Dart-Konvention.
- **UI-Texte: Deutsch & Englisch gleichzeitig.** ARB-Dateien in `nuuray_ui/lib/src/l10n/`.
- **Deutsch ist die Primärsprache.** `app_de.arb` wird zuerst geschrieben, `app_en.arb` parallel.
- **Content (Horoskope, Coaching-Texte): Deutsch & Englisch.** Claude API wird mit der User-Sprache aufgerufen.

## Claude API — Richtlinien

### Kosten minimieren
- **Tages-Horoskope vorab generieren**, nicht pro User. Supabase Cron Job (Edge Function) generiert morgens um 4:00 UTC für alle 12 Sternzeichen + Mondphase.
- **Personalisierung als zweite Schicht:** Gecachter Basis-Content + kurzer Claude-Call für persönliche Akzente.
- **Caching aggressiv nutzen:** Supabase-Tabelle `daily_content` mit TTL.
- **Model: `claude-sonnet-4-20250514`** für Content-Generierung (gutes Preis-Leistungs-Verhältnis).
- **Claude Opus nur für komplexe Coaching-Journeys** in Path (später).

### Prompt-Architektur
- System-Prompts als Templates in `nuuray_api/lib/src/prompts/`.
- Variablen: `{sternzeichen}`, `{mondphase}`, `{tagesenergie}`, `{sprache}`.
- Ton pro App definiert: Glow = unterhaltsam & staunend, Tide = achtsam & empowernd, Path = warm & reflektiert.
- **Nie den gesamten Chart in den Prompt packen.** Nur die relevanten Datenpunkte für den jeweiligen Content-Typ.

### Brand Voice — PFLICHTLEKTÜRE vor jedem Content-Call
**⚠️ WICHTIG: Vor dem Schreiben von Claude API Prompts, Content-Texten oder UI-Copy: Lies [`docs/NUURAY_BRAND_SOUL.md`](docs/NUURAY_BRAND_SOUL.md)**

- **NIEMALS ein System isoliert.** IMMER alle drei verweben (Western Astrology, Bazi, Numerologie).
- **Widersprüche sind Features, keine Bugs.** Spannungen zwischen den Systemen zeigen, dann auflösen.
- **Jeder generierte Text muss den 7-Fragen-Qualitätscheck bestehen** (siehe Brand Soul Dokument).
- **Verbotene Worte:** "Die Sterne sagen...", "Das Universum möchte...", "Schicksal", "Wunder", "Magie", "Kosmische Energie", "Positive Schwingungen"
- **Der 5-Schritt-Bogen:** Hook → Spannung → Bazi-Tiefe → Auflösung → Impuls
- **Ton-Modifikatoren pro App:** Glow = kluge Freundin beim Kaffee, Tide = achtsame Begleiterin, Path = weise Mentorin

## Supabase — Konventionen

### Tabellen-Naming
- **snake_case**, Plural: `users`, `birth_charts`, `daily_horoscopes`, `cycle_entries`.
- Prefix für app-spezifische Tabellen: `glow_`, `tide_`, `path_`.
- Shared-Tabellen ohne Prefix.

### Row Level Security (RLS)
- **Immer aktiviert.** Keine Ausnahmen.
- User sehen nur ihre eigenen Daten (`auth.uid() = user_id`).
- `daily_horoscopes` und anderer Public Content: Leserechte für alle authentifizierten User.

### Edge Functions
- TypeScript/Deno.
- Naming: `generate-daily-content`, `calculate-chart`, `sync-cycle-data`.
- Authentifizierung via Supabase JWT.

## Payments

- **In-App Purchases** über Apple StoreKit / Google Play Billing für alle Abo-Features.
- **RevenueCat** als Abstraktionsschicht evaluieren (vereinfacht Cross-Platform-Subscriptions).
- **Subscription-Status serverseitig verifizieren** — nie nur clientseitig.
- Supabase-Tabelle `subscriptions` trackt aktiven Status, Produkt-ID, Plattform.

## Code-Stil

### Dart/Flutter
- **Analyse: `flutter_lints` (strict).**
- Klassen: PascalCase (`BirthChart`, `MoonPhaseService`).
- Dateien: snake_case (`birth_chart.dart`, `moon_phase_service.dart`).
- Const überall wo möglich.
- Immutable Models mit `freezed` oder `equatable`.
- Keine `print()` — immer `log()` aus `dart:developer` oder Logger-Package.

### Fehlerbehandlung
- Ergebnis-Typen: Eigenes `Result<T, E>` oder `dartz Either`.
- Keine unbehandelten Exceptions in Services.
- UI zeigt immer einen sinnvollen Fehlerzustand.

### Tests
- Unit-Tests für `nuuray_core` (Berechnungen sind kritisch).
- Widget-Tests für wichtige UI-Flows.
- Integration-Tests für Auth + Datenfluss.

## Git-Konventionen

- **Commits: Deutsch.** Format: `feat: Tageshoroskop-Ansicht hinzugefügt`
- Prefixes: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`, `test:`
- **Main-Branch: `main`** (immer deploybar).
- Feature-Branches: `feature/tageshoroskop`, `fix/mondphasen-berechnung`.

## Aktuelle Priorität

**Glow MVP.** Alles andere hat gerade keine Priorität. Wenn du bei einer Entscheidung unsicher bist, frag dich: "Braucht Glow das für den MVP?" Wenn nein → Backlog.

### Glow MVP Features (in dieser Reihenfolge):
1. ✅ Auth (Supabase: Email Authentication)
   - Email-Login/Signup implementiert
   - Auth-State Management mit Riverpod
   - Routing mit GoRouter und Auth-Guards
   - TODO: Apple Sign-In + Google Sign-In
2. ✅ Onboarding: Geburtsdaten eingeben
   - **2-Schritte Onboarding-Flow** implementiert ✅
   - **Schritt 1:** Name-Felder (4 Felder: Rufname, Vornamen, Geburtsname, Nachname)
   - **Schritt 2:** Geburtsdaten kombiniert (Datum + Zeit + Ort)
   - Geburtsdatum (Pflicht) + Geburtszeit (optional)
   - Geburtsort mit **LIVE Google Places Autocomplete** ✅ (via Supabase Edge Function)
   - Speicherung in Supabase `profiles` Tabelle
3. ✅ Splash Screen mit Auth/Onboarding Routing
   - Prüft Auth-Status
   - Prüft Onboarding-Status
   - Leitet zu Login/Onboarding/Home weiter
4. ✅ Basic Home Screen
   - Begrüßung mit Tageszeit-Anpassung
   - Tagesenergie-Card (Placeholder)
   - Horoskop-Card (zeigt User-Sternzeichen aus Profil)
   - Quick Actions (Coming Soon)
   - Logout-Funktion
5. ✅ **"Deine Signatur" Dashboard** (inline auf Home Screen) ✅
   - Western Astrology Card (Sonne/Mond/Aszendent mit Graden)
   - Bazi Card (Vier Säulen, Day Master, Element Balance)
   - **Numerology Card (ERWEITERT):**
     - Kern-Zahlen: Life Path, Birthday, Attitude, Personal Year, Maturity
     - Name Energies: Birth Energy (expandable), Current Energy (expandable)
     - **Erweiterte Numerologie:** Karmic Debt, Challenge Numbers, Karmic Lessons, Bridge Numbers
6. ✅ Geburtsdaten-Engine: Chart berechnen
   - Western Astrology Calculator (Sonnenzeichen, Mondzeichen, Aszendent) ✅
   - Bazi Calculator (Vier Säulen, Day Master, Elemente) ✅
   - Numerology Calculator (Life Path, Expression, Soul Urge + Erweitert) ✅
7. ⬜ Tageshoroskop-Ansicht (gecachter Content + persönliche Akzente)
8. ⬜ Mondphasen-Kalender
9. ⬜ Wochen- und Monatsüberblick
10. ⬜ Basic Partner-Check
11. ⬜ Premium-Gating + In-App Purchase
12. ⬜ Push-Notifications (tägliches Horoskop)

### Implementierungs-Hinweise für "Deine Signatur" Dashboard
- **Datenmodell**: `BirthChart` mit drei Subsystemen (Western, Bazi, Numerology)
- **UI**: Drei Cards mit einheitlichem Design (AppColors, kein Gradient)
- **Berechnungen**: Calculator-Services in `nuuray_core`, nutzen Geburtsdaten aus User-Profil
- **Supabase**: `birth_charts` Tabelle mit JSONB für berechnete Daten + Cache
- **Provider**: `signatureProvider` (nutzt `CosmicProfileService`)
- **i18n**: Alle Sternzeichen, Elemente, Zahlen-Beschreibungen mehrsprachig
