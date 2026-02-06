import 'package:flutter/material.dart';

/// User-Profil mit Geburtsdaten für Chart-Berechnung
class UserProfile {
  final String id; // User ID (von Supabase Auth)

  // Name-Felder
  final String displayName; // Rufname (Pflichtfeld)
  final String? fullFirstNames; // Vornamen lt. Geburtsurkunde (optional)
  final String? lastName; // Nachname (optional)
  final String? birthName; // Geburtsname (optional)

  // Geburtsdaten
  final DateTime birthDate;
  final TimeOfDay? birthTime; // Optional, aber wichtig für genaue Berechnungen
  final bool hasBirthTime; // Flag ob Geburtszeit bekannt ist

  // Geburtsort
  final String? birthPlace; // Ortsname (z.B. "München, Deutschland")
  final double? birthLatitude; // GPS Koordinaten
  final double? birthLongitude;
  final String? birthTimezone; // z.B. "Europe/Berlin"

  // Metadaten
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool onboardingCompleted;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.fullFirstNames,
    this.lastName,
    this.birthName,
    required this.birthDate,
    this.birthTime,
    this.hasBirthTime = false,
    this.birthPlace,
    this.birthLatitude,
    this.birthLongitude,
    this.birthTimezone,
    required this.createdAt,
    this.updatedAt,
    this.onboardingCompleted = false,
  });

  /// Prüft ob alle wichtigen Daten für genaue Berechnungen vorhanden sind
  bool get hasCompleteBirthData =>
      hasBirthTime &&
      birthLatitude != null &&
      birthLongitude != null &&
      birthTimezone != null;

  /// Prüft ob mindestens Basisdaten vorhanden sind
  bool get hasMinimalBirthData => true; // birthDate ist required

  /// Copy-with-Methode für Updates
  UserProfile copyWith({
    String? displayName,
    String? fullFirstNames,
    String? lastName,
    String? birthName,
    DateTime? birthDate,
    TimeOfDay? birthTime,
    bool? hasBirthTime,
    String? birthPlace,
    double? birthLatitude,
    double? birthLongitude,
    String? birthTimezone,
    DateTime? updatedAt,
    bool? onboardingCompleted,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      fullFirstNames: fullFirstNames ?? this.fullFirstNames,
      lastName: lastName ?? this.lastName,
      birthName: birthName ?? this.birthName,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      hasBirthTime: hasBirthTime ?? this.hasBirthTime,
      birthPlace: birthPlace ?? this.birthPlace,
      birthLatitude: birthLatitude ?? this.birthLatitude,
      birthLongitude: birthLongitude ?? this.birthLongitude,
      birthTimezone: birthTimezone ?? this.birthTimezone,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  /// Von JSON (Supabase) zu Model
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // birth_date kann null sein, wenn Profil durch Auth-Trigger erstellt wurde
    final birthDateStr = json['birth_date'] as String?;

    return UserProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String? ?? 'Nutzerin',
      fullFirstNames: json['full_first_names'] as String?,
      lastName: json['last_name'] as String?,
      birthName: json['birth_name'] as String?,
      birthDate: birthDateStr != null
          ? DateTime.parse(birthDateStr)
          : DateTime.now(), // Fallback (sollte nie passieren nach Onboarding)
      birthTime: json['birth_time'] != null
          ? _parseTimeOfDay(json['birth_time'] as String)
          : null,
      hasBirthTime: json['has_birth_time'] as bool? ?? false,
      birthPlace: json['birth_place'] as String?,
      birthLatitude: json['birth_latitude'] as double?,
      birthLongitude: json['birth_longitude'] as double?,
      birthTimezone: json['birth_timezone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
    );
  }

  /// Von Model zu JSON (Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'full_first_names': fullFirstNames,
      'last_name': lastName,
      'birth_name': birthName,
      'birth_date': birthDate.toIso8601String(),
      'birth_time': birthTime != null ? _formatTimeOfDay(birthTime!) : null,
      'has_birth_time': hasBirthTime,
      'birth_place': birthPlace,
      'birth_latitude': birthLatitude,
      'birth_longitude': birthLongitude,
      'birth_timezone': birthTimezone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'onboarding_completed': onboardingCompleted,
    };
  }

  /// Helper: TimeOfDay zu String (HH:mm)
  static String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Helper: String (HH:mm) zu TimeOfDay
  static TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
