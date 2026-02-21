import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuuray_core/nuuray_core.dart';
import '../../../core/providers/app_providers.dart';
import '../../profile/providers/user_profile_provider.dart';

/// Löscht den Synthese-Cache für den aktuellen User (nur für Entwicklung/Testing)
///
/// Setzt profiles.deep_synthesis_text auf NULL → nächster Aufruf generiert neu.
Future<void> resetDeepSynthesisCache(WidgetRef ref) async {
  final supabase = ref.read(supabaseClientProvider);
  final profile = ref.read(userProfileProvider).valueOrNull;
  final userId = profile?.id;
  if (userId == null) return;

  await supabase
      .from('profiles')
      .update({'deep_synthesis_text': null})
      .eq('id', userId);

  ref.invalidate(deepSynthesisProvider);
  log('🗑️ [Synthese] Cache gelöscht — wird beim nächsten Aufruf neu generiert');
}

/// Provider für die tiefe Drei-System-Synthese
///
/// Generiert die Synthese via Claude API und cached sie in Supabase.
/// Cache-Reset: resetDeepSynthesisCache(ref) aufrufen.
final deepSynthesisProvider = FutureProvider.family<String, BirthChart>((ref, birthChart) async {
  final supabase = ref.read(supabaseClientProvider);
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final userId = profile?.id;

  if (userId == null) {
    throw Exception('Kein User-Profil vorhanden');
  }

  // 1. Cache-Check: Bereits gespeicherte Synthese laden
  try {
    final cached = await supabase
        .from('profiles')
        .select('deep_synthesis_text')
        .eq('id', userId)
        .maybeSingle();

    if (cached != null) {
      final existingText = cached['deep_synthesis_text'] as String?;
      if (existingText != null && existingText.isNotEmpty) {
        log('✅ [Synthese] Cache Hit — nutze gespeicherte Synthese');
        return existingText;
      }
    }
  } catch (e) {
    log('⚠️ [Synthese] Cache-Check fehlgeschlagen: $e');
    // Weiter mit Generierung
  }

  // 2. Claude API aufrufen
  log('🤖 [Synthese] Generiere tiefe Synthese für User: $userId');

  final claudeService = ref.read(claudeApiServiceProvider);
  if (claudeService == null) {
    throw Exception('Claude API Service nicht verfügbar — API Key fehlt');
  }

  final language = profile?.language ?? 'de';

  final synthesisText = await claudeService.generateDeepSynthesis(
    sunSign: birthChart.sunSign,
    moonSign: birthChart.moonSign,
    ascendantSign: birthChart.ascendantSign,
    baziDayStem: birthChart.baziDayStem,
    baziElement: birthChart.baziElement,
    baziYearStem: birthChart.baziYearStem,
    baziMonthStem: birthChart.baziMonthStem,
    lifePathNumber: birthChart.lifePathNumber,
    birthdayNumber: birthChart.birthdayNumber,
    personalYear: birthChart.personalYear,
    challengeNumbers: birthChart.challengeNumbers,
    karmicDebtLifePath: birthChart.karmicDebtLifePath,
    karmicLessons: birthChart.karmicLessons,
    language: language,
    gender: profile?.gender,
  );

  log('✨ [Synthese] Synthese generiert (${synthesisText.length} Zeichen)');

  // 3. In Datenbank cachen
  try {
    await supabase.from('profiles').update({
      'deep_synthesis_text': synthesisText,
    }).eq('id', userId);
    log('💾 [Synthese] Synthese in DB gespeichert');
  } catch (e) {
    log('⚠️ [Synthese] Fehler beim Cachen: $e');
    // Text trotzdem zurückgeben
  }

  return synthesisText;
});

/// Deep Synthesis Section im Signatur-Screen
///
/// Zeigt die tiefe Drei-System-Synthese: 700-1000 Wörter,
/// alle drei Systeme verwoben, NUURAY Brand Soul Philosophie.
///
/// Folgt dem 5-Schritt-Bogen:
/// Hook → Psyche & Spannung → Energie-Wahrheit → Seelenweg → Auflösung → Impuls
class DeepSynthesisSection extends ConsumerWidget {
  const DeepSynthesisSection({
    required this.birthChart,
    super.key,
  });

  final BirthChart birthChart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final synthesisAsync = ref.watch(deepSynthesisProvider(birthChart));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Und so fügt sich alles zusammen',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C2C2C),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Die Synthese aus allen drei Systemen',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Content: Loading / Error / Data
        synthesisAsync.when(
          data: (text) => _buildSynthesisContent(text),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(ref, error),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  /// Zeigt den fertigen Synthese-Text
  Widget _buildSynthesisContent(String text) {
    // Text in Absätze aufteilen für bessere Lesbarkeit
    final paragraphs = text
        .split('\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8E3D8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dekorative Linie oben
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Absätze
          for (int i = 0; i < paragraphs.length; i++) ...[
            Text(
              paragraphs[i],
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2C2C2C),
                height: 1.75,
                letterSpacing: 0.1,
              ),
            ),
            if (i < paragraphs.length - 1) const SizedBox(height: 20),
          ],

          const SizedBox(height: 20),

          // Footer: NUURAY Signatur + Debug Reset
          Row(
            children: [
              Container(
                height: 1,
                width: 24,
                color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Text(
                'Deine NUURAY Signatur',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              // Debug-only: Cache-Reset Button (nur im Debug-Build sichtbar)
              if (const bool.fromEnvironment('dart.vm.product') == false)
                Consumer(
                  builder: (context, ref, _) => GestureDetector(
                    onLongPress: () async {
                      await resetDeepSynthesisCache(ref);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🗑️ Synthese-Cache gelöscht — wird neu generiert'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Icon(
                      Icons.refresh,
                      size: 14,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Lade-Zustand: Synthese wird generiert
  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Animierter Indikator
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Deine Synthese wird berechnet...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Alle drei Systeme werden zu einer Geschichte verwoben.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Fehler-Zustand
  Widget _buildErrorState(WidgetRef ref, Object error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red[400], size: 20),
              const SizedBox(width: 8),
              Text(
                'Synthese konnte nicht geladen werden',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Die Synthese wird beim nächsten Öffnen automatisch erneut versucht.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => ref.invalidate(deepSynthesisProvider(birthChart)),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Erneut versuchen'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[600],
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ],
      ),
    );
  }
}
