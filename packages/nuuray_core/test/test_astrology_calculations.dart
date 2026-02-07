import 'package:nuuray_core/src/services/zodiac_calculator.dart';
import 'package:nuuray_core/src/models/zodiac_sign.dart';

void main() {
  print('🔮 NUURAY Astrologie-Berechnungs-Test\n');
  print('=' * 80);

  // Test-Cases
  // WICHTIG: Koordinaten präzise verwenden (aus Screenshots)
  final testCases = [
    {
      'name': 'Matilda Maier',
      'date': DateTime(1977, 2, 7, 8, 25),
      'location': 'Berlin',
      'lat': 54.0333, // Berlin (54°2' N aus Screenshot)
      'lng': 10.4333, // Berlin (10°26' E aus Screenshot)
      'expected': {
        'sun': 'Wassermann',
        'moon': 'Jungfrau',
        'ascendant': 'Fische'
      }
    },
    {
      'name': 'Rasheeda Günes',
      'date': DateTime(2004, 12, 7, 16, 40),
      'location': 'Ravensburg',
      'lat': 47.782082, // Ravensburg
      'lng': 9.61173,
      'expected': {
        'sun': 'Schütze',
        'moon': 'Waage',
        'ascendant': 'Zwilling'
      }
    },
    {
      'name': 'Rakim Günes',
      'date': DateTime(2006, 7, 6, 4, 55),
      'location': 'Ravensburg',
      'lat': 47.782082,
      'lng': 9.61173,
      'expected': {
        'sun': 'Krebs',
        'moon': 'Skorpion',
        'ascendant': 'Krebs'
      }
    },
    {
      'name': 'Derya Aydin',
      'date': DateTime(1992, 9, 27, 18, 39),
      'location': 'Istanbul',
      'lat': 41.0, // Istanbul (41°0' N aus Screenshot)
      'lng': 28.9333, // Istanbul (28°56' E aus Screenshot)
      'expected': {
        'sun': 'Waage',
        'moon': 'Waage',
        'ascendant': 'Widder'
      }
    },
  ];

  int totalTests = 0;
  int passedTests = 0;

  for (final testCase in testCases) {
    final name = testCase['name'] as String;
    final date = testCase['date'] as DateTime;
    final location = testCase['location'] as String;
    final lat = testCase['lat'] as double;
    final lng = testCase['lng'] as double;
    final expected = testCase['expected'] as Map<String, String>;

    print('\n📋 Test: $name');
    print('   Geburt: ${date.day}.${date.month}.${date.year} um ${date.hour}:${date.minute.toString().padLeft(2, '0')} in $location');
    print('   Koordinaten: ${lat.toStringAsFixed(4)}°N, ${lng.toStringAsFixed(4)}°E');
    print('');

    // Berechnungen
    final sunSign = ZodiacCalculator.calculateSunSign(date);
    final moonSign = ZodiacCalculator.calculateMoonSign(date);
    final ascendantSign = ZodiacCalculator.calculateAscendant(
      birthDateTime: date,
      latitude: lat,
      longitude: lng,
    );

    // Vergleich
    final sunMatch = sunSign.nameDe == expected['sun'];
    final moonMatch = moonSign.nameDe == expected['moon'];
    final ascMatch = ascendantSign?.nameDe == expected['ascendant'];

    totalTests += 3;
    if (sunMatch) passedTests++;
    if (moonMatch) passedTests++;
    if (ascMatch) passedTests++;

    // Sonne
    print('   ☀️  Sonne:     ${sunMatch ? '✅' : '❌'} ${sunSign.nameDe.padRight(12)} (erwartet: ${expected['sun']})');

    // Mond
    print('   🌙 Mond:      ${moonMatch ? '✅' : '❌'} ${moonSign.nameDe.padRight(12)} (erwartet: ${expected['moon']})');

    // Aszendent
    final ascName = ascendantSign?.nameDe ?? 'null';
    print('   ⬆️  Aszendent: ${ascMatch ? '✅' : '❌'} ${ascName.padRight(12)} (erwartet: ${expected['ascendant']})');
  }

  print('\n' + '=' * 80);
  print('📊 Ergebnis: $passedTests / $totalTests Tests bestanden');
  print('   Erfolgsrate: ${(passedTests / totalTests * 100).toStringAsFixed(1)}%');
  print('=' * 80);
}
