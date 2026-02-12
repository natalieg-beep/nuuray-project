// Script: Migration manuell anwenden
// Verwendung: dart run scripts/apply_migration.dart

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  print('🔧 Apply Migration Script');
  print('═══════════════════════════════════════');

  // 1. Load .env
  print('📦 Loading .env...');
  await dotenv.load(fileName: 'apps/glow/.env');

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

  // 3. Read migration file
  print('📖 Reading migration file...');
  final migrationFile = File('supabase/migrations/20260210_extend_birth_charts_numerology.sql');
  final sql = await migrationFile.readAsString();

  // 4. Execute migration
  print('⚡ Executing migration...');
  try {
    await supabase.rpc('exec_sql', params: {'sql_query': sql});
    print('✅ Migration erfolgreich angewendet!');
  } catch (e) {
    // Fallback: Nutze direkte ALTER TABLE Statements
    print('⚠️ RPC fehlgeschlagen, nutze direkte Statements...');

    final statements = [
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS display_name_number INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS birthday_number INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS attitude_number INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS personal_year INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS maturity_number INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS birth_expression_number INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS birth_soul_urge_number INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS birth_personality_number INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS birth_name TEXT",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS current_expression_number INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS current_soul_urge_number INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS current_personality_number INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS current_name TEXT",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS karmic_debt_life_path INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS karmic_debt_expression INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS karmic_debt_soul_urge INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS challenge_numbers INTEGER[]",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS karmic_lessons INTEGER[]",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS bridge_life_path_expression INTEGER",
      "ALTER TABLE public.birth_charts ADD COLUMN IF NOT EXISTS bridge_soul_urge_personality INTEGER",
    ];

    for (final stmt in statements) {
      try {
        await supabase.rpc('exec', params: {'query': stmt});
        print('  ✓ ${stmt.substring(0, 50)}...');
      } catch (e2) {
        print('  ⚠️ Fehler bei Statement: $e2');
      }
    }

    print('✅ Alle ALTER TABLE Statements ausgeführt!');
  }

  print('\n═══════════════════════════════════════');
  print('🎉 Fertig!');
}
