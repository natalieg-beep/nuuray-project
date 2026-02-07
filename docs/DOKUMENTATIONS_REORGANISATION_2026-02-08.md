# 📚 Dokumentations-Reorganisation — 2026-02-08

## Motivation

Die Dokumentation war über mehrere Orte verstreut:
- DONE-Dateien im Root-Verzeichnis (wenig aussagekräftige Namen)
- CHECK_MIGRATION.md im Root (gehört zu Glow-Implementation)
- CHANGELOG_DOKUMENTATION.md im Root (gehört zu docs/)
- Keine klare Verweis-Struktur in README.md und CLAUDE.md

**Ziel:** Strukturierte, navigierbare Dokumentation mit sprechenden Dateinamen.

---

## Durchgeführte Änderungen

### 1. Dateien verschoben

| Alt | Neu | Begründung |
|-----|-----|------------|
| `DONE_2026-02-08.md` | `docs/daily-logs/2026-02-08_session-zusammenfassung.md` | Session-Logs gehören zu daily-logs, sprechender Name |
| `CHECK_MIGRATION.md` | `docs/glow/implementation/migration-daily-horoscopes-status.md` | Implementation-Detail, sprechender Name |
| `CHANGELOG_DOKUMENTATION.md` | `docs/CHANGELOG_DOKUMENTATION.md` | Dokumentations-Meta-Info gehört zu docs/ |

### 2. Aktualisierte Dateien

#### `docs/README.md`
- ✅ Vollständige Struktur-Übersicht mit allen Unterordnern
- ✅ Tabellarische Navigation nach Use-Case
- ✅ Hinweis auf neue Session-Log-Format: `YYYY-MM-DD_beschreibung.md`
- ✅ Inkonsistenz-Status aktualisiert (Onboarding = GELÖST)

#### `README.md` (Root)
- ✅ Dokumentations-Sektion neu strukturiert
- ✅ Prominenter Link zu `docs/README.md` als Dokumentations-Hub
- ✅ Projekt-Struktur zeigt vollständige docs/-Hierarchie
- ✅ Stand auf 2026-02-08 aktualisiert

#### `CLAUDE.md`
- ✅ Link zu `docs/README.md` als primäre Dokumentations-Quelle
- ✅ Verweis auf GLOW_SPEC_V2.md (nicht mehr V1)
- ✅ Link zu neuester Session-Zusammenfassung

---

## Neue Namens-Konvention

### Daily Logs

**Format:** `YYYY-MM-DD_typ.md`

**Typen:**
- `session-zusammenfassung` — Was wurde in der Session erledigt, Learnings
- `feature-name` — Detaillierte Feature-Implementation (z.B. `onboarding-2-schritte`)
- `bug-fix-name` — Debug-Logs (z.B. `aszendent-fix`, `geocoding-fix`)

**Beispiele:**
- ✅ `2026-02-08_session-zusammenfassung.md`
- ✅ `2026-02-08_onboarding-2-schritte.md`
- ✅ `2025-02-07_aszendent-fix.md`

**Nicht mehr:**
- ❌ `DONE_2026-02-08.md` (zu generisch)
- ❌ `CHECK_MIGRATION.md` (kein Datum, unklar)

### Implementation-Docs

**Format:** `beschreibung-des-themas.md` (lowercase mit Bindestrichen)

**Beispiele:**
- ✅ `migration-daily-horoscopes-status.md`
- ✅ `cosmic-profile-implementation.md`
- ✅ `geocoding-implementation.md`

---

## Dokumentations-Hierarchie

```
nuuray-project/
├── CLAUDE.md                          ← Projektanweisung für Claude AI
├── README.md                          ← Projekt-Übersicht
├── TODO.md                            ← Aktuelle Aufgabenliste
│
└── docs/                              ← 📚 ALLE Dokumentation hier
    ├── README.md                      ← ⭐ START HIER! Dokumentations-Hub
    ├── CHANGELOG_DOKUMENTATION.md     ← Meta: Dokumentations-Änderungen
    │
    ├── architecture/
    │   └── PROJECT_BRIEF.md           ← Vollständige Architektur (alle 3 Apps)
    │
    ├── glow/                          ← Glow-spezifische Dokumentation
    │   ├── README.md                  ← Glow-Übersicht
    │   ├── GLOW_SPEC_V2.md           ← ✨ AKTUELLE Spec
    │   ├── SPEC_CHANGELOG.md         ← Konzeptionelle Änderungen
    │   ├── CHANGELOG.md               ← Code-Entwicklungs-History
    │   └── implementation/            ← Technische Details
    │       ├── cosmic-profile-implementation.md
    │       ├── geocoding-implementation.md
    │       ├── claude-api-implementation.md
    │       ├── horoscope-strategy.md
    │       └── migration-daily-horoscopes-status.md  ← NEU!
    │
    ├── daily-logs/                    ← Session-Logs & Zusammenfassungen
    │   ├── README.md
    │   ├── 2026-02-08_session-zusammenfassung.md  ← NEU!
    │   ├── 2026-02-08_onboarding-2-schritte.md
    │   └── 2025-02-07_*.md
    │
    └── archive/                       ← Veraltete Dokumente
        ├── README.md
        └── GLOW_SPEC_V1.md            ← Ursprüngliche Spec (deprecated)
```

---

## Navigation

### Von Root-Dateien

- **`CLAUDE.md`** → verweist auf `docs/README.md` als Hub
- **`README.md`** → verweist auf `docs/README.md` + wichtigste Docs
- **`TODO.md`** → verweist auf Implementation-Docs bei Bedarf

### Von docs/README.md

- **Tabellarische Navigation** nach Use-Case (z.B. "Ich will Feature entwickeln" → GLOW_SPEC_V2.md)
- **Schnellzugriff-Tabelle** zu allen wichtigen Dokumenten
- **Struktur-Diagramm** zeigt gesamte Hierarchie

---

## Vorteile

✅ **Zentrale Navigation:** `docs/README.md` als Single Source of Truth
✅ **Sprechende Namen:** Sofort erkennbar, was die Datei enthält
✅ **Logische Gruppierung:** Session-Logs, Implementation-Details, Architektur getrennt
✅ **Skalierbar:** Neue Docs folgen klarer Namens-Konvention
✅ **Auffindbar:** Use-Case-basierte Tabelle in docs/README.md

---

## Nächste Schritte

1. ✅ **DONE:** Dateien verschoben und umbenannt
2. ✅ **DONE:** docs/README.md aktualisiert
3. ✅ **DONE:** README.md und CLAUDE.md aktualisiert
4. ⏳ **TODO:** Alte Session-Logs umbenennen nach neuer Konvention (optional)
5. ⏳ **TODO:** Bei neuen Docs: Konvention befolgen

---

**Datum:** 2026-02-08
**Dauer:** ~15 Min
**Ergebnis:** ✅ Dokumentation strukturiert, navigierbar, wartbar
