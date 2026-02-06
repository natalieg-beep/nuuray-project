# NUURAY GLOW — TODO Liste

> Letzte Aktualisierung: 2025-02-06
> Stand: Auth ✅, Onboarding ✅, Basic Home ✅, Cosmic Profile Dashboard 🔨

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

---

## 🔨 IN ARBEIT

### Cosmic Profile Dashboard
**Status:** Spezifikation vorhanden, Implementierung steht bevor

**Komponenten:**
1. **Datenmodell** (nuuray_core)
   - [ ] CosmicProfile (freezed) mit drei Subsystemen
   - [ ] WesternAstrology Model (Sonne/Mond/Aszendent mit Graden)
   - [ ] Bazi Model (Vier Säulen, Day Master, Element Balance)
   - [ ] Numerology Model (Life Path, Expression, Soul Urge)
   - [ ] Enums: ZodiacSign, BaziElement, HeavenlyStem, EarthlyBranch

2. **Calculator Services** (nuuray_core)
   - [ ] WesternAstrologyCalculator
     - Sonnenzeichen aus Geburtsdatum
     - Mondzeichen aus Geburtsdatum + Zeit (Vereinfachte Berechnung für MVP)
     - Aszendent aus Geburtsdatum + Zeit + Ort (oder null)
   - [ ] BaziCalculator
     - Vier Säulen (Jahr, Monat, Tag, Stunde) aus Geburtsdatum + Zeit
     - Day Master identifizieren
     - Dominantes Element berechnen
     - Chinesischer Kalender korrekt (Lichun-Grenze beachten)
   - [ ] NumerologyCalculator
     - Life Path Number aus Geburtsdatum (Meisterzahlen 11, 22, 33 beachten)
     - Expression Number aus vollständigem Namen
     - Soul Urge Number aus Vokalen des Namens

3. **Supabase**
   - [ ] Migration: cosmic_profiles Tabelle erstellen
     - id (UUID, FK zu profiles)
     - western_astrology (JSONB)
     - bazi (JSONB)
     - numerology (JSONB)
     - calculated_at (Timestamp)
     - RLS Policies (User sieht nur eigenes Profil)
   - [ ] CosmicProfileService (CRUD + Cache-Logik)

4. **UI Widgets** (apps/glow)
   - [ ] CosmicProfileDashboard Screen
   - [ ] WesternAstrologyCard Widget
     - Gradient: Gold/Orange
     - Sonne/Mond/Aszendent mit Symbolen + Graden
     - "Mehr erfahren" Button
   - [ ] BaziCard Widget
     - Gradient: Rot/Braun
     - Vier Säulen Visualisierung
     - Day Master prominent
     - Element Balance Diagramm
     - "Mehr erfahren" Button
   - [ ] NumerologyCard Widget
     - Gradient: Lila/Pink
     - Drei Zahlen mit Bedeutung
     - "Mehr erfahren" Button

5. **i18n** (nuuray_ui)
   - [ ] Sternzeichen-Namen (DE + EN)
   - [ ] Bazi-Elemente + Stems/Branches (DE + EN)
   - [ ] Numerologie-Beschreibungen (DE + EN)

6. **Integration**
   - [ ] Provider: cosmicProfileProvider (berechnet + cached Profil)
   - [ ] Home Screen: Link zum Cosmic Profile Dashboard
   - [ ] Onboarding: Nach Abschluss Profil berechnen

---

## ⏳ TODO (Nächste Schritte nach Dashboard)

### Geburtsdaten-Engine vervollständigen
- [ ] Mondzeichen-Berechnung verfeinern (Astronomische Bibliothek oder API evaluieren)
- [ ] Aszendent-Berechnung implementieren (Geburtszeit + Ort → Längen-/Breitengrad)
- [ ] Bazi: Stundensäule korrekt berechnen (nur mit Geburtszeit)
- [ ] Tests für alle Berechnungen (kritisch für Genauigkeit)

### Geburtsort Geocoding
- [ ] Google Places API Integration (aktuell: Text-Input)
  - Option 1: Client-seitig mit google_places_flutter (API Key: AIzaSyBG207MVH8bkIjk_zNAKplAaB1H45HjndM)
  - Option 2: Server-seitig über Supabase Edge Function (sicherer)
- [ ] Latitude/Longitude Felder im UserProfile nutzen
- [ ] Timezone-Berechnung aus Geburtsort

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
