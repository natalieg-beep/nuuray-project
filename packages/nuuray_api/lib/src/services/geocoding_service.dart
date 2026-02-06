import 'package:supabase_flutter/supabase_flutter.dart';

/// Service für Geocoding via Supabase Edge Function.
///
/// Nutzt Google Places API server-seitig über Edge Function,
/// um Ortsnamen in Koordinaten + Timezone zu konvertieren.
class GeocodingService {
  final SupabaseClient _supabase;

  GeocodingService(this._supabase);

  /// Geocode einen Ortsnamen zu Koordinaten + Timezone.
  ///
  /// Returns: Map mit 'place', 'latitude', 'longitude', 'timezone'
  /// oder null bei Fehler.
  Future<GeocodingResult?> geocodePlace(String query) async {
    try {
      final response = await _supabase.functions.invoke(
        'geocode-place',
        body: {'query': query},
      );

      if (response.status != 200) {
        print('Geocoding Fehler: Status ${response.status}');
        return null;
      }

      final data = response.data as Map<String, dynamic>;

      return GeocodingResult(
        place: data['place'] as String,
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
        timezone: data['timezone'] as String,
      );
    } catch (e) {
      print('Geocoding Exception: $e');
      return null;
    }
  }

  /// Autocomplete für Ortssuche (vereinfacht - nutzt direkt geocodePlace).
  ///
  /// Für eine vollständige Autocomplete-Lösung müsste die Edge Function
  /// erweitert werden, um nur Vorschläge zu liefern (ohne Details).
  Future<List<String>> searchPlaces(String query) async {
    if (query.isEmpty || query.length < 3) {
      return [];
    }

    // Für MVP: Gibt nur den eingegeben Text zurück als Vorschlag
    // TODO: Edge Function erweitern für echte Autocomplete-Liste
    return [query];
  }
}

/// Ergebnis eines Geocoding-Requests.
class GeocodingResult {
  final String place; // Formatierte Adresse
  final double latitude;
  final double longitude;
  final String timezone;

  const GeocodingResult({
    required this.place,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  @override
  String toString() {
    return 'GeocodingResult(place: $place, lat: $latitude, lng: $longitude, tz: $timezone)';
  }
}
