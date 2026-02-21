# NUURAY GLOW — TODO Liste

> Letzte Aktualisierung: 2026-02-21 (Tiefe Drei-System-Synthese — Herzstück der App fertig! 🎉)
> Stand: Auth ✅, Onboarding ✅, Geocoding ✅, Basic Home ✅, Deine Signatur ✅, **Archetyp-System (Claude-Synthese) ✅**, Claude API ✅, Erweiterte Numerologie ✅, **Tageshoroskop On-Demand ✅, i18n DE/EN 100% ✅, Profile Edit (Auto-Regenerierung) ✅, Rufnamen-Numerologie ✅, Web Platform Fix ✅, Content Library ✅, Gender Tracking ✅, Bazi Vier Säulen + Element Balance ✅, Code Quality Cleanup ✅, Reports UI Foundation ✅, **Tiefe Drei-System-Synthese ✅**
>
> **📚 Neue Dokumentation:**
> - **`docs/daily-logs/2026-02-21_deep-synthesis-meilenstein.md`** — **NEU! 2026-02-21** 🎯 Tiefe Synthese Meilenstein
> - **`docs/NUURAY_BRAND_SOUL.md`** — **ERWEITERT 2026-02-21** 🌙 3-Spannungsfelder-Methode, SCHATTENSEITEN-Regel, Gender-Prompting
> - **`docs/CLAUDE_BRIEFING_CONTENT_STRATEGY.md`** — **NEU! 2026-02-12** 🎯 **Klare Aufstellung für Claude Chats** (Archetyp vs. Content Library)
> - **`docs/daily-logs/2026-02-12_content-strategy-klarstellung.md`** — **NEU!** Verwirrung aufgelöst: Archetyp ≠ Content Library
> - `docs/glow/MVP_VS_POST_LAUNCH_V2.md` — **NEU! 2026-02-12** 🚀 Launch-Ready Roadmap (4-5 Monate)
> - `docs/daily-logs/2026-02-12_archetyp-konzept-klarstellung.md` — **NEU!** Archetyp = Synthese (KEINE Detail-Screens!)
> - `docs/glow/GLOW_REPORTS_OTP.md` — **NEU! 2026-02-12** 📊 Reports & OTPs (SoulMate Finder, Soul Purpose, etc.)
> - `docs/daily-logs/2026-02-12_reports-ui-foundation.md` — **NEU!** Reports UI Foundation (Insights Screen + Settings)
> - `docs/daily-logs/2026-02-12_reports-otp-dokumentation.md` — **NEU!** Reports Dokumentations-Gap geschlossen
> - `docs/daily-logs/2026-02-12_code-quality-cleanup.md` — **NEU!** Null-Safety Cleanup (43 Warnings behoben)
> - `docs/deployment/HOROSCOPE_STRATEGY.md` — Tageshoroskop On-Demand vs. Cron Job Strategie
> - `docs/glow/GLOW_SPEC_V2.md` — Aktualisierte vollständige Projektbeschreibung
> - `docs/glow/SPEC_CHANGELOG.md` — Changelog der konzeptionellen Änderungen

---

## ✅ FERTIG

### Auth & User Management
- ✅ Supabase Projekt Setup (URL: https://ykkayjbplutdodummcte.supabase.co)
- ✅ Email Authentication (Login, Signup, Password Reset)
- ✅ AuthService mit deutschen Fehlermeldungen
- ✅ Auth-State Management mit Riverpod
- ✅ LoginScreen + SignupScreen
- ✅ Router mit Auth-Guards (GoRouter + refreshListenable)
- ✅ **Profile Edit (FINAL mit Auto-Regenerierung!)** — **FERTIG 2026-02-08!** 🔄✨
  - EditProfileScreen mit inline Form-Feldern (Name, Geburtsdaten, Ort)
  - Live Google Places Autocomplete für Geburtsort
  - Change Tracking + Form-Validierung
  - **Automatische Neuberechnung:** Chart + Archetyp-Signatur sofort nach Speichern
  - **Kein Logout nötig** - Änderungen sofort sichtbar
  - Workflow:
    1. Speichert in DB
    2. Löscht BirthChart + signature_text
    3. Invalidiert Provider → Chart wird neu berechnet
    4. Wartet 500ms → Lädt Chart synchron
    5. Generiert Archetyp-Signatur NEU via Claude API
    6. Final Invalidation → UI aktualisiert sich
  - Settings: "Profil bearbeiten" Button
  - Siehe: `docs/daily-logs/2026-02-08_profile-edit-FINAL.md`
- ✅ **Web Platform Fix (Provider Caching)** — **FERTIG 2026-02-08!** 🌐
  - Problem: Profil konnte in Chrome/Web nicht geladen werden (funktionierte aber in macOS)
  - Root Cause: Provider wurde VOR Login initialisiert und cached `null`-Ergebnis
  - Fix: `ref.invalidate(userProfileProvider)` nach erfolgreichem Login
  - Bonus: Defensive DateTime-Parsing für Web-Kompatibilität
  - Bonus: `print()` statt `log()` für Chrome Console Visibility
  - Siehe: `docs/daily-logs/2026-02-08_web-provider-caching-fix.md`

### Onboarding
- ✅ **2-Schritte Onboarding-Flow** (**FERTIG 2026-02-08!**) 🎉
  - **Schritt 1:** Name & Identität (**4 FELDER** - zurück zu ursprünglichem Design)
    - Rufname/Username (Pflicht) → `displayName`
    - Vornamen lt. Geburtsurkunde (Optional) → `fullFirstNames`
    - Geburtsname / Maiden Name (Optional) → `birthName`
    - Aktueller Nachname (Optional) → `lastName`
    - **Numerologie-Konzept:**
      - **Birth Energy (Urenergie):** `fullFirstNames + birthName` (z.B. "Natalie Frauke Pawlowski")
      - **Current Energy (Aktuelle Energie):** `fullFirstNames + lastName` (z.B. "Natalie Frauke Günes")
  - **Schritt 2:** Geburtsdaten KOMBINIERT auf einem Screen
    - Geburtsdatum (Pflicht) → Date Picker
    - Geburtszeit (Optional) → Time Picker + Checkbox "unbekannt"
    - Geburtsort (Optional) → **LIVE-Autocomplete mit Google Places API** ✨
      - Debounced Search (800ms)
      - Automatische Suche beim Tippen (mind. 3 Zeichen)
      - Success-Anzeige: Grüne Box mit Ort + Koordinaten + Timezone
      - Error-Anzeige: Rote Box mit Hilfetext
      - "Geburtsort überspringen" Button wenn nicht gefunden
      - Gefundener Ort erscheint im TextField
  - **File:** `onboarding_name_screen.dart` (4 Felder), `onboarding_birthdata_combined_screen.dart`
- ✅ UserProfile Model mit allen Feldern (inkl. `fullFirstNames`, `birthName`, `lastName`, `birth_latitude`, `birth_longitude`, `birth_timezone`)
- ✅ UserProfileService (CRUD + Upsert-Logik)
- ✅ GeocodingService (`nuuray_api/services/geocoding_service.dart`)
- ✅ Supabase Migrations:
  - 001_initial_schema.sql (profiles Tabelle)
  - 002_add_onboarding_fields.sql (Name-Felder, Onboarding-Status, Geburtsort-Felder)
  - 003_cleanup_profile_columns.sql (Alte Spalten entfernen)
- ✅ Supabase Edge Function: `geocode-place` (deployed)

### Basic UI
- ✅ Splash Screen mit Auth/Onboarding Routing
- ✅ Home Screen mit Placeholder-Content
  - Header mit personalisierter Begrüßung
  - Tagesenergie-Card (Gradient, Placeholder)
  - Horoskop-Card (zeigt User-Sternzeichen aus Cosmic Profile)
  - Quick Actions (Coming Soon)
  - Logout Button
- ✅ **"Deine Signatur" Dashboard** (inline auf Home Screen) — **FERTIG 2026-02-08!**
  - Western Astrology Card (Sonne/Mond/Aszendent)
  - Bazi Card (Vier Säulen + Day Master)
  - **Numerology Card (ERWEITERT 2026-02-08!):**
    - Kern-Zahlen: Life Path, **Display Name (Rufname) ✅**, Birthday, Attitude, Personal Year, Maturity
    - Name Energies: Birth Energy (expandable), Current Energy (expandable)
    - **NEU: Erweiterte Numerologie:**
      - ⚡ Karmic Debt Numbers (13/14/16/19) mit Bedeutungen
      - 🎯 Challenge Numbers (4 Phasen als Chips)
      - 📚 Karmic Lessons (fehlende Zahlen 1-9 als Badges)
      - 🌉 Bridge Numbers (Life Path ↔ Expression, Soul ↔ Personality)
    - **NEU: Rufnamen-Numerologie (Display Name):** ✅ **FERTIG 2026-02-08!**
      - Zeigt numerologischen Wert des Rufnamens (z.B. "Natalie" = 8)
      - Positioniert unter Life Path Number
      - Kompaktes Design: 40x40 Badge + Label + Bedeutung
      - Master Number Indicator (✨) für 11/22/33
      - Siehe: `docs/daily-logs/2026-02-08_rufnamen-numerologie.md`
  - Einheitliches Design mit AppColors (keine Gradients)
  - Provider: `signatureProvider` (vorher: `cosmicProfileProvider`)
  - Folder: `features/signature/` (vorher: `cosmic_profile/`)

### Claude API Integration
- ✅ ClaudeApiService implementiert (`apps/glow/lib/src/core/services/claude_api_service.dart`)
  - Tageshoroskop-Generierung (80-120 Wörter, Deutsch + Englisch)
  - Cosmic Profile Interpretation (400-500 Wörter, Synthese aller 3 Systeme)
  - Token-Usage Tracking für Kosten-Kalkulation
  - System-Prompts für konsistenten Ton (unterhaltsam, staunend, empowernd)
- ✅ Supabase Migration: `daily_horoscopes` Tabelle
- ✅ Supabase Migration: `display_name_number` Spalte in `birth_charts` Tabelle ✅ **DEPLOYED 2026-02-08!**
- ✅ **Tageshoroskop: On-Demand Strategie (AKTIV)** — **FERTIG 2026-02-08!**
  - DailyHoroscopeService mit Cache-First + On-Demand Generation
  - Kosten Testphase: $0 | 100 User: ~$6-7/Monat
  - Edge Function vorbereitet für späteren Cron Job (ab 1000+ User)
  - Siehe: `docs/deployment/HOROSCOPE_STRATEGY.md`
- ✅ Test-Script erstellt (`apps/glow/test/test_claude_api.dart`)
- ✅ Dokumentation
  - `docs/glow/implementation/CLAUDE_API_IMPLEMENTATION.md`
  - `docs/deployment/HOROSCOPE_STRATEGY.md` — Phase 1 (On-Demand) vs. Phase 2 (Cron)

---

## ✅ SESSION 2026-02-10

### Content Library Integration
- ✅ **ContentLibraryService** in Signature Screens integriert
  - Western Astrology Section: Lädt Texte für Sonne/Mond/Aszendent
  - Bazi Section: Lädt Day Master Beschreibung
  - Numerology Section: Lädt Life Path, Soul Urge, Expression Numbers
  - FutureBuilder für async Content-Loading
  - In-Memory Caching durch ContentLibraryService
- ✅ **Content Library KOMPLETT generiert (DE)** (254/254 Texte = 100%) — **FERTIG 2026-02-12!** 🎉
  - ⏳ **Englische Texte (EN) fehlen noch** (0/254 Texte) — Siehe Backlog "Internationalisierung"
  - ✅ Sun/Moon/Rising Signs (36 × DE) — Mit verbesserten Prompts regeneriert
  - ✅ Life Path Numbers (12 × DE)
  - ✅ Soul Urge Numbers (12 × DE)
  - ✅ Expression Numbers (12 × DE)
  - ✅ **Bazi Day Masters** (60 × DE) — Bereits vorhanden (10. Feb)
  - ✅ **Personality Numbers** (12 × DE) — NEU!
  - ✅ **Birthday Numbers** (31 × DE) — NEU!
  - ✅ **Attitude Numbers** (12 × DE) — NEU!
  - ✅ **Personal Year** (9 × DE) — NEU!
  - ✅ **Maturity Numbers** (12 × DE) — NEU!
  - ✅ **Display Name Numbers** (12 × DE) — NEU!
  - ✅ **Karmic Debt** (4 × DE) — NEU!
  - ✅ **Challenge Numbers** (12 × DE) — NEU!
  - ✅ **Karmic Lessons** (9 × DE) — NEU!
  - ✅ **Bridge Numbers** (9 × DE) — NEU!
  - ✅ **Prompt-Qualität: 80-90% Brand Soul konform** (4 category-specific prompts)
  - 🟡 **Englische Texte (EN) fehlen noch** (254 Texte, ~$0.76)
  - Kosten bisher: ~$0.90 | Gesamt-Kosten bei EN-Generierung: ~$1.66
- ✅ **RLS Policy Fix:** `daily_horoscopes` INSERT für authenticated users

### Gender-Tracking im Onboarding
- ✅ **DB Migration:** `20260210_add_gender_to_profiles.sql`
  - Spalte `gender TEXT CHECK (gender IN ('female', 'male', 'diverse', 'prefer_not_to_say'))`
  - Index für Abfragen
- ✅ **UserProfile Model erweitert:** `gender` Feld hinzugefügt
- ✅ **Onboarding UI:** Neuer Screen `onboarding_gender_screen.dart`
  - 4 Optionen: Weiblich 👩, Männlich 👨, Divers ✨, Keine Angabe 🤐
  - Auto-advance nach 400ms (smooth UX)
- ✅ **Onboarding Flow:** Jetzt 3 Schritte (Name → Gender → Geburtsdaten)
- ✅ **Zweck:** Personalisierte Content-Generierung (Horoskope, Coaching)

### Deutsche Sternzeichen-Namen
- ✅ **ZodiacNames i18n Map** erstellt (`nuuray_core/src/l10n/zodiac_names.dart`)
  - Deutsche Map: `sagittarius` → `Schütze`
  - Englische Map: `sagittarius` → `Sagittarius`
  - Helper: `ZodiacNames.getName(sign, locale)`
- ✅ **Western Astrology Section:** Nutzt lokalisierte Namen
  - **Vorher:** "Sagittarius in Sonne" ❌
  - **Nachher:** "Schütze in Sonne" ✅

---

## ✅ SESSION 2026-02-12

### Code Quality Cleanup
- ✅ **Null-Safety Warnings behoben** (43 Stück)
  - `language_provider.dart`: Redundante Null-Checks entfernt
  - Alle `AppLocalizations.of(context)!` → `AppLocalizations.of(context)` gefixt
  - `daily_horoscope_service.dart`: `_claudeService!` → `_claudeService`
  - `numerology_card.dart`: Flow-analysis sichere Null-Checks
  - Backup-File gelöscht: `onboarding_birthdata_combined_screen_backup.dart`
  - **Ergebnis:** 0 `unnecessary_non_null_assertion` Warnings
- ✅ **Signatur Screen Cleanup:**
  - `signature_dashboard_screen.dart` gelöscht (veraltet, ungenutzt)
  - Nur `signature_screen.dart` ist aktiv

### Reports Documentation & Strategy
- ✅ **GLOW_REPORTS_OTP.md erstellt** — Vollständige Report-Strategie
  - Vision: Reports als Premium-Produkte (OTPs statt Abo)
  - Report-Katalog: Alle 10 Report-Typen mit Preisen (€4,99 - €9,99)
  - Report-Struktur: Luxury Dossier Format (8 Sektionen)
  - Design-System: Cosmic Nude Palette, Typografie, Layout
  - Technische Architektur: StructuredReport Model, PDF-Generator, Claude API
  - Entwicklungs-Phasen: MVP (SoulMate Finder) → Core → Expansion
  - Monetarisierung: Pricing-Tiers, Bundle-Angebote, Freemium
  - UI/UX: Insights-Tab, Home Section, Settings-Bibliothek
  - Kauf-Flow: 6-Schritte-Journey (Discovery → Purchase → Generation → View)
- ✅ **TODO.md aktualisiert:**
  - Partner-Check aus "Bezahlung/Premium" → Neue Section "📊 Reports & OTPs"
  - Phase 1/2/3 Roadmap hinzugefügt
- ✅ **docs/README.md aktualisiert:**
  - GLOW_REPORTS_OTP.md in Projektstruktur eingefügt
  - Schnellzugriff-Link hinzugefügt
- ✅ **Session-Log:** `docs/daily-logs/2026-02-12_reports-otp-dokumentation.md`

### Archetyp-System Klarstellung
- ✅ **Archetyp-System = Synthese aller 3 Systeme** (Claude-generiert, FERTIG!)
  - Archetyp-Titel: Individuell via Claude API (z.B. "Die bühnenreife Perfektionistin")
  - Signatur-Satz: Verwebt Western + Bazi + Numerologie
  - Home Screen + Signatur Screen Integration ✅
  - **KEINE hardcodierten Namen nötig**
  - **KEINE 12 Detail-Screens nötig**
  - **5-7 Wochen Entwicklungszeit gespart!** 🎉
  - Siehe: `docs/daily-logs/2026-02-12_archetyp-konzept-klarstellung.md`
  - Siehe: `docs/glow/MVP_VS_POST_LAUNCH_V2.md`

### Reports UI Foundation
- ✅ **Bottom Navigation neu sortiert:**
  - **Vorher:** `[Home] [Signatur] [Mond] [Insights]`
  - **Nachher:** `[Home] [Signatur] [Insights] [Mond]`
  - Insights direkt neben Signatur (thematisch zusammenhängend)
  - File: `apps/glow/lib/src/core/widgets/scaffold_with_nav_bar.dart`
- ✅ **Insights Screen erstellt** — Report-Katalog mit allen 10 Reports
  - File: `apps/glow/lib/src/features/insights/screens/insights_screen.dart`
  - **10 Reports aus Beyond Horoscope:**
    1. SoulMate Finder (€4,99) — Partner-Check
    2. Soul Purpose (€7,99) — Seelenmission
    3. Shadow & Light (€7,99) — Schatten-Integration
    4. The Purpose Path (€6,99) — Berufung
    5. Golden Money Blueprint (€7,99) — Geld-Energie
    6. Body Vitality (€5,99) — Lebensenergie
    7. Aesthetic Style Guide (€5,99) — Kosmischer Stil
    8. Cosmic Parenting (€6,99) — Elternschaft
    9. Relocation Astrology (€7,99) — Idealer Ort
    10. Yearly Energy Forecast (€9,99) — Persönliches Jahr
  - **UI:** Material Cards mit farbigen Icons, Preis-Badges, "Coming Soon" Labels
  - **Layout:** 8 Kategorien (Beziehungen, Seele, Berufung, Geld, Gesundheit, Lifestyle, Ortswechsel, Prognosen)
  - **Interaktion:** Tap zeigt "Coming Soon" Snackbar
- ✅ **Settings Screen erweitert** — "Meine Inhalte" Section
  - File: `apps/glow/lib/src/features/settings/screens/settings_screen.dart`
  - **Neue Section zwischen "Account" und "Information":**
    - 📚 Meine Reports (Gekaufte Reports & Analysen)
    - ⭐ Premium (Dein Abo verwalten)
  - **Aktuell:** Beide zeigen "Coming Soon" Snackbar
  - **Später:** Navigation zu Report-Bibliothek bzw. Premium-Verwaltung
- ✅ **Session-Log:** `docs/daily-logs/2026-02-12_reports-ui-foundation.md`

**Status:** ✅ UI Foundation komplett — Funktionalität kommt nach MVP-Launch

---

## ✅ SESSION 2026-02-21 — Tiefe Drei-System-Synthese (Herzstück)

### 🎉 Meilenstein: Deep Synthesis — Das Herzstück der App ist fertig!

Die Tiefe Drei-System-Synthese ist die wichtigste Premium-Feature der App: Eine KI-generierte, 900-1200 Wörter lange Lebensgeschichte die Western Astrology, Bazi und Numerologie kausal verbindet.

#### ✅ Was wurde implementiert:

**Feature: DeepSynthesisSection**
- ✅ `deepSynthesisProvider` (FutureProvider.family<String, BirthChart>) mit Cache-First-Logik
- ✅ Cache in `profiles.deep_synthesis_text` (Supabase)
- ✅ Supabase Migration: `supabase/migrations/20260221_add_deep_synthesis_text.sql`
- ✅ `DeepSynthesisSection` ConsumerWidget mit Loading/Error/Data States
- ✅ `_SynthesisContent` als eigenständiges ConsumerWidget (Fix: ref-Zugriff)
- ✅ Debug-Reset: Long-Press auf Refresh-Icon löscht Cache (nur Debug-Build)
- ✅ Signatur Screen: Herzstück-Section am Ende eingefügt
- ✅ Alte Placeholder-Container entfernt
- ✅ `generateDeepSynthesis()` Methode im ClaudeApiService
- ✅ `_callClaudeWithMaxTokens()` (4096 Tokens = genug für 900-1200 Wörter)

**Prompt-Architektur: 3-Spannungsfelder-Methode (NEU)**
- ✅ Von 5-Schritt-Bogen zur 3-Spannungsfelder-Methode migriert
- ✅ KAUSALE VERBINDUNGEN: "...und genau deshalb...", "...was erklärt, warum..."
- ✅ Systeme erklären sich gegenseitig — nicht parallel, sondern kausal
- ✅ SCHATTENSEITEN PFLICHT: 40% Stärke, 40% Schatten/Preis, 20% Auflösung
- ✅ "Ein guter Text tut ein bisschen weh und fühlt sich trotzdem richtig an"
- ✅ ANSPRACHE-Block jetzt ganz oben im System-Prompt (Gender-Drift verhindert)
- ✅ Persönliches Jahr mit Jahreszahl: "Persönliches Jahr 2026 (aktuelle Jahresenergie)"
- ✅ Englischer System-Prompt ebenfalls aktualisiert

**Bugfixes:**
- ✅ FutureProvider.family Cache-Reset Bug: `ref.invalidate(deepSynthesisProvider(birthChart))` — Parameter ist Pflicht!
- ✅ Gender-Bug: Weibliche Ansprache für männliche User — ANSPRACHE-Block nach oben verschoben + alle hardcodierten "sie/Nutzerin" entfernt
- ✅ `user_profile.dart`: `displayName: ?? 'Nutzerin'` → `?? ''` gefixt
- ✅ Western Astrology Section: Hinweis wenn Mond/Aszendent fehlen (fehlende Geburtszeit)
- ✅ Prompt-Fix: Explizite Anweisung wenn keine Geburtszeit → Claude erfindet keine Daten

**Kosten (zur Referenz):**
- Deep Synthesis: ~500 Input + ~900 Output Tokens ≈ $0.012-0.015 pro Call
- Einmalig pro User, danach gecacht → effektiv $0 Folgekosten
- Bei 1000 Users: ~$12-15 einmalige Generierungskosten

**Dokumentation:**
- ✅ `docs/NUURAY_BRAND_SOUL.md` erweitert (3-Spannungsfelder-Methode + SCHATTENSEITEN-Regel)
- ✅ `docs/daily-logs/2026-02-21_deep-synthesis-meilenstein.md` erstellt
- ✅ `docs/README.md` aktualisiert
- ✅ `TODO.md` aktualisiert

#### 📋 Ergebnis & Feedback:
- Erste Probeleser-Reaktionen: "Das ist der Hammer" ✨
- Einmalige Generierungskosten pro User: ~$0.01
- Textlänge: 900-1200 Wörter (wie Beyond Horoscope Premium Reports)

---

## ⏳ NÄCHSTE SCHRITTE (AKTUELL)

### 🐛 Onboarding: Gender Screen Bottom Overflow
- [ ] **Bug:** `BOTTOM OVERFLOWED BY 174 PIXELS` auf kleinen Screens
- **Ursache:** 4 Optionen (Weiblich/Männlich/Divers/Keine Angabe) passen nicht in sichtbaren Bereich
- **Fix:** `SingleChildScrollView` wrappen oder Layout anpassen (kleinere Tiles, kompakteres Spacing)
- **File:** `apps/glow/lib/src/features/onboarding/screens/onboarding_gender_screen.dart`

### 🚻 Gender-Personalisierung in Content-Generierung
- [ ] **Problem:** Alle generierten Texte (Horoskope, Archetyp-Signatur) sind aktuell weiblich formuliert
- **Ursache:** Claude API Prompts berücksichtigen `gender` Feld aus User-Profil nicht
- **Fix:** `{gender}` Variable in alle Claude API Prompts einfügen
  - `generate_horoscope` Prompt: "Schreibe für eine {weibliche/männliche/diverse} Person..."
  - `generate_archetype` Prompt: Gender-sensitive Formulierungen
- **Files:**
  - `apps/glow/lib/src/core/services/claude_api_service.dart`
  - `nuuray_api/lib/src/prompts/` (System-Prompts)
- **Priorität:** Mittel (vor Launch wichtig, aber kein Blocker)

### 📋 Deep Synthesis: UX-Verbesserungen (2026-02-21 — nach Meilenstein)

- [ ] **Synthese-Text kopierbar machen**
  - `SelectableText` Widget statt `Text` für Synthese-Paragraphen
  - User können Teile des Textes markieren und kopieren
  - **File:** `apps/glow/lib/src/features/signature/widgets/premium_synthesis_section.dart`
  - **Widget:** `_SynthesisContent` → Paragraphen in `SelectableText` umwandeln

- [ ] **PDF Export für die Synthese**
  - User soll komplette Synthese als PDF exportieren/teilen können
  - **Optionen:**
    - A) `printing` + `pdf` Flutter Package (empfohlen, gut dokumentiert)
    - B) `share_plus` für reinen Text-Share (einfacher, kein PDF)
  - **UX:** Teilen-Button oben rechts in `_SynthesisContent` (neben Debug-Reset)
  - **Format:** NUURAY-styled PDF mit Logo, Archetyp-Titel, Synthese-Text
  - **Hinweis:** Report-System (`GLOW_REPORTS_OTP.md`) plant bereits LuxuryPdfGenerator — Synthese-Export kann darauf aufbauen
  - **Priorität:** Mittlere (nice-to-have vor Launch, kein MVP-Blocker)

- [ ] **Synthese: Cache-Invalidierung bei Profil-Änderung**
  - Wenn User Geburtsdaten ändert (Profile Edit), muss deep_synthesis_text ebenfalls geleert werden
  - Aktuell: Profile Edit löscht `signature_text` und `birth_chart` — aber `deep_synthesis_text` bleibt!
  - **Fix:** In `profile_edit_screen.dart` oder `user_profile_service.dart`: `deep_synthesis_text: null` beim Update mitsetzen
  - **File:** `apps/glow/lib/src/features/profile_edit/screens/profile_edit_screen.dart`

### 💡 Signatur-Check-In (neues Feature — nächste Session)
> **Konzept:** `docs/glow/SIGNATURE_CHECKIN_SPEC.md` — vollständige Spezifikation

Der Check-In verbindet die statische Synthese mit dem dynamischen Jetzt des Users: 3 Taps (Lebenssituation + Gefühl + Bedürfnis) → Claude destilliert aus dem bereits gecachten Synthese-Text eine direkte Antwort für genau diese Situation + 1 konkreten Impuls + sanfter Report-Hinweis.

- [ ] **Schritt 1:** Supabase Migration `signature_checkin_results` Tabelle
- [ ] **Schritt 2:** `CheckinSelection` Model (Enums für 3 Fragen)
- [ ] **Schritt 3:** `SignatureCheckinSection` Widget (3×4 Chip-Auswahl + CTA)
- [ ] **Schritt 4:** `generateCheckinResponse()` in ClaudeApiService
- [ ] **Schritt 5:** `checkinProvider` (FutureProvider.family, Cache-First)
- [ ] **Schritt 6:** `CheckinResultWidget` (Ergebnis + Impuls + Report-Hinweis)
- [ ] **Schritt 7:** Integration in SignatureScreen + i18n
- [ ] **Offen:** Premium-Gating Entscheidung (sofort oder nach Launch?)
- **Kosten:** ~$0.003-0.004 pro Call, gecacht per 64 Kombinationen
- **Zeitaufwand:** ~6-8 Stunden
- **Siehe:** `docs/glow/SIGNATURE_CHECKIN_SPEC.md` für vollständiges Konzept

### 🐉 Bazi UI Verbesserungen (2026-02-21)
- [ ] **Deutsche Element-Namen in Vier Säulen Tabelle**
  - Aktuell: Nur chinesische Namen (Bing, Jia, etc.)
  - Gewünscht: + deutsches Element (z.B. "Bing · Yang-Feuer", "Jia · Yang-Holz")
  - **File:** `apps/glow/lib/src/features/signature/widgets/bazi_section.dart`
- [ ] **Neue Reihenfolge im Bazi Screen:**
  1. Vier Säulen Tabelle (Überblick)
  2. Element-Balance
  3. Day Master (mit Beschreibung)
  4. Bazi-Synthese (neu! Claude API)
  5. Jahr-Säule (expandable)
  6. Monat-Säule (expandable)
  7. Stunden-Säule (expandable)
- [ ] **Bazi-Synthese via Claude API**
  - Kurzer Text (80-120 Wörter) der alle 4 Säulen zusammenfasst
  - Zeigt wie scheinbare Widersprüche zwischen den Säulen zusammenspielen
  - Cached in `birth_charts` Tabelle (wie Archetyp-Signatur)
  - Brand Soul konform (5-Schritt-Bogen, konkret, Schattenseiten)



### 🔴 **KRITISCH: Berechnungs-Validierung aller 3 Systeme** ⚠️
**Priorität: SEHR HOCH** 🚨

Heute (2026-02-11) wurde ein **kritischer Bug im Bazi Calculator** entdeckt und gefixt:
- **Problem:** Julian Day Referenzdatum war falsch (Tag-Säule um 1-2 Tage verschoben)
- **Fix:** Neue empirische Referenz (3. Okt 1983 = Jia-Rat) + Offset-Korrektur
- **Verifiziert:** 30.11.1983 22:32 = Ren-Xu (Yang Water + Dog) ✅

**⚠️ TODO: Alle Berechnungen MÜSSEN jetzt systematisch getestet werden!**

#### 📋 **Test-Plan:**
1. **Western Astrology Calculator:**
   - [ ] Sonnenzeichen: 10-20 bekannte Geburtsdaten testen
   - [ ] Mondzeichen: 5-10 Testfälle mit bekannten Ergebnissen
   - [ ] Aszendent: 5-10 Testfälle (mit Koordinaten!)
   - [ ] Gradzahlen: Stimmen die Degree-Werte?

2. **Bazi Calculator:**
   - [ ] **Day Pillar:** 10-20 bekannte Geburtsdaten mit externen Bazi-Rechnern abgleichen
   - [ ] **Month Pillar:** Solar Terms korrekt? (Monatsgrenzen prüfen!)
   - [ ] **Year Pillar:** Lichun-Grenze korrekt? (Geburt vor/nach 4. Februar)
   - [ ] **Hour Pillar:** 2-Stunden-Blöcke korrekt?
   - [ ] **Element Balance:** Zählung von Stems + Branches korrekt?

3. **Numerology Calculator:**
   - [ ] **Life Path:** 10 bekannte Beispiele testen (inkl. Meisterzahlen 11/22/33)
   - [ ] **Expression/Soul Urge/Personality:** Methode B (Gesamt-Addition) verifizieren
   - [ ] **Display Name Number:** Rufnamen-Berechnung korrekt?
   - [ ] **Karmic Debt:** 13/14/16/19 Detection funktioniert?
   - [ ] **Challenge Numbers:** 4 Phasen korrekt berechnet?
   - [ ] **Karmic Lessons:** Fehlende Zahlen korrekt identifiziert?

#### 🧪 **Test-Dateien erstellen:**
```
packages/nuuray_core/test/
├── western_astrology_calculator_test.dart  ← Unit Tests mit bekannten Daten
├── bazi_calculator_test.dart               ← Unit Tests mit verifizierten Bazi-Charts
└── numerology_calculator_test.dart         ← Unit Tests mit bekannten Numerologie-Profilen
```

#### 📚 **Test-Daten sammeln:**
- Nutze externe Quellen (astro.com, cafeastrology.com für Western)
- Nutze Bazi-Rechner (fourpillars.net, chineseastrology.com)
- Nutze Numerologie-Rechner (tokenrock.com, psychicscience.org)

#### ⚠️ **Warum ist das KRITISCH?**
- **Alle BirthCharts in der DB basieren auf diesen Berechnungen!**
- Wenn ein Calculator falsch ist, sind ALLE User-Daten falsch!
- Neuberechnung = aufwendig + User merken Änderungen
- **Besser JETZT testen, bevor Launch!**

---

### 🔴 **KRITISCH: Testing nach Archetyp-Bugfix** ⚠️
- [ ] **Profile Edit → signature_text bleibt erhalten?**
  - Login → Edit Profile (z.B. Name ändern) → Speichern
  - Erwartung: Archetyp-Titel bleibt gleich
- [ ] **Logout/Login → Archetyp bleibt konstant?**
  - Notiere Archetyp-Titel → Logout → Login
  - Erwartung: Archetyp-Titel ist identisch
- [ ] **Home Screen = Signatur Screen?**
  - Home Screen: Notiere Titel
  - Signatur-Detail-Screen: Notiere Titel
  - Erwartung: Beide Titel sind IDENTISCH
- 📝 **Bugfix:** `user_profile_service.dart` überschrieb `signature_text` mit `null`
- ✅ **Gefixt:** Nur non-null Felder werden in Update-Map gepackt
- 📋 **Siehe:** `docs/daily-logs/2026-02-10_archetyp-signatur-bugfix.md`

### ✅ **Signatur Screen: Archetyp-Header Fix** (2026-02-11)
- ✅ **Problem identifiziert:** Es gibt ZWEI Signature Screens!
  - `signature_dashboard_screen.dart` (alt/ungenutzt?)
  - `signature_screen.dart` (aktiv - **das war das richtige File!**)
- ✅ **Archetyp-Header eingefügt** in `signature_screen.dart`
  - Zeigt nur Titel (keine Synthese, kein Tap-Hint)
  - Nutzt `profile.signatureText` als Datenquelle (identisch mit Home Screen)
- ✅ **`ArchetypeHeader` Widget erweitert:**
  - Parameter `showSynthesis: bool` hinzugefügt (default: true)
  - Home Screen: `showSynthesis: true` (Titel + Synthese + Tap-Hint)
  - Signatur Screen: `showSynthesis: false` (nur Titel)
- ✅ **Provider-Struktur gefixt:** Nested `.when()` für Profile + BirthChart
- 📋 **Siehe:** `docs/daily-logs/2026-02-11_signatur-screen-archetyp-fix.md`
- ⚠️ **TODO:** Klären was mit `signature_dashboard_screen.dart` passieren soll (löschen?)

### 🎨 **CONTENT QUALITY: Brand Soul Compliance**
- [ ] **Content Library Prompt Überarbeitung** (siehe `docs/CONTENT_LIBRARY_PROMPT_ANLEITUNG.md`)
  - [ ] 4 neue kategorie-spezifische Prompts implementieren (sun_sign, moon_sign, bazi_day_master, life_path_number)
  - [ ] Test-Run: 4 Texte generieren (Schütze, Waage-Mond, Yin-Metall, Lebenszahl 8)
  - [ ] Review & 7-Fragen-Check
  - [ ] Volle Generierung: 264 Texte neu generieren
  - [ ] Qualitäts-Stichprobe nach Generierung

- [ ] **🐉 Bazi Day Master Content Library befüllen** (60 Kombinationen)
  - **Problem:** Content Library Tabelle ist leer → Day Master Card zeigt "Lädt Beschreibung..." Fallback
  - **Aktuell:** Keine Einträge in Kategorie `bazi_day_master`
  - **Benötigt:** 60 Beschreibungen (10 Stems × 12 Branches) in DE + EN = **120 Texte**
  - **Optionen:**
    - A) Edge Function mit Claude API Batch-Generierung (empfohlen, folgt Brand Voice)
    - B) Seed-SQL mit Placeholder-Texten (schnell für MVP, aber generisch)
  - **TODO:** Mit Content Library Prompt Überarbeitung zusammen angehen
  - **Siehe:** Bazi Section zeigt korrekte Vier Säulen + Element Balance, nur Day Master Description fehlt

### 🌍 Internationalisierung (i18n)
- [ ] **Englische Content Library generieren** — **254 Texte (EN)** 🌐
  - **Methode:** Claude API mit Brand Soul Prompts (Option A - empfohlen!)
  - **Kosten:** ~$0.76 (einmalige Investition)
  - **Dauer:** ~20 Minuten
  - **Warum Claude statt DeepL:**
    - ✅ Konsistente Brand Voice auch auf Englisch
    - ✅ Kulturell angepasste Texte (nicht 1:1 Übersetzung)
    - ✅ Gleiche Qualität wie Deutsche Texte
    - ❌ DeepL = maschinell, verliert Brand Soul
  - **Script:** `dart scripts/seed_content_library.dart --locale=en`
  - **Kategorien (17):** Sun/Moon/Rising Signs, Bazi Day Masters, Life Path, Expression, Soul Urge, Personality, Birthday, Attitude, Personal Year, Maturity, Display Name, Karmic Debt, Challenges, Karmic Lessons, Bridges
  - **Status:** 0/254 Texte (0%) — Auf Backlog, nach MVP-Launch
  - **Siehe:** `docs/daily-logs/2026-02-12_session-zusammenfassung.md` (Session 4)

### 🔧 Bugfixes & Verbesserungen
- [x] **Code Quality: Null-Safety Cleanup** ✅ **ERLEDIGT 2026-02-12**
  - [x] `language_provider.dart`: Redundanten `profile.language != null` Check entfernt
  - [x] `language_provider.dart`: Unnötiges `!` bei `profile.language!.toLowerCase()` entfernt
  - [x] **Alle 43 `AppLocalizations.of(context)!` → `AppLocalizations.of(context)` gefixt**
  - [x] `daily_horoscope_service.dart`: 3× `_claudeService!.` → `_claudeService.` gefixt
  - [x] `numerology_card.dart`: `currentName!` → `currentName` (flow-analysis safe)
  - [x] Backup-File gelöscht: `onboarding_birthdata_combined_screen_backup.dart`
  - **Ergebnis:** 0 `unnecessary_non_null_assertion` Warnings (von 43+) 🎯
  - **Flutter Analyze:** Nur noch harmlose Warnings (unused imports, deprecated methods)

- [x] **Signatur Screen Cleanup:** ✅ **ERLEDIGT 2026-02-12**
  - [x] Geprüft: `signature_dashboard_screen.dart` wird NICHT verwendet
  - [x] File gelöscht (war veraltet, nur `signature_screen.dart` ist aktiv)
  - [x] Routing bestätigt: `signature_screen.dart` ist im Router registriert

- [ ] **Gender Migration deployen:**
  ```sql
  -- In Supabase Dashboard SQL Editor ausführen:
  ALTER TABLE profiles ADD COLUMN gender TEXT CHECK (gender IN ('female', 'male', 'diverse', 'prefer_not_to_say'));
  CREATE INDEX idx_profiles_gender ON profiles(gender);
  ```
- [ ] **Bazi Debug:** Warum lädt Beschreibung nicht?
  - User-Profil prüfen: Welcher Wert in `baziElement`?
  - Content Library prüfen: Existiert Eintrag für diesen Key?
  - FutureBuilder Debug: Supabase Query-Fehler?
- [ ] **Numerologie Section vervollständigen:**
  - Fehlende Zahlen: Birthday, Attitude, Maturity, Personal Year
  - Birth Energy (expandable): birthExpressionNumber, birthSoulUrgeNumber, birthPersonalityNumber
  - Current Energy (expandable): currentExpressionNumber, currentSoulUrgeNumber, currentPersonalityNumber
  - Erweiterte Numerologie: Karmic Debt, Challenge Numbers, Karmic Lessons, Bridge Numbers
  - Content Library Seeds für fehlende Kategorien generieren
- [ ] **Content Review + Neu-Generierung:**
  - Seed-Prompts mit `{gender}` Variable erweitern
  - Bessere Prompts: Konkreter, emotionaler, überraschender (weniger Plattitüden)
  - Content Library komplett neu generieren (~$0.50 Kosten)
- [ ] **Bazi Vier Säulen** (großes Feature - später):
  - Bazi Calculator erweitern (Year, Month, Day, Hour Pillar)
  - Tabellen-UI für alle 4 Säulen
  - Content Library für Säulen-Kombinationen

### 📚 Dokumentation & Konzept-Updates
- [x] **Onboarding-Anpassung:** ✅ **FERTIG 2026-02-08!**
  - Code auf 2 Schritte umgestellt (Name → Geburtsdaten kombiniert)
  - Name-Felder: **4 Felder bleiben** (displayName, fullFirstNames, birthName, lastName)
  - LIVE-Autocomplete für Geburtsort implementiert
  - **UX-Fixes:** Bottom Overflow + Autocomplete behält Eingabe ✅
  - Siehe: `docs/daily-logs/2026-02-08_onboarding-2-schritte.md`
  - Siehe: `docs/daily-logs/2026-02-08_ux-fixes.md`
- [x] **"Deine Signatur" Umbenennung:** ✅ **KOMPLETT FERTIG 2026-02-08!**
  - [x] Code-Suche: `Cosmic Profile` → `Deine Signatur` (Code + UI) ✅
  - [x] Provider: `cosmicProfileProvider` → `signatureProvider` ✅
  - [x] Folder: `cosmic_profile/` → `signature/` ✅
  - [x] Screen: `CosmicProfileDashboardScreen` → `SignatureDashboardScreen` ✅
  - [x] Card-Design vereinheitlicht (alle Gradients entfernt, AppColors verwendet) ✅
  - [x] Service: `CosmicProfileService` → `SignatureService` ✅ **FERTIG!**
  - [x] ClaudeApiService Prompts: "Cosmic Profile" → "Deine Signatur" ✅ **FERTIG!**
  - [x] Test-Datei umbenannt: `cosmic_profile_test.dart` → `signature_test.dart` ✅ **FERTIG!**
  - [ ] Datenbank-Tabelle: `birth_charts` → `signature_profiles` ❌ **OPTIONAL** (nicht kritisch)
- [x] **i18n-Strategie umsetzen:** ✅ **100% KOMPLETT (2026-02-08 Abend)!**
  - [x] ARB-Dateien erstellt (`app_de.arb`, `app_en.arb`) — **260+ Strings!**
  - [x] l10n.yaml Konfiguration
  - [x] Localizations generiert (`flutter gen-l10n`)
  - [x] MaterialApp mit AppLocalizations konfiguriert
  - [x] LanguageProvider (Riverpod) erstellt
  - [x] Settings Screen mit Sprach-Switcher (🇩🇪 / 🇬🇧)
  - [x] Profile-Tabelle: `language` Spalte hinzugefügt (Migration 004) ✅
  - [x] UserProfileService: `updateLanguage()` implementiert ✅
  - [x] **ALLE Screens 100% lokalisiert:** ✅
    - [x] Login, Signup, Settings, Home, Onboarding ✅
    - [x] Daily Horoscope Section (Tageshoroskop + Personal Insights) ✅
    - [x] **Signature Cards (Deine Signatur):** ✅
      - [x] Western Astrology Card: "Mehr erfahren" + Aszendent-Placeholder ✅
      - [x] Bazi Card: "Mehr erfahren" + Elemente (Holz, Feuer, ...) + Branches (Ratte, Schwein, ...) ✅
      - [x] Numerology Card: "Mehr erfahren" + alle Labels + erweiterte Numerologie ✅
  - [ ] **OFFEN:** Tageshoroskop-Text aus API auf Englisch (on-demand, später)

### 🎯 SOFORT (Testing & Deployment)
- [x] **Anthropic API Key:** ✅ **GETESTET 2026-02-08!**
  - Key in `.env` vorhanden
  - Tests erfolgreich: Tageshoroskop + Cosmic Profile
  - Kosten: ~$0.02 pro Horoskop (sehr günstig!)
- [x] **Onboarding testen:** ✅ **App läuft!**
  - 2-Schritte Flow funktioniert
  - Autocomplete funktioniert
  - Name-Felder (3) funktionieren
- [x] **Supabase Migration deployen:** ✅ **DEPLOYED 2026-02-08!**
  - Migration `20260207_add_daily_horoscopes.sql` ist deployed
  - Tabelle `daily_horoscopes` existiert mit Beispiel-Daten
  - Verifiziert via Supabase Dashboard (2 Testeinträge: Aries + Cancer)
  - **Migration `006_add_display_name_number.sql` deployed** ✅ **2026-02-08 Spätabend!**
- [x] **Edge Function erstellen:** ✅ **FERTIG 2026-02-08!**
  - `supabase/functions/generate-daily-horoscopes/index.ts` erstellt
  - **WICHTIG:** Phase 2 Code (NICHT deployed, nur vorbereitet für später!)
  - Generiert nur benötigte Horoskope (user-spezifisch nach Sprache)
  - Kosten (wenn aktiviert): ~$0.50/Tag = ~$15/Monat
  - Siehe: `docs/deployment/HOROSCOPE_STRATEGY.md`
- [x] **Tageshoroskop-Strategie:** ✅ **PHASE 1 AKTIV!**
  - **Aktiv:** On-Demand Generation (DailyHoroscopeService)
  - **Inaktiv:** Edge Function + Cron Job (vorbereitet für Phase 2)
  - **Cleanup:** Supabase Cron Job gelöscht, Edge Function nicht deployed
  - Siehe: `docs/deployment/HOROSCOPE_STRATEGY.md` (Cleanup-Section)

## ⏳ NÄCHSTE SCHRITTE (VORHER)

### 🐛 BUGS ZU FIXEN
**PRIORITÄT 1:**
- [x] **Numerologie-Berechnung reparieren** ✅ **GELÖST 2026-02-08!**
  - **Problem:** Name-Felder waren verwirrend (3 Felder mit unklarer Zuordnung)
  - **Fix implementiert:**
    1. ✅ Onboarding Name-Screen: REVERT zu 4 Feldern (displayName, fullFirstNames, birthName, lastName)
    2. ✅ `UserProfile` Model komplett aktualisiert (alle neuen Onboarding-Felder)
    3. ✅ Numerologie massiv erweitert (4 neue Feature-Bereiche: Karmic Debt, Challenges, Lessons, Bridges)
    4. ✅ Migration bereits vorhanden (`002_add_onboarding_fields.sql`)
    5. ✅ **UI erweitert:** Numerologie-Card zeigt jetzt alle erweiterten Features
  - **Status**: ✅ Produktionsreif! (UI komplett)

- [x] **Aszendent-Berechnung prüfen** ✅ **GELÖST!**
  - Problem identifiziert: UTC-Konvertierung in `_calculateJulianDay()`
  - Fix implementiert: Lokale Zeit ohne UTC-Konvertierung verwenden
  - Ergebnis: Rakim Günes Aszendent = Krebs ✅ (100% korrekt)
  - Verifikation: Test mit 4 Geburtsdaten → Sonnenzeichen 100%, Mondzeichen 100%, Aszendent funktioniert
  - Code ist mathematisch korrekt nach Meeus "Astronomical Algorithms"
  - **Status**: ✅ Produktionsreif!

- [x] **Tageshoroskop zeigt falsches Sternzeichen** ✅ **GELÖST!**
  - Problem: Home Screen zeigte hardcoded "Schütze"-Horoskop
  - Fix implementiert: `cosmicProfileProvider` wird jetzt verwendet
  - Zeigt User-Sternzeichen (Sonnenzeichen) aus Cosmic Profile
  - File: `apps/glow/lib/src/features/home/screens/home_screen.dart`
  - Loading/Error States hinzugefügt
  - **Status**: ✅ Produktionsreif!

### 🧪 TESTING
**Status:** Code ist fertig, aber **noch nicht visuell getestet**

**Was muss getestet werden:**
- [ ] App starten und durch Home Screen navigieren
- [ ] **"Deine Signatur" Dashboard visuell prüfen (alle 3 Cards)**
- [ ] **Numerologie: Erweiterte Features visuell prüfen:**
  - [ ] **Display Name Number (Rufname) sichtbar unter Life Path** ✅ **IMPLEMENTIERT!**
  - [ ] Karmic Debt Numbers sichtbar (⚡)
  - [ ] Challenge Numbers als 4 Chips (🎯), Challenge 0 grün
  - [ ] Karmic Lessons als Warning-Badges (📚)
  - [ ] Bridge Numbers mit Erklärungen (🌉)
  - [ ] Soul Urge = 33 verifizieren (Meisterzahl ✨)
- [ ] Neues Onboarding mit 4 Name-Feldern durchspielen
- [ ] Geocoding Autocomplete testen (✅ Funktioniert grundsätzlich!)
- [ ] Aszendent-Berechnung verifizieren (✅ Code korrekt!)
- [ ] **Web Platform testen:** Chrome/Web Login + Profil-Load ✅ **FUNKTIONIERT!**

---

## ✅ IMPLEMENTIERT (Code fertig, Testing ausstehend)

### Cosmic Profile Dashboard
**Status:** ✅ CODE KOMPLETT (Stand: 2025-02-06), ⏳ Testing morgen

**Komponenten:**
1. **Datenmodell** (nuuray_core)
   - ✅ BirthChart Model (Equatable) mit drei Subsystemen
   - ✅ WesternAstrology Felder (sunSign, moonSign, ascendantSign mit Graden)
   - ✅ Bazi Felder (Vier Säulen: Year/Month/Day/Hour Stem+Branch, Day Master, Element)
   - ✅ NumerologyProfile Model (Life Path, Birthday, Attitude, Personal Year, Maturity)
   - ✅ Birth Energy + Current Energy (Dual-Profil für Namenswechsel)
   - ✅ Enums: ZodiacSign (mit Symbolen + i18n), BaziElement, Stems, Branches

2. **Calculator Services** (nuuray_core)
   - ✅ WesternAstrologyCalculator
     - ✅ Sonnenzeichen aus Geburtsdatum (VSOP87 Präzision)
     - ✅ Mondzeichen aus Geburtsdatum + Zeit (ELP2000 Algorithmus)
     - ✅ Aszendent aus Geburtsdatum + Zeit + Koordinaten (Meeus Algorithmus)
   - ✅ BaziCalculator
     - ✅ Vier Säulen (Jahr, Monat, Tag, Stunde) mit Solar Terms
     - ✅ Day Master identifizieren
     - ✅ Dominantes Element berechnen
     - ✅ Chinesischer Kalender korrekt (Lichun-Grenze, Hsia Calendar)
   - ✅ NumerologyCalculator
     - ✅ Life Path Number (Meisterzahlen 11, 22, 33)
     - ✅ Birthday, Attitude, Personal Year, Maturity Numbers
     - ✅ Expression Number aus vollständigem Namen (Methode B: Gesamt-Addition)
     - ✅ Soul Urge Number aus Vokalen (Methode B: Meisterzahlen-erhaltend!)
     - ✅ Personality Number aus Konsonanten (Methode B)
     - ✅ Dual-Profil: Birth Energy (Geburtsname) + Current Energy (aktueller Name)
     - ✅ Umlaut-Normalisierung (Ü→UE für deutsche Namen)

3. **Supabase**
   - ✅ Migration 004: birth_chart Tabelle erstellt (JSONB für alle drei Systeme)
   - ✅ RLS Policies (User sieht nur eigenes Chart)
   - ✅ CosmicProfileService (CRUD + Cache-Logik)
   - ✅ BirthChartService (berechnet + speichert Chart aus UserProfile)

4. **UI Widgets** (apps/glow)
   - ✅ Inline Dashboard auf Home Screen (kein separater Screen)
   - ✅ WesternAstrologyCard Widget
     - ✅ Gradient: Gold/Orange
     - ✅ Sonne/Mond/Aszendent mit Symbolen + Graden
     - ✅ Placeholder für fehlenden Aszendent (Koordinaten erforderlich)
     - ✅ "Mehr erfahren" Button (TODO: Navigation)
   - ✅ BaziCard Widget
     - ✅ Gradient: Rot/Braun
     - ✅ Vier Säulen Visualisierung (Jahr/Monat/Tag/Stunde)
     - ✅ Day Master prominent (Stem-Branch Kombination)
     - ✅ Element Badge mit Emoji
     - ✅ "Mehr erfahren" Button (TODO: Navigation)
   - ✅ NumerologyCard Widget
     - ✅ Gradient: Lila/Pink
     - ✅ Life Path Number prominent (großer Kreis)
     - ✅ Kleine Zahlen: Birthday, Attitude, Personal Year, Maturity
     - ✅ Expandable Sections: Birth Energy (Urenergie) + Current Energy
     - ✅ Master Numbers mit ✨ Highlight
     - ✅ "Mehr erfahren" Button (TODO: Navigation)

5. **i18n** ✅ **100% KOMPLETT (2026-02-08 Abend)**
   - ✅ **Flutter i18n Setup** (flutter_localizations + ARB-Dateien)
   - ✅ **ARB-Dateien** (`app_de.arb` + `app_en.arb`) mit 260+ Strings
   - ✅ **ALLE Screens 100% lokalisiert:**
     - ✅ Login, Signup, Home, Onboarding, Settings
     - ✅ Daily Horoscope Section (Tageshoroskop + Sternzeichen-Namen + Personal Insights)
     - ✅ **Signature Cards vollständig:**
       - ✅ Western Astrology: "Mehr erfahren" Button + Aszendent-Placeholder
       - ✅ Bazi: "Mehr erfahren" Button + Elemente (Holz/Wood, Feuer/Fire, ...) + Branches (Ratte/Rat, Schwein/Pig, ...)
       - ✅ Numerology: "Mehr erfahren" Button + Subtitle + Labels + Life Path Meanings + Karmic Debt + Challenges + Lessons + Bridges
   - ✅ **Language Provider** (Riverpod StateNotifier + Supabase Sync)
   - ✅ **Settings Screen** mit visuellem Sprachenwähler (DE 🇩🇪 / EN 🇬🇧)
   - ✅ **UserProfile.language** Feld + Migration 004 + `updateLanguage()` Service
   - ✅ **Dynamic Locale** (lädt Sprache aus User-Profil, speichert Änderungen in DB)
   - ✅ Sternzeichen-Namen (DE/EN: nameDe/nameEn Property in ZodiacSign)
   - ✅ Bazi-Elemente übersetzt (Holz, Feuer, Erde, Metall, Wasser)
   - ✅ Branches übersetzt (Ratte, Büffel, Tiger, etc.)
   - ⏳ Stems: Bleiben in Pinyin (Jia, Yi, etc.) — kulturell korrekt
   - ⏳ **API-Content:** Tageshoroskop-Text bleibt gecacht (on-demand, später)
   - 📝 **Weitere Sprachen (Backlog):** ES (Spanisch), FR (Französisch), TR (Türkisch)
     - Strategie: Nach MVP-Launch mit DeepL API automatisiert übersetzen
     - Einfach: Neue ARB-Datei + 2 Zeilen in LanguageProvider

6. **Integration**
   - ✅ Provider: cosmicProfileProvider (cached BirthChart)
   - ✅ Home Screen: Cosmic Profile Dashboard inline integriert
   - ✅ Loading/Error/Empty States
   - ⏳ Onboarding: Chart-Berechnung nach Abschluss (TODO)

---

---

## 📋 BACKLOG (Nach Testing)

### Signature Screen: UI-Verbesserungen
- [ ] **Kurze Beschreibungen unter Titeln hinzufügen** (wie bei Numerologie)
  - Western Astrology: Sonne/Mond/Aszendent mit Subtitle (z.B. "Dein grundlegendes Wesen")
  - Bazi: Day Master mit Subtitle (z.B. "Deine energetische Konstitution")
  - Aktuell: Nur Numerologie hat Subtitles ("Dein grundlegender Lebensweg" etc.)
  - Siehe: Numerologie Cards als Referenz

- [ ] **Challenges: Zeige aktuelle Phase des Users**
  - Berechne aktuelle Phase basierend auf Alter (welche der 4 Challenges)
  - Visueller Indicator: Highlight + "Aktuelle Phase" Badge
  - Phase 1: 0 bis ca. 28 Jahre
  - Phase 2: 28 bis ca. 56 Jahre
  - Phase 3: Mittleres Alter
  - Phase 4: Reifes Alter / Später im Leben

### Dokumentation
- ✅ **Karmic Debt Berechnung dokumentiert** — `docs/glow/KARMIC_DEBT_CALCULATION.md`
  - Konzept: Versteckte Zahlen in Zwischensummen (13, 14, 16, 19)
  - Berechnung: Life Path, Expression, Soul Urge
  - Bedeutung aller 4 Schuldzahlen
  - Code-Referenz: `numerology_calculator.dart` (Zeilen 225-330)

- ✅ **Karmic Debt für Namen integriert** — `docs/daily-logs/2026-02-12_karmic-debt-name-integration.md` ⚡
  - UI: Expression + Soul Urge Karmic Debt in Birth/Current Energy Sections
  - Design: Amber Badges mit ⚡ Icon + Content Library Integration
  - Thematisch korrekt: Namen-Karmic-Debt bei Namen-Energien (nicht separate Cards)
  - Beispiel: "Natalie Frauke Pawlowski" → Expression 19/1 (Machtmissbrauch → Geben lernen)
  - Status: ✅ Implementiert, ready to test!

### Cosmic Profile: Verbesserungen
- [ ] **Detail-Ansichten** für jedes System (klickbar auf "Mehr erfahren")
  - Western Astrology: Alle Planeten + Häuser (Premium)
  - Bazi: Luck Pillars, Hidden Stems, Element Balance Chart (Premium)
  - Numerology: Alle 30+ Zahlen + Lebensphasen (Premium)
- [ ] **Premium-Gating** für erweiterte Berechnungen
- [ ] **Supabase Migration:** Neue Spalten für erweiterte Daten

### i18n & Mehrsprachigkeit
- ✅ **Basis-Setup komplett:** DE + EN (300+ Strings in ARB-Dateien)
- ✅ **Alle Screens migriert:** Login, Signup, Home, Onboarding, Settings, Signature Cards
- ✅ **Settings Screen** mit visuellem Sprachenwähler (DE 🇩🇪 / EN 🇬🇧)
- ✅ **Language Provider** mit Supabase-Sync (speichert Auswahl in DB)
- ✅ **UserProfile.language** Feld hinzugefügt
- 📋 **Weitere Sprachen (Backlog - nach MVP):**
  - [ ] Spanisch (ES) - mit DeepL API automatisiert
  - [ ] Französisch (FR) - mit DeepL API automatisiert
  - [ ] Türkisch (TR) - mit DeepL API automatisiert
  - **Strategie:** Nach MVP-Launch, wenn UI-Texte stabil sind
  - **Aufwand:** ~2-3h manuell mit DeepL oder 10min mit DeepL API
  - **Einfach:** Neue `app_XX.arb` kopieren + 2 Zeilen in `LanguageProvider`

### Geburtsdaten-Engine vervollständigen
- [x] Mondzeichen-Berechnung (✅ ELP2000 Algorithmus implementiert)
- [x] Aszendent-Berechnung (✅ Meeus Algorithmus, aber Koordinaten fehlen)
- [x] Bazi: Stundensäule (✅ implementiert, aber nur mit Geburtszeit)
- [ ] **Tests für alle Berechnungen** (kritisch für Genauigkeit!)
  - [ ] Western Astrology: Test Cases für bekannte Geburtsdaten
  - [ ] Bazi: Solar Terms Grenzen prüfen
  - [ ] Numerology: Meisterzahlen-Fälle testen

### Geburtsort Geocoding
- [x] **Google Places API Integration** ✅ ✅ ✅ (FUNKTIONIERT!)
  - [x] Edge Function `/geocode-place` deployed mit `--no-verify-jwt` Flag
  - [x] Supabase Edge Function akzeptiert Requests ohne User-JWT
  - [x] Flutter-Code nutzt globalen Supabase-Client (authentifiziert)
  - [x] Google Cloud: 4 APIs aktiviert (Places, Autocomplete, Details, Timezone)
  - [x] API Key als Secret in Supabase hinterlegt
  - [x] **ERFOLGREICH GETESTET:** "Ravensburg" findet Stadt + Koordinaten + Timezone ✅
- [x] **Autocomplete-UI mit Debouncing** ✅
  - [x] Suche startet nach 3+ Zeichen + 800ms Delay
  - [x] Loading-Indicator während Suche
  - [x] Grüne Success-Box mit Koordinaten + Timezone
  - [x] Fehlerbehandlung mit hilfreichen Meldungen
- [x] **Latitude/Longitude in Onboarding speichern** ✅ (birth_latitude, birth_longitude, birth_timezone)
- [x] Timezone-Berechnung aus Geburtsort ✅ (Google Timezone API)
- [x] Chart neu berechnen (Aszendent + präzise Bazi-Stunde) - Automatisch beim Profil-Load ✅
- [ ] **⚠️ MORGEN:** Aszendent-Berechnung debuggen (zeigt Zwillinge statt Krebs)

### Tageshoroskop
- [ ] daily_content Tabelle (Supabase)
  - Spalten: date, zodiac_sign, language, content_text, moon_phase
- [ ] Claude API Prompt-Templates
  - Basis-Horoskop pro Sternzeichen + Mondphase
  - Personalisierungs-Layer (Mondzeichen, Bazi-Bezug)
- [ ] Edge Function: generate-daily-horoscopes (Cron Job 4:00 UTC)
- [ ] TageshoroskopScreen mit gecachtem Content
- [ ] Premium: Personalisierte Variante

### Mondphasen
- [ ] Mondphasen-Berechnung (Bibliothek oder API)
- [ ] Mondphasen-Kalender Screen
- [ ] Mondphasen-Widget für Home Screen (aktuell Placeholder)

### Premium-Features
- [ ] Premium-Gating Logic (Riverpod Provider für Subscription-Status)
- [ ] In-App Purchase Setup
  - Apple StoreKit Configuration
  - Google Play Billing Configuration
  - RevenueCat evaluieren
- [ ] subscriptions Tabelle (Supabase)
- [ ] Wochen-Horoskop (Premium)
- [ ] Monats-Horoskop (Premium)
- [ ] Detailansichten für Cosmic Profile (Premium)

### 📊 Reports & OTPs (One-Time Purchases)

> **Dokumentation:** Siehe `docs/glow/GLOW_REPORTS_OTP.md` 📄
> **Code-Basis:** `/altesProjektBeyondHoroscope/` (Models, PDF-Generator, Theme)
> **Status:** 🎨 UI Foundation ✅ — Backend/Funktionalität kommt NACH MVP-Launch
> **Preisstrategie:** Einmalige Käufe (€4,99 - €9,99), nicht im Abo enthalten

**✅ UI Foundation (2026-02-12):**
- ✅ **Bottom Nav:** Insights-Tab zwischen Signatur & Mond
- ✅ **Insights Screen:** Alle 10 Reports mit Kategorien, Preisen, Icons
- ✅ **Settings:** "Meine Reports" + "Premium" Section (Platzhalter)
- ✅ **Dokumentation:** `docs/daily-logs/2026-02-12_reports-ui-foundation.md`

**Phase 1: MVP Report (SoulMate Finder / Partner-Check) — NACH Glow Launch**
- [ ] **Report-System Foundation**
  - [ ] `StructuredReport` Model in `nuuray_core` portieren
  - [ ] `LuxuryPdfGenerator` in `nuuray_api` integrieren
  - [ ] Fonts (Noto Sans, Nunito) zu assets hinzufügen
  - [ ] PDF-Sharing (Web: Download, Native: Share Sheet)

- [ ] **SoulMate Finder / Partner-Check Report** (€4,99)
  - [ ] UI: Partner-Daten-Eingabe-Screen (2 Geburtsdaten)
  - [ ] Compatibility Score Berechnung:
    - Western Astrology: Synastrie-Aspekte
    - Bazi: Element-Harmonie
    - Numerologie: Life Path Kompatibilität
  - [ ] Claude API Prompt: Partner-Check (Brand Voice-kompatibel)
  - [ ] Report-Preview-Screen (Teaser + Sample-Seiten)
  - [ ] In-App Purchase: SoulMate Finder Produkt (€4,99)
  - [ ] Report-Viewer-Screen (PDF in-app + Download + Share)
  - [ ] Report-Bibliothek: "Meine Reports" (gekaufte Reports)

**Phase 2: Core Reports (nach SoulMate Finder)**
- [ ] **Soul Purpose Report** (€7,99)
  - Seelenmission, Nordknoten, Life Path Number
- [ ] **Yearly Forecast Report** (€9,99)
  - Persönliches Jahr, Solar Return, Transite

**Phase 3: Expansion Reports (später)**
- [ ] **Shadow & Light Report** (€7,99) — Pluto, Lilith, Schatten-Integration
- [ ] **The Purpose Path Report** (€6,99) — MC (Berufung), Expression Number
- [ ] **Body Vitality Report** (€5,99) — 6. Haus, Saturn, Gesundheit

**UI/UX: Wo leben Reports?**
- [ ] Bottom Navigation: Neuer Tab "Explore" (Report-Katalog)
- [ ] Home Screen: "Empfohlene Reports" Section
- [ ] Profil: "Meine Reports" (Bibliothek gekaufter Reports)

**Content-Vorbereitung:**
- [ ] Partner-Check Prompt (Brand Voice, siehe `NUURAY_BRAND_SOUL.md`)
- [ ] Soul Purpose Prompt
- [ ] Yearly Forecast Prompt
- [ ] Test-Generierungen (5-10 Reports manuell reviewen)

---

### Push-Notifications
- [ ] Firebase Cloud Messaging Setup
- [ ] Notification Permissions
- [ ] Tägliches Horoskop Push (morgens)
- [ ] Mondphasen-Alerts (optional)

### Polishing
- [ ] Loading States (Skeletons statt Spinner)
- [ ] Error States mit Retry
- [ ] Leere Zustände gestalten
- [ ] Offline-Caching (drift für lokale DB)
- [ ] Accessibility (Semantics, Kontraste, Touch-Targets)
- [ ] Performance-Optimierung

---

---

## ℹ️ HINWEISE FÜR MORGEN

### Aszendent-Problem beheben (Alternative)
Wenn Geocoding morgen nicht funktioniert, **Profil manuell updaten**:
1. Gehe zu: https://supabase.com/dashboard/project/ykkayjbplutdodummcte/editor
2. Tabelle: `profiles`
3. User: natalie.guenes.tr@gmail.com
4. Setze:
   - `birth_latitude`: 47.6546609
   - `birth_longitude`: 9.4798766
   - `birth_timezone`: Europe/Berlin
5. Chart wird automatisch neu berechnet beim nächsten App-Start

### Google Places Testing
- Google API Aktivierung kann 5-10 Min dauern
- App Hot Restart nötig: `R` in Terminal
- Mit eingelogtem User testen

---

## 🐛 BEKANNTE PROBLEME

### macOS Testing
- **Problem:** "Connection failed (OS Error: Operation not permitted)" bei macOS Runner
- **Ursache:** Wahrscheinlich Firewall/Network Permission Issue
- **Workaround:** Testing in Chrome Web funktioniert
- **TODO:** macOS Entitlements prüfen für Release

---

## 📋 BACKLOG (Später)

### Auth Erweiterungen
- [ ] Apple Sign-In Integration
- [ ] Google Sign-In Integration
- [ ] Email-Verifizierung
- [ ] Account-Löschung (GDPR/KVKK Compliance)

### Shared Packages
- [ ] nuuray_core Package erstellen (Models, Berechnungen)
- [ ] nuuray_api Package erstellen (Supabase, Claude API)
- [ ] nuuray_ui Package erstellen (Theme, Widgets, i18n)
- [ ] Packages in apps/glow integrieren

### Tide App (Phase 3)
- [ ] Zyklustracking Features
- [ ] Mondphasen-Overlay
- [ ] Stimmungsprognose

### Path App (Phase 4)
- [ ] Coaching-Journey
- [ ] Journaling
- [ ] Fortschritts-Tracking

---

## 🔍 TECHNISCHE NOTIZEN

### Supabase
- **URL:** https://ykkayjbplutdodummcte.supabase.co
- **Publishable Key:** sb_publishable_kcM8qKBrYN2xqOrevEHQGA_DdtvgmBb
- **Region:** EU (für GDPR Compliance bevorzugt)
- **RLS:** Aktiviert auf allen Tabellen

### Google Cloud
- **Places API Key:** AIzaSyBG207MVH8bkIjk_zNAKplAaB1H45HjndM
- **APIs aktiviert:** Places API (old) + Places API (New)

### User für Testing
- **Email:** natalie.guenes.tr@gmail.com
- **Passwort:** test123
- **Profil:** Vollständig angelegt (Name, Geburtsdatum/-zeit/-ort, Onboarding abgeschlossen)

### Projekt-Ordner
- **Pfad:** `/Users/natalieg/nuuray-project/`
- **Struktur:**
  - `apps/glow/` — Flutter App (aktuell)
  - `apps/tide/` — Flutter App (geplant)
  - `apps/path/` — Flutter App (geplant)
  - `packages/` — Shared Packages (geplant)
  - `supabase/` — Migrations, Edge Functions
  - `docs/` — Dokumentation

---

## 💡 ENTSCHEIDUNGEN & LEARNINGS

### Numerologie Berechnungs-Methode
- **Problem:** Zwei valide Methoden für Name-basierte Zahlen (Expression, Soul Urge, Personality)
  - **Methode A:** Pro Namensteil reduzieren, dann summieren (z.B. "Natalie Günes" → 7+8 = 15 → 6)
  - **Methode B:** Alle Buchstaben summieren, dann EINMAL reduzieren (z.B. → 16+8 = 24 → 6)
- **Entscheidung:** **Methode B** implementiert
- **Grund:** Erhält Meisterzahlen (11, 22, 33) in der Gesamtenergie besser
- **Beispiel:** "Natalie Frauke Günes" Soul Urge = **33** ✨ (statt 2 bei Methode A)
- **Learning:** Spirituelle Bedeutung von Meisterzahlen ist wichtiger als Namensteil-Reduktion

### Google Places API
- **Entscheidung:** Text-Input für MVP statt sofortige Places-Integration
- **Grund:** API-Integration war fehleranfällig, blockierte Fortschritt
- **Nächster Schritt:** Server-seitige Geocoding später evaluieren

### Profile-Speicherung
- **Problem:** Auth-Trigger erstellt leeres Profil, Onboarding versuchte INSERT
- **Lösung:** Upsert-Logik (prüfe ob Profil existiert, dann UPDATE statt INSERT)
- **Learning:** Auth-Trigger + manuelle Profile-Erstellung brauchen Koordination

### Namens-Felder
- **Entscheidung:** Vier separate Name-Felder (displayName, fullFirstNames, lastName, birthName)
- **Grund:** Numerologie braucht vollständigen Namen, User nutzt aber Rufnamen
- **UX:** Rufname ist Pflicht, Rest optional mit Hinweis auf Genauigkeit

### Geburtszeit Optional
- **Entscheidung:** Geburtszeit optional, `hasBirthTime` Flag
- **Grund:** Nicht jeder kennt Geburtszeit, Aszendent + Bazi-Stunde dann null
- **UX:** Nutzer kann später ergänzen, Profil neu berechnen

---

## 📅 CHANGELOG — Letzte Sessions

### Session 2026-02-06 (Nachmittag) — Numerologie Methode B
**Was wurde gemacht:**
- ✅ Numerologie-Berechnung auf **Methode B** umgestellt (Gesamt-Addition statt per-Teil)
- ✅ Soul Urge für "Natalie Frauke Günes": **33** ✨ (statt 2)
- ✅ Alle UI-Labels auf Deutsch übersetzt
- ✅ TODO.md komplett aktualisiert mit Status aller Features

**Ergebnis:** Meisterzahlen werden jetzt spirituell korrekt berechnet!

### Session 2026-02-06 (Vormittag + Spätabend) — Google Places Integration
**Was wurde gemacht:**
- ✅ Supabase Edge Function `/geocode-place` implementiert & deployed
- ✅ JWT-Problem gelöst: `--no-verify-jwt` Flag beim Deployment
- ✅ Flutter-Code angepasst: Globaler Supabase-Client statt direkter HTTP-Calls
- ✅ Autocomplete-UI mit Debouncing (800ms, 3+ Zeichen)
- ✅ Google Cloud: 4 APIs aktiviert (Places Autocomplete, Place Details, Geocoding, Timezone)
- ✅ Vollständige Dokumentation + Deploy-Scripts
- ✅ **ERFOLGREICH GETESTET:** "Ravensburg" → Koordinaten + Timezone ✅

**Technische Learnings:**
- Supabase Edge Functions verlangen standardmäßig JWT-Validierung
- `--no-verify-jwt` Flag deaktiviert JWT-Check (für Onboarding vor Login)
- CORS-Problem beim direkten Google Places API Call vom Browser
- Lösung: Edge Function als Proxy, authentifizierter Supabase-Client

**Status:** ✅ 100% FUNKTIONIERT! (Aber: Aszendent-Berechnung noch zu prüfen)

### Session 2026-02-05 — Cosmic Profile Dashboard
**Was wurde gemacht:**
- ✅ Western Astrology Calculator (VSOP87, ELP2000, Meeus)
- ✅ Bazi Calculator (Solar Terms, Hsia Calendar)
- ✅ Numerology Calculator (9 Kern-Zahlen, Dual-Profil)
- ✅ Drei Dashboard-Cards mit Gradients & expandable Sections
- ✅ BirthChart Model & Service
- ✅ Supabase Migration 004

**Ergebnis:** Vollständiges Cosmic Profile auf Home Screen!

---

---

**Nächster Fokus (JETZT):**
1. 🧪 **Testing:** App starten und "Deine Signatur" Dashboard visuell prüfen
   - Erweiterte Numerologie-Card testen (⚡🎯📚🌉)
   - Soul Urge = 33 verifizieren (Meisterzahl)
   - Challenge 0 grüne Hervorhebung prüfen
2. 📸 **Screenshots:** Dashboard dokumentieren
3. 📝 **Dokumentation finalisieren:**
   - GLOW_SPEC_V2.md anpassen (Name-Felder: 4 statt 3)
   - Session-Log verifizieren
4. 🎯 **Dann:** Tageshoroskop mit Claude API implementieren

---

### Session 2026-02-08 (Abend) — Erweiterte Numerologie UI

**Was wurde gemacht:**
- ✅ **BirthChart Model erweitert:** 7 neue Felder für erweiterte Numerologie
- ✅ **CosmicProfileService aktualisiert:** Überträgt alle erweiterten Felder
- ✅ **Numerologie-Card UI komplett erweitert:**
  - ⚡ Karmic Debt Numbers (13/14/16/19) mit Bedeutungen
  - 🎯 Challenge Numbers (4 Phasen als Chips, Challenge 0 grün)
  - 📚 Karmic Lessons (fehlende Zahlen 1-9 als Warning-Badges)
  - 🌉 Bridge Numbers (Life Path ↔ Expression, Soul ↔ Personality)
- ✅ **Onboarding Name-Screen:** REVERT zu 4 Feldern (displayName, fullFirstNames, birthName, lastName)
- ✅ **Git Commit:** `c7fc7b5` — feat: Erweiterte Numerologie in UI anzeigen
- ✅ **Dokumentation:** Session-Log erstellt (`docs/daily-logs/2026-02-08_erweiterte-numerologie-ui.md`)

**Design:**
- Einheitliche Sections mit Icons (⚡, 🎯, 📚, 🌉)
- Responsive Wrap-Layout für Chips/Badges
- Farbcodierung: Primary (Karmic Debt), Success (Challenge 0), Warning (Lessons)

**Technische Highlights:**
- Vollständiger Datenfluss: NumerologyProfile → CosmicProfileService → BirthChart → UI
- 4 neue Widget-Builder-Methoden für modularen Code
- Conditional Rendering: Nur Sections anzeigen die Daten haben

**Status:** ✅ Code komplett, bereit zum Testing!

---

**Was wurde heute gemacht (2026-02-08 — Kompletter Tag):**
- ✅ "Cosmic Profile" → "Deine Signatur" Umbenennung komplett
- ✅ Card-Design vereinheitlicht (alle Gradients entfernt)
- ✅ Onboarding Name-Screen: REVERT zu 4 Feldern
- ✅ UserProfile Model in nuuray_core aktualisiert
- ✅ **NUMEROLOGIE MASSIV ERWEITERT:**
  - ⚡ Karmic Debt Numbers (13, 14, 16, 19) — Berechnung + UI
  - 🎯 Challenge Numbers (4 Lebensphasen) — Berechnung + UI
  - 📚 Karmic Lessons (Fehlende Zahlen) — Berechnung + UI
  - 🌉 Bridge Numbers (Verbindungen) — Berechnung + UI
  - 🔢 **Display Name Number (Rufname)** — Berechnung + UI + Migration ✅
- ✅ BirthChart Model erweitert (7 neue Felder → 8 mit displayNameNumber)
- ✅ Numerologie-Card UI komplett (Icons, Chips, Badges, Sections)
- ✅ **Web Platform Fix:** Provider Caching nach Login behoben 🌐
- ✅ **Defensive DateTime Parsing:** Web-kompatible Parsing-Methoden
- ✅ Dokumentation aktualisiert (TODO.md, Session-Logs)

---

### Session 2026-02-21 — Tiefe Drei-System-Synthese Meilenstein

**Was wurde gemacht:**
- ✅ **Tiefe Drei-System-Synthese implementiert** (Das Herzstück der App!)
  - `deepSynthesisProvider` FutureProvider.family mit Cache-First-Logik
  - `DeepSynthesisSection` + `_SynthesisContent` ConsumerWidgets
  - Supabase Migration: `profiles.deep_synthesis_text` Spalte
  - Debug-Reset: Long-Press auf Refresh-Icon (nur Debug-Build)
- ✅ **Prompt-Architektur revolutioniert:** 5-Schritt-Bogen → 3-Spannungsfelder-Methode
  - Systeme erklären sich kausal gegenseitig (nicht nebeneinander)
  - SCHATTENSEITEN-Pflicht: 40% Stärke, 40% Schatten/Preis, 20% Auflösung
  - ANSPRACHE-Block oben im System-Prompt (verhindert Gender-Drift)
  - Persönliches Jahr mit Jahreszahl "2026" für Kontext
- ✅ **Bugfixes:**
  - FutureProvider.family Cache-Reset: Parameter ist Pflicht
  - Gender-Bug: Weibliche Ansprache für männliche User
  - `displayName: ?? 'Nutzerin'` → `?? ''`
  - Western Astrology: Hinweis bei fehlender Geburtszeit
  - Prompt: Explizite Anweisung bei fehlender Geburtszeit
- ✅ **Dokumentation:**
  - `NUURAY_BRAND_SOUL.md` erweitert (3-Spannungsfelder)
  - Session-Log erstellt
  - TODO.md + README.md aktualisiert

**Feedback von Probelesern:** "Das ist der Hammer" ✨
**Kosten:** ~$0.01 einmalig pro User (Premium-Feature, gecacht)
**Textlänge:** 900-1200 Wörter

**Technische Learnings:**
- FutureProvider.family: `ref.invalidate(provider(param))` — ohne Parameter funktioniert nichts!
- Gender-Drift: Claude anchored an frühe Tokens — ANSPRACHE muss ganz oben stehen
- 40/40/20 Ratio erzwingt ehrliche Texte — ohne explizite Anweisung schreibt KI immer positiv
- 4096 max_tokens nötig für 900-1200 Wörter (Standard 2048 reicht nicht)

### Session 2026-02-08 (Spätabend) — Rufnamen-Numerologie + Web Platform Fix

**Was wurde gemacht:**
- ✅ **Rufnamen-Numerologie (Display Name Number):**
  - BirthChart Model: `displayNameNumber` Feld hinzugefügt
  - SignatureService: Berechnung via `NumerologyCalculator.calculateExpression()`
  - Provider: `displayName` aus UserProfile übergeben
  - UI: Kompakte Card unter Life Path (40x40 Badge + Label + Bedeutung)
  - Master Number Indicator (✨) für 11/22/33
  - Migration: `006_add_display_name_number.sql` erstellt
  - i18n: DE + EN Keys hinzugefügt + 25+ fehlende archetyp Keys nachgetragen
  - Dokumentation: `docs/daily-logs/2026-02-08_rufnamen-numerologie.md`

- ✅ **Web Platform Fix (Provider Caching):**
  - Problem: Profil konnte in Chrome/Web nicht geladen werden
  - Root Cause: `userProfileProvider` wurde VOR Login initialisiert → cached `null`
  - Fix: `ref.invalidate(userProfileProvider)` nach erfolgreichem Login
  - Bonus: Defensive DateTime-Parsing (`_parseDateTimeSafe()`, `_parseBirthTime()`)
  - Bonus: `print()` statt `log()` für Chrome Console Visibility
  - Dokumentation: `docs/daily-logs/2026-02-08_web-provider-caching-fix.md`

**Technische Highlights:**
- Vollständiger Stack: Model → Service → Provider → UI → i18n → Migration
- Pythagorean Numerology: Letter-to-number mapping (A=1, B=2, etc.)
- Web vs Native Timing: Provider-Initialisierung unterscheidet sich
- Riverpod Provider Lifecycle: FutureProviders cachen beim ersten Access

**Status:** ✅ Beide Features komplett implementiert und dokumentiert!
