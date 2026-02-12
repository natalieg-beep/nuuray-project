// ============================================================
// LUXURY PDF GENERATOR - Beyond Dossier Format
// ============================================================
//
// Creates elegant, high-end PDF documents from StructuredReports.
// Features:
// - Professional cover page with identity data
// - Beyond Insights (pull quotes)
// - Data visualizations (Beyond-Dreieck, Element-Waage)
// - Two-column layout for body content
// - Cosmic Nude color palette
// - Clean, markdown-free typography
//
// ============================================================

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

import '../core/theme/branding_assets.dart';
import '../models/structured_report.dart';
import 'synthesis_engine.dart';

// Conditional imports for native platforms
import 'luxury_pdf_generator_native.dart'
    if (dart.library.html) 'luxury_pdf_generator_web.dart' as platform;

class LuxuryPdfGenerator {
  // Singleton
  static final LuxuryPdfGenerator _instance = LuxuryPdfGenerator._internal();
  factory LuxuryPdfGenerator() => _instance;
  LuxuryPdfGenerator._internal();

  // ============================================================
  // COSMIC NUDE COLOR PALETTE
  // ============================================================

  static const PdfColor _cosmicNude = PdfColor.fromInt(0xFFB8A394);
  static const PdfColor _cosmicNudeLight = PdfColor.fromInt(0xFFD4C4B5);
  static const PdfColor _cosmicNudeDark = PdfColor.fromInt(0xFF8B7355);
  static const PdfColor _warmWhite = PdfColor.fromInt(0xFFFAF8F5);
  static const PdfColor _deepCharcoal = PdfColor.fromInt(0xFF2D2926);
  static const PdfColor _softGray = PdfColor.fromInt(0xFF6B6B6B);
  static const PdfColor _accentGold = PdfColor.fromInt(0xFFD4AF37);

  // Element colors
  static const PdfColor _fireColor = PdfColor.fromInt(0xFFE85A4F);
  static const PdfColor _earthColor = PdfColor.fromInt(0xFF8B7355);
  static const PdfColor _airColor = PdfColor.fromInt(0xFF87CEEB);
  static const PdfColor _waterColor = PdfColor.fromInt(0xFF4A90A4);
  static const PdfColor _woodColor = PdfColor.fromInt(0xFF6B8E23);
  static const PdfColor _metalColor = PdfColor.fromInt(0xFFC0C0C0);

  // ============================================================
  // PAGE FORMAT - Explicit A4 Portrait (595 x 842 points)
  // ============================================================
  // WICHTIG: Explizit Portrait definieren, da PdfPageFormat.a4
  // auf manchen Systemen/Browsern Querformat liefern kann
  static const PdfPageFormat _a4Portrait = PdfPageFormat(
    595.28,  // width in points (210mm)
    841.89,  // height in points (297mm)
    marginAll: 0,
  );

  // ============================================================
  // UNICODE GLYPHS FOR PDF (No Lucide Icons)
  // ============================================================

  /// Zodiac abbreviations (keine Unicode-Symbole - Font unterstützt sie nicht!)
  static const Map<String, String> _zodiacGlyphs = {
    'aries': 'AR',       // Widder
    'taurus': 'TA',      // Stier
    'gemini': 'GE',      // Zwillinge
    'cancer': 'CA',      // Krebs
    'leo': 'LE',         // Löwe
    'virgo': 'VI',       // Jungfrau
    'libra': 'LI',       // Waage
    'scorpio': 'SC',     // Skorpion
    'sagittarius': 'SA', // Schütze
    'capricorn': 'CP',   // Steinbock
    'aquarius': 'AQ',    // Wassermann
    'pisces': 'PI',      // Fische
  };

  /// Safe ASCII glyphs for PDF rendering
  /// WICHTIG: Keine Unicode-Symbole verwenden - Nunito Font unterstützt sie nicht!
  static const String glyphStar = '*';      // War: ✦
  static const String glyphSun = 'O';       // War: ☉
  static const String glyphMoon = 'C';      // War: ☽
  static const String glyphArrow = '>';     // War: →
  static const String glyphUp = '^';        // War: ⬆
  static const String glyphDown = 'v';      // War: ⬇
  static const String glyphBalance = '=';   // War: ⚖
  static const String glyphBolt = '!';      // War: ⚡
  static const String glyphTarget = '@';    // War: ◎
  static const String glyphDiamond = '<>';  // War: ◇
  static const String glyphCircle = 'o';    // War: ○
  static const String glyphFilledCircle = 'o'; // War: ●
  static const String glyphCheck = 'x';     // War: ✓

  /// Get zodiac glyph from sign name
  static String getZodiacGlyph(String? signName) {
    if (signName == null) return glyphStar;
    final key = signName.toLowerCase();
    return _zodiacGlyphs[key] ?? glyphStar;
  }

  // ============================================================
  // LOGO ASSET LOADING
  // ============================================================

  /// Cached logo bytes for PDF embedding
  Uint8List? _logoIconBytes;

  /// Load logo icon for PDF embedding
  Future<Uint8List?> _loadLogoIcon() async {
    if (_logoIconBytes != null) return _logoIconBytes;

    try {
      final ByteData data = await rootBundle.load(BrandingAssets.logoIconGoldNude);
      _logoIconBytes = data.buffer.asUint8List();
      return _logoIconBytes;
    } catch (e) {
      debugPrint('Could not load logo icon: $e');
      return null;
    }
  }

  // ============================================================
  // MAIN GENERATION METHOD
  // ============================================================

  /// Generate luxury PDF from structured report
  Future<Uint8List> generateLuxuryPdf(
    StructuredReport report,
    ReportType reportType,
  ) async {
    // DEBUG: Log Numerology Grid zur Validierung
    debugPrint('=== PDF GENERATION: NUMEROLOGY GRID ===');
    debugPrint('Life Path: ${report.logicData.numerologyGrid.lifePathNumber}');
    debugPrint('Destiny: ${report.logicData.numerologyGrid.destinyNumber}');
    debugPrint('Soul Urge: ${report.logicData.numerologyGrid.soulUrgeNumber}');
    debugPrint('Personality: ${report.logicData.numerologyGrid.personalityNumber}');
    debugPrint('Maturity: ${report.logicData.numerologyGrid.maturityNumber}');
    debugPrint('Personal Year: ${report.logicData.numerologyGrid.personalYear}');
    debugPrint('========================================');

    // Use Noto Sans for full Unicode support (Turkish ş, German ü, etc.)
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await _loadFont('assets/fonts/NotoSans-Regular.ttf'),
        bold: await _loadFont('assets/fonts/NotoSans-Bold.ttf'),
        italic: await _loadFont('assets/fonts/NotoSans-Italic.ttf'),
      ),
    );

    // Pre-load logo for Cover Page
    final logoBytes = await _loadLogoIcon();

    // 1. Cover Page (with logo seal)
    pdf.addPage(_buildCoverPage(report, reportType, logoBytes: logoBytes));

    // 2. Executive Summary (NEW - The Golden Three)
    pdf.addPage(_buildExecutiveSummaryPage(report));

    // 3. Identity & Overview Page
    pdf.addPage(_buildIdentityPage(report));

    // 4. Beyond Insights Page (Pull Quotes)
    if (report.pullQuotes.isNotEmpty) {
      pdf.addPage(_buildInsightsPage(report));
    }

    // 5. Visualizations Page (Beyond-Dreieck, Element-Waage)
    pdf.addPage(_buildVisualizationsPage(report));

    // 6. Energy Forecast Page (NEW - Transit Radar & Frequency Curve)
    pdf.addPage(_buildEnergyForecastPage(report));

    // 7. Body Sections (Multi-page with elegant layout)
    // Increased margins for luxury magazine feel
    pdf.addPage(
      pw.MultiPage(
        pageFormat: _a4Portrait,
        margin: const pw.EdgeInsets.symmetric(horizontal: 56, vertical: 64),
        header: (context) => _buildPageHeader(report, reportType, context),
        footer: (context) => _buildPageFooter(context),
        build: (context) => _buildBodyContent(report),
        maxPages: 50, // Allow more pages for proper breaks
      ),
    );

    // 8. Closing Page
    pdf.addPage(_buildClosingPage(report));

    return pdf.save();
  }

  /// Load custom font from assets
  Future<pw.Font> _loadFont(String path) async {
    try {
      final fontData = await rootBundle.load(path);
      return pw.Font.ttf(fontData);
    } catch (e) {
      debugPrint('Could not load font $path: $e');
      return pw.Font.helvetica();
    }
  }

  // ============================================================
  // PAGE 1: COVER PAGE (mit Logo-Siegel)
  // ============================================================

  pw.Page _buildCoverPage(
    StructuredReport report,
    ReportType reportType, {
    Uint8List? logoBytes,
  }) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: pw.EdgeInsets.zero,
      build: (context) => pw.Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const pw.BoxDecoration(
          color: _warmWhite,
        ),
        child: pw.Stack(
          children: [
            // Background geometric accent (obere rechte Ecke)
            pw.Positioned(
              top: 0,
              right: 0,
              child: pw.Container(
                width: 200,
                height: 200,
                decoration: const pw.BoxDecoration(
                  color: _cosmicNudeLight,
                ),
              ),
            ),

            // Logo-Siegel (untere rechte Ecke) - wenn verfügbar
            if (logoBytes != null)
              pw.Positioned(
                bottom: 64,
                right: 64,
                child: pw.Opacity(
                  opacity: 0.15,
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    width: 120,
                    height: 120,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),

            // Main content
            pw.Padding(
              padding: const pw.EdgeInsets.all(64),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Brand mit Logo-Icon (klein)
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      if (logoBytes != null) ...[
                        pw.Image(
                          pw.MemoryImage(logoBytes),
                          width: 24,
                          height: 24,
                          fit: pw.BoxFit.contain,
                        ),
                        pw.SizedBox(width: 12),
                      ],
                      pw.Text(
                        'BEYOND HOROSCOPE',
                        style: pw.TextStyle(
                          fontSize: 10,
                          letterSpacing: 4,
                          color: _softGray,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 80),

                  // Report Type Badge
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      color: _cosmicNude,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      reportType.displayName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 9,
                        letterSpacing: 2,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 24),

                  // Main Headline
                  pw.Text(
                    report.cover.headline,
                    style: pw.TextStyle(
                      fontSize: 42,
                      fontWeight: pw.FontWeight.bold,
                      color: _deepCharcoal,
                      lineSpacing: 8,
                    ),
                  ),
                  pw.SizedBox(height: 16),

                  // Subheadline
                  pw.Text(
                    report.cover.subheadline,
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: _softGray,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),

                  pw.Spacer(),

                  // Gold-Akzent-Linie
                  pw.Container(
                    width: 80,
                    height: 2,
                    color: _accentGold,
                  ),
                  pw.SizedBox(height: 32),

                  // For whom
                  pw.Text(
                    'Erstellt für',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: _softGray,
                      letterSpacing: 1,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    report.cover.userName ?? 'Dich',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: _deepCharcoal,
                    ),
                  ),
                  pw.SizedBox(height: 48),

                  // Generation date
                  pw.Text(
                    'Generiert am ${_formatDate(report.meta.generatedAt)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: _softGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAGE 2: EXECUTIVE SUMMARY (The Golden Three)
  // ============================================================

  pw.Page _buildExecutiveSummaryPage(StructuredReport report) {
    // Use data from executiveSummary or generate defaults
    // Dynamic year based on generation date
    final currentYear = DateTime.now().year;
    final summary = report.executiveSummary;
    final opportunity = summary?.biggestOpportunity ??
        'Deine einzigartige Kombination aus ${report.cover.sunSign ?? "Sternzeichen"} und Lebenszahl ${report.cover.lifePathNumber} eröffnet dir außergewöhnliche Möglichkeiten.';
    final blocker = summary?.biggestBlocker ??
        'Die elementare Spannung in deinem Chart kann zu Selbstzweifeln führen, wenn du sie nicht bewusst transformierst.';
    // Replace fixed year with dynamic rolling window
    final rawFocus = summary?.focusFor2026 ??
        'Nutze die kosmische Energie der kommenden 12 Monate, um langfristige Fundamente zu legen.';
    final focus = rawFocus.replaceAll('2026', '$currentYear').replaceAll('2025', '${currentYear - 1}').replaceAll('2027', '${currentYear + 1}');

    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Text(
            'EXECUTIVE SUMMARY',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: _cosmicNude,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Dein Report auf einen Blick',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: _deepCharcoal,
            ),
          ),
          pw.SizedBox(height: 48),

          // The Golden Three Cards - All in elegant gold tones
          // UNICODE-FIX: Nummerierte Icons statt Unicode-Symbole
          _buildGoldenCard(
            icon: '1',
            label: 'GRÖSSTE CHANCE',
            content: opportunity,
            color: _accentGold,
          ),
          pw.SizedBox(height: 24),

          _buildGoldenCard(
            icon: '2',
            label: 'GRÖSSTER BLOCKER',
            content: blocker,
            color: _cosmicNudeDark,
          ),
          pw.SizedBox(height: 24),

          _buildGoldenCard(
            icon: '3',
            label: 'DEIN 12-MONATE-FOKUS',
            content: focus,
            color: _cosmicNude,
          ),

          pw.Spacer(),

          // Footer note - UNICODE-FIX: "i" statt Sonnen-Symbol
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _cosmicNudeLight),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 24,
                  height: 24,
                  decoration: pw.BoxDecoration(
                    color: _accentGold,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'i',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Text(
                    'Diese drei Erkenntnisse sind der Kern deines Reports. Die folgenden Seiten vertiefen jeden Aspekt.',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: _softGray,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a golden insight card for Executive Summary
  /// UNICODE-FIX: Icon wird in einem Kreis angezeigt, kein Unicode nötig
  pw.Widget _buildGoldenCard({
    required String icon,
    required String label,
    required String content,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        color: color.shade(0.95),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: color.shade(0.8), width: 1.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              // UNICODE-FIX: Nummer in einem Kreis statt Unicode-Symbol
              pw.Container(
                width: 28,
                height: 28,
                decoration: pw.BoxDecoration(
                  color: color,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text(
                    icon,
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: color,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            content,
            style: pw.TextStyle(
              fontSize: 13,
              color: _deepCharcoal,
              lineSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 3: IDENTITY PAGE
  // ============================================================

  pw.Page _buildIdentityPage(StructuredReport report) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Section title
          pw.Text(
            'DEINE KOSMISCHE IDENTITÄT',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: _cosmicNude,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 32),

          // Identity Cards Row
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Western Astrology Card
              pw.Expanded(
                child: _buildIdentityCardWithGlyph(
                  system: 'Westliche Astrologie',
                  value: report.cover.sunSign ?? 'N/A',
                  label: 'Sonnenzeichen',
                  glyph: getZodiacGlyph(report.cover.sunSign),
                  accentColor: _accentGold,
                ),
              ),
              pw.SizedBox(width: 16),
              // Chinese Astrology Card
              pw.Expanded(
                child: _buildIdentityCardWithGlyph(
                  system: 'Chinesische Astrologie',
                  value: report.cover.chineseAnimal ?? 'N/A',
                  label: 'Tierzeichen',
                  glyph: glyphStar,
                  accentColor: _accentGold,
                ),
              ),
              pw.SizedBox(width: 16),
              // Numerology Card
              pw.Expanded(
                child: _buildIdentityCardWithGlyph(
                  system: 'Numerologie',
                  value: '${report.cover.lifePathNumber ?? 0}',
                  label: 'Lebenszahl',
                  glyph: glyphTarget,
                  accentColor: _accentGold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 48),

          // Intro Synthesis
          pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: _cosmicNudeLight,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'DIE SYNTHESE',
                  style: pw.TextStyle(
                    fontSize: 9,
                    letterSpacing: 2,
                    color: _cosmicNudeDark,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  report.intro.synthesis,
                  style: pw.TextStyle(
                    fontSize: 13,
                    color: _deepCharcoal,
                    lineSpacing: 6,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Dominant Vector - TEXT-OVERFLOW-FIX: Kleinere Schrift + Zeilenumbruch
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: _accentGold, width: 4),
              ),
              color: _warmWhite,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Dominanter Vektor',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: _softGray,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  report.intro.dominantVector,
                  style: pw.TextStyle(
                    fontSize: 12,  // Reduziert von 16 auf 12
                    fontWeight: pw.FontWeight.bold,
                    color: _deepCharcoal,
                    lineSpacing: 4,
                  ),
                  // Text wird automatisch umgebrochen
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildIdentityCardWithGlyph({
    required String system,
    required String value,
    required String label,
    required String glyph,
    required PdfColor accentColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _cosmicNudeLight, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Glyph header
          pw.Row(
            children: [
              pw.Text(
                glyph,
                style: pw.TextStyle(
                  fontSize: 20,
                  color: accentColor,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Container(
                width: 24,
                height: 2,
                color: accentColor,
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            system,
            style: pw.TextStyle(
              fontSize: 8,
              letterSpacing: 1,
              color: _softGray,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: _deepCharcoal,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              color: _softGray,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 3: BEYOND INSIGHTS (PULL QUOTES)
  // ============================================================

  pw.Page _buildInsightsPage(StructuredReport report) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BEYOND INSIGHTS',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: _cosmicNude,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Die Essenz deiner kosmischen Architektur',
            style: pw.TextStyle(
              fontSize: 14,
              color: _softGray,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 48),

          // Pull quotes
          ...report.pullQuotes.asMap().entries.map((entry) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 32),
              child: _buildPullQuote(entry.value, entry.key),
            );
          }),
        ],
      ),
    );
  }

  pw.Widget _buildPullQuote(String quote, int index) {
    final isEven = index % 2 == 0;
    return pw.Container(
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        color: isEven ? _warmWhite : _cosmicNudeLight,
        border: pw.Border(
          left: pw.BorderSide(
            color: _accentGold,
            width: 4,
          ),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '"',
            style: pw.TextStyle(
              fontSize: 48,
              color: _cosmicNude,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(top: 16),
              child: pw.Text(
                quote,
                style: pw.TextStyle(
                  fontSize: 16,
                  color: _deepCharcoal,
                  fontStyle: pw.FontStyle.italic,
                  lineSpacing: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 4: VISUALIZATIONS
  // ============================================================

  pw.Page _buildVisualizationsPage(StructuredReport report) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DEINE KOSMISCHE ARCHITEKTUR',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: _cosmicNude,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 48),

          // Beyond Triangle and Element Balance side by side
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Beyond-Dreieck
              pw.Expanded(
                child: _buildBeyondTriangleWidget(report.logicData.beyondTriangle),
              ),
              pw.SizedBox(width: 32),
              // Element Balance
              pw.Expanded(
                child: _buildElementBalanceWidget(report.logicData.elementBalance),
              ),
            ],
          ),
          pw.SizedBox(height: 48),

          // Numerology Grid
          _buildNumerologyGridWidget(report.logicData.numerologyGrid),
        ],
      ),
    );
  }

  pw.Widget _buildBeyondTriangleWidget(BeyondTriangle triangle) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _cosmicNudeLight),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header - UNICODE-FIX: "B" in Kreis statt Dreieck-Symbol
          pw.Row(
            children: [
              pw.Container(
                width: 24,
                height: 24,
                decoration: pw.BoxDecoration(
                  color: _accentGold,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text(
                    'B',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'BEYOND-DREIECK',
                style: pw.TextStyle(
                  fontSize: 9,
                  letterSpacing: 2,
                  color: _softGray,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Gewichtung der drei Systeme',
            style: pw.TextStyle(
              fontSize: 10,
              color: _softGray,
            ),
          ),
          pw.SizedBox(height: 24),

          // Elegant bar chart - all in gold tones for cohesion
          _buildTriangleBar('Westliche Astrologie', triangle.westernAstrology, _accentGold),
          pw.SizedBox(height: 12),
          _buildTriangleBar('Chinesische Astrologie', triangle.chineseAstrology, _cosmicNude),
          pw.SizedBox(height: 12),
          _buildTriangleBar('Numerologie', triangle.numerology, _cosmicNudeDark),
        ],
      ),
    );
  }

  pw.Widget _buildTriangleBar(String label, int percentage, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, color: _deepCharcoal),
            ),
            pw.Text(
              '$percentage%',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: _deepCharcoal,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Stack(
          children: [
            pw.Container(
              width: double.infinity,
              height: 8,
              decoration: pw.BoxDecoration(
                color: _warmWhite,
                borderRadius: pw.BorderRadius.circular(4),
              ),
            ),
            pw.Container(
              width: percentage * 1.8, // Scale to fit
              height: 8,
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildElementBalanceWidget(ElementBalance balance) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _cosmicNudeLight),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header - UNICODE-FIX: "E" in Kreis statt Waage-Symbol
          pw.Row(
            children: [
              pw.Container(
                width: 24,
                height: 24,
                decoration: pw.BoxDecoration(
                  color: _accentGold,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text(
                    'E',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'ELEMENT-WAAGE',
                style: pw.TextStyle(
                  fontSize: 9,
                  letterSpacing: 2,
                  color: _softGray,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Deine elementare Verteilung',
            style: pw.TextStyle(
              fontSize: 10,
              color: _softGray,
            ),
          ),
          pw.SizedBox(height: 24),

          // Western elements - elegant gold-toned circles
          pw.Row(
            children: [
              pw.Expanded(child: _buildElementDot('Feuer', balance.fire, _accentGold)),
              pw.Expanded(child: _buildElementDot('Erde', balance.earth, _cosmicNudeDark)),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(child: _buildElementDot('Luft', balance.air, _cosmicNude)),
              pw.Expanded(child: _buildElementDot('Wasser', balance.water, _cosmicNudeDark)),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            height: 1,
            color: _cosmicNudeLight,
          ),
          pw.SizedBox(height: 12),
          // Chinese elements
          pw.Row(
            children: [
              pw.Expanded(child: _buildElementDot('Holz', balance.wood, _cosmicNude)),
              pw.Expanded(child: _buildElementDot('Metall', balance.metal, _accentGold)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildElementDot(String name, int value, PdfColor color) {
    return pw.Row(
      children: [
        pw.Container(
          width: 12,
          height: 12,
          decoration: pw.BoxDecoration(
            color: color,
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              name,
              style: pw.TextStyle(fontSize: 9, color: _deepCharcoal),
            ),
            pw.Text(
              '$value%',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _deepCharcoal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildNumerologyGridWidget(NumerologyGrid grid) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        color: _cosmicNudeLight,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'NUMEROLOGIE-GRID',
            style: pw.TextStyle(
              fontSize: 9,
              letterSpacing: 2,
              color: _cosmicNudeDark,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildNumberCell('Lebenszahl', grid.lifePathNumber),
              _buildNumberCell('Schicksal', grid.destinyNumber),
              _buildNumberCell('Seele', grid.soulUrgeNumber),
              _buildNumberCell('Persönlichkeit', grid.personalityNumber),
              _buildNumberCell('Reife', grid.maturityNumber),
              _buildNumberCell('Pers. Jahr', grid.personalYear),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildNumberCell(String label, int number) {
    return pw.Column(
      children: [
        pw.Container(
          width: 48,
          height: 48,
          decoration: pw.BoxDecoration(
            color: _warmWhite,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Center(
            child: pw.Text(
              '$number',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: _deepCharcoal,
              ),
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 8,
            color: _cosmicNudeDark,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  // ============================================================
  // ENERGY FORECAST PAGE (Transit-Radar & Frequency Curve)
  // ============================================================

  pw.Page _buildEnergyForecastPage(StructuredReport report) {
    // Dynamic rolling window
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header - Dynamic rolling window
          pw.Text(
            'DEIN 12-MONATE-ENERGIE-FENSTER',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: _cosmicNude,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Deine kosmischen Rhythmen',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: _deepCharcoal,
            ),
          ),
          pw.SizedBox(height: 32),

          // Transit Radar (simplified visual)
          _buildTransitRadar(report),
          pw.SizedBox(height: 32),

          // Energy Frequency Curve
          _buildFrequencyCurve(report),

          pw.Spacer(),

          // Cusp Note (if applicable)
          if (report.cuspData?.moonOnCusp == true ||
              report.cuspData?.ascendantOnCusp == true)
            _buildCuspNote(report),
        ],
      ),
    );
  }

  /// Build a simplified Transit Radar visualization
  pw.Widget _buildTransitRadar(StructuredReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _cosmicNudeLight),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TRANSIT-RADAR',
            style: pw.TextStyle(
              fontSize: 9,
              letterSpacing: 2,
              color: _softGray,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Wichtige Planeten-Transite für dich',
            style: pw.TextStyle(fontSize: 10, color: _softGray),
          ),
          pw.SizedBox(height: 20),

          // Simplified transit indicators
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildTransitIndicator(
                  'Jupiter',
                  'Expansion & Glück',
                  _accentGold,
                  85, // strength percentage
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildTransitIndicator(
                  'Saturn',
                  'Struktur & Reife',
                  _earthColor,
                  60,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildTransitIndicator(
                  'Uranus',
                  'Veränderung',
                  _airColor,
                  45,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildTransitIndicator(
                  'Neptun',
                  'Intuition',
                  _waterColor,
                  70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTransitIndicator(
    String planet,
    String theme,
    PdfColor color,
    int strength,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              planet,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _deepCharcoal,
              ),
            ),
            pw.Text(
              '$strength%',
              style: pw.TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          theme,
          style: pw.TextStyle(fontSize: 9, color: _softGray),
        ),
        pw.SizedBox(height: 6),
        pw.Stack(
          children: [
            pw.Container(
              width: double.infinity,
              height: 6,
              decoration: pw.BoxDecoration(
                color: _warmWhite,
                borderRadius: pw.BorderRadius.circular(3),
              ),
            ),
            pw.Container(
              width: strength * 1.5, // Scale
              height: 6,
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build Energy Frequency Curve - Rolling 12 months from current date
  pw.Widget _buildFrequencyCurve(StructuredReport report) {
    final now = DateTime.now();
    final currentMonth = now.month;

    // Dynamic rolling phases based on current month
    // Phase 1: Current quarter, Phase 2-4: Following quarters
    final phases = _buildRollingPhases(currentMonth);

    return pw.Container(
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        color: _cosmicNudeLight,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DEINE ENERGIE-PHASEN',
            style: pw.TextStyle(
              fontSize: 9,
              letterSpacing: 2,
              color: _cosmicNudeDark,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Energetische Rhythmen der nächsten 12 Monate',
            style: pw.TextStyle(fontSize: 10, color: _cosmicNudeDark),
          ),
          pw.SizedBox(height: 24),

          // Bar chart visualization - Rolling phases
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: phases.map((phase) {
              final value = phase['value'] as int;
              final label = phase['label'] as String;
              final months = phase['months'] as String;
              final theme = phase['theme'] as String;

              return pw.Column(
                children: [
                  pw.Text(
                    '$value%',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: _deepCharcoal,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    width: 40,
                    height: value * 0.8, // Scale height
                    decoration: pw.BoxDecoration(
                      gradient: pw.LinearGradient(
                        begin: pw.Alignment.topCenter,
                        end: pw.Alignment.bottomCenter,
                        colors: [_accentGold, _cosmicNude],
                      ),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    label,
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: _deepCharcoal,
                    ),
                  ),
                  pw.Text(
                    months,
                    style: pw.TextStyle(fontSize: 8, color: _softGray),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    theme,
                    style: pw.TextStyle(fontSize: 7, color: _cosmicNudeDark),
                  ),
                ],
              );
            }).toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Divider(color: _cosmicNudeDark.shade(0.3)),
          pw.SizedBox(height: 8),
          pw.Text(
            'Hinweis: Die Phasen folgen deinem persönlichen Rhythmus ab Kaufdatum.',
            style: pw.TextStyle(
              fontSize: 9,
              color: _cosmicNudeDark,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Build rolling phases based on current month
  List<Map<String, dynamic>> _buildRollingPhases(int currentMonth) {
    // Phase themes that work regardless of calendar year
    const phaseThemes = [
      {'label': 'Phase 1', 'theme': 'Fundament', 'value': 70},
      {'label': 'Phase 2', 'theme': 'Aufbau', 'value': 85},
      {'label': 'Phase 3', 'theme': 'Ernte', 'value': 90},
      {'label': 'Phase 4', 'theme': 'Integration', 'value': 75},
    ];

    final monthNames = ['Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'];

    return List.generate(4, (i) {
      final startMonth = (currentMonth - 1 + i * 3) % 12;
      final endMonth = (startMonth + 2) % 12;

      return {
        'label': phaseThemes[i]['label'],
        'theme': phaseThemes[i]['theme'],
        'value': phaseThemes[i]['value'],
        'months': '${monthNames[startMonth]}-${monthNames[endMonth]}',
      };
    });
  }

  /// Build cusp note for planets at sign borders
  pw.Widget _buildCuspNote(StructuredReport report) {
    final cuspDescriptions = <String>[];

    if (report.cuspData?.moonOnCusp == true &&
        report.cuspData?.moonCuspDescription != null) {
      cuspDescriptions.add(report.cuspData!.moonCuspDescription!);
    }
    if (report.cuspData?.ascendantOnCusp == true &&
        report.cuspData?.ascendantCuspDescription != null) {
      cuspDescriptions.add(report.cuspData!.ascendantCuspDescription!);
    }

    if (cuspDescriptions.isEmpty) {
      // Generate default description
      cuspDescriptions.add(
        'Dein Mond steht an einer Zeichengrenze - du vereinst die Qualitäten beider Zeichen in deiner emotionalen Natur.',
      );
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _accentGold.shade(0.95),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _accentGold.shade(0.8)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // UNICODE-FIX: "!" in Kreis statt Waage-Symbol
          pw.Container(
            width: 24,
            height: 24,
            decoration: pw.BoxDecoration(
              color: _accentGold,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                '!',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'HINWEIS: CUSP-POSITION',
                  style: pw.TextStyle(
                    fontSize: 9,
                    letterSpacing: 1,
                    color: _accentGold,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                ...cuspDescriptions.map(
                  (desc) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      desc,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: _deepCharcoal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BODY CONTENT PAGES
  // ============================================================

  pw.Widget _buildPageHeader(
    StructuredReport report,
    ReportType reportType,
    pw.Context context,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 24),
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _cosmicNudeLight, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Beyond Horoscope',
            style: pw.TextStyle(
              fontSize: 9,
              color: _softGray,
              letterSpacing: 1,
            ),
          ),
          pw.Text(
            reportType.displayName,
            style: pw.TextStyle(
              fontSize: 9,
              color: _softGray,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPageFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 24),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            '${context.pageNumber}',
            style: pw.TextStyle(
              fontSize: 10,
              color: _softGray,
            ),
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _buildBodyContent(StructuredReport report) {
    final List<pw.Widget> widgets = [];

    for (int i = 0; i < report.bodySections.length; i++) {
      final section = report.bodySections[i];

      // Section title
      widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.only(top: i == 0 ? 0 : 32, bottom: 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 40,
                height: 3,
                color: _accentGold,
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                section.title.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: _deepCharcoal,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      );

      // Key insight (if available)
      if (section.keyInsight != null && section.keyInsight!.isNotEmpty) {
        widgets.add(
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _cosmicNudeLight,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 3,
                  height: 40,
                  color: _accentGold,
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Text(
                    section.keyInsight!,
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: _deepCharcoal,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Split content into paragraphs
      final paragraphs = section.content.split('\n\n').where((p) => p.trim().isNotEmpty).toList();

      for (final paragraph in paragraphs) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Text(
              paragraph.trim(),
              style: pw.TextStyle(
                fontSize: 11,
                color: _deepCharcoal,
                lineSpacing: 5,
              ),
              textAlign: pw.TextAlign.justify,
            ),
          ),
        );
      }

      // Beyond Action Box (if available)
      if (section.beyondAction != null) {
        widgets.add(_buildBeyondActionBox(section.beyondAction!));
      }
    }

    return widgets;
  }

  /// Build a Beyond Action Box - concrete actionable task
  /// KONTRAST-FIX: Text auf _deepCharcoal (dunkel) für maximale Lesbarkeit
  /// UNICODE-FIX: Keine Unicode-Symbole, nur ASCII-kompatible Zeichen
  pw.Widget _buildBeyondActionBox(BeyondAction action) {
    // Fallback für leeren Task
    final taskText = (action.task.isNotEmpty)
        ? action.task
        : 'Konkrete Handlungsempfehlung folgt.';

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16, bottom: 24),
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _warmWhite,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _accentGold, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: pw.BoxDecoration(
                  color: _accentGold,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'BEYOND ACTION',
                  style: pw.TextStyle(
                    fontSize: 8,
                    letterSpacing: 1.5,
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              if (action.timeframe != null && action.timeframe!.isNotEmpty) ...[
                pw.SizedBox(width: 12),
                pw.Text(
                  action.timeframe!,
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: _cosmicNudeDark,
                    fontStyle: pw.FontStyle.italic,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // UNICODE-FIX: Verwende ">" statt Unicode-Pfeil
              pw.Container(
                width: 20,
                height: 20,
                decoration: pw.BoxDecoration(
                  color: _accentGold,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text(
                    '>',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Text(
                  taskText,
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: _deepCharcoal,
                    fontWeight: pw.FontWeight.bold,
                    lineSpacing: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CLOSING PAGE
  // ============================================================

  pw.Page _buildClosingPage(StructuredReport report) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ZUSAMMENFASSUNG',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: _cosmicNude,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 32),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: _cosmicNudeLight,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              report.closing.summary,
              style: pw.TextStyle(
                fontSize: 14,
                color: _deepCharcoal,
                lineSpacing: 8,
              ),
            ),
          ),
          pw.SizedBox(height: 48),

          // Action Items
          pw.Text(
            'DEINE NÄCHSTEN SCHRITTE',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: _softGray,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 24),

          ...report.closing.actionItems.asMap().entries.map((entry) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 16),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 28,
                    height: 28,
                    decoration: pw.BoxDecoration(
                      color: _accentGold,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        '${entry.key + 1}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 4),
                      child: pw.Text(
                        entry.value,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: _deepCharcoal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          pw.Spacer(),

          // Footer - UNICODE-FIX: Einfaches Design ohne Unicode
          pw.Center(
            child: pw.Column(
              children: [
                pw.Container(
                  width: 32,
                  height: 32,
                  decoration: pw.BoxDecoration(
                    color: _cosmicNude,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'BH',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Beyond Horoscope',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: _softGray,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Deine kosmische Synthese aus drei Welten',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: _softGray,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  String _formatDate(DateTime date) {
    final months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
    ];
    return '${date.day}. ${months[date.month - 1]} ${date.year}';
  }

  /// Save and share PDF - works on both web and native platforms
  Future<void> sharePdf(StructuredReport report, ReportType reportType) async {
    final pdfBytes = await generateLuxuryPdf(report, reportType);

    // Generate filename based on report type and content
    String fileName;
    if (reportType == ReportType.soulMateFinder && report.cover.headline.contains('&')) {
      // SoulMate Seelen-Check: Use both names from headline
      final cleanHeadline = report.cover.headline
          .replaceAll('Die kosmische Alchemie von ', '')
          .replaceAll(' ', '_')
          .replaceAll('&', 'und');
      fileName = 'SoulMate_Seelen_Check_$cleanHeadline.pdf';
    } else if (reportType == ReportType.soulMateFinder) {
      // SoulMate Blueprint (Version A)
      fileName = 'SoulMate_Blueprint_${report.cover.userName}.pdf';
    } else {
      // All other reports
      fileName = 'BeyondDossier_${reportType.displayName.replaceAll(' ', '_')}_${report.cover.userName}.pdf';
    }

    if (kIsWeb) {
      // Web: Download via browser
      _downloadPdfWeb(pdfBytes, fileName);
    } else {
      // Native: Use platform-specific implementation
      await platform.savePdfNative(pdfBytes, fileName, reportType);
    }
  }

  /// Download PDF in web browser
  void _downloadPdfWeb(Uint8List pdfBytes, String fileName) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
    debugPrint('PDF downloaded via web browser: $fileName');
  }
}
