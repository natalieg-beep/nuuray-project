import 'package:supabase_flutter/supabase_flutter.dart';

/// Content Library Service
///
/// Lädt statische Freemium-Beschreibungen aus der Supabase `content_library` Tabelle.
/// Nutzt In-Memory-Cache für Performance.
class ContentLibraryService {
  ContentLibraryService({
    required SupabaseClient supabaseClient,
  }) : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  // In-Memory Cache für häufig genutzte Beschreibungen
  final Map<String, String> _cache = {};

  /// Lädt eine Beschreibung aus der Content Library
  ///
  /// [category]: z.B. 'sun_sign', 'moon_sign', 'bazi_day_master', 'life_path_number'
  /// [key]: z.B. 'aries', 'yang_wood_rat', '11'
  /// [locale]: 'de' oder 'en'
  ///
  /// Returns: Beschreibungs-Text oder null wenn nicht gefunden
  Future<String?> getDescription({
    required String category,
    required String key,
    required String locale,
  }) async {
    // Cache-Key generieren
    final cacheKey = '$category:$key:$locale';

    // Cache-Lookup
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      // Supabase Query
      final response = await _supabase
          .from('content_library')
          .select('description')
          .eq('category', category)
          .eq('key', key)
          .eq('locale', locale)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final description = response['description'] as String?;

      // Cache speichern
      if (description != null) {
        _cache[cacheKey] = description;
      }

      return description;
    } catch (e) {
      // Fehler loggen (in Produktion: Logger nutzen)
      print('ContentLibraryService.getDescription Error: $e');
      return null;
    }
  }

  /// Lädt Titel + Beschreibung
  Future<ContentLibraryEntry?> getEntry({
    required String category,
    required String key,
    required String locale,
  }) async {
    try {
      final response = await _supabase
          .from('content_library')
          .select('title, description')
          .eq('category', category)
          .eq('key', key)
          .eq('locale', locale)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ContentLibraryEntry(
        title: response['title'] as String,
        description: response['description'] as String,
      );
    } catch (e) {
      print('ContentLibraryService.getEntry Error: $e');
      return null;
    }
  }

  /// Cache leeren (z.B. nach Sprach-Wechsel)
  void clearCache() {
    _cache.clear();
  }

  /// Cache-Statistik (für Debugging)
  int get cacheSize => _cache.length;
}

/// Content Library Entry Model
class ContentLibraryEntry {
  const ContentLibraryEntry({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}
