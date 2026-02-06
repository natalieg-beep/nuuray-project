import 'package:test/test.dart';
import 'package:nuuray_core/nuuray_core.dart';

void main() {
  group('Numerology Dual Name Tests (Birth vs. Current)', () {
    test('Natalie mit Geburtsname Pawlowski', () {
      // Arrange
      final birthDate = DateTime(1983, 11, 30);
      const birthName = 'Natalie Frauke Pawlowski';

      // Act
      final profile = NumerologyCalculator.calculateCompleteProfile(
        birthDate: birthDate,
        birthName: birthName,
      );

      // Assert
      print('\n📊 BIRTH ENERGY (Pawlowski):');
      print('   Life Path: ${profile.lifePathNumber}');
      print('   Expression: ${profile.birthExpressionNumber}');
      print('   Soul Urge: ${profile.birthSoulUrgeNumber}');
      print('   Personality: ${profile.birthPersonalityNumber}');

      expect(profile.lifePathNumber, equals(8));
      expect(profile.hasNameChange, isFalse);
      expect(profile.birthName, equals(birthName));
      expect(profile.currentName, isNull);
    });

    test('Natalie mit aktuellem Namen Günes (Namenswechsel)', () {
      // Arrange
      final birthDate = DateTime(1983, 11, 30);
      const birthName = 'Natalie Frauke Pawlowski';
      const currentName = 'Natalie Frauke Günes';

      // Act
      final profile = NumerologyCalculator.calculateCompleteProfile(
        birthDate: birthDate,
        birthName: birthName,
        currentName: currentName,
      );

      // Assert
      print('\n📊 DUAL ENERGY PROFILE:');
      print('   Life Path: ${profile.lifePathNumber}\n');

      print('   BIRTH ENERGY ($birthName):');
      print('     Expression: ${profile.birthExpressionNumber}');
      print('     Soul Urge: ${profile.birthSoulUrgeNumber}');
      print('     Personality: ${profile.birthPersonalityNumber}\n');

      print('   CURRENT ENERGY ($currentName):');
      print('     Expression: ${profile.currentExpressionNumber}');
      print('     Soul Urge: ${profile.currentSoulUrgeNumber}');
      print('     Personality: ${profile.currentPersonalityNumber}\n');

      print('   ACTIVE ENERGY (seit Namenswechsel):');
      print('     Expression: ${profile.activeExpressionNumber}');
      print('     Soul Urge: ${profile.activeSoulUrgeNumber}');

      expect(profile.lifePathNumber, equals(8));
      expect(profile.hasNameChange, isTrue);
      expect(profile.birthName, equals(birthName));
      expect(profile.currentName, equals(currentName));

      // Birth und Current müssen unterschiedlich sein
      expect(profile.birthExpressionNumber, isNot(equals(profile.currentExpressionNumber)));
      expect(profile.birthSoulUrgeNumber, isNot(equals(profile.currentSoulUrgeNumber)));
    });

    test('Vergleich: Pawlowski vs. Günes Zahlen', () {
      // Arrange
      final birthDate = DateTime(1983, 11, 30);

      // Act - Nur Pawlowski
      final pawlowski = NumerologyCalculator.calculateCompleteProfile(
        birthDate: birthDate,
        birthName: 'Natalie Frauke Pawlowski',
      );

      // Act - Nur Günes
      final guenes = NumerologyCalculator.calculateCompleteProfile(
        birthDate: birthDate,
        birthName: 'Natalie Frauke Günes',
      );

      // Assert
      print('\n🔢 VERGLEICH PAWLOWSKI vs. GÜNES:');
      print('   ─────────────────────────────────────────');
      print('   Life Path (immer gleich): ${pawlowski.lifePathNumber}');
      print('   ─────────────────────────────────────────');
      print('   Expression:     ${pawlowski.birthExpressionNumber} (Pawlowski) vs. ${guenes.birthExpressionNumber} (Günes)');
      print('   Soul Urge:      ${pawlowski.birthSoulUrgeNumber} (Pawlowski) vs. ${guenes.birthSoulUrgeNumber} (Günes)');
      print('   Personality:    ${pawlowski.birthPersonalityNumber} (Pawlowski) vs. ${guenes.birthPersonalityNumber} (Günes)');
      print('   ─────────────────────────────────────────');

      // Pawlowski sollte: Expression 9, Soul Urge 22 (Meisterzahl)
      // Günes sollte: Expression 6, Soul Urge 11 (Meisterzahl)

      if (pawlowski.birthSoulUrgeNumber == 22) {
        print('   ✨ Pawlowski: MEISTERZAHL 22 (Master Builder)');
      }

      if (guenes.birthSoulUrgeNumber == 11) {
        print('   ✨ Günes: MEISTERZAHL 11 (Spiritual Messenger)');
      }
    });

    test('Umlaute: Ü wird als UE behandelt', () {
      // Test wie "Ü" behandelt wird
      final guenes1 = NumerologyCalculator.calculateExpression('Günes');
      final guenes2 = NumerologyCalculator.calculateExpression('Guenes');

      print('\n🔤 UMLAUT-TEST:');
      print('   "Günes" (Ü→UE normalisiert): Expression = $guenes1');
      print('   "Guenes" (ohne Umlaut):      Expression = $guenes2');

      // Sie sollten GLEICH sein, da normalizeName Ü→UE macht
      expect(guenes1, equals(guenes2)); // Beide ergeben 8
      print('   ✓ Umlaute werden korrekt als UE behandelt');
    });
  });
}
