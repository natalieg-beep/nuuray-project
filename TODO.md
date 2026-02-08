# NUURAY GLOW — TODO Liste

> Letzte Aktualisierung: 2026-02-08 (i18n VOLLSTÄNDIG! 🌍✨)
> Stand: Auth ✅, Onboarding ✅, Geocoding ✅, Basic Home ✅, Deine Signatur ✅, Claude API ✅, Erweiterte Numerologie ✅, **Tageshoroskop On-Demand ✅, i18n DE/EN 100% ✅**
>
> **📚 Neue Dokumentation:**
> - `docs/deployment/HOROSCOPE_STRATEGY.md` — **NEU!** Tageshoroskop On-Demand vs. Cron Job Strategie
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
    - Kern-Zahlen: Life Path, Birthday, Attitude, Personal Year, Maturity
    - Name Energies: Birth Energy (expandable), Current Energy (expandable)
    - **NEU: Erweiterte Numerologie:**
      - ⚡ Karmic Debt Numbers (13/14/16/19) mit Bedeutungen
      - 🎯 Challenge Numbers (4 Phasen als Chips)
      - 📚 Karmic Lessons (fehlende Zahlen 1-9 als Badges)
      - 🌉 Bridge Numbers (Life Path ↔ Expression, Soul ↔ Personality)
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

## ⏳ NÄCHSTE SCHRITTE

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
  - [ ] Karmic Debt Numbers sichtbar (⚡)
  - [ ] Challenge Numbers als 4 Chips (🎯), Challenge 0 grün
  - [ ] Karmic Lessons als Warning-Badges (📚)
  - [ ] Bridge Numbers mit Erklärungen (🌉)
  - [ ] Soul Urge = 33 verifizieren (Meisterzahl ✨)
- [ ] Neues Onboarding mit 4 Name-Feldern durchspielen
- [ ] Geocoding Autocomplete testen (✅ Funktioniert grundsätzlich!)
- [ ] Aszendent-Berechnung verifizieren (✅ Code korrekt!)

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
- [ ] Partner-Check (Premium)
- [ ] Detailansichten für Cosmic Profile (Premium)

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
- ✅ BirthChart Model erweitert (7 neue Felder)
- ✅ Numerologie-Card UI komplett (Icons, Chips, Badges, Sections)
- ✅ Dokumentation aktualisiert (TODO.md, Session-Log)
