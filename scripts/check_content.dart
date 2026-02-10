import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final supabaseUrl = 'https://ykkayjbplutdodummcte.supabase.co';
  final key = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'] ?? 
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlra2F5amJwbHV0ZG9kdW1tY3RlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MDMxMjg3MiwiZXhwIjoyMDg1ODg4ODcyfQ.3r_n0v-5yWiweUpALI5mJuPM_Td_tBNhuiQ20EqOKOY';

  // Hole ein paar Beispiele
  final response = await http.get(
    Uri.parse('$supabaseUrl/rest/v1/content_library?limit=3'),
    headers: {
      'apikey': key,
      'Authorization': 'Bearer $key',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List;
    print('📚 Beispiel-Texte aus der Content Library:\n');
    for (final item in data) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📌 ${item['category']} → ${item['key']}');
      print('🏷️  Titel: ${item['title']}');
      print('📝 Beschreibung:');
      print('   ${item['description']}');
      print('📊 Wörter: ${(item['description'] as String).split(' ').length}');
      print('');
    }
  } else {
    print('Fehler: ${response.statusCode}');
    print(response.body);
  }
}
