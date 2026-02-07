import 'dart:developer';
import 'package:timezone/timezone.dart' as tz;

/// Timezone Converter
///
/// Konvertiert lokale Geburtszeiten in UTC für astronomische Berechnungen.
///
/// WICHTIG: Astrologie-Berechnungen (Julian Day, Sternzeit, Aszendent)
/// benötigen Universal Time (UT), nicht lokale Zeit!
///
/// Problem: Dart's DateTime hat nur local/utc, keine echten Timezones.
/// Lösung: timezone Package mit IANA Timezone Database.
///
/// Phase 1 (MVP): Timezone-String aus birth_timezone DB-Feld nutzen
/// Phase 2 (Production): Google Time Zone API + utc_offset_seconds in DB
class TimezoneConverter {
  static bool _initialized = false;

  /// Initialisiert die Timezone-Datenbank
  ///
  /// MUSS einmal beim App-Start aufgerufen werden!
  /// Am besten in main.dart vor runApp().
  ///
  /// WICHTIG: Nutzt die eingebaute Timezone-Datenbank.
  /// Für Flutter Apps: Wird automatisch mit dem Package gebündelt.
  static void initialize() {
    if (_initialized) return;

    try {
      // Lade die eingebaute Timezone-Datenbank
      // initializeTimeZones() lädt die Datenbank aus dem Package
      tz.initializeTimeZones();
      _initialized = true;
      log('✅ Timezone-Datenbank initialisiert');
    } catch (e) {
      log('❌ Fehler beim Laden der Timezone-Datenbank: $e');
      log('   Versuche manuelle Initialisierung...');
      // Fallback ohne Fehler
      _initialized = false;
    }
  }

  /// Konvertiert lokale Geburtszeit in UTC
  ///
  /// Parameter:
  /// - [localDateTime]: Geburtsdatum + Zeit als lokale Zeit
  /// - [timezoneId]: IANA Timezone ID (z.B. "Europe/Berlin", "America/New_York")
  ///
  /// Gibt UTC-DateTime zurück, das für astronomische Berechnungen genutzt wird.
  ///
  /// Beispiel:
  /// ```dart
  /// // 30.11.1983 22:32 in Friedrichshafen (MEZ = UTC+1 Winter)
  /// final localTime = DateTime(1983, 11, 30, 22, 32);
  /// final utcTime = TimezoneConverter.toUTC(
  ///   localDateTime: localTime,
  ///   timezoneId: 'Europe/Berlin',
  /// );
  /// // Ergebnis: 1983-11-30 21:32:00.000Z (UTC)
  /// ```
  static DateTime toUTC({
    required DateTime localDateTime,
    required String timezoneId,
  }) {
    if (!_initialized) {
      throw StateError(
        'Timezone-Datenbank nicht initialisiert! '
        'Rufe TimezoneConverter.initialize() beim App-Start auf.',
      );
    }

    try {
      // Lade Location (Timezone) aus Datenbank
      final location = tz.getLocation(timezoneId);

      // Erstelle TZDateTime mit lokaler Zeit in dieser Timezone
      final tzDateTime = tz.TZDateTime(
        location,
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
        localDateTime.hour,
        localDateTime.minute,
        localDateTime.second,
        localDateTime.millisecond,
        localDateTime.microsecond,
      );

      // Konvertiere zu UTC
      final utcDateTime = tzDateTime.toUtc();

      log('🌍 Timezone-Konvertierung:');
      log('   Input: ${localDateTime.toIso8601String()} ($timezoneId)');
      log('   UTC:   ${utcDateTime.toIso8601String()}');
      log('   Offset: ${tzDateTime.timeZoneOffset.inHours}h ${tzDateTime.timeZoneOffset.inMinutes % 60}m');

      return utcDateTime;
    } catch (e) {
      log('❌ Fehler bei Timezone-Konvertierung: $e');
      log('   Timezone: $timezoneId');
      log('   DateTime: ${localDateTime.toIso8601String()}');

      // Fallback: Wenn Timezone unbekannt, nutze direkt die Zeit
      // (Besser als App-Crash, aber nicht ideal)
      log('⚠️  Fallback: Nutze lokale Zeit ohne Konvertierung');
      return localDateTime;
    }
  }

  /// Prüft, ob eine Timezone-ID gültig ist
  ///
  /// Nützlich für Validierung im Onboarding.
  static bool isValidTimezone(String timezoneId) {
    if (!_initialized) return false;

    try {
      tz.getLocation(timezoneId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gibt alle verfügbaren Timezone-IDs zurück
  ///
  /// Für Debugging und Testing.
  static List<String> getAllTimezones() {
    if (!_initialized) return [];

    return tz.timeZoneDatabase.locations.keys.toList()..sort();
  }

  /// Findet Timezone-IDs für eine Region
  ///
  /// Beispiel: getTimezonesForRegion('Europe') → ['Europe/Berlin', 'Europe/Paris', ...]
  static List<String> getTimezonesForRegion(String region) {
    if (!_initialized) return [];

    return tz.timeZoneDatabase.locations.keys
        .where((id) => id.startsWith('$region/'))
        .toList()
      ..sort();
  }
}
