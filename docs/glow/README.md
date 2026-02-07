# 🌙 Nuuray Glow — Dokumentation

Alle Glow-spezifischen Dokumente und Implementierungs-Details.

---

## 📁 Struktur

```
docs/glow/
├── README.md                          ← Du bist hier
├── GLOW_SPEC.md                       ← Original-Spezifikation (veraltet, ersetzt durch V2)
├── GLOW_SPEC_V2.md                    ← ✨ AKTUELLE Vollständige Projektbeschreibung
├── SPEC_CHANGELOG.md                  ← ✨ Änderungshistorie der Spezifikation
├── CHANGELOG.md                       ← Code-Entwicklungs-History
└── implementation/
    ├── COSMIC_PROFILE_IMPLEMENTATION.md   ← Cosmic Profile Dashboard (Tech-Details)
    ├── GEOCODING_IMPLEMENTATION.md        ← Google Places Integration
    ├── CLAUDE_API_IMPLEMENTATION.md       ← Claude API Integration
    └── HOROSCOPE_STRATEGY.md              ← 3-Stufen Horoskop-Strategie
```

---

## 📚 Wichtigste Dokumente

### 1. **GLOW_SPEC_V2.md** (NEU!) ⭐
**Vollständige Projektbeschreibung** — aktualisiert am 2026-02-07

**Enthält:**
- 2-Schritte Onboarding (statt 3)
- "Deine Signatur" Dashboard (statt "Cosmic Profile")
- Sprachen-Strategie (DE + EN ab Tag 1)
- Jahresvorschau-Feature (Premium, On-Demand)
- Detaillierte Screen-Mockups
- Datenbank-Schema mit allen Tabellen
- Content-Strategie (Tageshoroskop, Wochenausblick, Partner-Check)

**Wann lesen:**
- Für vollständigen Überblick über Glow
- Bei konzeptionellen Fragen
- Für UX/UI-Entscheidungen
- Für Feature-Planung

---

### 2. **SPEC_CHANGELOG.md** (NEU!)
**Änderungshistorie** — was hat sich konzeptionell geändert?

**Enthält:**
- "Cosmic Profile" → "Deine Signatur" (Naming)
- Dashboard-Platzierung (oben auf Home Screen)
- Onboarding: 3 → 2 Schritte
- Name-Felder neu strukturiert
- Jahresvorschau hinzugefügt
- Sprachen-Strategie definiert

**Wann lesen:**
- Bei Inkonsistenzen zwischen Code und Docs
- Um zu verstehen, warum etwas anders ist als erwartet

---

### 3. **GLOW_SPEC.md** (Original, veraltet)
⚠️ **Veraltet** — ersetzt durch GLOW_SPEC_V2.md

Nur noch zur Referenz, falls man sehen will, wie das ursprüngliche Konzept war.

---

### 4. **CHANGELOG.md**
**Code-Entwicklungs-History** — was wurde wann implementiert?

**Enthält:**
- Release-Notes (0.1.0, 0.2.0, etc.)
- Bug-Fixes mit Details
- Feature-Implementierungen
- Deployment-Status

**Wann lesen:**
- Um zu sehen, was bereits funktioniert
- Bei Debugging (wann wurde was geändert?)

---

## 🛠️ Implementation Docs

### **COSMIC_PROFILE_IMPLEMENTATION.md**
Technische Details zum Cosmic Profile Dashboard (wird zu "Deine Signatur" umbenannt)

**Enthält:**
- Calculator-Services (Western Astrology, Bazi, Numerologie)
- Datenmodelle (BirthChart, NumerologyProfile)
- UI-Widgets (Cards, Expandable Sections)
- Supabase-Integration

---

### **GEOCODING_IMPLEMENTATION.md**
Google Places API Integration (Server-seitig)

**Enthält:**
- Edge Function: `geocode-place`
- Google Cloud Setup
- Kosten-Analyse ($200/Monat Free Tier)
- Deployment-Anleitung

---

### **CLAUDE_API_IMPLEMENTATION.md**
Claude API Integration für Content-Generierung

**Enthält:**
- ClaudeApiService (Tageshoroskop, Cosmic Profile Interpretation)
- Kosten-Kalkulation (MVP: ~$11/Monat)
- Caching-Strategie (99.9% Einsparung)
- Prompt-Templates

---

### **HOROSCOPE_STRATEGY.md**
3-Stufen Horoskop-Strategie (A/B/C)

**Enthält:**
- Variante A: UI-Synthese ($1.80/Monat)
- Variante B: Mini-Personalisierung ($31.80/Monat)
- Variante C: Tiefe Synthese ($46.80/Monat)
- Kosten-Vergleich
- PersonalInsights (60 Bazi + 33 Numerologie)

---

## 🔄 Inkonsistenzen zwischen Code & Docs

### ⚠️ Onboarding
**Code (implementiert):** 3 Schritte, 4 Name-Felder
**GLOW_SPEC_V2.md:** 2 Schritte, 3 Name-Felder

**Status:** Konzeptionelle Änderung noch nicht umgesetzt

**Nächste Schritte:**
1. Testing mit aktuellem Code
2. Entscheidung: Code anpassen ODER Dokumentation korrigieren

---

### ⚠️ Naming: "Cosmic Profile" vs. "Deine Signatur"
**Code:** Verwendet "Cosmic Profile"
**GLOW_SPEC_V2.md:** Verwendet "Deine Signatur"

**Status:** Umbenennung geplant, noch nicht im Code

**Nächste Schritte:**
1. Code-Suche: `Cosmic Profile` → `Deine Signatur`
2. Datenbank: `cosmic_profiles` → `signature_profiles`
3. Provider: `cosmicProfileProvider` → `signatureProfileProvider`

---

## 📊 Entwicklungs-Status

| Feature | Code | Spec V2 | Status |
|---------|------|---------|--------|
| Auth | ✅ | ✅ | Produktionsreif |
| Onboarding (3 Schritte) | ✅ | ⚠️ (2 Schritte) | Inkonsistenz |
| Geocoding | ✅ | ✅ | Funktioniert |
| Cosmic Profile Dashboard | ✅ | ⚠️ (heißt "Deine Signatur") | Naming-Inkonsistenz |
| Claude API | ✅ | ✅ | Getestet, bereit |
| 3-Stufen Horoskop | ✅ | ✅ | Implementiert |
| i18n (DE/EN) | ❌ | ✅ | Geplant |
| Jahresvorschau | ❌ | ✅ | Geplant |

---

## 🚀 Prioritäten

### SOFORT (Testing)
1. App durchspielen mit aktuellem Code
2. Cosmic Profile Dashboard prüfen
3. Claude API testen (Key holen!)

### DANN (Konzept-Anpassungen)
1. Entscheiden: Onboarding 2 oder 3 Schritte?
2. Umbenennung: "Cosmic Profile" → "Deine Signatur"
3. i18n-Integration (ARB-Dateien)

### SPÄTER (Neue Features)
1. Edge Function: `generate-daily-horoscopes`
2. Settings Screen mit Sprach-Auswahl
3. Jahresvorschau-Feature

---

**Letzte Aktualisierung:** 2026-02-07
**Maintainer:** Solo-Entwicklung (Natalie)
