// ============================================================
// NUURAY SIGNATUR-REPORT PDF GENERATOR
// ============================================================
//
// Generiert einen hochwertigen PDF-Report (~12-15 Seiten) aus der
// kosmischen Signatur des Users. Adaptiert vom Beyond Horoscope
// LuxuryPdfGenerator, deutlich schlanker.
//
// Seiten:
// 1. Cover (NUURAY Branding, Name, Archetyp)
// 2. Kosmische Identität (Überblick aller 3 Systeme)
// 3-4. Tiefe Synthese (bestehender Text)
// 5-6. Deine Psyche: Westliche Astrologie
// 7-8. Deine Energie: Bazi
// 8-10. Dein Seelenweg: Numerologie
// 11. Das Wesentliche (3 Erkenntnisse)
// 12. Fragen an dich (7 Reflexionsfragen)
// 13. Closing Page
//
// ============================================================

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/signature_report_data.dart';

class SignaturePdfGenerator {
  // Singleton
  static final SignaturePdfGenerator _instance = SignaturePdfGenerator._internal();
  factory SignaturePdfGenerator() => _instance;
  SignaturePdfGenerator._internal();

  // ============================================================
  // NUURAY COLOR PALETTE
  // ============================================================

  static const PdfColor _warmWhite = PdfColor.fromInt(0xFFFAF9F6);
  static const PdfColor _deepCharcoal = PdfColor.fromInt(0xFF2C2C2C);
  static const PdfColor _accentGold = PdfColor.fromInt(0xFFD4AF37);
  static const PdfColor _softGray = PdfColor.fromInt(0xFF6B6B6B);
  static const PdfColor _borderColor = PdfColor.fromInt(0xFFE8E3D8);
  static const PdfColor _goldLight = PdfColor.fromInt(0xFFFFF8E7);

  // ============================================================
  // PAGE FORMAT — A4 Portrait
  // ============================================================

  static const PdfPageFormat _a4Portrait = PdfPageFormat(
    595.28, // width in points (210mm)
    841.89, // height in points (297mm)
    marginAll: 0,
  );

  // ============================================================
  // ZODIAC ABBREVIATIONS (ASCII only — NotoSans lacks zodiac Unicode)
  // ============================================================

  static const Map<String, String> _zodiacAbbrDE = {
    'aries': 'Widder',
    'taurus': 'Stier',
    'gemini': 'Zwillinge',
    'cancer': 'Krebs',
    'leo': 'Löwe',
    'virgo': 'Jungfrau',
    'libra': 'Waage',
    'scorpio': 'Skorpion',
    'sagittarius': 'Schütze',
    'capricorn': 'Steinbock',
    'aquarius': 'Wassermann',
    'pisces': 'Fische',
  };

  static const Map<String, String> _zodiacAbbrEN = {
    'aries': 'Aries',
    'taurus': 'Taurus',
    'gemini': 'Gemini',
    'cancer': 'Cancer',
    'leo': 'Leo',
    'virgo': 'Virgo',
    'libra': 'Libra',
    'scorpio': 'Scorpio',
    'sagittarius': 'Sagittarius',
    'capricorn': 'Capricorn',
    'aquarius': 'Aquarius',
    'pisces': 'Pisces',
  };

  static const Map<String, String> _baziElementsDE = {
    // Stems → Element + Polarität
    'Jia': 'Yang-Holz', 'Yi': 'Yin-Holz',
    'Bing': 'Yang-Feuer', 'Ding': 'Yin-Feuer',
    'Wu': 'Yang-Erde', 'Ji': 'Yin-Erde',
    'Geng': 'Yang-Metall', 'Xin': 'Yin-Metall',
    'Ren': 'Yang-Wasser', 'Gui': 'Yin-Wasser',
    // Deutsche Element-Keys
    'Holz': 'Holz', 'Feuer': 'Feuer', 'Erde': 'Erde',
    'Metall': 'Metall', 'Wasser': 'Wasser',
    // Englische Element-Keys (DB-Werte)
    'Wood': 'Holz', 'Fire': 'Feuer', 'Earth': 'Erde',
    'Metal': 'Metall', 'Water': 'Wasser',
  };

  static const Map<String, String> _baziElementsEN = {
    // Stems → Element + Polarität
    'Jia': 'Yang Wood', 'Yi': 'Yin Wood',
    'Bing': 'Yang Fire', 'Ding': 'Yin Fire',
    'Wu': 'Yang Earth', 'Ji': 'Yin Earth',
    'Geng': 'Yang Metal', 'Xin': 'Yin Metal',
    'Ren': 'Yang Water', 'Gui': 'Yin Water',
    // Deutsche Element-Keys
    'Holz': 'Wood', 'Feuer': 'Fire', 'Erde': 'Earth',
    'Metall': 'Metal', 'Wasser': 'Water',
    // Englische Element-Keys (DB-Werte)
    'Wood': 'Wood', 'Fire': 'Fire', 'Earth': 'Earth',
    'Metal': 'Metal', 'Water': 'Water',
  };

  // Erdzweige (Branches) → Tierzeichen DE/EN
  static const Map<String, String> _baziBranchDE = {
    // Pinyin-Keys
    'Zi': 'Ratte', 'Chou': 'Ochse', 'Yin': 'Tiger',
    'Mao': 'Hase', 'Chen': 'Drache', 'Si': 'Schlange',
    'Wu': 'Pferd', 'Wei': 'Ziege', 'Shen': 'Affe',
    'You': 'Hahn', 'Xu': 'Hund', 'Hai': 'Schwein',
    // Englische Keys (DB-Werte)
    'Rat': 'Ratte', 'Ox': 'Ochse', 'Tiger': 'Tiger',
    'Rabbit': 'Hase', 'Dragon': 'Drache', 'Snake': 'Schlange',
    'Horse': 'Pferd', 'Goat': 'Ziege', 'Monkey': 'Affe',
    'Rooster': 'Hahn', 'Dog': 'Hund', 'Pig': 'Schwein',
  };

  static const Map<String, String> _baziBranchEN = {
    // Pinyin-Keys
    'Zi': 'Rat', 'Chou': 'Ox', 'Yin': 'Tiger',
    'Mao': 'Rabbit', 'Chen': 'Dragon', 'Si': 'Snake',
    'Wu': 'Horse', 'Wei': 'Goat', 'Shen': 'Monkey',
    'You': 'Rooster', 'Xu': 'Dog', 'Hai': 'Pig',
    // Englische Keys (DB-Werte → bleiben gleich)
    'Rat': 'Rat', 'Ox': 'Ox', 'Tiger': 'Tiger',
    'Rabbit': 'Rabbit', 'Dragon': 'Dragon', 'Snake': 'Snake',
    'Horse': 'Horse', 'Goat': 'Goat', 'Monkey': 'Monkey',
    'Rooster': 'Rooster', 'Dog': 'Dog', 'Pig': 'Pig',
  };

  // ============================================================
  // MAIN GENERATION METHOD
  // ============================================================

  /// Generiert das vollständige Signatur-Report PDF
  Future<Uint8List> generateReport(SignatureReportData data) async {
    // Fonts laden (NotoSans für volle Unicode-Unterstützung)
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await _loadFont('assets/fonts/NotoSans-Regular.ttf'),
        bold: await _loadFont('assets/fonts/NotoSans-Bold.ttf'),
        italic: await _loadFont('assets/fonts/NotoSans-Italic.ttf'),
      ),
    );

    final isDe = data.language.toUpperCase() == 'DE';

    // 1. Cover Page
    pdf.addPage(_buildCoverPage(data, isDe));

    // 2. Einleitung — Was dich hier erwartet
    pdf.addPage(_buildIntroductionPage(isDe));

    // 3. Deine Kosmische Signatur — Alle Parameter auf einen Blick
    pdf.addPage(_buildParameterOverviewPage(data, isDe));

    // 4-5. Westliche Astrologie
    pdf.addPage(pw.MultiPage(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.symmetric(horizontal: 56, vertical: 64),
      header: (context) => _buildPageHeader(isDe),
      footer: (context) => _buildPageFooter(context),
      build: (context) => _buildChapterContent(
        title: isDe ? 'Dein Inneres Muster' : 'Your Inner Pattern',
        subtitle: isDe ? 'Westliche Astrologie' : 'Western Astrology',
        text: data.chapterWestern,
      ),
    ));

    // 6-7. Bazi — Chinesische Astrologie
    pdf.addPage(pw.MultiPage(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.symmetric(horizontal: 56, vertical: 64),
      header: (context) => _buildPageHeader(isDe),
      footer: (context) => _buildPageFooter(context),
      build: (context) => _buildChapterContent(
        title: isDe ? 'Dein Elementares Wesen' : 'Your Elemental Nature',
        subtitle: isDe ? 'Bazi — Die Vier Säulen' : 'Bazi — The Four Pillars',
        text: data.chapterBazi,
      ),
    ));

    // 8-9. Numerologie
    pdf.addPage(pw.MultiPage(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.symmetric(horizontal: 56, vertical: 64),
      header: (context) => _buildPageHeader(isDe),
      footer: (context) => _buildPageFooter(context),
      build: (context) => _buildChapterContent(
        title: isDe ? 'Deine Zahlen' : 'Your Numbers',
        subtitle: isDe ? 'Numerologie' : 'Numerology',
        text: data.chapterNumerology,
      ),
    ));

    // 10-11. Synthese — Und so fügt sich alles zusammen
    pdf.addPage(pw.MultiPage(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.symmetric(horizontal: 56, vertical: 64),
      header: (context) => _buildPageHeader(isDe),
      footer: (context) => _buildPageFooter(context),
      build: (context) => _buildChapterContent(
        title: isDe ? 'Und so fügt sich alles zusammen' : 'How It All Comes Together',
        subtitle: isDe ? 'Die Synthese aus allen drei Systemen' : 'The synthesis from all three systems',
        text: data.synthesisText,
      ),
    ));

    // 12. Das Wesentliche (3 Erkenntnisse)
    pdf.addPage(_buildEssencePage(data, isDe));

    // 13. Fragen an dich (7 Reflexionsfragen)
    pdf.addPage(_buildQuestionsPage(data, isDe));

    // 14. Closing Page
    pdf.addPage(_buildClosingPage(data, isDe));

    return pdf.save();
  }

  /// Exportiert das PDF in den Downloads-Ordner.
  /// Gibt den Dateipfad zurück.
  Future<String> shareReport(SignatureReportData data) async {
    final bytes = await generateReport(data);
    final fileName = 'NUURAY_Signatur_${data.displayName.replaceAll(' ', '_')}.pdf';

    if (kIsWeb) {
      _downloadWeb(bytes, fileName);
      return fileName;
    } else {
      return await _saveToDownloads(bytes, fileName);
    }
  }

  // ============================================================
  // FONT LOADING
  // ============================================================

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
  // PAGE 1: COVER PAGE
  // ============================================================

  pw.Page _buildCoverPage(SignatureReportData data, bool isDe) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: pw.EdgeInsets.zero,
      build: (context) => pw.Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const pw.BoxDecoration(color: _warmWhite),
        child: pw.Stack(
          children: [
            // Geometrischer Akzent oben rechts
            pw.Positioned(
              top: 0,
              right: 0,
              child: pw.Container(
                width: 180,
                height: 180,
                decoration: const pw.BoxDecoration(color: _goldLight),
              ),
            ),

            // Gold-Linie diagonal (dezent)
            pw.Positioned(
              top: 0,
              right: 0,
              child: pw.Container(
                width: 180,
                height: 3,
                color: _accentGold,
              ),
            ),

            // Main Content
            pw.Padding(
              padding: const pw.EdgeInsets.all(64),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Brand
                  pw.Text(
                    'NUURAY GLOW',
                    style: pw.TextStyle(
                      fontSize: 10,
                      letterSpacing: 4,
                      color: _softGray,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 80),

                  // Report Type Badge
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: _accentGold,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      isDe ? 'DEINE SIGNATUR' : 'YOUR SIGNATURE',
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
                    isDe ? 'Deine Kosmische Signatur' : 'Your Cosmic Signature',
                    style: pw.TextStyle(
                      fontSize: 38,
                      fontWeight: pw.FontWeight.bold,
                      color: _deepCharcoal,
                      lineSpacing: 6,
                    ),
                  ),
                  pw.SizedBox(height: 16),

                  // Subtitle
                  pw.Text(
                    isDe
                        ? 'Ein persönlicher Report aus drei Weisheitssystemen'
                        : 'A personal report from three wisdom systems',
                    style: pw.TextStyle(
                      fontSize: 15,
                      color: _softGray,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),

                  // Archetyp-Titel (wenn vorhanden)
                  if (data.archetypeTitle != null && data.archetypeTitle!.isNotEmpty) ...[
                    pw.SizedBox(height: 32),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: _accentGold, width: 1),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Text(
                        data.archetypeTitle!,
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: _accentGold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],

                  pw.Spacer(),

                  // Gold-Akzent-Linie
                  pw.Container(width: 80, height: 2, color: _accentGold),
                  pw.SizedBox(height: 32),

                  // "Erstellt für"
                  pw.Text(
                    isDe ? 'Erstellt für' : 'Created for',
                    style: pw.TextStyle(fontSize: 11, color: _softGray, letterSpacing: 1),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    data.displayName,
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: _deepCharcoal,
                    ),
                  ),
                  pw.SizedBox(height: 48),

                  // Datum
                  pw.Text(
                    '${isDe ? "Generiert am" : "Generated on"} ${_formatDate(data.generatedAt, isDe)}',
                    style: pw.TextStyle(fontSize: 10, color: _softGray),
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
  // PAGE 2: EINLEITUNG — Drei Perspektiven, ein Bild
  // ============================================================

  pw.Page _buildIntroductionPage(bool isDe) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.symmetric(horizontal: 56, vertical: 64),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Überschrift
            pw.Text(
              isDe ? 'Drei Perspektiven, ein Bild' : 'Three Perspectives, One Picture',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: _deepCharcoal,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(width: 40, height: 2, color: _accentGold),
            pw.SizedBox(height: 24),

            // Einleitungstext
            pw.Text(
              isDe
                  ? 'Was du hier liest, wird sich stellenweise widersprechen. Genau das ist beabsichtigt.'
                  : 'What you read here will sometimes contradict itself. That is entirely intentional.',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                fontStyle: pw.FontStyle.italic,
                color: _deepCharcoal,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              isDe
                  ? 'Drei Systeme — entstanden in verschiedenen Kulturen, über Jahrtausende — betrachten dich aus drei verschiedenen Richtungen. Keine davon hat „recht". Keine davon sieht alles. Zusammen ergeben sie ein Bild, das reicher ist als jedes einzelne System es sein könnte.'
                  : 'Three systems — born from different cultures, over millennia — look at you from three different directions. None of them is "right." None of them sees everything. Together they create a picture richer than any single system could be.',
              style: pw.TextStyle(fontSize: 11, color: _deepCharcoal, lineSpacing: 5),
            ),
            pw.SizedBox(height: 24),

            // System 1: Westliche Astrologie
            _buildSystemIntroCard(
              isDe ? 'Westliche Astrologie' : 'Western Astrology',
              isDe
                  ? 'Liest aus der Stellung der Planeten zum Zeitpunkt deiner Geburt. Sie zeigt deine emotionalen Muster, wie du nach außen wirkst und wo deine inneren Spannungen liegen — dein psychologisches Profil, aber auch dein kreatives Potenzial und deine Beziehungsmuster.'
                  : 'Reads the positions of the planets at the moment of your birth. It reveals your emotional patterns, how you present yourself to the world, and where your inner tensions lie — your psychological profile, but also your creative potential and relationship patterns.',
            ),
            pw.SizedBox(height: 16),

            // System 2: Bazi
            _buildSystemIntroCard(
              isDe ? 'Bazi — Chinesische Astrologie' : 'Bazi — Chinese Astrology',
              isDe
                  ? 'Betrachtet das Zusammenspiel der fünf Elemente (Holz, Feuer, Erde, Metall, Wasser) in deinem Geburtsmoment. Sie zeigt, wie du Energie aufnimmst und abgibst, welche Ressourcen du natürlich mitbringst — aber auch deine Lebensrhythmen und Entscheidungsmuster.'
                  : 'Examines the interplay of the five elements (Wood, Fire, Earth, Metal, Water) at the moment of your birth. It shows how you absorb and release energy, what resources you naturally carry — but also your life rhythms and decision-making patterns.',
            ),
            pw.SizedBox(height: 16),

            // System 3: Numerologie
            _buildSystemIntroCard(
              isDe ? 'Numerologie' : 'Numerology',
              isDe
                  ? 'Übersetzt deinen Namen und dein Geburtsdatum in Zahlenschwingungen. Sie zeigt deinen Lebensweg und deine Lernaufgaben, aber auch deine verborgenen Talente, karmische Muster und die aktuelle Jahresenergie.'
                  : 'Translates your name and birth date into numerical vibrations. It reveals your life path and learning tasks, but also your hidden talents, karmic patterns, and current year energy.',
            ),
            pw.SizedBox(height: 24),

            // Abschluss
            pw.Text(
              isDe
                  ? 'Wenn die Astrologie sagt „du brauchst Stabilität" und die Numerologie sagt „du bist zum Wandel geboren" — dann ist genau diese Spannung dein Material. Nicht das eine oder das andere. Beides.'
                  : 'When astrology says "you need stability" and numerology says "you were born for change" — then that exact tension is your material. Not one or the other. Both.',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _deepCharcoal,
                lineSpacing: 5,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Einzelne System-Einführungskarte für die Intro-Seite
  pw.Widget _buildSystemIntroCard(String title, String description) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFAF8F5),
        border: pw.Border.all(color: _borderColor, width: 0.5),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: _accentGold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            description,
            style: pw.TextStyle(fontSize: 10, color: _deepCharcoal, lineSpacing: 4),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 3: PARAMETER-ÜBERSICHT (Steckbrief-Cards)
  // ============================================================

  pw.Page _buildParameterOverviewPage(SignatureReportData data, bool isDe) {
    final chart = data.birthChart;
    final zodiacNames = isDe ? _zodiacAbbrDE : _zodiacAbbrEN;
    final baziElements = isDe ? _baziElementsDE : _baziElementsEN;
    final baziBranches = isDe ? _baziBranchDE : _baziBranchEN;
    final currentYear = DateTime.now().year;

    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.symmetric(horizontal: 56, vertical: 56),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Überschrift
            pw.Text(
              isDe ? 'Deine Kosmische Signatur' : 'Your Cosmic Signature',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: _deepCharcoal,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              isDe ? 'Alle Parameter auf einen Blick' : 'All Parameters at a Glance',
              style: pw.TextStyle(fontSize: 10, color: _softGray),
            ),
            pw.SizedBox(height: 6),
            pw.Container(width: 40, height: 2, color: _accentGold),
            pw.SizedBox(height: 16),

            // === CARD 1: Westliche Astrologie ===
            _buildParamCard(
              title: isDe ? 'Westliche Astrologie' : 'Western Astrology',
              icon: '~',
              rows: [
                _ParamRow(
                  isDe ? 'Sonnenzeichen' : 'Sun Sign',
                  _formatZodiacWithDegree(chart.sunSign, chart.sunDegree, zodiacNames),
                ),
                if (chart.moonSign != null)
                  _ParamRow(
                    isDe ? 'Mondzeichen' : 'Moon Sign',
                    _formatZodiacWithDegree(chart.moonSign!, chart.moonDegree, zodiacNames),
                  ),
                if (chart.ascendantSign != null)
                  _ParamRow(
                    isDe ? 'Aszendent' : 'Ascendant',
                    _formatZodiacWithDegree(chart.ascendantSign!, chart.ascendantDegree, zodiacNames),
                  ),
              ],
            ),
            pw.SizedBox(height: 12),

            // === CARD 2: Bazi ===
            _buildParamCard(
              title: isDe ? 'Bazi — Die Vier Säulen' : 'Bazi — The Four Pillars',
              icon: '~',
              rows: [
                if (chart.baziDayStem != null)
                  _ParamRow(
                    isDe ? 'Tagesmeister' : 'Day Master',
                    _formatBaziPillar(chart.baziDayStem, chart.baziDayBranch, baziElements, baziBranches),
                  ),
                if (chart.baziYearStem != null)
                  _ParamRow(
                    isDe ? 'Jahressäule' : 'Year Pillar',
                    _formatBaziPillar(chart.baziYearStem, chart.baziYearBranch, baziElements, baziBranches),
                  ),
                if (chart.baziMonthStem != null)
                  _ParamRow(
                    isDe ? 'Monatssäule' : 'Month Pillar',
                    _formatBaziPillar(chart.baziMonthStem, chart.baziMonthBranch, baziElements, baziBranches),
                  ),
                if (chart.baziHourStem != null)
                  _ParamRow(
                    isDe ? 'Stundensäule' : 'Hour Pillar',
                    _formatBaziPillar(chart.baziHourStem, chart.baziHourBranch, baziElements, baziBranches),
                  ),
                if (chart.baziElement != null)
                  _ParamRow(
                    isDe ? 'Dominantes Element' : 'Dominant Element',
                    baziElements[chart.baziElement] ?? chart.baziElement!,
                  ),
              ],
            ),
            pw.SizedBox(height: 12),

            // === CARD 3: Numerologie ===
            _buildParamCard(
              title: isDe ? 'Numerologie' : 'Numerology',
              icon: '#',
              rows: [
                // Kern-Zahlen
                if (chart.lifePathNumber != null)
                  _ParamRow(isDe ? 'Lebenszahl' : 'Life Path', '${chart.lifePathNumber}'),
                if (chart.birthdayNumber != null)
                  _ParamRow(isDe ? 'Geburtstagszahl' : 'Birthday Number', '${chart.birthdayNumber}'),
                if (chart.attitudeNumber != null)
                  _ParamRow(isDe ? 'Attitüde' : 'Attitude', '${chart.attitudeNumber}'),
                if (chart.personalYear != null)
                  _ParamRow(
                    isDe ? 'Persönliches Jahr $currentYear' : 'Personal Year $currentYear',
                    '${chart.personalYear}',
                  ),
                if (chart.maturityNumber != null)
                  _ParamRow(isDe ? 'Reifezahl' : 'Maturity', '${chart.maturityNumber}'),
                // Name Energien
                if (chart.birthExpressionNumber != null)
                  _ParamRow(
                    isDe ? 'Geburtsname Expression' : 'Birth Name Expression',
                    '${chart.birthExpressionNumber}',
                  ),
                if (chart.birthSoulUrgeNumber != null)
                  _ParamRow(
                    isDe ? 'Geburtsname Soul Urge' : 'Birth Name Soul Urge',
                    '${chart.birthSoulUrgeNumber}',
                  ),
                if (chart.currentExpressionNumber != null)
                  _ParamRow(
                    isDe ? 'Aktueller Name Expression' : 'Current Name Expression',
                    '${chart.currentExpressionNumber}',
                  ),
                if (chart.currentSoulUrgeNumber != null)
                  _ParamRow(
                    isDe ? 'Aktueller Name Soul Urge' : 'Current Name Soul Urge',
                    '${chart.currentSoulUrgeNumber}',
                  ),
                // Erweitert
                if (chart.karmicDebtLifePath != null)
                  _ParamRow(isDe ? 'Karmische Schuld' : 'Karmic Debt', '${chart.karmicDebtLifePath}'),
                if (chart.challengeNumbers != null && chart.challengeNumbers!.isNotEmpty)
                  _ParamRow(
                    isDe ? 'Herausforderungen' : 'Challenges',
                    chart.challengeNumbers!.join(', '),
                  ),
                if (chart.karmicLessons != null && chart.karmicLessons!.isNotEmpty)
                  _ParamRow(
                    isDe ? 'Karmische Lektionen' : 'Karmic Lessons',
                    chart.karmicLessons!.join(', '),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Formatiert einen Zodiac-Eintrag mit Grad
  String _formatZodiacWithDegree(String sign, double? degree, Map<String, String> zodiacNames) {
    final name = zodiacNames[sign.toLowerCase()] ?? sign;
    if (degree != null) {
      return '$name (${degree.toStringAsFixed(1)}°)';
    }
    return name;
  }

  /// Formatiert eine Bazi-Säule: "Yang-Wasser Hund" (DE) / "Yang Water Dog" (EN)
  String _formatBaziPillar(
    String? stem, String? branch,
    Map<String, String> elements, Map<String, String> branches,
  ) {
    final translatedParts = <String>[];

    if (stem != null) {
      final el = elements[stem];
      translatedParts.add(el ?? stem);
    }
    if (branch != null) {
      final animal = branches[branch];
      translatedParts.add(animal ?? branch);
    }

    final translated = translatedParts.join(' ');
    return translated.isNotEmpty ? translated : '-';
  }

  /// Einzelne Parameter-Card für die Übersichtsseite
  pw.Widget _buildParamCard({
    required String title,
    required String icon,
    required List<_ParamRow> rows,
  }) {
    if (rows.isEmpty) return pw.SizedBox();

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFAF8F5),
        border: pw.Border.all(color: _borderColor, width: 0.5),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Card Header
          pw.Row(
            children: [
              pw.Container(
                width: 22,
                height: 22,
                decoration: pw.BoxDecoration(
                  color: _accentGold,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Center(
                  child: pw.Text(
                    icon,
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: _deepCharcoal,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(color: _borderColor, thickness: 0.5),
          pw.SizedBox(height: 6),
          // Rows
          ...rows.map((row) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 160,
                      child: pw.Text(
                        row.label,
                        style: pw.TextStyle(fontSize: 9, color: _softGray),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        row.value,
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: _deepCharcoal,
                        ),
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
  // PAGE 4: KOSMISCHE IDENTITÄT
  // ============================================================

  pw.Page _buildIdentityPage(SignatureReportData data, bool isDe) {
    final chart = data.birthChart;
    final zodiacNames = isDe ? _zodiacAbbrDE : _zodiacAbbrEN;
    final baziElements = isDe ? _baziElementsDE : _baziElementsEN;

    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Section Label
          pw.Text(
            isDe ? 'DEINE KOSMISCHE IDENTITÄT' : 'YOUR COSMIC IDENTITY',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: _accentGold,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 32),

          // Western Astrology Card
          _buildIdentityCard(
            title: isDe ? 'Psyche' : 'Psyche',
            subtitle: isDe ? 'Westliche Astrologie' : 'Western Astrology',
            items: [
              _IdentityItem(
                isDe ? 'Sonne' : 'Sun',
                '${zodiacNames[chart.sunSign] ?? chart.sunSign}${chart.sunDegree != null ? ' (${chart.sunDegree!.toStringAsFixed(0)}°)' : ''}',
              ),
              if (chart.moonSign != null)
                _IdentityItem(
                  isDe ? 'Mond' : 'Moon',
                  '${zodiacNames[chart.moonSign] ?? chart.moonSign!}${chart.moonDegree != null ? ' (${chart.moonDegree!.toStringAsFixed(0)}°)' : ''}',
                ),
              if (chart.ascendantSign != null)
                _IdentityItem(
                  isDe ? 'Aszendent' : 'Ascendant',
                  '${zodiacNames[chart.ascendantSign] ?? chart.ascendantSign!}${chart.ascendantDegree != null ? ' (${chart.ascendantDegree!.toStringAsFixed(0)}°)' : ''}',
                ),
            ],
          ),
          pw.SizedBox(height: 24),

          // Bazi Card
          _buildIdentityCard(
            title: isDe ? 'Energie' : 'Energy',
            subtitle: 'Bazi',
            items: [
              if (chart.baziDayStem != null)
                _IdentityItem(
                  'Day Master',
                  baziElements[chart.baziDayStem] ?? chart.baziDayStem!,
                ),
              if (chart.baziElement != null)
                _IdentityItem(
                  isDe ? 'Dominantes Element' : 'Dominant Element',
                  baziElements[chart.baziElement] ?? chart.baziElement!,
                ),
              if (chart.baziYearBranch != null)
                _IdentityItem(
                  isDe ? 'Jahres-Tier' : 'Year Animal',
                  chart.baziYearBranch!,
                ),
            ],
          ),
          pw.SizedBox(height: 24),

          // Numerologie Card
          _buildIdentityCard(
            title: isDe ? 'Seelenweg' : 'Soul Path',
            subtitle: isDe ? 'Numerologie' : 'Numerology',
            items: [
              if (chart.lifePathNumber != null)
                _IdentityItem(
                  isDe ? 'Lebenszahl' : 'Life Path',
                  '${chart.lifePathNumber}',
                ),
              if (chart.personalYear != null)
                _IdentityItem(
                  isDe ? 'Persönliches Jahr' : 'Personal Year',
                  '${chart.personalYear}',
                ),
              if (chart.maturityNumber != null)
                _IdentityItem(
                  isDe ? 'Reife-Zahl' : 'Maturity',
                  '${chart.maturityNumber}',
                ),
              if (chart.karmicDebtLifePath != null)
                _IdentityItem(
                  isDe ? 'Karmische Schuld' : 'Karmic Debt',
                  '${chart.karmicDebtLifePath}',
                ),
            ],
          ),

          pw.Spacer(),

          // Geburtsdatum
          if (data.birthDate != null)
            pw.Center(
              child: pw.Text(
                '${isDe ? "Geboren am" : "Born on"} ${_formatDate(data.birthDate!, isDe)}',
                style: pw.TextStyle(fontSize: 10, color: _softGray, fontStyle: pw.FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  /// Identity Card Widget
  pw.Widget _buildIdentityCard({
    required String title,
    required String subtitle,
    required List<_IdentityItem> items,
  }) {
    if (items.isEmpty) return pw.SizedBox();

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderColor, width: 0.5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(width: 3, height: 20, color: _accentGold),
              pw.SizedBox(width: 12),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: _deepCharcoal,
                    ),
                  ),
                  pw.Text(
                    subtitle,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: _softGray,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          ...items.map((item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              children: [
                pw.SizedBox(
                  width: 140,
                  child: pw.Text(
                    item.label,
                    style: pw.TextStyle(fontSize: 11, color: _softGray),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    item.value,
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: _deepCharcoal,
                    ),
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
  // CHAPTER PAGES (MultiPage Body Content)
  // ============================================================

  /// Baut den Inhalt eines Kapitels (Titel + Subtitle + Fließtext)
  List<pw.Widget> _buildChapterContent({
    required String title,
    required String subtitle,
    required String text,
  }) {
    final widgets = <pw.Widget>[];

    // Kapitel-Header
    widgets.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(width: 40, height: 3, color: _accentGold),
            pw.SizedBox(height: 12),
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: _deepCharcoal,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              subtitle,
              style: pw.TextStyle(
                fontSize: 12,
                color: _softGray,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );

    // Absätze
    final paragraphs = text
        .split('\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    for (final paragraph in paragraphs) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Text(
            paragraph,
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

    return widgets;
  }

  // ============================================================
  // PAGE: DAS WESENTLICHE (3 Erkenntnisse)
  // ============================================================

  pw.Page _buildEssencePage(SignatureReportData data, bool isDe) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Section Label
          pw.Text(
            isDe ? 'DAS WESENTLICHE' : 'THE ESSENCE',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: _accentGold,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            isDe
                ? 'Die 3 Kernerkenntnisse aus deiner Signatur'
                : 'The 3 key insights from your signature',
            style: pw.TextStyle(
              fontSize: 12,
              color: _softGray,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 32),

          // Gold-Linie
          pw.Container(width: 40, height: 3, color: _accentGold),
          pw.SizedBox(height: 24),

          // 3 Erkenntnisse
          ...data.keyInsights.asMap().entries.map((entry) {
            final insight = entry.value;
            final isLast = entry.key == data.keyInsights.length - 1;

            return pw.Padding(
              padding: pw.EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Label
                  pw.Text(
                    (insight['label'] ?? '').toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: _accentGold,
                      letterSpacing: 1,
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // Text
                  pw.Text(
                    insight['text'] ?? '',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: _deepCharcoal,
                      lineSpacing: 6,
                    ),
                  ),

                  // Divider
                  if (!isLast) ...[
                    pw.SizedBox(height: 20),
                    pw.Container(
                      width: double.infinity,
                      height: 0.5,
                      color: _borderColor,
                    ),
                  ],
                ],
              ),
            );
          }),

          pw.Spacer(),

          // Footer
          pw.Row(
            children: [
              pw.Container(width: 24, height: 1, color: _accentGold),
              pw.SizedBox(width: 8),
              pw.Text(
                isDe ? 'Aus deiner NUURAY Signatur' : 'From your NUURAY Signature',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: _softGray,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE: FRAGEN AN DICH (7 Reflexionsfragen)
  // ============================================================

  pw.Page _buildQuestionsPage(SignatureReportData data, bool isDe) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Section Label
          pw.Text(
            isDe ? 'FRAGEN AN DICH' : 'QUESTIONS FOR YOU',
            style: pw.TextStyle(
              fontSize: 10,
              letterSpacing: 3,
              color: _accentGold,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            isDe
                ? 'Diese Fragen hat deine Signatur für dich.\nNicht um sie zu beantworten — um sie zu spüren.'
                : 'Your signature has these questions for you.\nNot to answer — to feel.',
            style: pw.TextStyle(
              fontSize: 12,
              color: _softGray,
              fontStyle: pw.FontStyle.italic,
              lineSpacing: 4,
            ),
          ),
          pw.SizedBox(height: 32),

          // Gold-Linie
          pw.Container(width: 40, height: 3, color: _accentGold),
          pw.SizedBox(height: 24),

          // 7 Fragen
          ...data.reflectionQuestions.asMap().entries.map((entry) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Nummer in Gold-Kreis
                  pw.Container(
                    width: 24,
                    height: 24,
                    decoration: pw.BoxDecoration(
                      color: _accentGold,
                      shape: pw.BoxShape.circle,
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        '${entry.key + 1}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),

                  // Frage
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 3),
                      child: pw.Text(
                        entry.value,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: _deepCharcoal,
                          fontStyle: pw.FontStyle.italic,
                          lineSpacing: 5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          pw.Spacer(),
        ],
      ),
    );
  }

  // ============================================================
  // CLOSING PAGE
  // ============================================================

  pw.Page _buildClosingPage(SignatureReportData data, bool isDe) {
    return pw.Page(
      pageFormat: _a4Portrait,
      margin: const pw.EdgeInsets.all(56),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Spacer(),

          // NUURAY Circle
          pw.Container(
            width: 48,
            height: 48,
            decoration: pw.BoxDecoration(
              color: _accentGold,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                'N',
                style: pw.TextStyle(
                  fontSize: 20,
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 24),

          pw.Text(
            'NUURAY GLOW',
            style: pw.TextStyle(
              fontSize: 12,
              color: _softGray,
              letterSpacing: 3,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            isDe
                ? 'Deine kosmische Signatur aus drei Weisheitssystemen'
                : 'Your cosmic signature from three wisdom systems',
            style: pw.TextStyle(
              fontSize: 11,
              color: _softGray,
              fontStyle: pw.FontStyle.italic,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 32),

          pw.Container(width: 40, height: 1, color: _borderColor),
          pw.SizedBox(height: 32),

          pw.Text(
            isDe
                ? 'Generiert am ${_formatDate(data.generatedAt, isDe)}'
                : 'Generated on ${_formatDate(data.generatedAt, isDe)}',
            style: pw.TextStyle(fontSize: 10, color: _softGray),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            isDe
                ? 'Westliche Astrologie · Bazi · Numerologie'
                : 'Western Astrology · Bazi · Numerology',
            style: pw.TextStyle(fontSize: 9, color: _softGray, letterSpacing: 1),
          ),

          pw.Spacer(),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE HEADER & FOOTER (für MultiPage)
  // ============================================================

  pw.Widget _buildPageHeader(bool isDe) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 24),
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _borderColor, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            isDe ? 'NUURAY · Deine Signatur' : 'NUURAY · Your Signature',
            style: pw.TextStyle(fontSize: 9, color: _softGray, letterSpacing: 1),
          ),
          pw.Text(
            'NUURAY GLOW',
            style: pw.TextStyle(fontSize: 9, color: _softGray),
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
            style: pw.TextStyle(fontSize: 10, color: _softGray),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _formatDate(DateTime date, bool isDe) {
    if (isDe) {
      const months = [
        'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
        'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
      ];
      return '${date.day}. ${months[date.month - 1]} ${date.year}';
    } else {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  /// Web-Download via Blob
  void _downloadWeb(Uint8List bytes, String fileName) {
    // Web-Import nur wenn kIsWeb — wird via conditional import gelöst
    // Für jetzt: Fallback auf share_plus (funktioniert auch auf Web)
    debugPrint('Web download not yet implemented — use native share');
  }

  /// Speichert PDF in den Downloads-Ordner (Desktop) oder teilt via Share-Sheet (Mobile)
  Future<String> _saveToDownloads(Uint8List bytes, String fileName) async {
    // 1. Versuch: Downloads-Ordner (macOS/Linux/Windows)
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(bytes);
        return file.path;
      }
    } catch (e) {
      debugPrint('Downloads-Ordner nicht verfügbar: $e');
    }

    // 2. Fallback: Documents-Ordner (funktioniert immer)
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      if (!await docsDir.exists()) {
        await docsDir.create(recursive: true);
      }
      final file = File('${docsDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('Documents-Ordner nicht verfügbar: $e');
    }

    // 3. Letzter Fallback: Temp + Share-Sheet
    final tempDir = await getTemporaryDirectory();
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'NUURAY Signatur-Report',
    );
    return file.path;
  }
}

/// Helper-Klasse für Identity Page Items
class _IdentityItem {
  final String label;
  final String value;

  const _IdentityItem(this.label, this.value);
}

/// Helper-Klasse für Parameter-Übersicht Rows
class _ParamRow {
  final String label;
  final String value;

  const _ParamRow(this.label, this.value);
}
