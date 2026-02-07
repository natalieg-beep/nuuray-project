import 'dart:io';
import 'package:nuuray_glow/src/core/services/claude_api_service.dart';

/// Test-Script für Claude API Integration
///
/// WICHTIG: Vor dem Ausführen API Key in .env setzen:
/// ANTHROPIC_API_KEY=sk-ant-...
///
/// Run: dart test/test_claude_api.dart
void main() async {
  print('🧪 Testing Claude API Service...\n');

  // 1. API Key aus Environment laden
  final apiKey = Platform.environment['ANTHROPIC_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    print('❌ FEHLER: ANTHROPIC_API_KEY nicht gesetzt!');
    print('   Setze in .env: ANTHROPIC_API_KEY=sk-ant-...');
    exit(1);
  }

  // 2. Service initialisieren
  final claudeService = ClaudeApiService(
    apiKey: apiKey,
    model: 'claude-sonnet-4-20250514',
  );

  print('✅ Service initialisiert\n');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // 3. Test: Tageshoroskop für Krebs generieren
  print('🔮 Test 1: Tageshoroskop für Krebs (Deutsch)\n');

  try {
    final startTime = DateTime.now();

    final response = await claudeService.generateDailyHoroscope(
      zodiacSign: 'cancer',
      language: 'de',
      moonPhase: 'waxing_moon',
      date: DateTime.now(),
    );

    final duration = DateTime.now().difference(startTime);

    print('✅ Horoskop generiert!\n');
    print('📝 INHALT:');
    print('───────────────────────────────────────────────────────');
    print(response.text);
    print('───────────────────────────────────────────────────────\n');

    print('📊 METADATEN:');
    print('   Model: ${response.model}');
    print('   Input Tokens: ${response.inputTokens}');
    print('   Output Tokens: ${response.outputTokens}');
    print('   Total Tokens: ${response.totalTokens}');
    print('   Kosten: \$${response.estimatedCost.toStringAsFixed(4)}');
    print('   Dauer: ${duration.inMilliseconds}ms\n');

    // 4. Validierung
    final wordCount = response.text.split(' ').length;
    print('✅ Länge: $wordCount Wörter (Ziel: 80-120)');

    if (wordCount < 80 || wordCount > 120) {
      print('⚠️  WARNUNG: Länge außerhalb des Zielbereichs!');
    }
  } catch (e, stackTrace) {
    print('❌ FEHLER bei Horoskop-Generierung:');
    print('   $e');
    print('\n🔍 Stack Trace:');
    print(stackTrace);
    exit(1);
  }

  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // 5. Test: Cosmic Profile Interpretation
  print('🌟 Test 2: Cosmic Profile Interpretation (Deutsch)\n');

  try {
    final startTime = DateTime.now();

    final response = await claudeService.generateCosmicProfileInterpretation(
      sunSign: 'Cancer',
      moonSign: 'Leo',
      ascendant: 'Cancer',
      baziDayMaster: '丙火 Yang Fire',
      lifePathNumber: 9,
      language: 'de',
    );

    final duration = DateTime.now().difference(startTime);

    print('✅ Interpretation generiert!\n');
    print('📝 INHALT:');
    print('───────────────────────────────────────────────────────');
    print(response.text);
    print('───────────────────────────────────────────────────────\n');

    print('📊 METADATEN:');
    print('   Model: ${response.model}');
    print('   Input Tokens: ${response.inputTokens}');
    print('   Output Tokens: ${response.outputTokens}');
    print('   Total Tokens: ${response.totalTokens}');
    print('   Kosten: \$${response.estimatedCost.toStringAsFixed(4)}');
    print('   Dauer: ${duration.inMilliseconds}ms\n');

    // Validierung
    final wordCount = response.text.split(' ').length;
    print('✅ Länge: $wordCount Wörter (Ziel: 400-500)');

    if (wordCount < 400 || wordCount > 500) {
      print('⚠️  WARNUNG: Länge außerhalb des Zielbereichs!');
    }
  } catch (e, stackTrace) {
    print('❌ FEHLER bei Profile-Generierung:');
    print('   $e');
    print('\n🔍 Stack Trace:');
    print(stackTrace);
    exit(1);
  }

  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  print('🎉 Alle Tests erfolgreich!\n');
}
