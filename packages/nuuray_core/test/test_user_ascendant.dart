import 'dart:math' as math;

/// Test: User-Aszendent (30.11.1983 22:32 in Friedrichshafen)
/// Erwartet: Löwe
/// App zeigt: Jungfrau (FALSCH!)

void main() {
  print('🔍 User Aszendent-Test\n');
  print('=' * 80);

  final birthDateTime = DateTime(1983, 11, 30, 22, 32);
  final latitude = 47.6546; // Friedrichshafen
  final longitude = 9.4797;

  print('Geburtsdaten:');
  print('  Datum: 30.11.1983');
  print('  Zeit: 22:32 (MEZ = UTC+1 im Winter)');
  print('  Ort: Friedrichshafen');
  print('  Lat: ${latitude.toStringAsFixed(4)}°N');
  print('  Lng: ${longitude.toStringAsFixed(4)}°E');
  print('  Erwartet: Löwe ♌');
  print('');

  // Schritt 1: Julian Day
  final jd = calculateJulianDay(birthDateTime);
  print('Schritt 1: Julian Day');
  print('  JD = ${jd.toStringAsFixed(6)}');
  print('');

  // Schritt 2: Sidereal Time
  final T = (jd - 2451545.0) / 36525.0;
  var GMST = 280.46061837 +
      360.98564736629 * (jd - 2451545.0) +
      0.000387933 * T * T -
      T * T * T / 38710000.0;
  GMST = GMST % 360.0;
  if (GMST < 0) GMST += 360.0;

  print('Schritt 2: Greenwich Mean Sidereal Time');
  print('  T = ${T.toStringAsFixed(8)}');
  print('  GMST = ${GMST.toStringAsFixed(6)}°');
  print('');

  // Schritt 3: Local Sidereal Time
  var RAMC = GMST + longitude;
  RAMC = RAMC % 360.0;
  if (RAMC < 0) RAMC += 360.0;

  print('Schritt 3: Local Sidereal Time (RAMC)');
  print('  RAMC = GMST + longitude');
  print('  RAMC = ${GMST.toStringAsFixed(6)} + ${longitude.toStringAsFixed(4)}');
  print('  RAMC = ${RAMC.toStringAsFixed(6)}°');
  print('');

  // Schritt 4: Obliquity
  final epsilon = 23.439291 - 0.0130042 * T;
  print('Schritt 4: Obliquity (Schiefe der Ekliptik)');
  print('  ε = ${epsilon.toStringAsFixed(6)}°');
  print('');

  // Schritt 5: Aszendent berechnen
  final RAMCRad = RAMC * math.pi / 180.0;
  final latRad = latitude * math.pi / 180.0;
  final epsilonRad = epsilon * math.pi / 180.0;

  final y = math.cos(RAMCRad);
  final x = -(math.sin(epsilonRad) * math.tan(latRad) +
      math.cos(epsilonRad) * math.sin(RAMCRad));

  var ascendant = math.atan2(y, x) * 180.0 / math.pi;
  ascendant = ascendant % 360.0;
  if (ascendant < 0) ascendant += 360.0;

  print('Schritt 5: Aszendent-Formel');
  print('  y = cos(RAMC) = ${y.toStringAsFixed(6)}');
  print('  x = -(sin(ε) × tan(lat) + cos(ε) × sin(RAMC))');
  print('  x = ${x.toStringAsFixed(6)}');
  print('  atan2(y, x) = ${(math.atan2(y, x) * 180.0 / math.pi).toStringAsFixed(6)}°');
  print('  Aszendent = ${ascendant.toStringAsFixed(6)}°');
  print('');

  // Schritt 6: Sternzeichen
  final zodiacSign = getZodiacFromLongitude(ascendant);
  final degreeInSign = ascendant % 30;

  print('Schritt 6: Sternzeichen');
  print('  ${ascendant.toStringAsFixed(2)}° → $zodiacSign ${degreeInSign.toStringAsFixed(2)}°');
  print('');
  print('=' * 80);

  final isCorrect = zodiacSign == 'Löwe';
  final status = isCorrect ? '✅ KORREKT' : '❌ FALSCH';

  print('Ergebnis: $status');
  print('  Berechnet: $zodiacSign');
  print('  Erwartet:  Löwe');
  print('=' * 80);

  if (!isCorrect) {
    print('');
    print('🔍 ANALYSE:');
    print('  Löwe = 120°-150°');
    print('  Jungfrau = 150°-180°');
    print('  Differenz: ${ascendant.toStringAsFixed(2)}° liegt in $zodiacSign');
    print('  Um Löwe zu erreichen, müsste Aszendent < 150° sein');
    print('');

    // Test mit +/- 1 Stunde
    print('🧪 Timezone-Tests:');
    testWithTime(DateTime(1983, 11, 30, 21, 32), latitude, longitude, '21:32 (-1h)');
    testWithTime(DateTime(1983, 11, 30, 23, 32), latitude, longitude, '23:32 (+1h)');
  }
}

void testWithTime(DateTime dt, double lat, double lng, String label) {
  final asc = calculateAscendant(dt, lat, lng);
  final zodiac = getZodiacFromLongitude(asc);
  print('  $label: ${asc.toStringAsFixed(2)}° → $zodiac');
}

double calculateAscendant(DateTime dateTime, double lat, double lng) {
  final jd = calculateJulianDay(dateTime);
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

double calculateJulianDay(DateTime dateTime) {
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

String getZodiacFromLongitude(double longitude) {
  final normalizedLong = longitude % 360;
  final index = (normalizedLong / 30).floor();

  const zodiacNames = [
    'Widder',      // 0°-30°
    'Stier',       // 30°-60°
    'Zwillinge',   // 60°-90°
    'Krebs',       // 90°-120°
    'Löwe',        // 120°-150°
    'Jungfrau',    // 150°-180°
    'Waage',       // 180°-210°
    'Skorpion',    // 210°-240°
    'Schütze',     // 240°-270°
    'Steinbock',   // 270°-300°
    'Wassermann',  // 300°-330°
    'Fische',      // 330°-360°
  ];

  return zodiacNames[index % 12];
}
