# Integration Guide - Beyond Horoscope Design & OTP Reports

## 🎯 Quick Start

### 1. Dependencies hinzufügen

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  pdf: ^3.10.0
  google_fonts: ^6.0.0
  lucide_icons: ^0.0.1

fonts:
  - family: NotoSans
    fonts:
      - asset: assets/fonts/NotoSans-Regular.ttf
      - asset: assets/fonts/NotoSans-Bold.ttf
        weight: 700
      - asset: assets/fonts/NotoSans-Italic.ttf
        style: italic
  - family: Nunito
    fonts:
      - asset: assets/fonts/Nunito-Regular.ttf
      - asset: assets/fonts/Nunito-Bold.ttf
        weight: 700
      - asset: assets/fonts/Nunito-Italic.ttf
        style: italic
```

### 2. Theme System integrieren

```dart
// main.dart
import 'package:flutter/material.dart';
import 'theme/beyond_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beyond Reports',
      theme: BeyondTheme.lightTheme,
      home: HomeScreen(),
    );
  }
}
```

### 3. Farben & Typografie verwenden

```dart
import 'package:flutter/material.dart';
import 'theme/beyond_theme.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BeyondColors.cardBackground,
        borderRadius: BorderRadius.circular(BeyondSpacing.cardRadius),
        border: Border.all(color: BeyondColors.cardBorder),
      ),
      padding: BeyondSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Golden headline
          Text(
            'Soul Purpose',
            style: BeyondTypography.headlineLarge.copyWith(
              color: BeyondColors.primaryGold,
            ),
          ),
          SizedBox(height: BeyondSpacing.md),
          
          // Body text
          Text(
            'Deine kosmische Bestimmung wartet auf dich...',
            style: BeyondTypography.bodyMedium,
          ),
          
          // Icon mit Farbe
          Icon(
            BeyondIcons.reportPurpose,
            color: BeyondColors.primaryGold,
            size: BeyondIcons.defaultSize,
          ),
        ],
      ),
    );
  }
}
```

## 📄 OTP-Report erstellen

### Schritt 1: Report-Daten zusammenstellen

```dart
import 'models/structured_report.dart';

StructuredReport buildSampleReport() {
  return StructuredReport(
    meta: ReportMeta(
      reportType: 'soulPurpose',
      generatedAt: DateTime.now(),
      wordCount: 5000,
      estimatedPages: 20,
    ),
    
    cover: ReportCover(
      headline: 'Soul Purpose',
      subheadline: 'Die heilige Geometrie deines Seelenplans',
      userName: 'Anna Schmidt',
      birthDate: '15. März 1990',
      sunSign: 'Fische',
      chineseAnimal: 'Pferd',
      lifePathNumber: 7,
    ),
    
    executiveSummary: ExecutiveSummary(
      biggestOpportunity: 'Deine intuitive Gabe ist außergewöhnlich stark. '
          'Nutze sie, um anderen den Weg zu weisen.',
      biggestBlocker: 'Die Angst vor deiner eigenen Macht hält dich zurück. '
          'Dein Pluto in Skorpion fordert dich auf, diese Macht anzunehmen.',
      focusForNextYear: 'Das kommende Jahr ist deine Zeit für spirituelle '
          'Vertiefung. Dein Nordknoten ruft dich zu deiner wahren Bestimmung.',
    ),
    
    intro: ReportIntro(
      synthesis: 'Du bist eine Suchende, eine Brückenbauerin zwischen den '
          'Welten. Deine Seele kam hierher, um tiefe Transformation zu erleben '
          'und andere durch ihre Dunkelheit ins Licht zu führen.',
      dominantVector: 'Westliche Astrologie',
    ),
    
    pullQuotes: [
      'Deine größte Gabe liegt in deiner Fähigkeit, das Unsichtbare sichtbar zu machen.',
      'Der Schmerz, den du transformiert hast, ist deine Superkraft.',
      'Deine Bestimmung ist es, Heilung durch tiefes Verstehen zu bringen.',
    ],
    
    logicData: ReportLogicData(
      beyondTriangle: BeyondTriangle(
        westernAstrology: 45,
        chineseAstrology: 25,
        numerology: 30,
      ),
      elementBalance: ElementBalance(
        fire: 15,
        earth: 20,
        air: 25,
        water: 40,
        wood: 30,
        metal: 20,
      ),
      numerologyGrid: NumerologyGrid(
        lifePathNumber: 7,
        destinyNumber: 9,
        soulUrgeNumber: 11,
        personalityNumber: 2,
        maturityNumber: 7,
        personalYear: 5,
      ),
    ),
    
    bodySections: [
      ReportBodySection(
        title: 'Deine Seelenzahl 11',
        content: 'Die Meisterzahl 11 zeigt, dass du nicht hierher kamst, '
            'um ein gewöhnliches Leben zu leben. Du bist eine spirituelle '
            'Lehrerin, eine Lichtträgerin, eine Visionärin.\n\n'
            'Deine Sensibilität ist keine Schwäche – sie ist dein Werkzeug, '
            'um die feinstofflichen Ebenen wahrzunehmen, die anderen verborgen bleiben.',
        keyInsight: 'Du bist keine Suchende mehr – du bist bereit, zur Führenden zu werden.',
        beyondAction: BeyondAction(
          task: 'Starte einen spirituellen Blog oder Podcast, in dem du deine '
              'Erkenntnisse mit anderen teilst.',
          timeframe: 'Innerhalb der nächsten 3 Monate',
          category: 'Soul Expression',
        ),
      ),
      
      ReportBodySection(
        title: 'Nordknoten in Wassermann',
        content: 'Dein Nordknoten in Wassermann ruft dich dazu auf, deine '
            'Individualität radikal zu umarmen. Du sollst nicht mehr der Masse '
            'folgen, sondern deinen eigenen, unkonventionellen Weg gehen.\n\n'
            'Die Gemeinschaft, die du suchst, ist nicht die traditionelle Familie '
            'oder Gruppe – es ist eine Seelenfamilie von Gleichgesinnten, die '
            'ebenfalls die Normen hinterfragen.',
        keyInsight: 'Deine Exzentrizität ist deine Stärke, nicht deine Schwäche.',
      ),
    ],
    
    closing: ReportClosing(
      summary: 'Du stehst an der Schwelle zu deinem authentischen Leben. '
          'Die kosmische Konfiguration deiner Geburt zeigt klar: Du bist hier, '
          'um zu leuchten, zu heilen und zu führen. Deine Zeit ist jetzt.',
      actionItems: [
        'Meditiere täglich 20 Minuten, um deine intuitive Führung zu stärken',
        'Suche dir einen Mentor für spirituelle Entwicklung',
        'Beginne, deine Erkenntnisse öffentlich zu teilen (Blog, Social Media)',
        'Schaffe dir einen heiligen Raum für deine spirituelle Praxis',
      ],
      dharmaChecklist: DharmaChecklist(
        impactCheck: 'Habe ich diese Woche einen Beitrag geleistet, '
            'der größer ist als ich selbst?',
        growthCheck: 'Bin ich heute einen Schritt aus meiner Komfortzone '
            'herausgegangen?',
        talentCheck: 'Habe ich meine Gaben diese Woche mit anderen geteilt?',
      ),
    ),
  );
}
```

### Schritt 2: PDF generieren

```dart
import 'dart:typed_data';
import 'services/luxury_pdf_generator.dart';

Future<Uint8List> generateReport() async {
  final report = buildSampleReport();
  
  final generator = LuxuryPdfGenerator();
  final pdfBytes = await generator.generateLuxuryPdf(
    report,
    ReportType.soulPurpose,
  );
  
  return pdfBytes;
}

// PDF teilen/speichern
Future<void> shareReport() async {
  final report = buildSampleReport();
  final generator = LuxuryPdfGenerator();
  
  await generator.sharePdf(report, ReportType.soulPurpose);
}
```

## 🎨 UI-Komponenten

### Beyond Card

```dart
class BeyondCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color? accentColor;

  const BeyondCard({
    required this.title,
    required this.content,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BeyondColors.cardBackground,
        borderRadius: BorderRadius.circular(BeyondSpacing.cardRadius),
        border: Border.all(color: BeyondColors.cardBorder),
      ),
      padding: BeyondSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: accentColor ?? BeyondColors.primaryGold,
                size: BeyondIcons.largeSize,
              ),
              SizedBox(width: BeyondSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: BeyondTypography.headlineSmall,
                ),
              ),
            ],
          ),
          SizedBox(height: BeyondSpacing.lg),
          Text(
            content,
            style: BeyondTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}
```

### Beyond Button

```dart
class BeyondButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const BeyondButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return isPrimary
        ? ElevatedButton(
            onPressed: onPressed,
            child: Text(label),
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: Text(label),
          );
  }
}
```

## 📊 Visualisierungs-Komponenten

### Beyond Triangle Widget

```dart
class BeyondTriangleWidget extends StatelessWidget {
  final BeyondTriangle triangle;

  const BeyondTriangleWidget({required this.triangle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBar('Westliche Astrologie', triangle.westernAstrology),
        SizedBox(height: BeyondSpacing.sm),
        _buildBar('Chinesische Astrologie', triangle.chineseAstrology),
        SizedBox(height: BeyondSpacing.sm),
        _buildBar('Numerologie', triangle.numerology),
      ],
    );
  }

  Widget _buildBar(String label, int percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: BeyondTypography.bodySmall),
            Text('$percentage%', style: BeyondTypography.labelMedium),
          ],
        ),
        SizedBox(height: BeyondSpacing.xs),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: BeyondColors.backgroundMuted,
          color: BeyondColors.primaryGold,
        ),
      ],
    );
  }
}
```

## 🔐 Best Practices

### 1. Farben konsistent verwenden
- Verwende IMMER `BeyondColors.*` statt hardcoded Hex-Werte
- Primary Gold für Akzente, Call-to-Actions, Icons
- Cosmic Nude für sekundäre Elemente, Badges
- Warm White für Hintergründe

### 2. Typografie
- Headlines: `BeyondTypography.headline*`
- Body: `BeyondTypography.body*`
- Labels: `BeyondTypography.label*`
- Section Headers: `BeyondTypography.sectionHeader`

### 3. Spacing
- Verwende IMMER `BeyondSpacing.*` statt hardcoded Pixel-Werte
- `xs` (4px) für minimale Abstände
- `md` (12px) für Standard-Abstände
- `xl` (24px) für große Abstände

### 4. Icons
- Verwende Lucide Icons via `BeyondIcons.*`
- Report-Icons: `BeyondIcons.getReportIcon()`
- Element-Icons: `BeyondIcons.getElementIcon()`

### 5. PDF-Generierung
- Verwende Noto Sans für Unicode-Support (Tierkreiszeichen, etc.)
- Alle Farben in PdfColor konvertieren
- A4 Portrait (595x842 points)

---

**Viel Erfolg bei der Integration! 🚀**
