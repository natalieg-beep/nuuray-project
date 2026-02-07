import 'dart:math' as math;
import '../models/zodiac_sign.dart';

/// Berechnet Sonnenzeichen, Mondzeichen und Aszendent basierend auf Geburtsdaten.
///
/// Verwendet astronomische Algorithmen aus Meeus "Astronomical Algorithms"
/// und VSOP87-Theorie für präzise Planetenpositionen.
class ZodiacCalculator {
  /// Berechnet das Sonnenzeichen aus dem Geburtsdatum
  ///
  /// Nutzt ekliptische Länge der Sonne zur präzisen Berechnung.
  static ZodiacSign calculateSunSign(DateTime birthDate) {
    final julianDay = _calculateJulianDay(birthDate);
    final sunLongitude = _calculateSunLongitude(julianDay);
    return ZodiacSign.fromKey(_zodiacKeyFromLongitude(sunLongitude));
  }

  /// Berechnet das Mondzeichen aus Geburtsdatum und -zeit
  ///
  /// Erfordert genaue Geburtszeit, da der Mond alle ~2.5 Tage das Zeichen wechselt.
  static ZodiacSign calculateMoonSign(DateTime birthDateTime) {
    final julianDay = _calculateJulianDay(birthDateTime);
    final moonLongitude = _calculateMoonLongitude(julianDay);
    return ZodiacSign.fromKey(_zodiacKeyFromLongitude(moonLongitude));
  }

  /// Berechnet den Aszendenten aus Geburtsdatum, -zeit und -ort
  ///
  /// Erfordert:
  /// - Genaue Geburtszeit (Stunde/Minute)
  /// - Geburtsort (Breitengrad, Längengrad)
  ///
  /// Der Aszendent wechselt etwa alle 2 Stunden das Zeichen.
  static ZodiacSign? calculateAscendant({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
  }) {
    final julianDay = _calculateJulianDay(birthDateTime);
    final ascendantLongitude = _calculateAscendant(
      julianDay: julianDay,
      latitude: latitude,
      longitude: longitude,
    );

    if (ascendantLongitude == null) return null;

    return ZodiacSign.fromKey(_zodiacKeyFromLongitude(ascendantLongitude));
  }

  /// Berechnet die ekliptische Länge der Sonne (0-360°)
  ///
  /// Basiert auf VSOP87-Theorie (vereinfacht für App-Zwecke)
  static double _calculateSunLongitude(double julianDay) {
    // Julianische Jahrhunderte seit J2000.0
    final T = (julianDay - 2451545.0) / 36525.0;

    // Geometrische mittlere Länge der Sonne
    var L0 = 280.46646 + 36000.76983 * T + 0.0003032 * T * T;
    L0 = L0 % 360.0;
    if (L0 < 0) L0 += 360.0;

    // Mittlere Anomalie der Sonne
    var M = 357.52911 + 35999.05029 * T - 0.0001537 * T * T;
    M = M % 360.0;
    if (M < 0) M += 360.0;

    // Gleichung des Zentrums (Kepler-Korrektur)
    final MRad = M * math.pi / 180.0;
    final C = (1.914602 - 0.004817 * T - 0.000014 * T * T) * math.sin(MRad) +
        (0.019993 - 0.000101 * T) * math.sin(2 * MRad) +
        0.000289 * math.sin(3 * MRad);

    // Wahre Länge der Sonne
    var sunLongitude = L0 + C;
    sunLongitude = sunLongitude % 360.0;
    if (sunLongitude < 0) sunLongitude += 360.0;

    return sunLongitude;
  }

  /// Berechnet die ekliptische Länge des Mondes (0-360°)
  ///
  /// Basiert auf Chapront-Touzé ELP2000-82 Theorie (vereinfacht)
  /// Genauigkeit: ±0.5° (ausreichend für Zeichen-Bestimmung)
  static double _calculateMoonLongitude(double julianDay) {
    // Julianische Jahrhunderte seit J2000.0
    final T = (julianDay - 2451545.0) / 36525.0;

    // Mittlere Länge des Mondes
    var Lprime = 218.3164477 +
        481267.88123421 * T -
        0.0015786 * T * T +
        T * T * T / 538841.0 -
        T * T * T * T / 65194000.0;

    // Mittlere Elongation
    var D = 297.8501921 +
        445267.1114034 * T -
        0.0018819 * T * T +
        T * T * T / 545868.0 -
        T * T * T * T / 113065000.0;

    // Mittlere Anomalie der Sonne
    var M = 357.5291092 + 35999.0502909 * T - 0.0001536 * T * T + T * T * T / 24490000.0;

    // Mittlere Anomalie des Mondes
    var Mprime = 134.9633964 +
        477198.8675055 * T +
        0.0087414 * T * T +
        T * T * T / 69699.0 -
        T * T * T * T / 14712000.0;

    // Argument der Breite
    var F = 93.2720950 +
        483202.0175233 * T -
        0.0036539 * T * T -
        T * T * T / 3526000.0 +
        T * T * T * T / 863310000.0;

    // In Radianten konvertieren
    final LprimeRad = Lprime * math.pi / 180.0;
    final DRad = D * math.pi / 180.0;
    final MRad = M * math.pi / 180.0;
    final MprimeRad = Mprime * math.pi / 180.0;
    final FRad = F * math.pi / 180.0;

    // Hauptkorrekturen (Länge)
    final corrections = 6.289 * math.sin(MprimeRad) + // Evektion
        1.274 * math.sin(2 * DRad - MprimeRad) + // Variation
        0.658 * math.sin(2 * DRad) + // Jahresgleichung
        -0.186 * math.sin(MRad) + // Evektionskorrektur
        -0.114 * math.sin(2 * FRad); // Variation

    var moonLongitude = Lprime + corrections;
    moonLongitude = moonLongitude % 360.0;
    if (moonLongitude < 0) moonLongitude += 360.0;

    return moonLongitude;
  }

  /// Berechnet den Aszendenten (0-360°)
  ///
  /// Der Aszendent ist das Tierkreiszeichen am östlichen Horizont
  /// zum Zeitpunkt der Geburt.
  static double? _calculateAscendant({
    required double julianDay,
    required double latitude,
    required double longitude,
  }) {
    // Julianische Jahrhunderte seit J2000.0
    final T = (julianDay - 2451545.0) / 36525.0;

    // Greenwich Mean Sidereal Time (GMST)
    var GMST = 280.46061837 +
        360.98564736629 * (julianDay - 2451545.0) +
        0.000387933 * T * T -
        T * T * T / 38710000.0;
    GMST = GMST % 360.0;
    if (GMST < 0) GMST += 360.0;

    // Local Sidereal Time = Right Ascension of MC (RAMC)
    var RAMC = GMST + longitude;
    RAMC = RAMC % 360.0;
    if (RAMC < 0) RAMC += 360.0;

    // Schiefe der Ekliptik
    final epsilon = 23.439291 - 0.0130042 * T;

    // In Radianten konvertieren
    final RAMCRad = RAMC * math.pi / 180.0;
    final latRad = latitude * math.pi / 180.0;
    final epsilonRad = epsilon * math.pi / 180.0;

    // Aszendent-Formel mit atan2 für korrekten Quadranten
    // Korrekte Formel: atan2(sin, cos) für ekliptische Länge
    final y = math.cos(RAMCRad);
    final x = -(math.sin(epsilonRad) * math.tan(latRad) +
        math.cos(epsilonRad) * math.sin(RAMCRad));

    var ascendant = math.atan2(y, x) * 180.0 / math.pi;

    // Normalisieren auf 0-360°
    ascendant = ascendant % 360.0;
    if (ascendant < 0) ascendant += 360.0;

    return ascendant;
  }

  /// Berechnet die Julian Day Number (JD)
  ///
  /// Standard-Zeitmaß in der Astronomie. Fortlaufende Tageszählung
  /// seit 1. Januar 4713 v.Chr. (Julian Calendar).
  ///
  /// Basiert auf Meeus-Formel für gregorianischen Kalender.
  ///
  /// WICHTIG: Verwendet die übergebene Zeit OHNE UTC-Konvertierung.
  /// Für Aszendent-Berechnungen ist die lokale Zeit entscheidend,
  /// da die Longitude-Korrektur über die Sidereal Time erfolgt.
  static double _calculateJulianDay(DateTime dateTime) {
    // KEINE UTC-Konvertierung! Lokale Zeit ist wichtig für Aszendent
    int year = dateTime.year;
    int month = dateTime.month;
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final second = dateTime.second;

    // Monat-Jahr-Anpassung für Meeus-Formel
    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    // Gregorianische Kalenderkorrektur
    final A = (year / 100).floor();
    final B = 2 - A + (A / 4).floor();

    // Julian Day berechnen
    final JD = (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        (hour + minute / 60.0 + second / 3600.0) / 24.0 +
        B -
        1524.5;

    return JD;
  }

  /// Konvertiert ekliptische Länge (0-360°) in Sternzeichen-Key
  static String _zodiacKeyFromLongitude(double longitude) {
    final normalizedLong = longitude % 360;
    final index = (normalizedLong / 30).floor();

    const zodiacKeys = [
      'aries',      // 0°-30°
      'taurus',     // 30°-60°
      'gemini',     // 60°-90°
      'cancer',     // 90°-120°
      'leo',        // 120°-150°
      'virgo',      // 150°-180°
      'libra',      // 180°-210°
      'scorpio',    // 210°-240°
      'sagittarius', // 240°-270°
      'capricorn',  // 270°-300°
      'aquarius',   // 300°-330°
      'pisces',     // 330°-360°
    ];

    return zodiacKeys[index % 12];
  }

  /// Gibt die exakte Position in Grad innerhalb des Zeichens zurück (0-30°)
  static double getDegreeInSign(double longitude) {
    return longitude % 30;
  }
}
