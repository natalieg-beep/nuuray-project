// ============================================================
// SHADOW & LIGHT PDF GENERATOR
// ============================================================
//
// Extends LuxuryPdfGenerator with specialized pages for the
// "Shadow & Light" premium report.
//
// Design Philosophy:
// - Dark, moody accents (deep purple, midnight blue)
// - Elegant contrast with the gold palette
// - 4-Phase Shadow Radar visualization
// - Psychological depth with empowering tone
//
// ============================================================

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/structured_report.dart';
import 'shadow_light_service.dart';

class ShadowLightPdfGenerator {
  // Singleton
  static final ShadowLightPdfGenerator _instance = ShadowLightPdfGenerator._internal();
  factory ShadowLightPdfGenerator() => _instance;
  ShadowLightPdfGenerator._internal();

  // ============================================================
  // SHADOW & LIGHT COLOR PALETTE
  // ============================================================

  // Base colors from main palette
  static const PdfColor _warmWhite = PdfColor.fromInt(0xFFFAF8F5);
  static const PdfColor _deepCharcoal = PdfColor.fromInt(0xFF2D2926);
  static const PdfColor _softGray = PdfColor.fromInt(0xFF6B6B6B);
  static const PdfColor _accentGold = PdfColor.fromInt(0xFFD4AF37);
  static const PdfColor _cosmicNude = PdfColor.fromInt(0xFFB8A394);
  static const PdfColor _cosmicNudeLight = PdfColor.fromInt(0xFFD4C4B5);

  // Shadow-specific colors (dark, moody accents)
  static const PdfColor _shadowPurple = PdfColor.fromInt(0xFF4A3B5C);      // Deep purple
  static const PdfColor _shadowPurpleLight = PdfColor.fromInt(0xFF6B5A7D); // Lighter purple
  static const PdfColor _midnightBlue = PdfColor.fromInt(0xFF1A1A2E);      // Dark blue
  static const PdfColor _moonlightSilver = PdfColor.fromInt(0xFFB8C5D6);   // Cool silver
  static const PdfColor _plutoDeep = PdfColor.fromInt(0xFF2D1B2E);         // Pluto deep purple
  static const PdfColor _lilithMagenta = PdfColor.fromInt(0xFF8B3A62);     // Lilith magenta

  // Unicode glyphs
  static const String glyphStar = '✦';
  static const String glyphMoon = '☽';
  static const String glyphPluto = '♇';
  static const String glyphLilith = '⚸';
  static const String glyphPhoenix = '🜂';
  static const String glyphArrow = '→';
  static const String glyphCheck = '✓';
  static const String glyphDiamond = '◇';
  static const String glyphCircle = '●';

  // ============================================================
  // MAIN GENERATION METHOD
  // ============================================================

  /// Generate Shadow & Light PDF from analysis
  Future<Uint8List> generateShadowLightPdf(
    ShadowLightAnalysis analysis,
    StructuredReport baseReport,
  ) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await _loadFont('assets/fonts/Nunito-Regular.ttf'),
        bold: await _loadFont('assets/fonts/Nunito-Bold.ttf'),
        italic: await _loadFont('assets/fonts/Nunito-Italic.ttf'),
      ),
    );

    // 1. Shadow Cover Page
    pdf.addPage(_buildShadowCoverPage(baseReport, analysis));

    // 2. Executive Shadow Summary
    pdf.addPage(_buildShadowExecutiveSummary(analysis));

    // 3. Pluto Analysis Page
    pdf.addPage(_buildPlutoPage(analysis.plutoAnalysis));

    // 4. Lilith Analysis Page
    pdf.addPage(_buildLilithPage(analysis.lilithAnalysis));

    // 5. Shadow Numerology Page (Karmic or Missing Numbers)
    pdf.addPage(_buildShadowNumerologyPage(analysis.shadowNumerology));

    // 6. 4-Phase Shadow Radar Page
    pdf.addPage(_buildShadowRadarPage(analysis.shadowRadar));

    // 7. Integration & Action Page
    pdf.addPage(_buildIntegrationPage(analysis));

    // 8. Closing Page
    pdf.addPage(_buildShadowClosingPage(baseReport, analysis));

    return pdf.save();
  }

  /// Load custom font from assets
  Future<pw.Font> _loadFont(String path) async {
    try {
      final fontData = await rootBundle.load(path);
      return pw.Font.ttf(fontData);
    } catch (e) {
      return pw.Font.helvetica();
    }
  }

  // ============================================================
  // PAGE 1: SHADOW COVER PAGE
  // ============================================================

  pw.Page _buildShadowCoverPage(StructuredReport report, ShadowLightAnalysis analysis) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) => pw.Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const pw.BoxDecoration(
          color: _midnightBlue,
        ),
        child: pw.Stack(
          children: [
            // Gradient overlay effect (simulated with positioned containers)
            pw.Positioned(
              bottom: 0,
              right: 0,
              child: pw.Container(
                width: 300,
                height: 400,
                decoration: const pw.BoxDecoration(
                  color: _shadowPurple,
                ),
              ),
            ),
            // Main content
            pw.Padding(
              padding: const pw.EdgeInsets.all(64),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Brand
                  pw.Text(
                    'BEYOND HOROSCOPE',
                    style: pw.TextStyle(
                      fontSize: 10,
                      letterSpacing: 4,
                      color: _moonlightSilver,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 80),

                  // Report Type Badge
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      color: _lilithMagenta,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      'SHADOW & LIGHT',
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
                    'Deine Dunkle Seite',
                    style: pw.TextStyle(
                      fontSize: 42,
                      fontWeight: pw.FontWeight.bold,
                      color: _warmWhite,
                      lineSpacing: 8,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'als Treibstoff für dein hellstes Licht',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.normal,
                      color: _accentGold,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  pw.SizedBox(height: 32),

                  // Subheadline
                  pw.Container(
                    width: 300,
                    child: pw.Text(
                      'Eine tiefenpsychologische Analyse deiner verborgenen Kräfte, '
                      'karmischen Muster und des Pfades zur Integration.',
                      style: pw.TextStyle(
                        fontSize: 13,
                        color: _moonlightSilver,
                        lineSpacing: 5,
                      ),
                    ),
                  ),

                  pw.Spacer(),

                  // Divider with moon glyph
                  pw.Row(
                    children: [
                      pw.Container(width: 40, height: 2, color: _accentGold),
                      pw.SizedBox(width: 12),
                      pw.Text(
                        '$glyphMoon',
                        style: pw.TextStyle(fontSize: 18, color: _accentGold),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Container(width: 40, height: 2, color: _accentGold),
                    ],
                  ),
                  pw.SizedBox(height: 32),

                  // For whom
                  pw.Text(
                    'Erstellt für',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: _moonlightSilver,
                      letterSpacing: 1,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    report.cover.userName ?? 'Dich',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: _warmWhite,
                    ),
                  ),
                  pw.SizedBox(height: 48),

                  // Generation date
                  pw.Text(
                    'Generiert am ${_formatDate(analysis.generatedAt)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: _moonlightSilver,
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
  // PAGE 2: EXECUTIVE SHADOW SUMMARY
  // ============================================================

  pw.Page _buildShadowExecutiveSummary(ShadowLightAnalysis analysis) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Text(
            'DEIN SCHATTEN-PROFIL',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: _shadowPurple,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Die Essenz deiner verborgenen Kräfte',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: _deepCharcoal,
            ),
          ),
          pw.SizedBox(height: 32),

          // Key Shadow Elements
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildShadowElementCard(
                  glyph: glyphPluto,
                  label: 'PLUTO',
                  value: analysis.plutoAnalysis.sign.displayName,
                  theme: analysis.plutoAnalysis.theme,
                  color: _plutoDeep,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _buildShadowElementCard(
                  glyph: glyphLilith,
                  label: 'LILITH',
                  value: analysis.lilithAnalysis.sign.displayName,
                  theme: analysis.lilithAnalysis.theme,
                  color: _lilithMagenta,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // Shadow Numerology Summary
          _buildShadowNumerologySummary(analysis.shadowNumerology),
          pw.SizedBox(height: 32),

          // Key Pull Quote
          pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: _shadowPurple.shade(0.95),
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(color: _shadowPurple.shade(0.8), width: 1.5),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '"',
                  style: pw.TextStyle(
                    fontSize: 48,
                    color: _accentGold,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 16),
                    child: pw.Text(
                      analysis.shadowPullQuotes.isNotEmpty
                          ? analysis.shadowPullQuotes.first
                          : 'Deine Dunkelheit ist der Treibstoff für dein hellstes Licht.',
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
          ),

          pw.Spacer(),

          // Footer note
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _cosmicNudeLight),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  glyphMoon,
                  style: pw.TextStyle(fontSize: 16, color: _shadowPurple),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Text(
                    'Dieser Report arbeitet mit deinen tiefsten Mustern. Lies ihn mit Selbstmitgefühl.',
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

  pw.Widget _buildShadowElementCard({
    required String glyph,
    required String label,
    required String value,
    required String theme,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: color.shade(0.95),
        border: pw.Border.all(color: color.shade(0.7)),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                glyph,
                style: pw.TextStyle(fontSize: 24, color: color),
              ),
              pw.SizedBox(width: 8),
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
            value,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: _deepCharcoal,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            theme,
            style: pw.TextStyle(
              fontSize: 10,
              color: _softGray,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildShadowNumerologySummary(ShadowNumerology numerology) {
    final hasKarmic = numerology.karmicNumbers.isNotEmpty;

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _cosmicNudeLight,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                glyphDiamond,
                style: pw.TextStyle(fontSize: 16, color: _shadowPurple),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                hasKarmic ? 'KARMISCHE ZAHLEN' : 'FEHLENDE ZAHLEN',
                style: pw.TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: _shadowPurple,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          if (hasKarmic) ...[
            pw.Row(
              children: numerology.karmicNumbers.map((k) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(right: 12),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: _shadowPurple,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    '${k.number}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Karmische Zahlen zeigen Lektionen aus früheren Leben, die du meistern darfst.',
              style: pw.TextStyle(fontSize: 10, color: _softGray),
            ),
          ] else if (numerology.missingNumbers.isNotEmpty) ...[
            pw.Row(
              children: numerology.missingNumbers.take(5).map((m) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(right: 12),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: _shadowPurple, width: 2),
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    '${m.number}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: _shadowPurple,
                    ),
                  ),
                );
              }).toList(),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Fehlende Zahlen zeigen Energien, die du in diesem Leben bewusst kultivieren darfst.',
              style: pw.TextStyle(fontSize: 10, color: _softGray),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 3: PLUTO ANALYSIS
  // ============================================================

  pw.Page _buildPlutoPage(PlutoAnalysis pluto) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            children: [
              pw.Text(
                glyphPluto,
                style: pw.TextStyle(fontSize: 32, color: _plutoDeep),
              ),
              pw.SizedBox(width: 16),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PLUTO',
                    style: pw.TextStyle(
                      fontSize: 10,
                      letterSpacing: 3,
                      color: _plutoDeep,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Transformation & Verborgene Macht',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: _deepCharcoal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          // Position info
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: _plutoDeep.shade(0.95),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'Pluto in ${pluto.sign.displayName} ${pluto.degree.toStringAsFixed(1)}°'
              '${pluto.house != null ? ' im ${pluto.house}. Haus' : ''}',
              style: pw.TextStyle(
                fontSize: 12,
                color: _plutoDeep,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 32),

          // Theme card
          _buildInsightCard(
            label: 'DEIN PLUTO-THEMA',
            content: pluto.theme,
            color: _plutoDeep,
          ),
          pw.SizedBox(height: 20),

          // Two-column layout
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _buildPlutoSection(
                  title: 'Das Schattenmuster',
                  glyph: '↓',
                  content: pluto.shadowPattern,
                  color: _plutoDeep,
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _buildPlutoSection(
                  title: 'Das Kraftpotenzial',
                  glyph: '↑',
                  content: pluto.powerPotential,
                  color: _accentGold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 32),

          // Integration key (action box)
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
                colors: [_plutoDeep.shade(0.95), _cosmicNudeLight],
              ),
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: _plutoDeep.shade(0.7)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: _plutoDeep,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'INTEGRATIONS-SCHLÜSSEL',
                        style: pw.TextStyle(
                          fontSize: 8,
                          letterSpacing: 1.5,
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      glyphArrow,
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: _accentGold,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Text(
                        pluto.integrationKey,
                        style: pw.TextStyle(
                          fontSize: 12,
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
          ),

          pw.Spacer(),

          // Footer wisdom
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: const pw.BoxDecoration(
              color: _cosmicNudeLight,
            ),
            child: pw.Text(
              '"Pluto zerstört, um neu zu erschaffen. Was er nimmt, gibt er in transformierter '
              'Form zurück – stärker, authentischer, unaufhaltsam."',
              style: pw.TextStyle(
                fontSize: 11,
                color: _softGray,
                fontStyle: pw.FontStyle.italic,
                lineSpacing: 4,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInsightCard({
    required String label,
    required String content,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: color.shade(0.95),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border(
          left: pw.BorderSide(color: color, width: 4),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              letterSpacing: 2,
              color: color,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            content,
            style: pw.TextStyle(
              fontSize: 14,
              color: _deepCharcoal,
              fontWeight: pw.FontWeight.bold,
              lineSpacing: 5,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPlutoSection({
    required String title,
    required String glyph,
    required String content,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _cosmicNudeLight),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                glyph,
                style: pw.TextStyle(fontSize: 18, color: color),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                title.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 9,
                  letterSpacing: 1,
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
              fontSize: 11,
              color: _deepCharcoal,
              lineSpacing: 5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 4: LILITH ANALYSIS
  // ============================================================

  pw.Page _buildLilithPage(LilithAnalysis lilith) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            children: [
              pw.Text(
                glyphLilith,
                style: pw.TextStyle(fontSize: 32, color: _lilithMagenta),
              ),
              pw.SizedBox(width: 16),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LILITH',
                    style: pw.TextStyle(
                      fontSize: 10,
                      letterSpacing: 3,
                      color: _lilithMagenta,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Verbannte Kraft & Authentisches Selbst',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: _deepCharcoal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          // Position info
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: _lilithMagenta.shade(0.95),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'Lilith in ${lilith.sign.displayName} ${lilith.degree.toStringAsFixed(1)}°'
              '${lilith.house != null ? ' im ${lilith.house}. Haus' : ''}',
              style: pw.TextStyle(
                fontSize: 12,
                color: _lilithMagenta,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 32),

          // Theme card
          _buildInsightCard(
            label: 'DEIN LILITH-ARCHETYP',
            content: lilith.theme,
            color: _lilithMagenta,
          ),
          pw.SizedBox(height: 20),

          // Three cards
          _buildLilithSection(
            title: 'Was verbannt wurde',
            content: lilith.exilePattern,
            color: _lilithMagenta,
          ),
          pw.SizedBox(height: 16),

          _buildLilithSection(
            title: 'Die wilde Kraft dahinter',
            content: lilith.wildPower,
            color: _accentGold,
          ),
          pw.SizedBox(height: 16),

          // Reclamation path (action box)
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
                colors: [_lilithMagenta.shade(0.95), _cosmicNudeLight],
              ),
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: _lilithMagenta.shade(0.7)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: _lilithMagenta,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'RÜCKEROBERUNG',
                        style: pw.TextStyle(
                          fontSize: 8,
                          letterSpacing: 1.5,
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      glyphArrow,
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: _accentGold,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Text(
                        lilith.reclamationPath,
                        style: pw.TextStyle(
                          fontSize: 12,
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
          ),

          pw.Spacer(),

          // Footer wisdom
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: const pw.BoxDecoration(
              color: _cosmicNudeLight,
            ),
            child: pw.Text(
              '"Lilith erinnert dich an die Kraft, die du weggesperrt hast, um akzeptiert zu werden. '
              'Sie wartet darauf, dass du sie zurückholst – ungezähmt, unbeugsam, unentschuldigt."',
              style: pw.TextStyle(
                fontSize: 11,
                color: _softGray,
                fontStyle: pw.FontStyle.italic,
                lineSpacing: 4,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLilithSection({
    required String title,
    required String content,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _cosmicNudeLight),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 9,
              letterSpacing: 1,
              color: color,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            content,
            style: pw.TextStyle(
              fontSize: 11,
              color: _deepCharcoal,
              lineSpacing: 5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 5: SHADOW NUMEROLOGY (Karmic or Missing Numbers)
  // ============================================================

  pw.Page _buildShadowNumerologyPage(ShadowNumerology numerology) {
    final hasKarmic = numerology.karmicNumbers.isNotEmpty;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Text(
            hasKarmic ? 'KARMISCHE ZAHLEN' : 'FEHLENDE ZAHLEN',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: _shadowPurple,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            hasKarmic
                ? 'Lektionen aus der Seele'
                : 'Vakuum-Energie in deinem Chart',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: _deepCharcoal,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            hasKarmic
                ? 'Karmische Zahlen (13, 14, 16, 19) zeigen Lektionen, die deine Seele meistern möchte.'
                : 'Fehlende Zahlen zeigen Energien, die in deinem numerologischen Chart nicht natürlich vorhanden sind.',
            style: pw.TextStyle(
              fontSize: 11,
              color: _softGray,
              lineSpacing: 4,
            ),
          ),
          pw.SizedBox(height: 32),

          if (hasKarmic)
            ...numerology.karmicNumbers.map((k) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 16),
              child: _buildKarmicNumberCard(k),
            ))
          else
            ...numerology.missingNumbers.take(4).map((m) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 16),
              child: _buildMissingNumberCard(m),
            )),

          pw.Spacer(),

          // Shadow Number
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: _shadowPurple.shade(0.95),
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: _shadowPurple.shade(0.7)),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 56,
                  height: 56,
                  decoration: const pw.BoxDecoration(
                    color: _shadowPurple,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '${numerology.shadowNumber}',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'DEINE SCHATTENZAHL',
                        style: pw.TextStyle(
                          fontSize: 9,
                          letterSpacing: 2,
                          color: _shadowPurple,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        numerology.shadowNumberInterpretation,
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: _deepCharcoal,
                          lineSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildKarmicNumberCard(KarmicNumber karmic) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _cosmicNudeLight),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 48,
            height: 48,
            decoration: const pw.BoxDecoration(
              color: _shadowPurple,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                '${karmic.number}',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  karmic.karmicDebt,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: _deepCharcoal,
                  ),
                ),
                pw.Text(
                  'Gefunden in: ${karmic.source}',
                  style: pw.TextStyle(fontSize: 9, color: _softGray),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  karmic.transformationPath,
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: _deepCharcoal,
                    lineSpacing: 4,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Text(
                      glyphStar,
                      style: pw.TextStyle(fontSize: 10, color: _accentGold),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Expanded(
                      child: pw.Text(
                        karmic.strengthGained,
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: _accentGold,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMissingNumberCard(MissingNumber missing) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _cosmicNudeLight),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 48,
            height: 48,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _shadowPurple, width: 2),
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                '${missing.number}',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: _shadowPurple,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  missing.vacuumEnergy,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: _deepCharcoal,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  missing.manifestation,
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: _softGray,
                    lineSpacing: 4,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      glyphArrow,
                      style: pw.TextStyle(fontSize: 10, color: _accentGold),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Expanded(
                      child: pw.Text(
                        missing.balancePath,
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: _accentGold,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 6: 4-PHASE SHADOW RADAR (Rolling 12-Month Model)
  // ============================================================

  pw.Page _buildShadowRadarPage(ShadowRadar radar) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header - Rolling 12-Month Focus
          pw.Text(
            'DEIN 12-MONATE-SCHATTEN-FOKUS',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: _shadowPurple,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Der Weg zur Schattenintegration',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: _deepCharcoal,
            ),
          ),
          pw.SizedBox(height: 4),
          // Subtitle explaining rolling model
          pw.Text(
            'Dein persönlicher Transformationszyklus beginnt ab dem Kaufdatum',
            style: pw.TextStyle(
              fontSize: 10,
              color: _softGray,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 24),

          // Visual radar representation
          pw.Row(
            children: radar.allPhases.map((phase) {
              return pw.Expanded(
                child: _buildPhaseColumn(phase),
              );
            }).toList(),
          ),
          pw.SizedBox(height: 24),

          // Detailed phase descriptions
          ...radar.allPhases.map((phase) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 16),
            child: _buildPhaseDetailCard(phase),
          )),
        ],
      ),
    );
  }

  pw.Widget _buildPhaseColumn(ShadowPhase phase) {
    final phaseColors = [_shadowPurple, _plutoDeep, _lilithMagenta, _accentGold];
    final color = phaseColors[phase.phaseNumber - 1];

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(horizontal: 4),
      child: pw.Column(
        children: [
          // Timeframe label (Rolling 12-Month)
          pw.Text(
            phase.timeframeLabel,
            style: pw.TextStyle(
              fontSize: 8,
              color: color,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          // Phase number circle
          pw.Container(
            width: 36,
            height: 36,
            decoration: pw.BoxDecoration(
              color: color,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                '${phase.phaseNumber}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            phase.name,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _deepCharcoal,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${phase.completionPercent}%',
            style: pw.TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          // Progress bar
          pw.Container(
            width: 60,
            height: 4,
            decoration: pw.BoxDecoration(
              color: _cosmicNudeLight,
              borderRadius: pw.BorderRadius.circular(2),
            ),
            child: pw.Stack(
              children: [
                pw.Container(
                  width: phase.completionPercent * 0.6,
                  height: 4,
                  decoration: pw.BoxDecoration(
                    color: color,
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPhaseDetailCard(ShadowPhase phase) {
    final phaseColors = [_shadowPurple, _plutoDeep, _lilithMagenta, _accentGold];
    final color = phaseColors[phase.phaseNumber - 1];

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: color.shade(0.95),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border(
          left: pw.BorderSide(color: color, width: 3),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'PHASE ${phase.phaseNumber}: ${phase.name.toUpperCase()}',
                style: pw.TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  color: color,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                phase.keywords.join(' · '),
                style: pw.TextStyle(fontSize: 8, color: _softGray),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '"${phase.mantra}"',
            style: pw.TextStyle(
              fontSize: 11,
              color: _deepCharcoal,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                glyphCheck,
                style: pw.TextStyle(fontSize: 10, color: color),
              ),
              pw.SizedBox(width: 6),
              pw.Expanded(
                child: pw.Text(
                  phase.practicalAction,
                  style: pw.TextStyle(fontSize: 9, color: _deepCharcoal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 7: INTEGRATION PAGE
  // ============================================================

  pw.Page _buildIntegrationPage(ShadowLightAnalysis analysis) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Text(
            'DEIN INTEGRATIONS-FAHRPLAN',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: _shadowPurple,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Konkrete Schritte zur Transformation',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: _deepCharcoal,
            ),
          ),
          pw.SizedBox(height: 32),

          // Action items from phases
          _buildIntegrationStep(
            number: 1,
            title: 'Konfrontation',
            action: analysis.shadowRadar.konfrontation.practicalAction,
            color: _shadowPurple,
          ),
          pw.SizedBox(height: 16),

          _buildIntegrationStep(
            number: 2,
            title: 'Dekonstruktion',
            action: analysis.shadowRadar.dekonstruktion.practicalAction,
            color: _plutoDeep,
          ),
          pw.SizedBox(height: 16),

          _buildIntegrationStep(
            number: 3,
            title: 'Alchemie',
            action: analysis.shadowRadar.alchemie.practicalAction,
            color: _lilithMagenta,
          ),
          pw.SizedBox(height: 16),

          _buildIntegrationStep(
            number: 4,
            title: 'Inkarnation',
            action: analysis.shadowRadar.inkarnation.practicalAction,
            color: _accentGold,
          ),

          pw.Spacer(),

          // Key reminder
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
                colors: [_shadowPurple.shade(0.95), _accentGold.shade(0.95)],
              ),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  '$glyphMoon',
                  style: pw.TextStyle(fontSize: 24, color: _accentGold),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Erinnere dich:',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: _deepCharcoal,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Schattenarbeit ist kein linearer Prozess. Du bewegst dich in Spiralen, '
                  'und jede Runde bringt dich tiefer in deine Kraft. Sei geduldig mit dir selbst.',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: _deepCharcoal,
                    lineSpacing: 5,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildIntegrationStep({
    required int number,
    required String title,
    required String action,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _cosmicNudeLight),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 32,
            height: 32,
            decoration: pw.BoxDecoration(
              color: color,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                '$number',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    color: color,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  action,
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: _deepCharcoal,
                    lineSpacing: 4,
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
  // PAGE 8: CLOSING PAGE
  // ============================================================

  pw.Page _buildShadowClosingPage(StructuredReport report, ShadowLightAnalysis analysis) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DEIN LICHT WARTET',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: _accentGold,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 32),

          // Final message
          pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: _shadowPurple.shade(0.95),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Text(
              'Du hast den Mut bewiesen, in deinen Schatten zu blicken. '
              'Das ist bereits der erste und wichtigste Schritt. Jeder Mensch trägt '
              'verborgene Kräfte in sich, die darauf warten, integriert zu werden. '
              'Deine Dunkelheit ist nicht dein Feind – sie ist der Rohstoff für deine '
              'größte Transformation.\n\n'
              'Die Energien von Pluto und Lilith in deinem Chart zeigen, wo deine '
              'tiefste Kraft liegt. Die numerologischen Muster enthüllen die Lektionen, '
              'die deine Seele gewählt hat. Gemeinsam bilden sie den Schlüssel zu deinem '
              'vollständigen, strahlenden Selbst.\n\n'
              'Gehe behutsam, aber entschlossen. Du bist bereit.',
              style: pw.TextStyle(
                fontSize: 13,
                color: _deepCharcoal,
                lineSpacing: 6,
              ),
            ),
          ),
          pw.SizedBox(height: 48),

          // Pull quotes
          pw.Text(
            'DEINE SCHATTEN-MANTRAS',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: _softGray,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),

          ...analysis.shadowRadar.allPhases.map((phase) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 24,
                  height: 24,
                  decoration: const pw.BoxDecoration(
                    color: _accentGold,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '${phase.phaseNumber}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Text(
                    '"${phase.mantra}"',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: _deepCharcoal,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          )),

          pw.Spacer(),

          // Footer
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  '$glyphMoon $glyphStar $glyphMoon',
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: _accentGold,
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
                  'Shadow & Light Report',
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
}

// Note: ZodiacSign.displayName is already defined in models.dart
