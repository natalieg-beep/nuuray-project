import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Schneller Test: Prüft ob daily_horoscopes Tabelle existiert
///
/// Run: dart test/test_daily_horoscopes_table.dart
void main() async {
  print('🔍 Prüfe ob daily_horoscopes Tabelle existiert...\n');

  // 1. Lade .env
  await dotenv.load(fileName: '.env');

  // 2. Supabase initialisieren
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final supabase = Supabase.instance.client;

  try {
    // 3. Versuche Tabelle abzufragen
    final result = await supabase.from('daily_horoscopes').select().limit(1);

    print('✅ SUCCESS: Tabelle daily_horoscopes existiert!\n');
    print('📊 Gefundene Einträge: ${result.length}');

    if (result.isNotEmpty) {
      print('📝 Beispiel-Eintrag:');
      print('   - Date: ${result[0]['date']}');
      print('   - Zodiac: ${result[0]['zodiac_sign']}');
      print('   - Language: ${result[0]['language']}');
      print('   - Content: ${result[0]['content_text'].toString().substring(0, 50)}...');
    } else {
      print('ℹ️  Tabelle ist leer (noch keine Horoskope generiert)');
    }
  } catch (e) {
    print('❌ ERROR: Tabelle existiert NICHT!');
    print('   $e\n');
    print('👉 Migration muss noch deployed werden:');
    print('   1. Gehe zu: https://supabase.com/dashboard/project/ykkayjbplutdodummcte/sql');
    print('   2. Öffne SQL-Editor');
    print('   3. Kopiere Inhalt von: supabase/migrations/20260207_add_daily_horoscopes.sql');
    print('   4. Führe aus (Run Button)');
  }
}
