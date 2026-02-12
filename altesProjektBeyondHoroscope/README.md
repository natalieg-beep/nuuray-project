# Beyond Horoscope - Design & OTP Report System Export

Dieses Paket enthält alle Design-System-Dateien und OTP-Report-Strukturen aus dem Beyond Horoscope Projekt.

## 📁 Struktur

### 1. Theme System (`theme/`)
- **beyond_theme.dart** - Vollständiges Design-System mit:
  - Cosmic Nude Farbpalette (Gold, Nude, Warm White)
  - Typografie (Playfair Display + Montserrat)
  - Icons (Lucide Icons)
  - Spacing & Layout-Konstanten
  - Zodiac & Chinese Zodiac Glyphs

- **app_theme.dart** - Alternative Theme-Variante (Nunito-basiert)
- **branding_assets.dart** - Logo & Asset-Pfade

### 2. Report Models (`models/`)
- **structured_report.dart** - Hauptmodell für alle OTP-Reports
  - `StructuredReport` - Master-Report-Format
  - `ExecutiveSummary` - Die Golden Three
  - `BeyondTriangle` - Gewichtung der 3 Systeme
  - `ElementBalance` - Elementare Verteilung
  - `NumerologyGrid` - Numerologie-Daten
  - `BeyondAction` - Konkrete Handlungsempfehlungen
  - `DharmaChecklist` - Monday Morning Check-In

### 3. PDF Generators (`services/`)
- **luxury_pdf_generator.dart** - Basis-PDF-Generator für alle Reports
  - A4 Portrait Layout
  - Cosmic Nude Design
  - Unicode-sicher (Noto Sans Font)
  - Cover Page, Executive Summary, Visualizations
  - Beyond-Dreieck, Element-Waage, Numerologie-Grid
  - Energy Forecast (Transit-Radar, 12-Monate-Phasen)

- **soul_purpose_pdf_generator.dart** - Spezialisiert für Soul Purpose Reports
  - Spirit Indigo + Pearlescent Akzente
  - Soul Compass Visualization
  - Lotus & Moon Node Symbole

- **shadow_light_pdf_generator.dart** - Spezialisiert für Shadow & Light Reports
  - Dark Mode (Midnight Blue, Deep Purple)
  - Pluto & Lilith Analysen
  - 4-Phase Shadow Radar

### 4. Assets (`assets/`)
- **Fonts**:
  - NotoSans (Regular, Bold, Italic) - Für PDF Unicode-Support
  - Nunito (Regular, Bold, Italic) - Alternative Font

## 🎨 Design-Philosophie

### Farbpalette (Cosmic Nude)
- **Primary Gold**: `#D4AF37` - Luxus, Akzente
- **Cosmic Nude**: `#B8A394` - Warm, elegant
- **Warm White**: `#FAF8F5` - Hintergrund
- **Deep Charcoal**: `#2D2926` - Text

### Typografie
- **Headlines**: Playfair Display (Serif) - Elegant, poetisch
- **Body**: Montserrat (Sans) - Modern, lesbar
- **PDF**: Noto Sans - Unicode-sicher für alle Zeichen

### Report-Struktur
Alle OTP-Reports folgen diesem Format:
1. **Cover Page** - Headline, Subheadline, User Identity
2. **Executive Summary** - Die Golden Three (Chance, Blocker, Fokus)
3. **Identity Page** - 3 Systeme (Western/Chinese/Numerology)
4. **Beyond Insights** - Pull Quotes
5. **Visualizations** - Beyond-Dreieck, Element-Waage, Numerologie-Grid
6. **Energy Forecast** - Transit-Radar, 12-Monate-Phasen
7. **Body Sections** - Hauptinhalt mit Key Insights & Beyond Actions
8. **Closing Page** - Summary, Action Items, Dharma Checklist

## 🚀 Integration in neues Projekt

### 1. Theme System kopieren
```dart
import 'package:dein_projekt/theme/beyond_theme.dart';

MaterialApp(
  theme: BeyondTheme.lightTheme,
  // ...
);
```

### 2. Report-Modell verwenden
```dart
import 'package:dein_projekt/models/structured_report.dart';

final report = StructuredReport(
  meta: ReportMeta(
    reportType: 'soulPurpose',
    generatedAt: DateTime.now(),
    wordCount: 5000,
    estimatedPages: 20,
  ),
  cover: ReportCover(
    headline: 'Soul Purpose Report',
    subheadline: 'Deine kosmische Bestimmung',
    userName: 'Max Mustermann',
    // ...
  ),
  // ...
);
```

### 3. PDF generieren
```dart
import 'package:dein_projekt/services/luxury_pdf_generator.dart';

final pdfBytes = await LuxuryPdfGenerator().generateLuxuryPdf(
  report,
  ReportType.soulPurpose,
);
```

## 📊 Report-Typen

- **Soul Purpose** - Seelenzahl, Nordknoten, Karma
- **Shadow & Light** - Pluto, Lilith, Schatten-Integration
- **Purpose Path** - MC, Nordknoten, Expression Number
- **Body Vitality** - 6. Haus, Saturn, Gesundheit
- **Yearly Forecast** - Persönliches Jahr, Transite

## 🔧 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  pdf: ^3.10.0
  google_fonts: ^6.0.0
  lucide_icons: ^0.0.1
```

## 📝 Hinweise

- **Unicode-Support**: Noto Sans Font für alle Sonderzeichen (Tierkreiszeichen, etc.)
- **Responsive**: A4 Portrait (595x842 points)
- **Color-Safe**: Alle Farben im PdfColor-Format
- **Font-Loading**: Async Font-Loading mit Fallback auf Helvetica

---

**Erstellt**: Februar 2026  
**Quelle**: Beyond Horoscope v1.0  
**Autor**: Natalie G.
