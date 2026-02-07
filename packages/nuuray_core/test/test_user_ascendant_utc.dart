import 'package:nuuray_core/src/services/timezone_converter_simple.dart';
import 'package:nuuray_core/src/services/zodiac_calculator.dart';
import 'dart:math' as math;

/// Test: Aszendent mit UTC-Konvertierung
/// User: 30.11.1983 22:32 in Friedrichshafen
/// Erwartet: Löwe ♌

void main() {
  print('🔮 Aszendent-Test mit UTC-Konvertierung\n');
  print('=' * 80);

  // User-Geburtsdaten
  final localDateTime = DateTime(1983, 11, 30, 22, 32);
  final latitude = 47.6546; // Friedrichshafen
  final longitude = 9.4797;
  final timezoneId = 'Europe/Berlin';

  print('📋 Geburtsdaten:');
  print('   Datum: 30.11.1983');
  print('   Zeit: 22:32 (lokal in Friedrichshafen)');
  print('   Ort: Friedrichshafen ($latitude°N, $longitude°E)');
  print('   Timezone: $timezoneId');
  print('   Erwartet: Aszendent Löwe ♌');
  print('');

  // UTC-Konvertierung
  final utcDateTime = TimezoneConverterSimple.toUTC(
    localDateTime: localDateTime,
    timezoneId: timezoneId,
  );
  print('');

  // Aszendent-Berechnung MIT UTC
  print('🔮 Aszendent-Berechnung (MIT UTC-Konvertierung):');
  final ascendantSign = ZodiacCalculator.calculateAscendant(
    birthDateTime: utcDateTime,
    latitude: latitude,
    longitude: longitude,
  );
  final ascendantDegree = _getAscendantDegree(utcDateTime, latitude, longitude);
  final zodiacName = ascendantSign?.nameDe ?? 'null';

  print('   Aszendent: ${ascendantDegree.toStringAsFixed(2)}° → $zodiacName');
  print('');

  // Vergleich OHNE UTC
  print('🔮 Aszendent-Berechnung (OHNE UTC-Konvertierung):');
  final ascendantSignOld = ZodiacCalculator.calculateAscendant(
    birthDateTime: localDateTime,
    latitude: latitude,
    longitude: longitude,
  );
  final ascendantDegreeOld = _getAscendantDegree(localDateTime, latitude, longitude);
  final zodiacNameOld = ascendantSignOld?.nameDe ?? 'null';

  print('   Aszendent: ${ascendantDegreeOld.toStringAsFixed(2)}° → $zodiacNameOld');
  print('');

  print('=' * 80);
  final isCorrect = zodiacName == 'Löwe';
  print('Ergebnis: ${isCorrect ? "✅ KORREKT!" : "❌ NOCH FALSCH"}');
  print('');
  print('  MIT UTC:    $zodiacName ${ascendantDegree.toStringAsFixed(2)}°');
  print('  OHNE UTC:   $zodiacNameOld ${ascendantDegreeOld.toStringAsFixed(2)}°');
  print('  ERWARTET:   Löwe');
  print('  Differenz:  ${(ascendantDegree - ascendantDegreeOld).abs().toStringAsFixed(2)}°');
  print('=' * 80);

  if (!isCorrect) {
    print('');
    print('🔍 Debugging-Info:');
    print('  Löwe:     120°-150°');
    print('  Jungfrau: 150°-180°');
    print('  Waage:    180°-210°');
    print('');
    print('  30.11.1983: Normalzeit (MEZ = UTC+1) ✅');
    print('  22:32 MEZ = 21:32 UTC ✅');
  }
}

double _getAscendantDegree(DateTime dateTime, double lat, double lng) {
  final jd = _calculateJulianDay(dateTime);
  final T = (jd - 2451545.0) / 36525.0;

  var GMST = 280.46061837 +
      360.98564736629 * (jd - 2451545.0) +
      0.000387933 * T * T -
      T * T * T / 38710000.0;
  GMST = GMST % 360.0;
  if (GMST < 0) GMST += 360.0;

  var RAMC = GMST + lng;
  RAMC = RAMC % 360.0;
  if (RAMC < 0) RAMC += 360.0;

  final epsilon = 23.439291 - 0.0130042 * T;

  final RAMCRad = RAMC * math.pi / 180.0;
  final latRad = lat * math.pi / 180.0;
  final epsilonRad = epsilon * math.pi / 180.0;

  final y = math.cos(RAMCRad);
  final x = -(math.sin(epsilonRad) * math.tan(latRad) +
      math.cos(epsilonRad) * math.sin(RAMCRad));

  var ascendant = math.atan2(y, x) * 180.0 / math.pi;
  ascendant = ascendant % 360.0;
  if (ascendant < 0) ascendant += 360.0;

  return ascendant;
}

double _calculateJulianDay(DateTime dateTime) {
  int year = dateTime.year;
  int month = dateTime.month;
  final day = dateTime.day;
  final hour = dateTime.hour;
  final minute = dateTime.minute;
  final second = dateTime.second;

  if (month <= 2) {
    year -= 1;
    month += 12;
  }

  final A = (year / 100).floor();
  final B = 2 - A + (A / 4).floor();

  final JD = (365.25 * (year + 4716)).floor() +
      (30.6001 * (month + 1)).floor() +
      day +
      (hour + minute / 60.0 + second / 3600.0) / 24.0 +
      B -
      1524.5;

  return JD;
}
