# 📚 NUURAY — Dokumentations-Übersicht

Alle Projekt-Dokumente, strukturiert nach Thema.

---

## 🏗️ Projekt-Architektur

```
docs/
├── README.md                                    ← Du bist hier
├── CHANGELOG_DOKUMENTATION.md                   ← Dokumentations-Änderungen
├── architecture/
│   └── PROJECT_BRIEF.md                        ← Vollständige Architektur (alle 3 Apps)
├── glow/
│   ├── README.md                               ← Glow-Dokumentation Übersicht
│   ├── GLOW_SPEC_V2.md                        ← ✨ AKTUELLE Glow-Spezifikation
│   ├── SPEC_CHANGELOG.md                      ← ✨ Konzeptionelle Änderungen
│   ├── CHANGELOG.md                            ← Code-Entwicklungs-History
│   └── implementation/                         ← Technische Implementierungs-Details
│       ├── COSMIC_PROFILE_IMPLEMENTATION.md
│       ├── GEOCODING_IMPLEMENTATION.md
│       ├── CLAUDE_API_IMPLEMENTATION.md
│       ├── HOROSCOPE_STRATEGY.md
│       └── migration-daily-horoscopes-status.md ← Migration Status Tracking
├── daily-logs/                                  ← Tägliche Session-Logs & Zusammenfassungen
│   ├── README.md
│   ├── 2026-02-08_session-zusammenfassung.md  ← Session-Ergebnisse
│   ├── 2026-02-08_onboarding-2-schritte.md
│   └── 2025-02-07_*.md                         ← Ältere Session-Logs
└── archive/                                     ← Veraltete Dokumente
    ├── README.md
    └── GLOW_SPEC_V1.md                         ← Ursprüngliche Spec (deprecated)
```

---

## 📖 Hauptdokumente (nach Verwendung)

### 1. Für **Projekt-Überblick**
📄 **`architecture/PROJECT_BRIEF.md`**
- Alle 3 Apps (Glow, Tide, Path)
- Tech-Stack-Entscheidungen
- Shared Packages Strategie
- Warum Flutter + Supabase + Claude API?

---

### 2. Für **Glow-Entwicklung**
📄 **`glow/GLOW_SPEC_V2.md`** ⭐ (AKTUELL)
- Vollständige Glow-Spezifikation
- 2-Schritte Onboarding
- "Deine Signatur" Dashboard
- Screen-Mockups, DB-Schema, Content-Strategie

📄 **`glow/SPEC_CHANGELOG.md`** (NEU!)
- Was hat sich geändert?
- "Cosmic Profile" → "Deine Signatur"
- Onboarding 3 → 2 Schritte
- Sprachen-Strategie

📄 **`glow/README.md`**
- Glow-Dokumentation Übersicht
- Inkonsistenzen zwischen Code & Docs
- Entwicklungs-Status

---

### 3. Für **Implementierungs-Details**
📁 **`glow/implementation/`**
- `COSMIC_PROFILE_IMPLEMENTATION.md` — Dashboard (Tech)
- `GEOCODING_IMPLEMENTATION.md` — Google Places
- `CLAUDE_API_IMPLEMENTATION.md` — Content-Generierung
- `HOROSCOPE_STRATEGY.md` — 3-Stufen Strategie (A/B/C)

---

### 4. Für **Entwicklungs-History**
📄 **`glow/CHANGELOG.md`**
- Release-Notes (0.1.0, 0.2.0, etc.)
- Bug-Fixes
- Feature-Implementierungen

📁 **`daily-logs/`**
- **Session-Zusammenfassungen:** `2026-02-08_session-zusammenfassung.md` (was wurde erledigt, Learnings)
- **Feature-Logs:** `2026-02-08_onboarding-2-schritte.md` (detaillierte Implementation)
- **Debug-Logs:** Aszendent-Fix, Claude API Testing, Geocoding-Erfolge
- **Format:** `YYYY-MM-DD_beschreibung.md`

---

## 🔑 Schnellzugriff nach Task

| Ich will... | Dann lese... |
|-------------|--------------|
| **Vollständigen Projekt-Überblick** | `architecture/PROJECT_BRIEF.md` |
| **Glow Feature entwickeln** | `glow/GLOW_SPEC_V2.md` |
| **Verstehen, was sich geändert hat** | `glow/SPEC_CHANGELOG.md` |
| **Cosmic Profile debuggen** | `glow/implementation/COSMIC_PROFILE_IMPLEMENTATION.md` |
| **Claude API integrieren** | `glow/implementation/CLAUDE_API_IMPLEMENTATION.md` |
| **Google Places debuggen** | `glow/implementation/GEOCODING_IMPLEMENTATION.md` |
| **Horoskop-Kosten optimieren** | `glow/implementation/HOROSCOPE_STRATEGY.md` |
| **Sehen, was schon funktioniert** | `glow/CHANGELOG.md` |
| **Session-Log lesen** | `daily-logs/2026-02-08_session-zusammenfassung.md` |
| **Migration-Status prüfen** | `glow/implementation/migration-daily-horoscopes-status.md` |
| **Dokumentations-Änderungen** | `docs/CHANGELOG_DOKUMENTATION.md` |

---

## ⚠️ Wichtige Hinweise

### Veraltete Dokumente
- **`glow/GLOW_SPEC.md`** — Original-Spec, **ersetzt durch GLOW_SPEC_V2.md**
- Nur noch zur Referenz

### Inkonsistenzen
Siehe `glow/README.md` → Abschnitt "Inkonsistenzen zwischen Code & Docs"

**Aktueller Stand (2026-02-08):**
1. ✅ **Onboarding:** Code = 2 Schritte, Spec V2 = 2 Schritte (**GELÖST!**)
2. ⚠️ **Naming:** Code = "Cosmic Profile", Spec V2 = "Deine Signatur" (**TODO**)

---

## 📊 Dokumentations-Status

| Dokument | Status | Letzte Aktualisierung |
|----------|--------|-----------------------|
| `architecture/PROJECT_BRIEF.md` | ✅ Aktuell | 2026-02-07 |
| `glow/GLOW_SPEC_V2.md` | ✅ Aktuell | 2026-02-07 |
| `glow/SPEC_CHANGELOG.md` | ✅ Neu | 2026-02-07 |
| `glow/CHANGELOG.md` | ✅ Aktuell | 2026-02-07 |
| `glow/implementation/*.md` | ✅ Aktuell | 2026-02-07 |
| `daily-logs/*.md` | ✅ Laufend | 2026-02-07 |
| `glow/GLOW_SPEC.md` | ⚠️ Veraltet | 2025-02-05 |

---

## 🚀 Für neue Entwickler / Claude Sessions

**Start hier:**
1. `architecture/PROJECT_BRIEF.md` — Projekt verstehen (20 Min)
2. `glow/GLOW_SPEC_V2.md` — Glow-Features kennenlernen (30 Min)
3. `glow/README.md` — Entwicklungs-Status & Inkonsistenzen (5 Min)
4. `TODO.md` (Root) — Aktuelle Aufgaben (5 Min)

**Total:** ~1 Stunde Onboarding

---

**Letzte Aktualisierung:** 2026-02-07
**Maintainer:** Solo-Entwicklung (Natalie)
