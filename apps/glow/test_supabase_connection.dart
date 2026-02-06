import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Einfaches Test-Script um Supabase-Verbindung zu testen
Future<void> main() async {
  // .env laden
  await dotenv.load(fileName: 'apps/glow/.env');

  final url = dotenv.get('SUPABASE_URL', fallback: '');
  final anonKey = dotenv.get('SUPABASE_ANON_KEY', fallback: '');

  print('🔍 Teste Supabase-Verbindung...\n');
  print('URL: $url');
  print('Anon Key: ${anonKey.substring(0, 20)}...\n');

  if (url.isEmpty || anonKey.isEmpty) {
    print('❌ FEHLER: URL oder Anon Key fehlen in .env');
    return;
  }

  // Supabase initialisieren
  try {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    print('✅ Supabase initialisiert\n');
  } catch (e) {
    print('❌ Fehler bei Supabase-Initialisierung: $e');
    return;
  }

  final supabase = Supabase.instance.client;

  // Test 1: Login mit Test-User
  print('🔐 Teste Login mit natalie.guenes.tr@gmail.com...');
  try {
    final response = await supabase.auth.signInWithPassword(
      email: 'natalie.guenes.tr@gmail.com',
      password: 'test123',
    );

    if (response.user != null) {
      print('✅ Login erfolgreich!');
      print('   User ID: ${response.user!.id}');
      print('   Email: ${response.user!.email}');
      print('   Email bestätigt: ${response.user!.emailConfirmedAt != null}');
    } else {
      print('❌ Login fehlgeschlagen: Kein User zurückgegeben');
    }
  } catch (e) {
    print('❌ Login-Fehler: $e');
  }

  // Test 2: Aktuellen User abrufen
  print('\n👤 Teste aktuellen User...');
  final currentUser = supabase.auth.currentUser;
  if (currentUser != null) {
    print('✅ Aktueller User: ${currentUser.email}');
  } else {
    print('❌ Kein User eingeloggt');
  }

  // Test 3: User-Profil aus Datenbank laden
  print('\n📊 Teste User-Profil-Tabelle...');
  try {
    final userId = currentUser?.id;
    if (userId != null) {
      final profile = await supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) {
        print('✅ Profil gefunden: ${profile['display_name']}');
      } else {
        print('ℹ️  Kein Profil gefunden (normal nach frischer Registrierung)');
      }
    }
  } catch (e) {
    print('❌ Fehler beim Profil-Laden: $e');
  }

  print('\n✅ Test abgeschlossen!');
}
