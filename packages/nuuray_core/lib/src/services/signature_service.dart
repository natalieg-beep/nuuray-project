import 'dart:developer';
import '../models/birth_chart.dart';
import 'zodiac_calculator.dart';
import 'bazi_calculator.dart';
import 'numerology_calculator.dart';
import 'timezone_converter_simple.dart';

/// Signature Service (vormals Cosmic Profile Service)
///
/// Zentrale Service-Klasse, die alle drei Berechnungs-Systeme zusammenführt:
/// - Western Astrology (Sonne, Mond, Aszendent)
/// - Bazi (Vier Säulen, Day Master, Dominantes Element)
/// - Numerologie (Life Path, Expression, Soul Urge)
///
/// Nimmt User-Profil-Daten als Input und gibt ein vollständiges BirthChart zurück.
class SignatureService {
  /// Berechnet die vollständige "Deine Signatur" aus Geburtsdaten und Namen
  ///
  /// Parameter:
  /// - [userId]: User-ID für Zuordnung
  /// - [birthDate]: Geburtsdatum (Pflicht)
  /// - [birthTime]: Geburtszeit (Optional - für Aszendent, Mondzeichen, Stundensäule)
  /// - [birthLatitude]: Breitengrad des Geburtsortes (Optional - für Aszendent)
  /// - [birthLongitude]: Längengrad des Geburtsortes (Optional - für Aszendent)
  /// - [birthTimezone]: IANA Timezone ID (z.B. "Europe/Berlin") - für UTC-Konvertierung
  /// - [displayName]: Rufname (Optional - für Display Name Number, z.B. "Natalie")
  /// - [birthName]: Geburtsname (Optional - für Birth Energy Numerologie)
  /// - [currentName]: Aktueller Name (Optional - für Current Energy Numerologie)
  /// - [fullName]: DEPRECATED - Legacy Parameter, nutze birthName stattdessen
  ///
  /// Gibt ein [BirthChart] zurück mit allen berechneten Werten.
  static Future<BirthChart> calculateSignature({
    required String userId,
    required DateTime birthDate,
    DateTime? birthTime,
    double? birthLatitude,
    double? birthLongitude,
    String? birthTimezone,
    String? displayName,
    String? birthName,
    String? currentName,
    @Deprecated('Use birthName instead') String? fullName,
  }) async {
    // Legacy Support: Wenn fullName gesetzt, aber birthName nicht, verwende fullName
    final effectiveBirthName = birthName ?? fullName;

    log('📊 Berechne "Deine Signatur" für User: $userId');
    log('   Geburtsdatum: ${birthDate.toIso8601String()}');
    log('   Hat Geburtszeit: ${birthTime != null}');
    log('   Hat Geburtsort: ${birthLatitude != null && birthLongitude != null}');
    log('   Display Name: ${displayName ?? "nicht vorhanden"}');
    log('   Birth Name: ${effectiveBirthName ?? "nicht vorhanden"}');
    log('   Current Name: ${currentName ?? "nicht vorhanden"}');

    // ============================================================
    // 1. WESTERN ASTROLOGY
    // ============================================================

    // Sonnenzeichen (immer berechenbar)
    final sunSign = ZodiacCalculator.calculateSunSign(birthDate);
    // Grad-Position innerhalb des Zeichens berechnen wir aus der Position
    final sunDegree = _calculateDegreeInSign(birthDate, isForSun: true);

    log('☀️ Sonnenzeichen: ${sunSign.key} (${sunDegree.toStringAsFixed(2)}°)');

    // Mondzeichen (benötigt Geburtszeit + Timezone, sonst null)
    String? moonSignKey;
    double? moonDegree;

    if (birthTime != null) {
      // Kombiniere Datum + Zeit (wie beim Aszendenten)
      final birthDateTimeLocal = DateTime(
        birthDate.year,
        birthDate.month,
        birthDate.day,
        birthTime.hour,
        birthTime.minute,
        birthTime.second,
      );

      // UTC-Konvertierung für präzise Mondposition
      DateTime birthDateTimeUTC;
      if (birthTimezone != null && birthTimezone.isNotEmpty) {
        try {
          birthDateTimeUTC = TimezoneConverterSimple.toUTC(
            localDateTime: birthDateTimeLocal,
            timezoneId: birthTimezone,
          );
        } catch (e) {
          log('⚠️  Timezone-Konvertierung fehlgeschlagen (Mond): $e');
          birthDateTimeUTC = birthDateTimeLocal;
        }
      } else {
        birthDateTimeUTC = birthDateTimeLocal;
      }

      final moonSign = ZodiacCalculator.calculateMoonSign(birthDateTimeUTC);
      moonSignKey = moonSign.key;
      moonDegree = _calculateDegreeInSign(birthDateTimeUTC, isForSun: false);

      log('🌙 Mondzeichen: $moonSignKey (${moonDegree.toStringAsFixed(2)}°)');
    } else {
      log('🌙 Mondzeichen: Nicht berechnet (keine Geburtszeit)');
    }

    // Aszendent (benötigt Geburtszeit + Geburtsort + Timezone, sonst null)
    String? ascendantSignKey;
    double? ascendantDegree;

    if (birthTime != null && birthLatitude != null && birthLongitude != null) {
      // WICHTIG: birthTime kombiniert mit echtem Geburtsdatum für korrekte Berechnung!
      // birthTime hat Dummy-Datum (2000-01-01), wir brauchen aber das echte Datum
      // für die Julian Day Berechnung (JD hängt vom Datum ab!)
      final birthDateTimeLocal = DateTime(
        birthDate.year,
        birthDate.month,
        birthDate.day,
        birthTime.hour,
        birthTime.minute,
        birthTime.second,
      );

      log('🕐 Kombiniere Datum + Zeit: ${birthDateTimeLocal.toIso8601String()}');

      // NEU: UTC-Konvertierung mit historisch korrektem Timezone-Offset!
      // Astrologie-Berechnungen benötigen Universal Time (UT), nicht lokale Zeit.
      DateTime birthDateTimeUTC;

      if (birthTimezone != null && birthTimezone.isNotEmpty) {
        try {
          birthDateTimeUTC = TimezoneConverterSimple.toUTC(
            localDateTime: birthDateTimeLocal,
            timezoneId: birthTimezone,
          );
          log('🌍 UTC-Konvertierung: ${birthDateTimeLocal.toIso8601String()} → ${birthDateTimeUTC.toIso8601String()}');
        } catch (e) {
          log('⚠️  Timezone-Konvertierung fehlgeschlagen: $e');
          log('   Fallback: Nutze lokale Zeit ohne Konvertierung');
          birthDateTimeUTC = birthDateTimeLocal;
        }
      } else {
        log('⚠️  Keine Timezone angegeben, nutze lokale Zeit (kann ungenau sein!)');
        birthDateTimeUTC = birthDateTimeLocal;
      }

      final ascendantSign = ZodiacCalculator.calculateAscendant(
        birthDateTime: birthDateTimeUTC,  // ← UTC-Zeit!
        latitude: birthLatitude,
        longitude: birthLongitude,
      );

      if (ascendantSign != null) {
        ascendantSignKey = ascendantSign.key;
        // Für Aszendent können wir die Grad-Position approximieren
        // Basierend auf der Zeit und dem Zeichen
        ascendantDegree = _approximateAscendantDegree(birthDateTimeUTC, ascendantSign.key);

        log('⬆️ Aszendent: $ascendantSignKey (${ascendantDegree.toStringAsFixed(2)}°)');
      }
    } else {
      log('⬆️ Aszendent: Nicht berechnet (fehlende Daten)');
    }

    // ============================================================
    // 2. BAZI (VIER SÄULEN)
    // ============================================================

    // Jahressäule
    final yearPillar = BaziCalculator.calculateYearPillar(birthDate);
    log('🐉 Jahressäule: ${yearPillar['stem']}-${yearPillar['branch']} (${yearPillar['element']})');

    // Monatssäule
    final monthPillar = BaziCalculator.calculateMonthPillar(birthDate);
    log('🐉 Monatssäule: ${monthPillar['stem']}-${monthPillar['branch']} (${monthPillar['element']})');

    // Tagessäule (Day Master)
    final dayPillar = BaziCalculator.calculateDayPillar(birthDate);
    log('🐉 Tagessäule (Day Master): ${dayPillar['stem']}-${dayPillar['branch']} (${dayPillar['element']})');

    // Stundensäule (nur mit Geburtszeit)
    Map<String, String>? hourPillar;
    if (birthTime != null) {
      hourPillar = BaziCalculator.calculateHourPillar(birthDateTime: birthTime);
      log('🐉 Stundensäule: ${hourPillar!['stem']}-${hourPillar['branch']} (${hourPillar['element']})');
    } else {
      log('🐉 Stundensäule: Nicht berechnet (keine Geburtszeit)');
    }

    // Dominantes Element
    final dominantElement = BaziCalculator.calculateDominantElement(
      yearPillar: yearPillar,
      monthPillar: monthPillar,
      dayPillar: dayPillar,
      hourPillar: hourPillar,
    );
    log('🌟 Dominantes Element: $dominantElement');

    // ============================================================
    // 3. NUMEROLOGIE
    // ============================================================

    // Berechne komplettes Numerologie-Profil mit Dual-Energy Support
    final numerologyProfile = NumerologyCalculator.calculateCompleteProfile(
      birthDate: birthDate,
      birthName: effectiveBirthName,
      currentName: currentName,
    );

    // Rufnamen-Numerologie (Display Name Number)
    // Beispiel: "Natalie" → N+A+T+A+L+I+E = 5+1+2+1+3+9+5 = 26 → 8
    int? displayNameNumber;
    if (displayName != null && displayName.trim().isNotEmpty) {
      displayNameNumber = NumerologyCalculator.calculateExpression(displayName.trim());
      log('🔢 Display Name Number (${displayName.trim()}): $displayNameNumber${displayNameNumber != null && NumerologyCalculator.isMasterNumber(displayNameNumber) ? " ✨" : ""}');
    }

    log('🔢 Life Path: ${numerologyProfile.lifePathNumber}${NumerologyCalculator.isMasterNumber(numerologyProfile.lifePathNumber) ? " ✨" : ""}');
    log('🔢 Birthday: ${numerologyProfile.birthdayNumber}');
    log('🔢 Attitude: ${numerologyProfile.attitudeNumber}');
    log('🔢 Personal Year: ${numerologyProfile.personalYear}');
    if (numerologyProfile.maturityNumber != null) {
      log('🔢 Maturity: ${numerologyProfile.maturityNumber}');
    }
    if (numerologyProfile.birthName != null) {
      log('🔢 Birth Energy (${numerologyProfile.birthName}):');
      log('   Expression: ${numerologyProfile.birthExpressionNumber}${numerologyProfile.birthExpressionNumber != null && NumerologyCalculator.isMasterNumber(numerologyProfile.birthExpressionNumber!) ? " ✨" : ""}');
      log('   Soul Urge: ${numerologyProfile.birthSoulUrgeNumber}${numerologyProfile.birthSoulUrgeNumber != null && NumerologyCalculator.isMasterNumber(numerologyProfile.birthSoulUrgeNumber!) ? " ✨" : ""}');
      log('   Personality: ${numerologyProfile.birthPersonalityNumber}');
    }
    if (numerologyProfile.karmicDebtLifePath != null) {
      log('⚡ Karmic Debt Life Path: ${numerologyProfile.karmicDebtLifePath}');
    }
    if (numerologyProfile.challengeNumbers != null && numerologyProfile.challengeNumbers!.isNotEmpty) {
      log('🎯 Challenges: ${numerologyProfile.challengeNumbers}');
    }
    if (numerologyProfile.karmicLessons != null && numerologyProfile.karmicLessons!.isNotEmpty) {
      log('📚 Karmic Lessons: ${numerologyProfile.karmicLessons}');
    }
    if (numerologyProfile.bridgeLifePathExpression != null) {
      log('🌉 Bridge Life Path ↔ Expression: ${numerologyProfile.bridgeLifePathExpression}');
    }

    // ============================================================
    // 4. BIRTH CHART ZUSAMMENSTELLEN
    // ============================================================

    final birthChart = BirthChart(
      userId: userId,
      // Western Astrology
      sunSign: sunSign.key,
      moonSign: moonSignKey,
      ascendantSign: ascendantSignKey,
      sunDegree: sunDegree,
      moonDegree: moonDegree,
      ascendantDegree: ascendantDegree,
      // Bazi
      baziYearStem: yearPillar['stem'],
      baziYearBranch: yearPillar['branch'],
      baziMonthStem: monthPillar['stem'],
      baziMonthBranch: monthPillar['branch'],
      baziDayStem: dayPillar['stem'], // = Day Master
      baziDayBranch: dayPillar['branch'],
      baziHourStem: hourPillar?['stem'],
      baziHourBranch: hourPillar?['branch'],
      baziElement: dominantElement,
      // Numerologie - Kern-Zahlen
      lifePathNumber: numerologyProfile.lifePathNumber,
      displayNameNumber: displayNameNumber,
      birthdayNumber: numerologyProfile.birthdayNumber,
      attitudeNumber: numerologyProfile.attitudeNumber,
      personalYear: numerologyProfile.personalYear,
      maturityNumber: numerologyProfile.maturityNumber,
      // Numerologie - Birth Energy
      birthExpressionNumber: numerologyProfile.birthExpressionNumber,
      birthSoulUrgeNumber: numerologyProfile.birthSoulUrgeNumber,
      birthPersonalityNumber: numerologyProfile.birthPersonalityNumber,
      birthName: numerologyProfile.birthName,
      // Numerologie - Current Energy
      currentExpressionNumber: numerologyProfile.currentExpressionNumber,
      currentSoulUrgeNumber: numerologyProfile.currentSoulUrgeNumber,
      currentPersonalityNumber: numerologyProfile.currentPersonalityNumber,
      currentName: numerologyProfile.currentName,
      // Numerologie - Erweitert
      karmicDebtLifePath: numerologyProfile.karmicDebtLifePath,
      karmicDebtExpression: numerologyProfile.karmicDebtExpression,
      karmicDebtSoulUrge: numerologyProfile.karmicDebtSoulUrge,
      challengeNumbers: numerologyProfile.challengeNumbers,
      karmicLessons: numerologyProfile.karmicLessons,
      bridgeLifePathExpression: numerologyProfile.bridgeLifePathExpression,
      bridgeSoulUrgePersonality: numerologyProfile.bridgeSoulUrgePersonality,
      calculatedAt: DateTime.now(),
    );

    log('✅ Cosmic Profile erfolgreich berechnet!');

    return birthChart;
  }

  /// Test-Funktion: Berechnet Cosmic Profile für Test-User (Natalie)
  ///
  /// Geburtsdaten:
  /// - Datum: 30. November 1983
  /// - Zeit: 22:32
  /// - Ort: Friedrichshafen (47.6542°N, 9.4815°E)
  /// - Name: Natalie Frauke Günes (geb. Pawlowski)
  static Future<BirthChart> calculateTestProfile() async {
    log('🧪 Berechne Test-Profil für Natalie...');

    final birthDate = DateTime(1983, 11, 30);
    final birthTime = DateTime(1983, 11, 30, 22, 32);

    return calculateSignature(
      userId: 'test-user-natalie',
      birthDate: birthDate,
      birthTime: birthTime,
      birthLatitude: 47.6542,
      birthLongitude: 9.4815,
      birthTimezone: 'Europe/Berlin',  // NEU: Timezone für UTC-Konvertierung
      fullName: 'Natalie Frauke Günes',
    );
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Berechnet die Grad-Position innerhalb des Zeichens (0-30°)
  ///
  /// Vereinfachte Berechnung basierend auf der Tagesposition im Zeichen.
  /// Für MVP ausreichend, kann später mit präziser Längenberechnung verfeinert werden.
  static double _calculateDegreeInSign(DateTime dateTime, {required bool isForSun}) {
    // Vereinfachte Berechnung: Position im Zeichen basierend auf Tag im Monat
    // Jedes Zeichen hat ~30 Tage, wir approximieren die Grad-Position

    if (isForSun) {
      // Für Sonne: Basierend auf Tag im Sternzeichen
      final month = dateTime.month;
      final day = dateTime.day;

      // Approximation: Tag im aktuellen Zeichen
      // Sternzeichen wechseln zwischen 19.-23. des Monats
      double dayInSign;

      if (month == 1) {
        dayInSign = day < 20 ? day + 10 : day - 20; // Steinbock/Wassermann
      } else if (month == 2) {
        dayInSign = day < 19 ? day + 11 : day - 19; // Wassermann/Fische
      } else if (month == 3) {
        dayInSign = day < 21 ? day + 9 : day - 21; // Fische/Widder
      } else if (month == 4) {
        dayInSign = day < 20 ? day + 10 : day - 20; // Widder/Stier
      } else if (month == 5) {
        dayInSign = day < 21 ? day + 9 : day - 21; // Stier/Zwillinge
      } else if (month == 6) {
        dayInSign = day < 21 ? day + 9 : day - 21; // Zwillinge/Krebs
      } else if (month == 7) {
        dayInSign = day < 23 ? day + 8 : day - 23; // Krebs/Löwe
      } else if (month == 8) {
        dayInSign = day < 23 ? day + 8 : day - 23; // Löwe/Jungfrau
      } else if (month == 9) {
        dayInSign = day < 23 ? day + 7 : day - 23; // Jungfrau/Waage
      } else if (month == 10) {
        dayInSign = day < 23 ? day + 7 : day - 23; // Waage/Skorpion
      } else if (month == 11) {
        dayInSign = day < 22 ? day + 8 : day - 22; // Skorpion/Schütze
      } else {
        dayInSign = day < 22 ? day + 8 : day - 22; // Schütze/Steinbock
      }

      return dayInSign.toDouble();
    } else {
      // Für Mond: Approximation basierend auf Stunde (Mond wechselt ~alle 2.5 Tage = 60 Stunden das Zeichen)
      // Vereinfacht: 12° pro Tag
      final hour = dateTime.hour;
      final minute = dateTime.minute;

      final hourFraction = hour + (minute / 60.0);
      final degreePerHour = 0.5; // ~12° pro Tag = 0.5° pro Stunde

      return (hourFraction * degreePerHour) % 30;
    }
  }

  /// Approximiert die Aszendent-Position in Grad (0-30°)
  ///
  /// Vereinfachte Berechnung basierend auf Geburtszeit.
  /// Aszendent wechselt alle ~2 Stunden das Zeichen (12 Zeichen in 24 Stunden).
  static double _approximateAscendantDegree(DateTime birthTime, String ascendantKey) {
    // Aszendent-Position basierend auf Minute innerhalb der 2-Stunden-Periode
    final hour = birthTime.hour;
    final minute = birthTime.minute;

    // Position innerhalb der 2-Stunden-Periode (0-120 Minuten)
    final minuteInPeriod = (hour % 2) * 60 + minute;

    // 30° pro 2 Stunden = 0.25° pro Minute
    return (minuteInPeriod * 0.25) % 30;
  }
}
