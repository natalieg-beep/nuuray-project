import 'dart:developer';

/// Timezone Converter (Simplified)
///
/// Berechnet UTC-Offset für historische Geburtsdaten basierend auf bekannten Regeln.
///
/// Phase 1 (MVP): Einfache Implementierung für häufigste Fälle
/// Phase 2 (Production): Google Time Zone API Integration
class TimezoneConverterSimple {
  /// Konvertiert lokale Zeit in UTC basierend auf historischen Timezone-Regeln
  ///
  /// Unterstützt aktuell nur Europe/Berlin (Deutschland, Österreich, Schweiz westl.)
  /// Für andere Timezones: Fallback auf Standard-Offset ohne Sommerzeit.
  static DateTime toUTC({
    required DateTime localDateTime,
    required String timezoneId,
  }) {
    // Europe/Berlin: Historische Sommerzeit-Regeln
    if (timezoneId == 'Europe/Berlin' ||
        timezoneId == 'Europe/Vienna' ||
        timezoneId == 'Europe/Zurich') {
      return _convertEuropeBerlin(localDateTime);
    }

    // Fallback: Nutze Standard-Offsets (ohne Sommerzeit-Berechnung)
    final offset = _getStandardOffset(timezoneId);
    final utcDateTime = localDateTime.subtract(Duration(hours: offset));

    log('⚠️  Timezone-Fallback: $timezoneId → UTC-${offset}h');
    log('   ${localDateTime.toIso8601String()} → ${utcDateTime.toIso8601String()}');

    return utcDateTime;
  }

  /// Konvertiert Europe/Berlin Zeit in UTC mit historisch korrekter Sommerzeit
  ///
  /// Sommerzeit-Regeln in Deutschland:
  /// - Vor 1980: Verschiedene Regeln
  /// - 1980-1995: Letzter Sonntag März/September
  /// - 1996-heute: Letzter Sonntag März/Oktober
  ///
  /// MEZ (Normalzeit): UTC+1
  /// MESZ (Sommerzeit): UTC+2
  static DateTime _convertEuropeBerlin(DateTime localDateTime) {
    final year = localDateTime.year;
    final month = localDateTime.month;
    final day = localDateTime.day;

    // Prüfe ob Sommerzeit gilt
    bool isDST = false;

    if (year >= 1980) {
      // Nach 1980: Standardregeln
      final dstStart = _getLastSundayOfMonth(year, 3); // März
      final dstEnd = year >= 1996
          ? _getLastSundayOfMonth(year, 10) // Oktober (seit 1996)
          : _getLastSundayOfMonth(year, 9); // September (1980-1995)

      // Prüfe ob Datum in Sommerzeit-Periode liegt
      final dateOnly = DateTime(year, month, day);
      isDST = dateOnly.isAfter(dstStart) && dateOnly.isBefore(dstEnd);

      // Spezialfall: Am Wechseltag selbst (02:00/03:00 Uhr)
      if (dateOnly.isAtSameMomentAs(dstStart)) {
        isDST = localDateTime.hour >= 2; // Ab 02:00 → 03:00 ist Sommerzeit
      } else if (dateOnly.isAtSameMomentAs(dstEnd)) {
        isDST = localDateTime.hour < 3; // Bis 03:00 → 02:00 ist noch Sommerzeit
      }
    }

    // Offset berechnen
    final offsetHours = isDST ? 2 : 1; // MESZ: UTC+2, MEZ: UTC+1
    final utcDateTime = localDateTime.subtract(Duration(hours: offsetHours));

    log('🌍 Europe/Berlin → UTC:');
    log('   Lokal: ${localDateTime.toIso8601String()}');
    log('   UTC:   ${utcDateTime.toIso8601String()}');
    log('   Offset: UTC+$offsetHours (${isDST ? "MESZ" : "MEZ"})');

    return utcDateTime;
  }

  /// Findet den letzten Sonntag eines Monats
  static DateTime _getLastSundayOfMonth(int year, int month) {
    // Letzter Tag des Monats
    final lastDay = DateTime(year, month + 1, 0);

    // Gehe rückwärts bis Sonntag (weekday == 7)
    var day = lastDay;
    while (day.weekday != DateTime.sunday) {
      day = day.subtract(const Duration(days: 1));
    }

    return day;
  }

  /// Standard-Offset für häufige Timezones (ohne Sommerzeit)
  static int _getStandardOffset(String timezoneId) {
    // Wichtigste Timezones mit Standard-Offset
    const offsets = {
      'Europe/London': 0, // GMT/BST
      'Europe/Paris': 1, // CET/CEST
      'Europe/Berlin': 1, // CET/CEST
      'Europe/Vienna': 1,
      'Europe/Zurich': 1,
      'Europe/Rome': 1,
      'Europe/Madrid': 1,
      'Europe/Athens': 2, // EET/EEST
      'Europe/Istanbul': 3, // TRT (seit 2016 keine Sommerzeit)
      'America/New_York': -5, // EST/EDT
      'America/Chicago': -6, // CST/CDT
      'America/Denver': -7, // MST/MDT
      'America/Los_Angeles': -8, // PST/PDT
      'Asia/Tokyo': 9, // JST
      'Asia/Shanghai': 8, // CST
      'Australia/Sydney': 10, // AEST/AEDT
    };

    return offsets[timezoneId] ?? 0; // Fallback: UTC
  }

  /// Prüft ob eine Timezone unterstützt wird
  static bool isSupported(String timezoneId) {
    // Europe/Berlin hat volle Unterstützung
    if (timezoneId == 'Europe/Berlin' ||
        timezoneId == 'Europe/Vienna' ||
        timezoneId == 'Europe/Zurich') {
      return true;
    }

    // Andere Timezones: Fallback verfügbar
    return _getStandardOffset(timezoneId) != 0;
  }
}
