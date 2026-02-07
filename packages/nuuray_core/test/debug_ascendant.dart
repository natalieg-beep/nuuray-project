import 'dart:math' as math;

/// Debug-Script für Aszendent-Berechnung
/// Vergleicht unsere Berechnung mit bekannten Werten

void main() {
  print('🔍 Aszendent-Berechnung Debug\n');

  // Test: Rakim Günes - 06.07.2006 um 04:55 in Ravensburg
  // Erwartet: Krebs, Unsere Berechnung: ?

  final birthDateTime = DateTime(2006, 7, 6, 4, 55); // Lokale Zeit (MESZ = UTC+2)
  final latitude = 47.782082;  // Ravensburg
  final longitude = 9.61173;

  print('Geburtsdaten:');
  print('  Datum: ${birthDateTime.day}.${birthDateTime.month}.${birthDateTime.year}');
  print('  Zeit: ${birthDateTime.hour}:${birthDateTime.minute.toString().padLeft(2, '0')} (MESZ = UTC+2)');
  print('  Ort: Ravensburg');
  print('  Lat: $latitude°N');
  print('  Lng: $longitude°E');
  print('');

  // Schritt 1: Julian Day
  final jd = calculateJulianDay(birthDateTime);
  print('Schritt 1: Julian Day');
  print('  JD = $jd');
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
  print('  T = $T');
  print('  GMST = ${GMST.toStringAsFixed(6)}°');
  print('');

  // Schritt 3: Local Sidereal Time
  var RAMC = GMST + longitude;
  RAMC = RAMC % 360.0;
  if (RAMC < 0) RAMC += 360.0;

  print('Schritt 3: Local Sidereal Time (RAMC)');
  print('  RAMC = GMST + longitude');
  print('  RAMC = ${GMST.toStringAsFixed(6)} + $longitude');
  print('  RAMC = ${RAMC.toStringAsFixed(6)}°');
  print('');

  // Schritt 4: Obliquity (Schiefe der Ekliptik)
  final epsilon = 23.439291 - 0.0130042 * T;
  print('Schritt 4: Obliquity (Schiefe der Ekliptik)');
  print('  ε = ${epsilon.toStringAsFixed(6)}°');
  print('');

  // Schritt 5: Aszendent berechnen
  final RAMCRad = RAMC * math.pi / 180.0;
  final latRad = latitude * math.pi / 180.0;
  final epsilonRad = epsilon * math.pi / 180.0;

  final numerator = math.cos(RAMCRad);
  final denominator = -(math.sin(epsilonRad) * math.tan(latRad) +
      math.cos(epsilonRad) * math.sin(RAMCRad));

  var ascendant = math.atan2(numerator, denominator) * 180.0 / math.pi;
  ascendant = ascendant % 360.0;
  if (ascendant < 0) ascendant += 360.0;

  print('Schritt 5: Aszendent-Formel');
  print('  numerator = cos(RAMC) = ${numerator.toStringAsFixed(6)}');
  print('  denominator = -(sin(ε) × tan(lat) + cos(ε) × sin(RAMC))');
  print('  denominator = ${denominator.toStringAsFixed(6)}');
  print('  atan2(num, denom) = ${(math.atan2(numerator, denominator) * 180.0 / math.pi).toStringAsFixed(6)}°');
  print('  Aszendent = ${ascendant.toStringAsFixed(6)}°');
  print('');

  // Schritt 6: Sternzeichen bestimmen
  final zodiacSign = getZodiacFromLongitude(ascendant);
  final degreeInSign = ascendant % 30;

  print('Schritt 6: Sternzeichen');
  print('  ${ascendant.toStringAsFixed(2)}° → $zodiacSign ${degreeInSign.toStringAsFixed(2)}°');
  print('');
  print('=' * 80);
  print('Ergebnis: Aszendent = $zodiacSign');
  print('Erwartet: Aszendent = Krebs');
  print('=' * 80);
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
