import 'package:test/test.dart';
import 'package:nuuray_core/nuuray_core.dart';

void main() {
  group('Cosmic Profile Service Tests', () {
    test('Berechne Cosmic Profile für Natalie (30.11.1983, 22:32, Friedrichshafen)', () async {
      // Arrange
      final birthDate = DateTime(1983, 11, 30);
      final birthTime = DateTime(1983, 11, 30, 22, 32);
      const latitude = 47.6542;
      const longitude = 9.4815;
      const fullName = 'Natalie Frauke Günes';

      // Act
      final cosmicProfile = await CosmicProfileService.calculateCosmicProfile(
        userId: 'test-natalie',
        birthDate: birthDate,
        birthTime: birthTime,
        birthLatitude: latitude,
        birthLongitude: longitude,
        fullName: fullName,
      );

      // Assert
      print('\n📊 COSMIC PROFILE RESULTS:');
      print('═══════════════════════════════════════════════════\n');

      print('☀️  WESTERN ASTROLOGY');
      print('   Sonnenzeichen: ${cosmicProfile.sunSign} (${cosmicProfile.sunDegree?.toStringAsFixed(2)}°)');
      print('   Mondzeichen: ${cosmicProfile.moonSign ?? "N/A"} (${cosmicProfile.moonDegree?.toStringAsFixed(2) ?? "N/A"}°)');
      print('   Aszendent: ${cosmicProfile.ascendantSign ?? "N/A"} (${cosmicProfile.ascendantDegree?.toStringAsFixed(2) ?? "N/A"}°)\n');

      print('🐉 BAZI (VIER SÄULEN)');
      print('   Jahressäule: ${cosmicProfile.baziYearStem}-${cosmicProfile.baziYearBranch}');
      print('   Monatssäule: ${cosmicProfile.baziMonthStem}-${cosmicProfile.baziMonthBranch}');
      print('   Tagessäule (Day Master): ${cosmicProfile.baziDayStem}-${cosmicProfile.baziDayBranch}');
      print('   Stundensäule: ${cosmicProfile.baziHourStem ?? "N/A"}-${cosmicProfile.baziHourBranch ?? "N/A"}');
      print('   Dominantes Element: ${cosmicProfile.baziElement}\n');

      print('🔢 NUMEROLOGIE');
      print('   Life Path Number: ${cosmicProfile.lifePathNumber}');
      print('   Expression Number: ${cosmicProfile.expressionNumber ?? "N/A"}');
      print('   Soul Urge Number: ${cosmicProfile.soulUrgeNumber ?? "N/A"}\n');

      print('═══════════════════════════════════════════════════');

      // Validierungen
      expect(cosmicProfile.sunSign, equals('sagittarius')); // 30. Nov = Schütze
      expect(cosmicProfile.moonSign, isNotNull);
      expect(cosmicProfile.ascendantSign, isNotNull);
      expect(cosmicProfile.lifePathNumber, isNotNull);
      expect(cosmicProfile.baziDayStem, isNotNull); // Day Master muss existieren
    });

    test('Test mit Testprofil-Helper', () async {
      // Act
      final cosmicProfile = await CosmicProfileService.calculateTestProfile();

      // Assert
      expect(cosmicProfile.userId, equals('test-user-natalie'));
      expect(cosmicProfile.sunSign, isNotNull);
      expect(cosmicProfile.lifePathNumber, isNotNull);

      print('\n🧪 Test-Profil erfolgreich berechnet!');
      print('   User: ${cosmicProfile.userId}');
      print('   Sonnenzeichen: ${cosmicProfile.sunSign}');
      print('   Life Path: ${cosmicProfile.lifePathNumber}');
    });

    test('Berechne Profile ohne optionale Felder', () async {
      // Arrange: Nur Geburtsdatum, keine Zeit/Ort/Name
      final birthDate = DateTime(1990, 6, 15);

      // Act
      final cosmicProfile = await CosmicProfileService.calculateCosmicProfile(
        userId: 'test-minimal',
        birthDate: birthDate,
      );

      // Assert
      expect(cosmicProfile.sunSign, equals('gemini')); // 15. Juni = Zwillinge
      expect(cosmicProfile.moonSign, isNull); // Keine Geburtszeit
      expect(cosmicProfile.ascendantSign, isNull); // Keine Zeit/Ort
      expect(cosmicProfile.expressionNumber, isNull); // Kein Name
      expect(cosmicProfile.soulUrgeNumber, isNull); // Kein Name
      expect(cosmicProfile.lifePathNumber, isNotNull); // Nur Datum benötigt

      print('\n📊 Minimales Profil erfolgreich berechnet!');
      print('   Sonnenzeichen: ${cosmicProfile.sunSign}');
      print('   Life Path: ${cosmicProfile.lifePathNumber}');
    });
  });
}
