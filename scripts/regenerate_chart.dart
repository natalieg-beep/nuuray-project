// Script: Chart manuell neu berechnen
// Verwendung: dart run scripts/regenerate_chart.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Add path dependencies manually since this is a script
import '../packages/nuuray_core/lib/nuuray_core.dart';
import '../packages/nuuray_api/lib/src/supabase_client.dart' as nuuray_supabase;

void main() async {
  print('🔧 Chart Regeneration Script');
  print('═══════════════════════════════════════');

  // 1. Load .env
  print('📦 Loading .env...');
  await dotenv.load(fileName: '../apps/glow/.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    print('❌ SUPABASE_URL oder SUPABASE_ANON_KEY fehlt in .env');
    exit(1);
  }

  // 2. Initialize Supabase
  print('🔌 Initializing Supabase...');
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final supabase = Supabase.instance.client;

  // 3. Get user profile
  print('👤 Loading profile...');
  final userId = '584f27d2-09a2-47e6-8f70-c0f3a015b1b6'; // Deine User-ID

  final profileResponse = await supabase
      .from('profiles')
      .select()
      .eq('id', userId)
      .single();

  final profile = UserProfile.fromJson(profileResponse);
  print('✅ Profil geladen: ${profile.displayName}');
  print('   Geburtsdatum: ${profile.birthDate}');
  print('   Geburtszeit: ${profile.birthTime}');
  print('   Geburtsort: ${profile.birthCity}');

  // 4. Calculate chart
  print('\n🧮 Berechne Birth Chart...');
  final signatureService = SignatureService();
  final chart = await signatureService.calculateChart(profile);

  print('✅ Chart berechnet!');
  print('   Sonnenzeichen: ${chart.sunSign}');
  print('   Mondzeichen: ${chart.moonSign}');
  print('   Aszendent: ${chart.ascendantSign}');
  print('   Bazi Element: ${chart.baziElement}');
  print('   Life Path: ${chart.lifePathNumber}');

  // 5. Save to database
  print('\n💾 Speichere Chart in Datenbank...');

  // Delete old chart if exists
  await supabase
      .from('birth_charts')
      .delete()
      .eq('user_id', userId);

  // Insert new chart
  final chartJson = chart.toJson();
  chartJson['user_id'] = userId;

  await supabase
      .from('birth_charts')
      .insert(chartJson);

  print('✅ Chart gespeichert!');
  print('\n═══════════════════════════════════════');
  print('🎉 Fertig! Chart wurde neu berechnet.');
  print('   → App neu starten: Hot Reload mit "r"');
}
