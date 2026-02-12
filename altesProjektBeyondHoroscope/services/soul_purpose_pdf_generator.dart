// ============================================================
// SOUL PURPOSE PDF GENERATOR
// ============================================================
//
// "Soul Purpose – Die Reise Deiner Essenz"
//
// Design Philosophy:
// - "Cosmic Nude" palette with Spirit Indigo + Pearlescent accents
// - Meditative, spacious layout with generous white space
// - Lotus, Moon Node symbols (☊ / ☋), Infinity (∞) as design elements
// - Poetisch, tiefgründig, weise tone
//
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/models.dart';
import '../models/soul_purpose_analysis.dart';
import '../models/structured_report.dart';

class SoulPurposePdfGenerator {
  // Singleton
  static final SoulPurposePdfGenerator _instance = SoulPurposePdfGenerator._internal();
  factory SoulPurposePdfGenerator() => _instance;
  SoulPurposePdfGenerator._internal();

  // ============================================================
  // COSMIC NUDE + SPIRIT INDIGO COLOR PALETTE
  // ============================================================

  static const PdfColor _warmWhite = PdfColor.fromInt(0xFFFAF8F5);
  static const PdfColor _deepCharcoal = PdfColor.fromInt(0xFF2D2926);
  static const PdfColor _softGray = PdfColor.fromInt(0xFF6B6B6B);
  static const PdfColor _cosmicNude = PdfColor.fromInt(0xFFB8A394);
  static const PdfColor _cosmicNudeLight = PdfColor.fromInt(0xFFD4C4B5);
  static const PdfColor _cosmicNudeDark = PdfColor.fromInt(0xFF8B7355);

  // Soul Purpose specific colors
  static const PdfColor _spiritIndigo = PdfColor.fromInt(0xFF4B5D8C);
  static const PdfColor _spiritIndigoLight = PdfColor.fromInt(0xFFE8EBF3);
  static const PdfColor _pearlescent = PdfColor.fromInt(0xFFF5F0E8);
  static const PdfColor _soulGold = PdfColor.fromInt(0xFFCFB87C);

  // Phase colors for Soul Compass
  static const PdfColor _phaseIndigo = PdfColor.fromInt(0xFF4B5D8C);
  static const PdfColor _phasePearl = PdfColor.fromInt(0xFFD4C4B5);
  static const PdfColor _phaseNude = PdfColor.fromInt(0xFFB8A394);
  static const PdfColor _phaseGold = PdfColor.fromInt(0xFFCFB87C);

  // ============================================================
  // UNICODE GLYPHS
  // ============================================================

  static const String glyphSouthNode = '☋';
  static const String glyphNorthNode = '☊';
  static const String glyphLotus = '✿';
  static const String glyphSaturn = '♄';
  static const String glyphInfinity = '∞';
  static const String glyphStar = '✦';
  static const String glyphMoon = '☽';
  static const String glyphSun = '☉';
  static const String glyphArrow = '→';
  static const String glyphCheck = '✓';

  // Zodiac glyphs
  static const Map<String, String> _zodiacGlyphs = {
    'aries': '♈', 'taurus': '♉', 'gemini': '♊', 'cancer': '♋',
    'leo': '♌', 'virgo': '♍', 'libra': '♎', 'scorpio': '♏',
    'sagittarius': '♐', 'capricorn': '♑', 'aquarius': '♒', 'pisces': '♓',
  };

  static String getZodiacGlyph(ZodiacSign? sign) {
    if (sign == null) return glyphStar;
    return _zodiacGlyphs[sign.name.toLowerCase()] ?? glyphStar;
  }

  // ============================================================
  // PAGE FORMAT
  // ============================================================

  static const PdfPageFormat _a4Portrait = PdfPageFormat(
    595.28,
    841.89,
    marginAll: 0,
  );

  // ============================================================
  // MAIN GENERATION METHOD
  // ============================================================

  Future<Uint8List> generateSoulPurposePdf(
    SoulPurposeAnalysis analysis,
    StructuredReport baseReport,
  ) async {
    debugPrint('=== GENERATING SOUL PURPOSE PDF ===');
    debugPrint('Soul Urge: ${analysis.soulUrgeAnalysis.soulUrgeNumber}');
    debugPrint('Is Master Number: ${analysis.soulUrgeAnalysis.isMasterNumber}');

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await _loadFont('assets/fonts/Nunito-Regular.ttf'),
        bold: await _loadFont('assets/fonts/Nunito-Bold.ttf'),
        italic: await _loadFont('assets/fonts/Nunito-Italic.ttf'),
      ),
    );

    // Page 1: Cover - Das Portal zur Essenz
    pdf.addPage(_buildCoverPage(baseReport, analysis));

    // Page 2: Der Ruf Deiner Seele (Seelenzahl)
    pdf.addPage(_buildSoulUrgePage(analysis.soulUrgeAnalysis));

    // Page 3: Karma & Befreiung (Südknoten + Saturn)
    pdf.addPage(_buildKarmaPage(analysis.karmaAnalysis));

    // Page 4: Die Bestimmung Deiner Essenz (Nordknoten + Reifezahl)
    pdf.addPage(_buildEssencePage(analysis.essenceDestinyAnalysis));

    // Page 5: Die Seelen-Synthese
    pdf.addPage(_buildSynthesisPage(analysis.soulSynthesis));

    // Page 6: 12-Monate Seelen-Kompass
    pdf.addPage(_buildSoulCompassPage(analysis.soulCompass));

    return pdf.save();
  }

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
  // PAGE 1: COVER - DAS PORTAL ZUR ESSENZ
  // ============================================================

  pw.Page _buildCoverPage(StructuredReport report, SoulPurposeAnalysis analysis) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: pw.EdgeInsets.zero,
      build: (context) => pw.Container(
        width: double.infinity,
        height: double.infinity,
        decoration: pw.BoxDecoration(
          gradient: pw.LinearGradient(
            begin: pw.Alignment.topCenter,
            end: pw.Alignment.bottomCenter,
            colors: [_warmWhite, _spiritIndigoLight],
          ),
        ),
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(56),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Brand
              pw.Text(
                'BEYOND HOROSCOPE',
                style: pw.TextStyle(
                  fontSize: 10,
                  letterSpacing: 4,
                  color: _softGray,
                ),
              ),
              pw.SizedBox(height: 48),

              // Lotus Symbol
              pw.Text(
                glyphLotus,
                style: pw.TextStyle(
                  fontSize: 64,
                  color: _spiritIndigo,
                ),
              ),
              pw.SizedBox(height: 32),

              // Main Title
              pw.Text(
                'SOUL PURPOSE',
                style: pw.TextStyle(
                  fontSize: 42,
                  fontWeight: pw.FontWeight.bold,
                  color: _deepCharcoal,
                  letterSpacing: 6,
                ),
              ),
              pw.SizedBox(height: 16),

              // Subtitle
              pw.Text(
                'Die heilige Geometrie Deines Seelenplans',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontStyle: pw.FontStyle.italic,
                  color: _spiritIndigo,
                ),
              ),
              pw.SizedBox(height: 64),

              // Decorative line
              pw.Container(
                width: 100,
                height: 1,
                color: _soulGold,
              ),
              pw.SizedBox(height: 64),

              // User info
              pw.Text(
                'Erstellt für',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: _softGray,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                report.cover.userName,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: _deepCharcoal,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                report.cover.birthDate,
                style: pw.TextStyle(
                  fontSize: 12,
                  color: _softGray,
                ),
              ),
              pw.SizedBox(height: 48),

              // Soul Urge Badge
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _spiritIndigo, width: 1),
                  borderRadius: pw.BorderRadius.circular(24),
                ),
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      '$glyphLotus  Seelenzahl ',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: _spiritIndigo,
                      ),
                    ),
                    pw.Text(
                      '${analysis.soulUrgeAnalysis.soulUrgeNumber}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: _spiritIndigo,
                      ),
                    ),
                    if (analysis.soulUrgeAnalysis.isMasterNumber)
                      pw.Text(
                        '  $glyphStar MEISTER',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: _soulGold,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAGE 2: DER RUF DEINER SEELE (SEELENZAHL)
  // ============================================================

  pw.Page _buildSoulUrgePage(SoulUrgeAnalysis analysis) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            children: [
              pw.Text(
                glyphLotus,
                style: pw.TextStyle(fontSize: 24, color: _spiritIndigo),
              ),
              pw.SizedBox(width: 12),
              pw.Text(
                'DIE SEELENZAHL',
                style: pw.TextStyle(
                  fontSize: 10,
                  letterSpacing: 3,
                  color: _spiritIndigo,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Der Ruf Deiner Seele',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: _deepCharcoal,
            ),
          ),
          pw.SizedBox(height: 32),

          // Large Soul Urge Number
          pw.Center(
            child: pw.Container(
              width: 100,
              height: 100,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                gradient: pw.LinearGradient(
                  colors: [_spiritIndigo, _spiritIndigoLight],
                ),
              ),
              child: pw.Center(
                child: pw.Text(
                  '${analysis.soulUrgeNumber}',
                  style: pw.TextStyle(
                    fontSize: 48,
                    fontWeight: pw.FontWeight.bold,
                    color: _warmWhite,
                  ),
                ),
              ),
            ),
          ),
          if (analysis.isMasterNumber)
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8),
                child: pw.Text(
                  '$glyphStar MEISTERZAHL $glyphStar',
                  style: pw.TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: _soulGold,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
          pw.SizedBox(height: 32),

          // Deepest Desire Card
          _buildInsightCard(
            label: 'DEIN TIEFSTER HERZENSWUNSCH',
            content: analysis.deepestDesire,
            color: _spiritIndigo,
          ),
          pw.SizedBox(height: 20),

          // Soul Nourishment Card
          _buildInsightCard(
            label: 'WAS DICH WIRKLICH NÄHRT',
            content: analysis.soulNourishment,
            color: _cosmicNudeDark,
          ),
          pw.SizedBox(height: 20),

          // Master Frequency Call (only if master number)
          if (analysis.isMasterNumber && analysis.masterFrequencyCall != null)
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: _soulGold.shade(0.15),
                border: pw.Border.all(color: _soulGold, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '$glyphStar DER RUF DER MEISTER-FREQUENZ',
                    style: pw.TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: _soulGold,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    analysis.masterFrequencyCall!,
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: _deepCharcoal,
                      lineSpacing: 5,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          pw.Spacer(),

          // Soul Gifts Tags
          pw.Text(
            'DEINE SEELEN-GABEN',
            style: pw.TextStyle(
              fontSize: 9,
              letterSpacing: 2,
              color: _spiritIndigo,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: analysis.soulGifts.map((gift) => _buildTag(gift, _spiritIndigoLight)).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 3: KARMA & BEFREIUNG
  // ============================================================

  pw.Page _buildKarmaPage(KarmaAnalysis analysis) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            children: [
              pw.Text(
                glyphSouthNode,
                style: pw.TextStyle(fontSize: 24, color: _cosmicNudeDark),
              ),
              pw.SizedBox(width: 12),
              pw.Text(
                'KARMA & BEFREIUNG',
                style: pw.TextStyle(
                  fontSize: 10,
                  letterSpacing: 3,
                  color: _cosmicNudeDark,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Die Last, die zur Leiter wird',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: _deepCharcoal,
            ),
          ),
          pw.SizedBox(height: 24),

          // South Node Position
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _cosmicNudeLight.shade(0.5),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  getZodiacGlyph(analysis.southNodeSign),
                  style: pw.TextStyle(fontSize: 32, color: _cosmicNudeDark),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SÜDKNOTEN',
                        style: pw.TextStyle(
                          fontSize: 9,
                          letterSpacing: 2,
                          color: _softGray,
                        ),
                      ),
                      pw.Text(
                        analysis.southNodeSign.displayName,
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: _deepCharcoal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Karmic Pattern
          _buildInsightCard(
            label: 'DEIN KARMISCHES MUSTER',
            content: analysis.karmicPattern,
            color: _cosmicNudeDark,
          ),
          pw.SizedBox(height: 16),

          // Release Theme
          _buildInsightCard(
            label: 'WAS DU LOSLASSEN DARFST',
            content: analysis.releaseTheme,
            color: _spiritIndigo,
          ),
          pw.SizedBox(height: 24),

          // Saturn Section
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _cosmicNude, width: 1),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      glyphSaturn,
                      style: pw.TextStyle(fontSize: 20, color: _cosmicNudeDark),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      'SATURNS LEKTION  $glyphArrow  ${analysis.saturnSign.displayName}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        letterSpacing: 1,
                        color: _cosmicNudeDark,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: _buildSmallCard(
                        label: 'DIE PRÜFUNG',
                        content: analysis.saturnLesson,
                        color: _cosmicNudeDark,
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _buildSmallCard(
                        label: 'DAS GESCHENK',
                        content: analysis.saturnGift,
                        color: _soulGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.Spacer(),

          // Past Life Echoes
          pw.Text(
            'ECHOS VERGANGENER LEBEN',
            style: pw.TextStyle(
              fontSize: 9,
              letterSpacing: 2,
              color: _softGray,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          ...analysis.pastLifeEchoes.map((echo) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  children: [
                    pw.Text(
                      glyphMoon,
                      style: pw.TextStyle(fontSize: 12, color: _cosmicNude),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      echo,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: _softGray,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 4: DIE BESTIMMUNG DEINER ESSENZ
  // ============================================================

  pw.Page _buildEssencePage(EssenceDestinyAnalysis analysis) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            children: [
              pw.Text(
                glyphNorthNode,
                style: pw.TextStyle(fontSize: 24, color: _spiritIndigo),
              ),
              pw.SizedBox(width: 12),
              pw.Text(
                'DEIN NORDSTERN',
                style: pw.TextStyle(
                  fontSize: 10,
                  letterSpacing: 3,
                  color: _spiritIndigo,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Die Bestimmung Deiner Essenz',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: _deepCharcoal,
            ),
          ),
          pw.SizedBox(height: 24),

          // North Node Position (prominent)
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [_spiritIndigo, _spiritIndigoLight],
              ),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  getZodiacGlyph(analysis.northNodeSign),
                  style: pw.TextStyle(fontSize: 40, color: _warmWhite),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'NORDKNOTEN',
                        style: pw.TextStyle(
                          fontSize: 9,
                          letterSpacing: 2,
                          color: _warmWhite.shade(0.8),
                        ),
                      ),
                      pw.Text(
                        analysis.northNodeSign.displayName,
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: _warmWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Soul Direction
          _buildInsightCard(
            label: 'IN WELCHE ENERGIE SOLLST DU HINEINWACHSEN?',
            content: analysis.soulDirection,
            color: _spiritIndigo,
          ),
          pw.SizedBox(height: 16),

          // North Star Vision
          _buildInsightCard(
            label: 'DEIN NORDSTERN - DIE VISION',
            content: analysis.northStarVision,
            color: _soulGold,
          ),
          pw.SizedBox(height: 24),

          // Maturity Number Section
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _pearlescent,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 50,
                  height: 50,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    color: _cosmicNude,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '${analysis.maturityNumber}',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: _warmWhite,
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
                        'REIFEZAHL ${analysis.maturityNumber}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          letterSpacing: 2,
                          color: _cosmicNudeDark,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Erfüllung in der zweiten Lebenshälfte',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: _softGray,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        analysis.secondHalfFulfillment,
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

          pw.Spacer(),

          // Essence Qualities
          pw.Text(
            'QUALITÄTEN DEINER ESSENZ',
            style: pw.TextStyle(
              fontSize: 9,
              letterSpacing: 2,
              color: _spiritIndigo,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: analysis.essenceQualities.map((quality) => _buildEssencePillar(quality)).toList(),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEssencePillar(String quality) {
    return pw.Column(
      children: [
        pw.Container(
          width: 60,
          height: 60,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: _spiritIndigo, width: 2),
          ),
          child: pw.Center(
            child: pw.Text(
              glyphStar,
              style: pw.TextStyle(fontSize: 20, color: _spiritIndigo),
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          quality,
          style: pw.TextStyle(
            fontSize: 9,
            color: _deepCharcoal,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  // ============================================================
  // PAGE 5: DIE SEELEN-SYNTHESE
  // ============================================================

  pw.Page _buildSynthesisPage(SoulSynthesis synthesis) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            children: [
              pw.Text(
                glyphInfinity,
                style: pw.TextStyle(fontSize: 24, color: _soulGold),
              ),
              pw.SizedBox(width: 12),
              pw.Text(
                'DIE SEELEN-SYNTHESE',
                style: pw.TextStyle(
                  fontSize: 10,
                  letterSpacing: 3,
                  color: _soulGold,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Die Verschmelzung Deiner Essenzen',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: _deepCharcoal,
            ),
          ),
          pw.SizedBox(height: 32),

          // Inner Animal Box
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _cosmicNudeLight, width: 1),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      synthesis.innerAnimal.emoji,
                      style: const pw.TextStyle(fontSize: 32),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'DEIN INNERES TIER',
                            style: pw.TextStyle(
                              fontSize: 9,
                              letterSpacing: 2,
                              color: _cosmicNudeDark,
                            ),
                          ),
                          pw.Text(
                            'Der ${synthesis.innerAnimal.displayName}',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: _deepCharcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  synthesis.innerAnimalEmotion,
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: _deepCharcoal,
                    lineSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Emotion Fuel Connection
          _buildInsightCard(
            label: 'WARUM DEINE EMOTIONEN DER TREIBSTOFF SIND',
            content: synthesis.emotionFuelConnection,
            color: _spiritIndigo,
          ),
          pw.SizedBox(height: 24),

          // Sacred Yes Box
          pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: _soulGold.shade(0.15),
              border: pw.Border.all(color: _soulGold, width: 2),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '$glyphStar DAS HEILIGE JA $glyphStar',
                  style: pw.TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: _soulGold,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  synthesis.sacredYes,
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: _deepCharcoal,
                    lineSpacing: 5,
                  ),
                ),
              ],
            ),
          ),

          pw.Spacer(),

          // Soul Mission Statement
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: _deepCharcoal,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'DEINE SEELEN-MISSION',
                  style: pw.TextStyle(
                    fontSize: 9,
                    letterSpacing: 2,
                    color: _warmWhite.shade(0.7),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  '"${synthesis.soulMission}"',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontStyle: pw.FontStyle.italic,
                    color: _warmWhite,
                    lineSpacing: 6,
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

  // ============================================================
  // PAGE 6: 12-MONATE SEELEN-KOMPASS
  // ============================================================

  pw.Page _buildSoulCompassPage(SoulCompass compass) {
    final phases = [
      {'phase': compass.purification, 'color': _phaseIndigo, 'number': 1},
      {'phase': compass.intuition, 'color': _phasePearl, 'number': 2},
      {'phase': compass.embodiment, 'color': _phaseNude, 'number': 3},
      {'phase': compass.mastery, 'color': _phaseGold, 'number': 4},
    ];

    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            children: [
              pw.Text(
                glyphMoon,
                style: pw.TextStyle(fontSize: 24, color: _spiritIndigo),
              ),
              pw.SizedBox(width: 12),
              pw.Text(
                'DEIN 12-MONATE SEELEN-KOMPASS',
                style: pw.TextStyle(
                  fontSize: 10,
                  letterSpacing: 3,
                  color: _spiritIndigo,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Der Rhythmus Deiner Seelen-Reise',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: _deepCharcoal,
            ),
          ),
          pw.SizedBox(height: 32),

          // Phase Cards
          ...phases.map((p) {
            final phase = p['phase'] as SoulPhase;
            final color = p['color'] as PdfColor;
            final number = p['number'] as int;
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 16),
              child: _buildPhaseCard(phase, color, number),
            );
          }),

          pw.Spacer(),

          // Footer Note
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _pearlescent,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  glyphInfinity,
                  style: pw.TextStyle(fontSize: 20, color: _spiritIndigo),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Text(
                    'Die Phasen folgen deinem persönlichen Rhythmus ab dem Kaufdatum. '
                    'Jeder Zyklus baut auf dem vorherigen auf. Vertraue dem Prozess.',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: _softGray,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Brand Footer
          pw.Center(
            child: pw.Text(
              '$glyphStar  BEYOND HOROSCOPE  $glyphStar',
              style: pw.TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                color: _cosmicNude,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPhaseCard(SoulPhase phase, PdfColor accentColor, int number) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: accentColor, width: 4)),
        color: accentColor.shade(0.95),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Phase Number Circle
          pw.Container(
            width: 36,
            height: 36,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: accentColor,
            ),
            child: pw.Center(
              child: pw.Text(
                '$number',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: _warmWhite,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      phase.theme.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: pw.FontWeight.bold,
                        color: _deepCharcoal,
                      ),
                    ),
                    pw.Text(
                      phase.timeframe,
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: _softGray,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  phase.guidance,
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: _deepCharcoal,
                    lineSpacing: 4,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  phase.meditation,
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: _spiritIndigo,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                if (phase.completionPercent > 0) ...[
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Container(
                          height: 4,
                          decoration: pw.BoxDecoration(
                            color: _cosmicNudeLight,
                            borderRadius: pw.BorderRadius.circular(2),
                          ),
                          child: pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Container(
                              width: phase.completionPercent * 2.0,
                              height: 4,
                              decoration: pw.BoxDecoration(
                                color: accentColor,
                                borderRadius: pw.BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        '${phase.completionPercent}%',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: _softGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REUSABLE WIDGETS
  // ============================================================

  pw.Widget _buildInsightCard({
    required String label,
    required String content,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: color, width: 4)),
        color: color.shade(0.95),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
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
              fontSize: 10,
              color: _deepCharcoal,
              lineSpacing: 5,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSmallCard({
    required String label,
    required String content,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: color, width: 3)),
        color: color.shade(0.95),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8,
              letterSpacing: 1,
              color: color,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            content,
            style: pw.TextStyle(
              fontSize: 9,
              color: _deepCharcoal,
              lineSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTag(String text, PdfColor backgroundColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: backgroundColor,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          color: _deepCharcoal,
        ),
      ),
    );
  }
}
