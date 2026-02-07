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
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      birthTime: json['birth_time'] != null
          ? DateTime.parse('2000-01-01 ${json['birth_time']}')
          : null,
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
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'full_first_names': fullFirstNames,
    'last_name': lastName,
    'birth_name': birthName,
    'birth_date': birthDate?.toIso8601String().split('T').first,
    'birth_time': birthTime != null
        ? '${birthTime!.hour.toString().padLeft(2, '0')}:${birthTime!.minute.toString().padLeft(2, '0')}'
        : null,
    'has_birth_time': hasBirthTime,
    'birth_city': birthCity,
    'birth_place': birthCity, // Alias für Kompatibilität
    'birth_latitude': birthLatitude,
    'birth_longitude': birthLongitude,
    'birth_timezone': birthTimezone,
    'language': language,
    'timezone': timezone,
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
    birthDate,
    birthTime,
    hasBirthTime,
    birthLatitude,
    birthLongitude,
    birthTimezone,
    language,
    onboardingCompleted,
  ];
}
