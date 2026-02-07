import 'dart:math' as math;

/// Test: Timezone-Impact auf Aszendent

void main() {
  print('🔍 Timezone-Impact Test\n');
  print('=' * 80);
  print('Test: Matilda Maier - 7.2.1977 um 8:25 in Berlin');
  print('Erwartet: Fische');
  print('=' * 80);
  print('');

  final lat = 52.5200; // Berlin
  final lng = 13.4050;

  // Test 1: Als lokale Zeit (MEZ = UTC+1)
  print('1️⃣ Als lokale Zeit 8:25 (MEZ = UTC+1)');
  final local = DateTime(1977, 2, 7, 8, 25);
  final ascLocal = calculateAscendant(local, lat, lng);
  print('   Eingabe: 8:25 lokal');
  print('   Aszendent: ${ascLocal.toStringAsFixed(2)}° → ${getZodiac(ascLocal)}');
  print('');

  // Test 2: Als UTC interpretiert (also eigentlich 9:25 MEZ)
  print('2️⃣ Wenn 8:25 als UTC interpretiert wird (= 9:25 MEZ)');
  final asUTC = DateTime.utc(1977, 2, 7, 8, 25);
  final ascAsUTC = calculateAscendant(asUTC, lat, lng);
  print('   Eingabe: 8:25 UTC (= 9:25 lokal)');
  print('   Aszendent: ${ascAsUTC.toStringAsFixed(2)}° → ${getZodiac(ascAsUTC)}');
  print('');

  // Test 3: 1 Stunde früher (7:25 MEZ)
  print('3️⃣ Eine Stunde früher (7:25 MEZ statt 8:25)');
  final minus1h = DateTime(1977, 2, 7, 7, 25);
  final ascMinus1 = calculateAscendant(minus1h, lat, lng);
  print('   Eingabe: 7:25 lokal');
  print('   Aszendent: ${ascMinus1.toStringAsFixed(2)}° → ${getZodiac(ascMinus1)}');
  print('');

  // Test 4: 2 Stunden früher (6:25 MEZ)
  print('4️⃣ Zwei Stunden früher (6:25 MEZ statt 8:25)');
  final minus2h = DateTime(1977, 2, 7, 6, 25);
  final ascMinus2 = calculateAscendant(minus2h, lat, lng);
  print('   Eingabe: 6:25 lokal');
  print('   Aszendent: ${ascMinus2.toStringAsFixed(2)}° → ${getZodiac(ascMinus2)}');
  print('');

  // Test 5: Am Vorabend 20:25 (12h früher)
  print('5️⃣ Am Vorabend 20:25 (6.2.1977 20:25)');
  final minus12h = DateTime(1977, 2, 6, 20, 25);
  final ascMinus12 = calculateAscendant(minus12h, lat, lng);
  print('   Eingabe: 6.2.1977 20:25');
  print('   Aszendent: ${ascMinus12.toStringAsFixed(2)}° → ${getZodiac(ascMinus12)}');
  print('');

  print('=' * 80);
  print('Fazit: Aszendent ändert sich alle ~2 Stunden um ~30° (1 Zeichen)');
  print('       Um von Widder (17°) zu Fische (350°) zu kommen,');
  print('       müsste die Zeit ~23 Stunden FRÜHER sein!');
  print('       → Entweder ist die Referenz falsch, oder unser Code hat');
  print('         einen systematischen Fehler.');
  print('=' * 80);
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

String getZodiac(double longitude) {
  final normalizedLong = longitude % 360;
  final index = (normalizedLong / 30).floor();

  const zodiacNames = [
    'Widder',
    'Stier',
    'Zwillinge',
    'Krebs',
    'Löwe',
    'Jungfrau',
    'Waage',
    'Skorpion',
    'Schütze',
    'Steinbock',
    'Wassermann',
    'Fische',
  ];

  return zodiacNames[index % 12];
}
