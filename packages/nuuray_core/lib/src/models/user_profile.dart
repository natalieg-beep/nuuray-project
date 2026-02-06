import 'package:equatable/equatable.dart';

/// User-Profil — Shared über alle drei Apps.
class UserProfile extends Equatable {
  final String id;
  final String? displayName;
  final DateTime? birthDate;
  final DateTime? birthTime;
  final String? birthCity;
  final double? birthLat;
  final double? birthLng;
  final String language;
  final String timezone;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    this.displayName,
    this.birthDate,
    this.birthTime,
    this.birthCity,
    this.birthLat,
    this.birthLng,
    this.language = 'de',
    this.timezone = 'Europe/Berlin',
    required this.createdAt,
  });

  /// Prüft ob das Onboarding abgeschlossen ist (Geburtsdatum gesetzt).
  bool get isOnboardingComplete => birthDate != null;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date'] as String) : null,
      birthTime: json['birth_time'] != null ? DateTime.parse('2000-01-01 ${json['birth_time']}') : null,
      birthCity: json['birth_city'] as String?,
      birthLat: (json['birth_lat'] as num?)?.toDouble(),
      birthLng: (json['birth_lng'] as num?)?.toDouble(),
      language: json['language'] as String? ?? 'de',
      timezone: json['timezone'] as String? ?? 'Europe/Berlin',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'birth_date': birthDate?.toIso8601String().split('T').first,
    'birth_city': birthCity,
    'birth_lat': birthLat,
    'birth_lng': birthLng,
    'language': language,
    'timezone': timezone,
  };

  @override
  List<Object?> get props => [id, birthDate, language];
}
