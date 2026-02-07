import 'dart:math' as math;

/// Test: Einzel-Aszendent Berechnung mit Debug-Output

void main() {
  print('🔍 Aszendent Einzel-Test\n');
  print('=' * 80);

  // Test 1: Rakim (FUNKTIONIERT)
  testAscendant(
    name: 'Rakim Günes',
    dateTime: DateTime(2006, 7, 6, 4, 55),
    lat: 47.782082,
    lng: 9.61173,
    location: 'Ravensburg',
    expectedSign: 'Krebs',
  );

  print('\n' + '=' * 80 + '\n');

  // Test 2: Matilda mit Screenshot-Koordinaten (54°2' N, 10°26' E)
  testAscendant(
    name: 'Matilda Maier (Screenshot-Koordinaten)',
    dateTime: DateTime(1977, 2, 7, 8, 25),
    lat: 54.0333, // 54°2' N
    lng: 10.4333, // 10°26' E
    location: 'Screenshot-Wert',
    expectedSign: 'Fische',
  );

  print('\n' + '=' * 80 + '\n');

  // Test 3: Matilda mit echten Berlin-Koordinaten
  testAscendant(
    name: 'Matilda Maier (echtes Berlin)',
    dateTime: DateTime(1977, 2, 7, 8, 25),
    lat: 52.5200, // Berlin echt
    lng: 13.4050, // Berlin echt
    location: 'Berlin (52.52°N, 13.41°E)',
    expectedSign: '?',
  );
}

void testAscendant({
  required String name,
  required DateTime dateTime,
  required double lat,
  required double lng,
  required String location,
  required String expectedSign,
}) {
  print('📋 Test: $name');
  print('   Zeit: ${dateTime.day}.${dateTime.month}.${dateTime.year} um ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}');
  print('   Ort: $location');
  print('   Koordinaten: ${lat.toStringAsFixed(4)}°N, ${lng.toStringAsFixed(4)}°E');
  print('');

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

  final zodiacSign = getZodiacFromLongitude(ascendant);
  final degreeInSign = ascendant % 30;

  final match = zodiacSign == expectedSign ? '✅' : '❌';

  print('   Aszendent: $match ${ascendant.toStringAsFixed(2)}° → $zodiacSign ${degreeInSign.toStringAsFixed(2)}°');
  print('   Erwartet: $expectedSign');
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
