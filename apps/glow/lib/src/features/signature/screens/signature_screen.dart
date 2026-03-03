import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../signature/providers/signature_provider.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../../home/widgets/archetype_header.dart';
import '../widgets/western_astrology_section.dart';
import '../widgets/bazi_section.dart';
import '../widgets/numerology_section.dart';
import '../widgets/premium_synthesis_section.dart';
import '../widgets/key_insights_section.dart';
import '../providers/signature_report_provider.dart';
import '../services/signature_pdf_generator.dart';
import 'package:nuuray_core/nuuray_core.dart';
import 'package:nuuray_ui/nuuray_ui.dart';

/// Signature Screen — Detaillierte kosmische Signatur (Vollansicht)
///
/// Zeigt alle 5 Sektionen:
/// 1. Hero (Archetyp-Titel + Mini-Synthese)
/// 2. Western Astrology (Sonne, Mond, Aszendent)
/// 3. Bazi (Day Master + Element Balance)
/// 4. Numerologie (Life Path + Kern-Zahlen)
/// 5. Tiefe Drei-System-Synthese (Herzstück — 700-1000 Wörter)
class SignatureScreen extends ConsumerWidget {
  const SignatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Warmer Off-White
      appBar: AppBar(
        title: const Text(
          'Deine Signatur',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2C2C),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return _buildEmptyState();
          }

          // Jetzt haben wir das Profil, baue Content
          return _buildContent(context, ref, profile, l10n);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorState(ref),
      ),
    );
  }

  /// Build Content with Profile
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    AppLocalizations l10n,
  ) {
    final signatureAsync = ref.watch(signatureProvider);

    return signatureAsync.when(
      data: (birthChart) {
        if (birthChart == null) {
          return _buildEmptyState();
        }

        // Erstelle Archetyp aus BirthChart + Profile (gleiche Quelle wie Home Screen!)
        final archetype = Archetype.fromBirthChart(
          lifePathNumber: birthChart.lifePathNumber ?? 1,
          dayMasterStem: birthChart.baziDayStem ?? 'Jia',
          signatureText: profile.signatureText,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Archetyp-Hero Section (nur Titel, keine Synthese)
              ArchetypeHeader(
                archetype: archetype,
                onTap: () {
                  // Bereits auf Signatur-Screen - kein Tap-Verhalten nötig
                },
                showSynthesis: false, // Nur Titel anzeigen
              ),
              const SizedBox(height: 24),

              // Überleitung: "Deine Signatur setzt sich aus drei Perspektiven zusammen..."
              Text(
                l10n.signatureOverviewIntro,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // 2. Western Astrology Section
              WesternAstrologySection(
                birthChart: birthChart,
              ),

              // 3. Bazi Section
              BaziSection(
                birthChart: birthChart,
              ),

              // 4. Numerology Section
              NumerologySection(
                birthChart: birthChart,
              ),

              // 5. Tiefe Drei-System-Synthese (Herzstück)
              DeepSynthesisSection(
                birthChart: birthChart,
              ),

              // 6. Das Wesentliche + Fragen an dich
              KeyInsightsSection(
                birthChart: birthChart,
              ),

              // 7. PDF Export Button
              const SizedBox(height: 16),
              _ExportButton(
                birthChart: birthChart,
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => _buildErrorState(ref),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.stars_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Profil wird berechnet...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Fehler beim Laden der Signatur',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.refresh(signatureProvider),
            child: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }
}

/// Export-Button Widget — Generiert und teilt den Signatur-Report PDF
class _ExportButton extends ConsumerStatefulWidget {
  const _ExportButton({required this.birthChart});

  final BirthChart birthChart;

  @override
  ConsumerState<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends ConsumerState<_ExportButton> {
  bool _isExporting = false;
  String? _statusMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          // Divider
          Container(
            height: 1,
            color: const Color(0xFFE8E3D8).withValues(alpha: 0.6),
          ),
          const SizedBox(height: 24),

          // Export Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isExporting ? null : () => _exportReport(l10n),
              icon: _isExporting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey[400],
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined, size: 20),
              label: Text(
                _isExporting
                    ? (_statusMessage ?? l10n.reportExportLoading)
                    : l10n.reportExportButton,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isExporting
                    ? Colors.grey[200]
                    : const Color(0xFF2C2C2C),
                foregroundColor: _isExporting
                    ? Colors.grey[600]
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),

          // Status Text
          if (_statusMessage != null && _isExporting)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _statusMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _exportReport(AppLocalizations l10n) async {
    setState(() {
      _isExporting = true;
      _statusMessage = l10n.reportExportChaptersLoading;
    });

    try {
      // 1. Report-Daten laden/generieren (inkl. ggf. fehlende Chapters)
      log('📄 [Export] Starte Report-Generierung...');
      final reportData = await ref.read(
        signatureReportProvider(widget.birthChart).future,
      );

      if (!mounted) return;
      setState(() {
        _statusMessage = l10n.reportExportLoading;
      });

      // 2. PDF generieren und in Downloads speichern
      log('📄 [Export] Generiere PDF...');
      final pdfGenerator = SignaturePdfGenerator();
      final filePath = await pdfGenerator.shareReport(reportData);

      if (!mounted) return;
      setState(() {
        _isExporting = false;
        _statusMessage = null;
      });

      log('✅ [Export] PDF gespeichert: $filePath');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.reportExportSuccess} ✓'),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color(0xFF2C2C2C),
          ),
        );
      }
    } catch (e) {
      log('❌ [Export] Fehler: $e');

      if (!mounted) return;
      setState(() {
        _isExporting = false;
        _statusMessage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.reportExportError}: $e'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }
}
