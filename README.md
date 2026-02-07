# 🌙 NUURAY — Mondlicht Apps für Frauen

**NUURAY** (arabisch *nur* = Licht + türkisch *ay* = Mond) ist eine Markenfamilie aus drei eigenständigen Apps, die Frauen durch die Synthese von westlicher Astrologie, chinesischer Astrologie (Bazi) und Numerologie unterstützen.

---

## 📱 Die drei Apps

| App | Tagline | Status | Zielgruppe |
|-----|---------|--------|------------|
| **🌟 Nuuray Glow** | Kosmische Unterhaltung | 🔨 **In Entwicklung** | Frauen 20-40, die Horoskope lieben |
| **🌊 Nuuray Tide** | Zyklus & Mond | ⏳ Geplant (Phase 3) | Frauen, die ihren Zyklus tracken |
| **🧭 Nuuray Path** | Coaching & Selbsterkenntnis | ⏳ Geplant (Phase 4) | Frauen, die sich weiterentwickeln wollen |

---

## 🎯 Das Besondere (USP)

Die meisten Horoskop-Apps zeigen nur westliche Astrologie. NUURAY kombiniert **drei Systeme** zu einer einzigen, stimmigen Aussage:

- **🌟 Westliche Astrologie** — Persönlichkeitsstruktur (Sonne, Mond, Aszendent)
- **🀄 Bazi (Vier Säulen)** — Energetische Konstitution (Day Master, Elemente)
- **🔢 Numerologie** — Lebensweg und Talente (Life Path, Expression, Soul Urge)

Diese Synthese passiert nicht als Auflistung, sondern als **ein einziger, stimmiger Text** durch die Claude API.

---

## 🏗️ Architektur

### Drei Apps, ein Backend

```
┌─────────────────────────────────────────────────────┐
│                    SHARED LAYER                      │
├─────────────┬─────────────────┬─────────────────────┤
│ nuuray_core │   nuuray_api    │     nuuray_ui       │
│ Models      │   Supabase      │     Theme           │
│ Berechnungen│   Claude API    │     Widgets         │
│ Logik       │   Repositories  │     i18n            │
├─────────────┴─────────────────┴─────────────────────┤
│                    SUPABASE                          │
│  Auth │ PostgreSQL │ Edge Functions │ Storage        │
└─────────────────────────────────────────────────────┘
         ↑               ↑               ↑
    Nuuray Glow     Nuuray Tide     Nuuray Path
```

### Tech Stack

| Bereich | Technologie |
|---------|-------------|
| Frontend | **Flutter** (iOS + Android + Web) |
| Backend | **Supabase** (PostgreSQL, Auth, Edge Functions) |
| AI | **Claude API** (Anthropic) — Personalisierte Texte |
| State Management | **Riverpod** |
| Routing | **GoRouter** |
| i18n | **ARB** (Deutsch + Englisch) |
| Payments | **In-App Purchases** (Apple + Google) |

---

## 📂 Projektstruktur

```
nuuray-project/
├── CLAUDE.md                  # Projektanweisung für Claude AI
├── README.md                  # ← Du bist hier
├── TODO.md                    # Aktuelle Aufgabenliste
│
├── apps/
│   ├── glow/                  # Nuuray Glow (Flutter-App)
│   ├── tide/                  # Nuuray Tide (geplant)
│   └── path/                  # Nuuray Path (geplant)
│
├── packages/
│   ├── nuuray_core/           # Shared: Models, Services, Berechnungen
│   ├── nuuray_api/            # Shared: Supabase Client, Claude API
│   └── nuuray_ui/             # Shared: Theme, Widgets, i18n
│
├── supabase/
│   ├── migrations/            # SQL-Migrationen (versioniert)
│   ├── functions/             # Edge Functions (Deno/TypeScript)
│   └── seed/                  # Seed-Daten
│
└── docs/                      # 📚 Vollständige Dokumentation
    ├── README.md              # Dokumentations-Übersicht (START HIER!)
    ├── CHANGELOG_DOKUMENTATION.md  # Dokumentations-Änderungen
    ├── architecture/          # Architektur-Dokumentation
    │   └── PROJECT_BRIEF.md   # Vollständige Architektur (alle 3 Apps)
    ├── glow/                  # Glow-spezifische Dokumentation
    │   ├── README.md          # Glow-Dokumentation Übersicht
    │   ├── GLOW_SPEC_V2.md    # ✨ AKTUELLE Glow-Spezifikation
    │   ├── SPEC_CHANGELOG.md  # Konzeptionelle Änderungen
    │   ├── CHANGELOG.md       # Entwicklungs-History
    │   └── implementation/    # Technische Implementation-Details
    ├── daily-logs/            # Tägliche Session-Logs & Zusammenfassungen
    └── archive/               # Veraltete Dokumente (z.B. GLOW_SPEC_V1.md)
```

---

## 🚀 Quick Start

### Voraussetzungen

- Flutter SDK (>= 3.16.0)
- Dart SDK (>= 3.2.0)
- Supabase Account
- Google Cloud Account (für Places API)

### Installation

```bash
# Repository klonen
git clone https://github.com/nuuray/nuuray-project.git
cd nuuray-project

# Dependencies installieren (alle Packages)
flutter pub get

# Glow-App starten
cd apps/glow
flutter run
```

### Environment Setup

1. **Supabase:**
   - Erstelle `.env` in `apps/glow/`
   - Füge hinzu: `SUPABASE_URL` und `SUPABASE_ANON_KEY`

2. **Google Places API:**
   - Konfiguriere API Key in Supabase Secrets
   - Siehe: `docs/glow/implementation/GEOCODING_IMPLEMENTATION.md`

---

## 📚 Dokumentation

> **⭐ START HIER:** [`docs/README.md`](docs/README.md) — Vollständige Dokumentations-Übersicht

### Wichtigste Dokumente

| Dokument | Beschreibung |
|----------|--------------|
| [`CLAUDE.md`](CLAUDE.md) | ⚙️ Projektanweisung für Claude AI (Tech Stack, Konventionen, Git) |
| [`TODO.md`](TODO.md) | ✅ Aktuelle Aufgabenliste mit Status |
| [`docs/README.md`](docs/README.md) | 📚 **Dokumentations-Hub** — Navigation zu allen Docs |
| [`docs/glow/GLOW_SPEC_V2.md`](docs/glow/GLOW_SPEC_V2.md) | 🌟 **Aktuelle Glow-Spezifikation** (2-Schritte Onboarding, Deine Signatur) |
| [`docs/glow/SPEC_CHANGELOG.md`](docs/glow/SPEC_CHANGELOG.md) | 📝 Konzeptionelle Änderungen (was hat sich geändert?) |
| [`docs/architecture/PROJECT_BRIEF.md`](docs/architecture/PROJECT_BRIEF.md) | 🏗️ Vollständige Architektur (alle 3 Apps) |
| [`docs/daily-logs/2026-02-08_session-zusammenfassung.md`](docs/daily-logs/2026-02-08_session-zusammenfassung.md) | 📅 Neueste Session-Zusammenfassung |

---

## 🌍 Sprachen

- **Entwicklungssprache:** Deutsch (Code-Kommentare, Commits, Docs)
- **Code:** Englisch (Variablen, Klassen, Funktionen)
- **UI:** Deutsch + Englisch (ARB-Dateien)
- **Content:** Deutsch + Englisch (Claude API generiert beide)

---

## 👥 Team

Solo-Entwicklerin: **Natalie Günes**
Firma: **Be Hamarat Group Teknoloji** (İzmir, Türkei)

---

## 📝 Lizenz

Proprietär — Alle Rechte vorbehalten.

---

## 🔗 Links

- **Supabase Dashboard:** https://supabase.com/dashboard/project/ykkayjbplutdodummcte
- **Google Cloud Console:** https://console.cloud.google.com
- **Claude API:** https://console.anthropic.com

---

**Stand:** 2026-02-08 | **Version:** 0.3.0 (MVP in Entwicklung)
