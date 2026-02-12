# NUURAY GLOW — Reports & OTPs (One-Time Purchases)

**Erstellt:** 2026-02-12
**Status:** 📋 Konzept (basierend auf Beyond Horoscope v1.0)
**Monetarisierung:** Einmalige Käufe (€2,99 - €9,99), kein Abo

---

## 🎯 Vision: Reports als Premium-Produkte

Reports sind **hochwertige, personalisierte PDF-Dossiers** (15-25 Seiten), die dem User tiefe Einblicke in spezifische Lebensthemen geben. Im Gegensatz zum Premium-Abo (monatliche Features) sind Reports **einmalige Käufe** für spezielle Analysen.

### Warum OTPs statt Abo?
- **Niedrige Einstiegshürde**: User können einzelne Reports testen, bevor sie ein Abo abschließen
- **Gezielte Bedürfnisse**: Nicht jeder braucht alle Reports
- **Upsell-Potenzial**: Reports generieren höhere Einzelumsätze als ein Abo-Monat
- **Shareability**: PDFs können ausgedruckt/gespeichert/geteilt werden → Viralität

---

## 📊 Report-Katalog (aus Beyond Horoscope v1.0)

Basierend auf dem Code in `altesProjektBeyondHoroscope/`, waren folgende Reports geplant:

| Report-Typ | Fokus | Preis (geplant) | Status |
|------------|-------|-----------------|--------|
| **Soul Purpose** | Seelenmission, Nordknoten, Life Path | €7,99 | 📋 Konzept |
| **Shadow & Light** | Pluto, Lilith, Schatten-Integration | €7,99 | 📋 Konzept |
| **The Purpose Path** | MC (Berufung), Nordknoten, Expression Number | €6,99 | 📋 Konzept |
| **Body Vitality** | 6. Haus, Saturn, Gesundheit & Energie | €5,99 | 📋 Konzept |
| **Yearly Forecast** | Persönliches Jahr, Solar Return, Transite | €9,99 | 📋 Konzept |
| **SoulMate Finder** | Partner-Kompatibilität (2 Charts) | €4,99 | 📋 Konzept |

---

## 📄 Report-Struktur (Luxury Dossier Format)

Jeder Report folgt diesem professionellen Format:

### 1. **Cover Page**
- Report-Titel (z.B. "Soul Purpose")
- Subheadline (z.B. "Die heilige Geometrie deines Seelenplans")
- User-Identity: Name, Geburtsdatum, Sternzeichen, Chinesisches Tierkreiszeichen, Life Path

### 2. **Executive Summary ("Die Golden Three")**
Auf einen Blick die wichtigsten Insights:
- **Biggest Opportunity** — Wo liegt dein größtes Potential?
- **Biggest Blocker** — Was hält dich zurück?
- **Focus for Next Year** — Worauf solltest du dich konzentrieren?

### 3. **Identity Page**
Deine astrologische Signatur:
- Western Astrology (Sonne/Mond/Aszendent + Aspekte)
- Chinese Astrology (Vier Säulen, Day Master, Elemente)
- Numerology (Life Path, Expression, Soul Urge, Maturity)

### 4. **Beyond Insights**
3-5 Pull Quotes (poetische Kernaussagen):
> "Deine größte Gabe liegt in deiner Fähigkeit, das Unsichtbare sichtbar zu machen."

### 5. **Visualizations**
- **Beyond-Dreieck**: Gewichtung der 3 Systeme (Western 45% / Bazi 25% / Numerologie 30%)
- **Element-Balance**: Verteilung der Elemente (Feuer, Erde, Luft, Wasser, Holz, Metall)
- **Numerologie-Grid**: Alle Kern-Zahlen visualisiert

### 6. **Energy Forecast**
- **Transit-Radar**: Aktuell wichtige Planeten-Energien (4-Phasen-Radar)
- **12-Monate-Phasen**: Quartalsweise Prognose

### 7. **Body Sections** (Hauptinhalt)
Thematische Kapitel mit:
- **Titel** (z.B. "Deine Seelenzahl 11")
- **Content** (2-3 Absätze, ~300 Wörter)
- **Key Insight** (1 Satz, fett hervorgehoben)
- **Beyond Action** (konkrete Handlungsempfehlung mit Zeitrahmen)

### 8. **Closing Page**
- **Summary**: Zusammenfassung des Reports
- **Action Items**: 4-6 konkrete To-Dos
- **Dharma Checklist**: "Monday Morning Check-In" (3 Reflexionsfragen)

---

## 🎨 Design-System (Cosmic Nude)

**Farbpalette:**
- **Primary Gold**: `#D4AF37` — Akzente, CTAs
- **Cosmic Nude**: `#B8A394` — Warm, elegant
- **Warm White**: `#FAF8F5` — Hintergrund
- **Deep Charcoal**: `#2D2926` — Text

**Typografie:**
- **Headlines**: Playfair Display (Serif, elegant)
- **Body**: Montserrat (Sans, modern)
- **PDF**: Noto Sans (Unicode-Support für ♈︎♉︎♊︎)

**Layout:**
- A4 Portrait (595x842 points)
- 2-Spalten-Layout für Body-Sections
- Große Weißräume (luxuriöser Look)

---

## 🔧 Technische Architektur

### Datenmodell: `StructuredReport`

```dart
class StructuredReport {
  final ReportMeta meta;                    // Type, Datum, Word Count
  final ReportCover cover;                  // Titel, User-Identity
  final ExecutiveSummary? executiveSummary; // Golden Three
  final ReportIntro intro;                  // Synthese-Text
  final List<String> pullQuotes;            // 3-5 Zitate
  final ReportLogicData logicData;          // Beyond-Dreieck, Element-Balance
  final List<ReportBodySection> bodySections; // Hauptinhalt
  final ReportClosing closing;              // Summary, Action Items
}
```

### PDF-Generierung: `LuxuryPdfGenerator`

- **Input**: `StructuredReport` (JSON-basiert)
- **Output**: PDF (Uint8List)
- **Features**:
  - Unicode-Support (Tierkreiszeichen, Chinesische Zeichen)
  - Automatische Seitenumbrüche
  - Visualisierungen (Dreieck, Waage, Grid)
  - Sharing (Web: Download, Native: Share Sheet)

### Content-Generierung: Claude API

- **Prompt-Template** pro Report-Typ
- **Input**: `BirthChart` (aus Datenbank)
- **Output**: `StructuredReport` (JSON)
- **Word Count**: ~5.000 Wörter (20 Seiten)
- **Tone**: Warm, inspirierend, poetisch (siehe Brand Soul)

---

## 🚀 Entwicklungs-Phasen

### Phase 1: MVP (After Glow Launch)
- [ ] **SoulMate Finder** (Partner-Check)
  - Technisch am einfachsten (2 Charts vergleichen)
  - Hohe Nachfrage ("Passen wir zusammen?")
  - Test-Kandidat für Report-System

### Phase 2: Core Reports (Q2 2026)
- [ ] **Soul Purpose** (Seelenmission)
- [ ] **Yearly Forecast** (Jahres-Prognose)

### Phase 3: Expansion (Q3 2026)
- [ ] **Shadow & Light** (Schatten-Arbeit)
- [ ] **The Purpose Path** (Berufung)
- [ ] **Body Vitality** (Gesundheit)

---

## 💰 Monetarisierungs-Strategie

### Pricing Tiers
- **Quick Check** (SoulMate Finder): €4,99
- **Standard Reports** (Purpose Path, Body Vitality): €5,99 - €6,99
- **Deep-Dive Reports** (Soul Purpose, Shadow & Light): €7,99
- **Premium Reports** (Yearly Forecast): €9,99

### Bundle-Angebote
- **Soul Trio**: Soul Purpose + Shadow & Light + Purpose Path = €19,99 (statt €22,97)
- **Full Insight Package**: Alle 6 Reports = €39,99 (statt €42,95)

### Freemium-Strategie
- **Free**: Tageshoroskop, Mondphasen, Basic Signatur
- **Premium Abo** (€9,99/Monat): Erweiterte Features, Wochen-/Monats-Prognosen
- **OTP Reports**: Einmalige Deep-Dives (€4,99 - €9,99)

---

## 📱 UI/UX: Wo leben Reports in Glow?

### Option A: Eigener Tab "Explore" (Empfohlen)

```
┌─────────────────────────────────────┐
│  [Heute] [Kalender] [Explore] [Ich] │ ← Bottom Navigation
└─────────────────────────────────────┘

Explore Screen:
├─ Header: "Entdecke deine Tiefen"
├─ Featured Report (Wechselnd)
├─ Report-Kategorien:
│  ├─ 💫 Seele & Purpose
│  │  ├─ Soul Purpose Report
│  │  └─ Shadow & Light Report
│  ├─ 💼 Berufung & Erfolg
│  │  └─ Purpose Path Report
│  ├─ 💖 Beziehungen
│  │  └─ SoulMate Finder
│  ├─ 🌱 Gesundheit & Energie
│  │  └─ Body Vitality Report
│  └─ 📅 Prognosen
│     └─ Yearly Forecast
└─ "Meine Reports" (Gekaufte Reports)
```

### Option B: Section im Home Screen

```
Home Screen:
├─ Archetyp Header
├─ Tageshoroskop
├─ Mondphase
├─ Deine Signatur
└─ 📊 Empfohlene Reports  ← NEU
   ├─ "Bereit für mehr?"
   ├─ Featured Report Card (1-2)
   └─ "Alle Reports anzeigen" Button
```

### Option C: Profil-Integration

```
Profil Screen (Ich):
├─ Profil bearbeiten
├─ Einstellungen
├─ 📊 Meine Reports  ← NEU
│  ├─ Gekaufte Reports
│  └─ "Neue Reports entdecken"
└─ Premium
```

**Empfehlung: Hybrid A + B**
- **Bottom Tab "Explore"** für Report-Katalog (Discovery)
- **Home Screen Section** für personalisierte Empfehlungen (Upsell)
- **Profil "Meine Reports"** für Bibliothek (Zugriff)

---

## 🎯 Report-Kauf-Flow

```
1. User entdeckt Report (Explore/Home)
   ↓
2. Report-Preview-Screen
   - Was erwartet dich? (Teaser-Content)
   - Sample-Seiten (2-3 Seiten als Vorschau)
   - Preis & "Jetzt kaufen" Button
   ↓
3. In-App Purchase (StoreKit / Google Play)
   - Einmalige Zahlung (€4,99 - €9,99)
   ↓
4. Report-Generierung (Claude API)
   - Loading-Screen: "Dein Report wird erstellt..."
   - Progress: "Analysiere dein Chart..." → "Verwebe die Systeme..." → "Fast fertig..."
   ↓
5. Report-Ansicht
   - PDF-Viewer (in-app)
   - "Download PDF" Button
   - "Teilen" Button (Share Sheet)
   ↓
6. Report-Bibliothek
   - Alle gekauften Reports
   - Re-Download möglich
   - "Neuen Report kaufen" CTA
```

---

## 🔮 Zukunfts-Ideen (Phase 4+)

- **Monthly Deep-Dive**: Monatlicher Report zu aktuellen Transiten (€3,99/Monat)
- **Custom Reports**: User wählt Thema (z.B. "Karriere-Switch", "Baby-Timing") → €12,99
- **Couple's Journey**: 3-Monate-Beziehungs-Report-Serie (€24,99)
- **Print-Option**: Physisches Buch (A5, Hardcover) für €39,99 + Versand

---

## 📚 Code-Basis (aus Beyond Horoscope)

Verfügbar in `/altesProjektBeyondHoroscope/`:

- **Models**: `structured_report.dart` (vollständiges Datenmodell)
- **PDF Generator**: `luxury_pdf_generator.dart` (A4 Portrait, Cosmic Nude Design)
- **Theme**: `beyond_theme.dart` (Farben, Typografie, Icons)
- **Assets**: Noto Sans & Nunito Fonts (Unicode-Support)

**Integration-Status:**
- ✅ Modelle vorhanden
- ✅ PDF-Generator fertig
- ⏳ Claude API Prompts (müssen für NUURAY Brand Voice angepasst werden)
- ⏳ UI-Screens (müssen in Glow-Design übersetzt werden)

---

## ✅ Next Steps

### 1. MVP: SoulMate Finder implementieren
- [ ] Report-Modell in `nuuray_core` integrieren
- [ ] PDF-Generator in `nuuray_api` portieren
- [ ] Claude API Prompt für Partner-Check schreiben
- [ ] UI: Report-Preview-Screen
- [ ] UI: Report-Viewer-Screen
- [ ] In-App Purchase: Produkt anlegen (€4,99)
- [ ] Testing: 10 Test-Käufe mit echten User-Daten

### 2. Explore-Tab vorbereiten
- [ ] Bottom Navigation um "Explore" erweitern
- [ ] Explore-Screen Layout
- [ ] Report-Katalog-Design
- [ ] Featured-Report Rotation-Logic

### 3. Content-Vorbereitung
- [ ] Soul Purpose Prompt (Brand Voice-kompatibel)
- [ ] Yearly Forecast Prompt
- [ ] Test-Generierungen (5-10 Reports manuell reviewen)

---

**Zusammenfassung:**

Reports sind ein **zentraler Monetarisierungs-Pfeiler** für Glow. Sie bieten:
- **Höhere Margen** als Abos
- **Weniger Churn** (einmaliger Kauf)
- **Shareable Content** (PDFs → Viralität)
- **Upsell-Potenzial** für Free- & Premium-User

Der Code aus Beyond Horoscope v1.0 gibt uns einen **riesigen Vorsprung** — wir müssen nur das Design anpassen und die Prompts für die NUURAY Brand Voice überarbeiten! 🚀
