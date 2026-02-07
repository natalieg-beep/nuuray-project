import 'package:nuuray_core/src/services/timezone_converter.dart';
import 'package:nuuray_core/src/services/zodiac_calculator.dart';
import 'dart:math' as math;

/// Test: UTC-Konvertierung für Aszendent-Berechnung
///
/// User-Daten: 30.11.1983 22:32 in Friedrichshafen
/// Erwartet: Aszendent Löwe ♌

void main() {
  print('🔮 Timezone-Konvertierung Test\n');
  print('=' * 80);

  // Timezone-Datenbank initialisieren
  TimezoneConverter.initialize();
  print('✅ Timezone-Datenbank geladen\n');

  // User-Geburtsdaten
  final localDateTime = DateTime(1983, 11, 30, 22, 32);
  final latitude = 47.6546; // Friedrichshafen
  final longitude = 9.4797;
  final timezoneId = 'Europe/Berlin';

  print('📋 Geburtsdaten:');
  print('   Datum: 30.11.1983');
  print('   Zeit: 22:32 (lokal in Friedrichshafen)');
  print('   Ort: Friedrichshafen');
  print('   Lat: ${latitude.toStringAsFixed(4)}°N');
  print('   Lng: ${longitude.toStringAsFixed(4)}°E');
  print('   Timezone: $timezoneId');
  print('   Erwartet: Aszendent Löwe ♌');
  print('');

  // 1. UTC-Konvertierung
  print('Schritt 1: UTC-Konvertierung');
  final utcDateTime = TimezoneConverter.toUTC(
    localDateTime: localDateTime,
    timezoneId: timezoneId,
  );
  print('   Lokal: ${localDateTime.toIso8601String()}');
  print('   UTC:   ${utcDateTime.toIso8601String()}');
  print('   Offset: ${localDateTime.difference(utcDateTime).inHours}h');
  print('');

  // 2. Aszendent-Berechnung mit UTC-Zeit
  print('Schritt 2: Aszendent-Berechnung (mit UTC)');
  final ascendantSign = ZodiacCalculator.calculateAscendant(
    birthDateTime: utcDateTime,  // ← UTC-Zeit!
    latitude: latitude,
    longitude: longitude,
  );

  final ascendantDegree = _getAscendantDegree(utcDateTime, latitude, longitude);
  final zodiacName = ascendantSign?.nameDe ?? 'null';

  print('   Aszendent: ${ascendantDegree.toStringAsFixed(2)}° → $zodiacName');
  print('');

  // 3. Vergleich mit alter Methode (ohne UTC)
  print('Schritt 3: Vergleich (ohne UTC-Konvertierung)');
  final ascendantSignOld = ZodiacCalculator.calculateAscendant(
    birthDateTime: localDateTime,  // ← Lokale Zeit (FALSCH!)
    latitude: latitude,
    longitude: longitude,
  );
  final ascendantDegreeOld = _getAscendantDegree(localDateTime, latitude, longitude);
  final zodiacNameOld = ascendantSignOld?.nameDe ?? 'null';

  print('   Aszendent: ${ascendantDegreeOld.toStringAsFixed(2)}° → $zodiacNameOld');
  print('');

  print('=' * 80);
  final isCorrect = zodiacName == 'Löwe';
  final status = isCorrect ? '✅ KORREKT!' : '❌ FALSCH';
  print('Ergebnis: $status');
  print('  Mit UTC:   $zodiacName ${ascendantDegree.toStringAsFixed(2)}°');
  print('  Ohne UTC:  $zodiacNameOld ${ascendantDegreeOld.toStringAsFixed(2)}°');
  print('  Erwartet:  Löwe');
  print('  Differenz: ${(ascendantDegree - ascendantDegreeOld).abs().toStringAsFixed(2)}°');
  print('=' * 80);

  if (!isCorrect) {
    print('');
    print('🔍 Debugging:');
    print('  Löwe = 120°-150°');
    print('  Jungfrau = 150°-180°');
    print('  Waage = 180°-210°');
    print('');

    // Test mit verschiedenen Offsets
    print('🧪 Alternative Zeiten testen:');
    for (var offsetHours in [-2, -1, 0, 1, 2]) {
      final testTime = localDateTime.add(Duration(hours: offsetHours));
      final testUTC = TimezoneConverter.toUTC(
        localDateTime: testTime,
        timezoneId: timezoneId,
      );
      final testAsc = ZodiacCalculator.calculateAscendant(
        birthDateTime: testUTC,
        latitude: latitude,
        longitude: longitude,
      );
      final testDeg = _getAscendantDegree(testUTC, latitude, longitude);
      final testName = testAsc?.nameDe ?? 'null';
      print('   ${testTime.hour}:${testTime.minute.toString().padLeft(2, '0')}: ${testDeg.toStringAsFixed(2)}° → $testName');
    }
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
