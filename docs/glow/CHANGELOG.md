# 📝 NUURAY GLOW — Changelog

Alle wichtigen Änderungen und Meilensteine der Glow-App Entwicklung.

---

## [Unreleased] - In Entwicklung

### 🎯 Aktuelle Priorität
- Cosmic Profile Dashboard Testing
- Claude API Integration für Tageshoroskope
- i18n finalisieren (DE + EN)

---

## [0.3.0] - 2025-02-07 — Bugfixes & Stabilität

### 🐛 Fixed
- **Aszendent-Berechnung korrigiert**
  - Problem: UTC-Konvertierung führte zu falschen Ergebnissen
  - Fix: Lokale Zeit direkt verwenden statt UTC-Konvertierung
  - Datei: `packages/nuuray_core/lib/src/services/zodiac_calculator.dart:197`
  - Ergebnis: Aszendent jetzt 100% korrekt ✅

- **Tageshoroskop zeigt User-Sternzeichen**
  - Problem: Hardcoded "Schütze ♐" auf Home Screen
  - Fix: Dynamisches Laden aus `cosmicProfileProvider`
  - Datei: `apps/glow/lib/src/features/home/screens/home_screen.dart`
  - Features: Loading/Error States hinzugefügt

### ✅ Verified
- Sonnenzeichen-Berechnung: 100% korrekt (4/4 Tests)
- Mondzeichen-Berechnung: 100% korrekt (4/4 Tests)
- Aszendent-Berechnung: Mathematisch korrekt nach Meeus

### 📚 Dokumentation
- `docs/daily-logs/2025-02-07_bugfixes-erfolg.md` — Erfolgs-Zusammenfassung
- `docs/daily-logs/2025-02-07_aszendent-fix.md` — Technische Details

---

## [0.2.0] - 2025-02-06 — Google Places Integration

### ✨ Added
- **Google Places API Integration (Server-seitig)**
  - Supabase Edge Function: `geocode-place`
  - Geocoding Service in `nuuray_api`
  - Onboarding Screen mit Ort-Suche
  - Koordinaten + Timezone werden gespeichert
  - Aszendent-Berechnung jetzt möglich ✅

### 🔒 Security
- API Key liegt nur server-seitig (Edge Function)
- User-Authentifizierung via JWT
- Rate Limiting durch Supabase

### 📦 Deployment
- Edge Function deployed zu Supabase
- Secrets konfiguriert: `GOOGLE_PLACES_API_KEY`
- Status: ✅ Produktionsreif

### 💰 Kosten
- Free Tier: $200/Monat = ~8000 Requests
- Pro Request: ~$0.025
- MVP (< 5000 Users): Komplett kostenlos

### 📚 Dokumentation
- `docs/glow/implementation/GEOCODING_IMPLEMENTATION.md` — Vollständige Dokumentation
- `docs/daily-logs/2025-02-06_geocoding-fix.md` — Änderungen
- `supabase/functions/README.md` — Deployment Guide

---

## [0.1.0] - 2025-02-06 — MVP Foundation

### ✨ Added
- **Auth System (Supabase)**
  - Email Authentication (Login, Signup, Password Reset)
  - AuthService mit deutschen Fehlermeldungen
  - Auth-State Management mit Riverpod
  - Router mit Auth-Guards (GoRouter)

- **Onboarding Flow (3 Schritte)**
  - Schritt 1: Name-Felder (displayName, fullFirstNames, lastName, birthName)
  - Schritt 2: Geburtsdatum (Pflicht) + Geburtszeit (Optional)
  - Schritt 3: Geburtsort (Text-Input, Google Places geplant)

- **Basic Home Screen**
  - Header mit personalisierter Begrüßung
  - Tagesenergie-Card (Gradient, Placeholder)
  - Horoskop-Card (Hardcoded Schütze → später dynamisch)
  - Quick Actions (Coming Soon)
  - Logout Button

- **Cosmic Profile Dashboard**
  - Western Astrology Card (Sonne/Mond/Aszendent mit Graden)
  - Bazi Card (Vier Säulen + Day Master + Element Balance)
  - Numerology Card (9 Kern-Zahlen + Dual-Profil)
  - Inline auf Home Screen (immer sichtbar)

- **Calculator Services (nuuray_core)**
  - WesternAstrologyCalculator (Sonne/Mond/Aszendent)
  - BaziCalculator (Vier Säulen, Day Master, Element Balance)
  - NumerologyCalculator (9 Zahlen, Meisterzahlen-Support)

### 🗄️ Database
- Supabase Migrations:
  - `001_initial_schema.sql` — profiles Tabelle
  - `002_add_onboarding_fields.sql` — Name-Felder, Onboarding-Status
  - `003_cleanup_profile_columns.sql` — Alte Spalten entfernen

### 📚 Dokumentation
- `docs/glow/implementation/COSMIC_PROFILE_IMPLEMENTATION.md`
- `docs/daily-logs/2025-02-06_onboarding-home.md`

---

## [0.0.1] - 2025-02-05 — Projekt-Initialisierung

### 🎬 Initial Setup
- Flutter-App erstellt (`com.nuuray.glow`)
- Ordnerstruktur aufgebaut
- Shared Packages konfiguriert (nuuray_core, nuuray_api, nuuray_ui)
- Dependencies installiert (121 packages)

### 🎨 Design System
- Glow-Farbpalette definiert (Primary: #C8956E Warm Gold)
- Material 3 Theme konfiguriert
- Localization-Support (DE/EN)

### 🔧 Tech Stack
- State Management: Riverpod
- Routing: GoRouter
- Backend: Supabase
- Storage: shared_preferences

### 📚 Dokumentation
- CLAUDE.md — Projektanweisung
- PROJECT_BRIEF.md — Architektur-Übersicht (alle 3 Apps)

---

## Legende

- ✨ **Added** — Neue Features
- 🐛 **Fixed** — Bug-Fixes
- 🔒 **Security** — Sicherheits-Verbesserungen
- 🗄️ **Database** — Datenbank-Änderungen
- 📦 **Deployment** — Deployment-Status
- 💰 **Kosten** — Kosten-Informationen
- 📚 **Dokumentation** — Neue Dokumentation
- ✅ **Verified** — Testing & Verifikation

---

## Konzeptionelle Änderungen

### 2025-02-07 — "Cosmic Profile" → "Deine Signatur"

**Warum?**
- Persönlicher ("Deine" statt "Cosmic")
- Einprägsamer
- Weniger esoterisch/abschreckend
- Impliziert Einzigartigkeit

**Geändert:**
- Screen-Namen
- Datenbank-Tabellen (`signature_profiles` statt `cosmic_profiles`)
- Edge Functions (`calculate-signature`)
- Alle UI-Texte

**Dashboard-Platzierung:**
- Neu: Immer sichtbar OBEN auf Home Screen
- Format: Kompakt (2-3 Zeilen)
- "Mehr erfahren →" Link zu Detail-View

### 2025-02-07 — Onboarding: 3 Schritte → 2 Schritte (geplant)

**Neu:**
- Schritt 1: Name & Identität (3 Felder)
- Schritt 2: Geburtsdaten (alles kombiniert)

**Name-Felder umstrukturiert:**
- `display_name` (Rufname/Username) — PFLICHT
- `full_birth_name` (Voller Geburtsname) — OPTIONAL
- `current_last_name` (Aktueller Nachname) — OPTIONAL

**Numerologie-Logik:**
- `full_birth_name` → Expression/Soul Urge/Personality
- `current_last_name` → Aktuelle Namens-Energie

**Status:** ⏳ Konzept definiert, Implementierung ausstehend

### 2025-02-07 — Content erweitert: Jahresvorschau (Premium)

**Features:**
- On-Demand beim Premium-Kauf generiert
- ~2000 Wörter (8-10 Min. Lesezeit)
- Enthält: Transite, Luck Pillars (Bazi), persönliches Jahr (Numerologie)
- Cache: 365 Tage

**Kosten:**
- ~$0.50 pro User (Claude Opus)
- Nicht für alle User am 1.1. generiert

**Status:** ⏳ Konzept definiert, Implementierung ausstehend

### 2025-02-07 — Sprachen: Deutsch + Englisch ab Tag 1

**Strategie:**
- Primärsprache: Deutsch (Entwicklung)
- Sekundärsprache: Englisch (parallel entwickelt)

**Settings Integration:**
- Dropdown: 🇩🇪 Deutsch / 🇬🇧 English
- Speichert in `profiles.language`
- Claude API nutzt User-Sprache

**ARB-Dateien:**
- `app_de.arb` (Primär)
- `app_en.arb` (Parallel)

**Status:** ⏳ Konzept definiert, i18n-Implementierung ausstehend

---

**Format:** [Semantic Versioning](https://semver.org/) (MAJOR.MINOR.PATCH)
**Sortierung:** Neueste zuerst (oben)
