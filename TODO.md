# NUURAY GLOW — TODO Liste

> Letzte Aktualisierung: 2025-02-06
> Stand: Auth ✅, Onboarding ✅, Basic Home ✅, **Cosmic Profile Dashboard ✅**

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
- ✅ 3-Schritte Onboarding-Flow
  - Schritt 1: Name-Felder (displayName, fullFirstNames, lastName, birthName)
  - Schritt 2: Geburtsdatum (Pflicht) + Geburtszeit (Optional)
  - Schritt 3: Geburtsort (Text-Input)
- ✅ UserProfile Model mit allen Feldern
- ✅ UserProfileService (CRUD + Upsert-Logik)
- ✅ Supabase Migrations:
  - 001_initial_schema.sql (profiles Tabelle)
  - 002_add_onboarding_fields.sql (Name-Felder, Onboarding-Status, Geburtsort-Felder)
  - 003_cleanup_profile_columns.sql (Alte Spalten entfernen)

### Basic UI
- ✅ Splash Screen mit Auth/Onboarding Routing
- ✅ Home Screen mit Placeholder-Content
  - Header mit personalisierter Begrüßung
  - Tagesenergie-Card (Gradient, Placeholder)
  - Horoskop-Card (Hardcoded Schütze)
  - Quick Actions (Coming Soon)
  - Logout Button
- ✅ Cosmic Profile Dashboard (inline auf Home Screen)
  - Western Astrology Card (Sonne/Mond/Aszendent)
  - Bazi Card (Vier Säulen + Day Master)
  - Numerology Card (9 Kern-Zahlen + Dual-Profil)

---

## 🔨 IN ARBEIT

### Cosmic Profile Dashboard
**Status:** ✅ FERTIG (Stand: 2025-02-06)

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

5. **i18n**
   - ✅ Alle UI-Labels auf Deutsch (Lebensweg, Seelenwunsch, Ausdruck, etc.)
   - ✅ Sternzeichen-Namen (DE: nameDe Property in ZodiacSign)
   - ✅ Bazi-Elemente übersetzt (Holz, Feuer, Erde, Metall, Wasser)
   - ✅ Branches übersetzt (Ratte, Büffel, Tiger, etc.)
   - ⏳ Stems: Aktuell ohne Übersetzung (Jia, Yi, etc. bleiben)
   - ⏳ ARB-Dateien: Noch nicht migriert (TODO für echte i18n)

6. **Integration**
   - ✅ Provider: cosmicProfileProvider (cached BirthChart)
   - ✅ Home Screen: Cosmic Profile Dashboard inline integriert
   - ✅ Loading/Error/Empty States
   - ⏳ Onboarding: Chart-Berechnung nach Abschluss (TODO)

---

## 🐛 AKTUELLE PROBLEME

### Aszendent fehlt
- **Problem:** Ascendant wird nicht berechnet, weil `birth_latitude` + `birth_longitude` null
- **Ursache:** Onboarding speichert nur Text-Input für Geburtsort, keine Koordinaten
- **UI-Lösung:** Placeholder "Geburtsort-Koordinaten erforderlich" angezeigt
- **Nächster Schritt:** Google Places API Integration (siehe unten)

---

## ⏳ TODO (Nächste Schritte nach Dashboard)

### Cosmic Profile: Verbesserungen
- [ ] **Detail-Ansichten** für jedes System (klickbar auf "Mehr erfahren")
  - Western Astrology: Alle Planeten + Häuser (Premium)
  - Bazi: Luck Pillars, Hidden Stems, Element Balance Chart (Premium)
  - Numerology: Alle 30+ Zahlen + Lebensphasen (Premium)
- [ ] **Premium-Gating** für erweiterte Berechnungen
- [ ] **Supabase Migration:** Neue Spalten für erweiterte Daten

### Geburtsdaten-Engine vervollständigen
- [x] Mondzeichen-Berechnung (✅ ELP2000 Algorithmus implementiert)
- [x] Aszendent-Berechnung (✅ Meeus Algorithmus, aber Koordinaten fehlen)
- [x] Bazi: Stundensäule (✅ implementiert, aber nur mit Geburtszeit)
- [ ] **Tests für alle Berechnungen** (kritisch für Genauigkeit!)
  - [ ] Western Astrology: Test Cases für bekannte Geburtsdaten
  - [ ] Bazi: Solar Terms Grenzen prüfen
  - [ ] Numerology: Meisterzahlen-Fälle testen

### Geburtsort Geocoding (PRIORITÄT: Aszendent fehlt!)
- [ ] **Google Places API Integration** (aktuell: Text-Input → keine Koordinaten)
  - Option 1: Client-seitig mit google_places_flutter (API Key vorhanden)
  - Option 2: Server-seitig über Supabase Edge Function (sicherer, bevorzugt)
- [ ] **Latitude/Longitude in Onboarding speichern** (birth_latitude, birth_longitude)
- [ ] Timezone-Berechnung aus Geburtsort (für präzise Bazi-Stunde)
- [ ] **Nach Geocoding:** Chart neu berechnen (Aszendent + präzise Bazi-Stunde)

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

## 🐛 BEKANNTE PROBLEME

### Geburtsort-Eingabe
- **Problem:** Google Places API liefert "Forbidden" Error
- **API Key:** AIzaSyBG207MVH8bkIjk_zNAKplAaB1H45HjndM
- **Status:** Beide APIs aktiviert (Places API + Places API New), korrekte Config
- **Workaround:** Text-Input für MVP
- **Langfristig:** Server-seitige Geocoding über Supabase Edge Function

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

**Nächster Fokus:** Cosmic Profile Dashboard implementieren — die drei Calculator-Services sind die Basis für alle weiteren Features.
