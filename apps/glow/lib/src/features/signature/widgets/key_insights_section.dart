import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuuray_core/nuuray_core.dart';
import 'package:nuuray_ui/nuuray_ui.dart';
import '../../../core/providers/app_providers.dart';
import '../../profile/providers/user_profile_provider.dart';

// ============================================================
// DATA MODEL
// ============================================================

/// Datenklasse für die extrahierten Key Insights + Reflexionsfragen
class KeyInsightsData {
  final List<Map<String, String>> insights; // [{label, text}, ...]
  final List<String> questions; // [frage1, frage2, ...]

  const KeyInsightsData({
    required this.insights,
    required this.questions,
  });

  bool get isEmpty => insights.isEmpty && questions.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

// ============================================================
// CACHE RESET (Debug)
// ============================================================

/// Löscht den Key Insights Cache für den aktuellen User (nur für Entwicklung/Testing)
///
/// Setzt profiles.key_insights + profiles.reflection_questions auf NULL.
/// [birthChart] muss übergeben werden da keyInsightsProvider ein family-Provider ist.
Future<void> resetKeyInsightsCache(WidgetRef ref, BirthChart birthChart) async {
  final supabase = ref.read(supabaseClientProvider);
  final profile = ref.read(userProfileProvider).valueOrNull;
  final userId = profile?.id;
  if (userId == null) return;

  await supabase
      .from('profiles')
      .update({
        'key_insights': null,
        'reflection_questions': null,
      })
      .eq('id', userId);

  ref.invalidate(keyInsightsProvider(birthChart));
  log('🗑️ [KeyInsights] Cache gelöscht — wird beim nächsten Aufruf neu generiert');
}

// ============================================================
// PROVIDER
// ============================================================

/// Provider für Key Insights + Reflexionsfragen — Cache-First + Claude API
///
/// Folgt dem deepSynthesisProvider-Pattern:
/// 1. Cache-Check in profiles (key_insights + reflection_questions)
/// 2. If miss: Lese deep_synthesis_text, dann Claude API Call
/// 3. UPDATE profiles mit Ergebnis
final keyInsightsProvider = FutureProvider.family<KeyInsightsData, BirthChart>((ref, birthChart) async {
  final supabase = ref.read(supabaseClientProvider);
  final profile = ref.watch(userProfileProvider).valueOrNull;
  final userId = profile?.id;

  if (userId == null) {
    throw Exception('Kein User-Profil vorhanden');
  }

  // 1. Cache-Check: Bereits gespeicherte Insights laden
  try {
    final cached = await supabase
        .from('profiles')
        .select('key_insights, reflection_questions')
        .eq('id', userId)
        .maybeSingle();

    if (cached != null) {
      final existingInsights = cached['key_insights'];
      final existingQuestions = cached['reflection_questions'];

      if (existingInsights != null && existingQuestions != null) {
        final insights = (existingInsights as List).map<Map<String, String>>((item) {
          final map = item as Map<String, dynamic>;
          return {
            'label': (map['label'] ?? '') as String,
            'text': (map['text'] ?? '') as String,
          };
        }).toList();

        final questions = (existingQuestions as List).map<String>((q) => q.toString()).toList();

        if (insights.isNotEmpty && questions.isNotEmpty) {
          log('✅ [KeyInsights] Cache Hit — nutze gespeicherte Insights');
          return KeyInsightsData(insights: insights, questions: questions);
        }
      }
    }
  } catch (e) {
    log('⚠️ [KeyInsights] Cache-Check fehlgeschlagen: $e');
  }

  // 2. Deep Synthesis Text laden (muss vorhanden sein)
  String? synthesisText;
  try {
    final result = await supabase
        .from('profiles')
        .select('deep_synthesis_text')
        .eq('id', userId)
        .maybeSingle();

    synthesisText = result?['deep_synthesis_text'] as String?;
  } catch (e) {
    log('⚠️ [KeyInsights] Synthese-Text konnte nicht geladen werden: $e');
  }

  if (synthesisText == null || synthesisText.isEmpty) {
    throw Exception('Deep Synthesis muss zuerst generiert werden');
  }

  // 3. Claude API aufrufen
  log('🤖 [KeyInsights] Extrahiere Insights + Fragen für User: $userId');

  final claudeService = ref.read(claudeApiServiceProvider);
  if (claudeService == null) {
    throw Exception('Claude API Service nicht verfügbar — API Key fehlt');
  }

  final language = profile?.language ?? 'de';

  final result = await claudeService.generateKeyInsightsAndQuestions(
    synthesisText: synthesisText,
    language: language,
    gender: profile?.gender,
  );

  final insights = (result['key_insights'] as List<Map<String, String>>?) ?? [];
  final questions = (result['reflection_questions'] as List<String>?) ?? [];

  log('✨ [KeyInsights] Extrahiert: ${insights.length} Insights + ${questions.length} Fragen');

  // 4. In Datenbank cachen
  try {
    await supabase.from('profiles').update({
      'key_insights': insights.map((i) => {'label': i['label'], 'text': i['text']}).toList(),
      'reflection_questions': questions,
    }).eq('id', userId);
    log('💾 [KeyInsights] In DB gespeichert');
  } catch (e) {
    log('⚠️ [KeyInsights] Fehler beim Cachen: $e');
  }

  return KeyInsightsData(insights: insights, questions: questions);
});

// ============================================================
// WIDGET
// ============================================================

/// Key Insights Section — "Das Wesentliche" + "Fragen an dich"
///
/// Lebt direkt unter der Deep Synthesis Section im Signatur-Screen.
/// Zeigt 3 Schlüsselerkenntnisse + 7 Reflexionsfragen, statisch und konsumierbar.
class KeyInsightsSection extends ConsumerWidget {
  const KeyInsightsSection({
    required this.birthChart,
    super.key,
  });

  final BirthChart birthChart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(keyInsightsProvider(birthChart));

    return insightsAsync.when(
      data: (data) => _KeyInsightsContent(
        data: data,
        birthChart: birthChart,
      ),
      loading: () => _buildLoadingState(context),
      error: (error, stack) => _buildErrorState(context, ref, error),
    );
  }

  /// Lade-Zustand: Insights werden extrahiert
  Widget _buildLoadingState(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        _buildSectionHeader(l10n.essenceSectionTitle, l10n.essenceSectionSubtitle),

        const SizedBox(height: 16),

        Container(
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
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.essenceLoading,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.essenceLoadingSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  /// Fehler-Zustand
  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    final l10n = AppLocalizations.of(context);
    final isSynthesisMissing = error.toString().contains('Deep Synthesis muss zuerst');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.essenceSectionTitle, l10n.essenceSectionSubtitle),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSynthesisMissing ? Colors.orange[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSynthesisMissing
                  ? Colors.orange.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: isSynthesisMissing ? Colors.orange[400] : Colors.red[400],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isSynthesisMissing
                          ? l10n.essenceSynthesisMissing
                          : l10n.essenceErrorTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSynthesisMissing ? Colors.orange[700] : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
              if (!isSynthesisMissing) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => ref.invalidate(keyInsightsProvider(birthChart)),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(l10n.essenceErrorRetry),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  /// Section Header (wiederverwendbar)
  static Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C2C2C),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Content-Widget für Key Insights — eigenständiges ConsumerWidget für ref-Zugriff
class _KeyInsightsContent extends ConsumerWidget {
  const _KeyInsightsContent({
    required this.data,
    required this.birthChart,
  });

  final KeyInsightsData data;
  final BirthChart birthChart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================
        // "Das Wesentliche" — 3 Schlüsselerkenntnisse
        // ========================================
        KeyInsightsSection._buildSectionHeader(
          l10n.essenceSectionTitle,
          l10n.essenceSectionSubtitle,
        ),

        const SizedBox(height: 16),

        // Erkenntnisse-Container
        Container(
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

              // 3 Erkenntnisse
              for (int i = 0; i < data.insights.length; i++) ...[
                // Label
                Text(
                  data.insights[i]['label'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.9),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Text
                Text(
                  data.insights[i]['text'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2C2C2C),
                    height: 1.7,
                    letterSpacing: 0.1,
                  ),
                ),

                // Divider (nicht nach dem letzten)
                if (i < data.insights.length - 1) ...[
                  const SizedBox(height: 20),
                  Container(
                    height: 1,
                    color: const Color(0xFFE8E3D8).withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 20),
                ],
              ],

              const SizedBox(height: 20),

              // Footer
              Row(
                children: [
                  Container(
                    height: 1,
                    width: 24,
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.essenceFooterLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  // Debug-only: Cache-Reset per Long-Press
                  if (const bool.fromEnvironment('dart.vm.product') == false)
                    GestureDetector(
                      onLongPress: () async {
                        await resetKeyInsightsCache(ref, birthChart);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🗑️ Insights-Cache gelöscht — neu generieren'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Icon(
                        Icons.refresh,
                        size: 16,
                        color: Colors.grey[350],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // ========================================
        // "Fragen an dich" — 7 Reflexionsfragen
        // ========================================
        KeyInsightsSection._buildSectionHeader(
          l10n.questionsSectionTitle,
          l10n.questionsSectionSubtitle,
        ),

        const SizedBox(height: 16),

        // Fragen-Container
        Container(
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

              // 7 Fragen
              for (int i = 0; i < data.questions.length; i++) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nummer
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${i + 1}.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.7),
                          height: 1.7,
                        ),
                      ),
                    ),

                    // Frage
                    Expanded(
                      child: Text(
                        data.questions[i],
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF2C2C2C),
                          height: 1.7,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),

                // Abstand zwischen Fragen
                if (i < data.questions.length - 1)
                  const SizedBox(height: 16),
              ],
            ],
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}
