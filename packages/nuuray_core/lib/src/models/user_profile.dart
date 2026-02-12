import 'package:equatable/equatable.dart';

/// User-Profil — Shared über alle drei Apps.
///
/// Enthält alle Geburtsdaten und Metadaten für die Chart-Berechnungen.
/// Synchronisiert mit der Supabase `profiles` Tabelle.
class UserProfile extends Equatable {
  // === CORE IDENTITY ===
  final String id; // User ID (von Supabase Auth)

  // === NAME FIELDS ===
  /// Rufname / Display Name (Pflichtfeld)
  /// z.B. "Natalie" - Wie der User angesprochen werden möchte
  final String displayName;

  /// Vollständiger Vorname lt. Geburtsurkunde (optional)
  /// z.B. "Natalie Frauke" - Für Numerologie Birth Energy
  final String? fullFirstNames;

  /// Nachname aktuell (optional)
  /// z.B. "Günes" - Für Numerologie Current Energy
  final String? lastName;

  /// Geburtsname / Maiden Name (optional)
  /// z.B. "Schmidt" - Für Numerologie (falls anders als lastName)
  final String? birthName;

  // === GENDER ===
  /// Geschlechtsidentität für personalisierte Content-Generierung
  /// Werte: 'female', 'male', 'diverse', 'prefer_not_to_say'
  final String? gender;

  // === BIRTH DATA ===
  /// Geburtsdatum (Pflichtfeld nach Onboarding)
  final DateTime? birthDate;

  /// Geburtszeit (optional, aber wichtig für genaue Berechnungen)
  /// Wird als DateTime gespeichert mit Dummy-Datum (2000-01-01)
  final DateTime? birthTime;

  /// Flag: Hat der User eine Geburtszeit angegeben?
  final bool hasBirthTime;

  // === BIRTH LOCATION ===
  /// Geburtsort als Text (z.B. "München, Deutschland")
  final String? birthCity;

  /// Geburtsort GPS Koordinaten (für präzise Astrologie-Berechnungen)
  final double? birthLatitude;
  final double? birthLongitude;

  /// Timezone des Geburtsortes (z.B. "Europe/Berlin")
  /// Wichtig für UTC-Konvertierung bei historischen Geburtsdaten
  final String? birthTimezone;

  // === LEGACY FIELDS (Deprecated) ===
  /// @deprecated Use birthLatitude instead
  final double? birthLat;

  /// @deprecated Use birthLongitude instead
  final double? birthLng;

  // === SETTINGS ===
  /// Sprache (ISO 639-1: "de" oder "en")
  final String language;

  /// User-Timezone (für aktuelle Zeit-Berechnungen)
  final String timezone;

  // === ARCHETYP-SYSTEM ===
  /// Archetyp-Signatur-Satz (Claude API generiert, gecacht)
  ///
  /// Einmalig beim Onboarding generiert. Verwebt alle drei Systeme
  /// (Western, Bazi, Numerologie) zu einer persönlichen Erzählung.
  ///
  /// Beispiel: "In dir verbindet sich die präzise Kraft des Metalls
  ///            mit einer Intuition, die andere erst in Jahren entwickeln..."
  ///
  /// Kann null sein wenn:
  /// - Noch nicht generiert (z.B. API-Fehler beim Onboarding)
  /// - User hat Onboarding vor Archetyp-System abgeschlossen
  final String? signatureText;

  // === METADATA ===
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Onboarding abgeschlossen?
  final bool onboardingCompleted;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.fullFirstNames,
    this.lastName,
    this.birthName,
    this.gender,
    this.birthDate,
    this.birthTime,
    this.hasBirthTime = false,
    this.birthCity,
    this.birthLatitude,
    this.birthLongitude,
    this.birthTimezone,
    this.birthLat, // deprecated
    this.birthLng, // deprecated
    this.language = 'de',
    this.timezone = 'Europe/Berlin',
    this.signatureText,
    required this.createdAt,
    this.updatedAt,
    this.onboardingCompleted = false,
  });

  /// Prüft ob das Onboarding abgeschlossen ist (Geburtsdatum gesetzt).
  bool get isOnboardingComplete => birthDate != null && onboardingCompleted;

  /// Prüft ob alle Daten für präzise Berechnungen vorhanden sind
  bool get hasCompleteBirthData =>
      birthDate != null &&
      hasBirthTime &&
      birthTime != null &&
      birthLatitude != null &&
      birthLongitude != null &&
      birthTimezone != null;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String? ?? 'Nutzerin',
      fullFirstNames: json['full_first_names'] as String?,
      lastName: json['last_name'] as String?,
      birthName: json['birth_name'] as String?,
      gender: json['gender'] as String?,
      birthDate: _parseDateTimeSafe(json['birth_date']),
      birthTime: _parseBirthTime(json['birth_time']),
      hasBirthTime: json['has_birth_time'] as bool? ?? false,
      birthCity: json['birth_city'] as String? ?? json['birth_place'] as String?,
      birthLatitude: (json['birth_latitude'] as num?)?.toDouble(),
      birthLongitude: (json['birth_longitude'] as num?)?.toDouble(),
      birthTimezone: json['birth_timezone'] as String?,
      // Legacy fields (fallback)
      birthLat: (json['birth_lat'] as num?)?.toDouble(),
      birthLng: (json['birth_lng'] as num?)?.toDouble(),
      language: json['language'] as String? ?? 'de',
      timezone: json['timezone'] as String? ?? json['birth_timezone'] as String? ?? 'Europe/Berlin',
      signatureText: json['signature_text'] as String?,
      createdAt: _parseDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTimeSafe(json['updated_at']),
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
    );
  }

  /// Sicheres DateTime-Parsing (Web-kompatibel)
  static DateTime? _parseDateTimeSafe(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value as String);
    } catch (e) {
      // Fehler beim Parsing - returniere null statt zu crashen
      return null;
    }
  }

  /// Sicheres Parsing von Zeitstrings (HH:MM:SS Format aus DB)
  static DateTime? _parseBirthTime(dynamic value) {
    if (value == null) return null;
    try {
      final timeStr = value as String;
      // Supabase gibt Zeit als "HH:MM:SS" zurück
      // Wir parsen die Komponenten manuell statt String-Concatenation
      final parts = timeStr.split(':');
      if (parts.isEmpty) return null;

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

      return DateTime(2000, 1, 1, hour, minute);
    } catch (e) {
      // Fehler beim Parsing - returniere null statt zu crashen
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'full_first_names': fullFirstNames,
    'last_name': lastName,
    'birth_name': birthName,
    'gender': gender,
    'birth_date': birthDate?.toIso8601String().split('T').first,
    'birth_time': birthTime != null
        ? '${birthTime!.hour.toString().padLeft(2, '0')}:${birthTime!.minute.toString().padLeft(2, '0')}'
        : null,
    'has_birth_time': hasBirthTime,
    'birth_place': birthCity, // DB-Spalte heißt birth_place (siehe Migration 003)
    'birth_latitude': birthLatitude,
    'birth_longitude': birthLongitude,
    'birth_timezone': birthTimezone,
    'language': language,
    'timezone': timezone,
    'signature_text': signatureText,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'onboarding_completed': onboardingCompleted,
  };

  @override
  List<Object?> get props => [
    id,
    displayName,
    fullFirstNames,
    lastName,
    birthName,
    gender,
    birthDate,
    birthTime,
    hasBirthTime,
    birthLatitude,
    birthLongitude,
    birthTimezone,
    language,
    signatureText,
    onboardingCompleted,
  ];

  /// CopyWith für Updates
  UserProfile copyWith({
    String? id,
    String? displayName,
    String? fullFirstNames,
    String? lastName,
    String? birthName,
    String? gender,
    DateTime? birthDate,
    DateTime? birthTime,
    bool? hasBirthTime,
    String? birthCity,
    double? birthLatitude,
    double? birthLongitude,
    String? birthTimezone,
    String? language,
    String? timezone,
    String? signatureText,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      fullFirstNames: fullFirstNames ?? this.fullFirstNames,
      lastName: lastName ?? this.lastName,
      birthName: birthName ?? this.birthName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      hasBirthTime: hasBirthTime ?? this.hasBirthTime,
      birthCity: birthCity ?? this.birthCity,
      birthLatitude: birthLatitude ?? this.birthLatitude,
      birthLongitude: birthLongitude ?? this.birthLongitude,
      birthTimezone: birthTimezone ?? this.birthTimezone,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      signatureText: signatureText ?? this.signatureText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
