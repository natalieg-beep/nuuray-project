import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';
import 'package:nuuray_ui/nuuray_ui.dart';

/// Archetyp-Header: Zeigt Claude-generierten Titel + Synthese prominent
///
/// Der Titel wird direkt aus `signature_text` geparst (Zeile 1).
/// Die Synthese ist der Rest des Textes (Zeile 3+).
///
/// Layout:
/// ```
/// ┌─────────────────────────────────────┐
/// │ ✨ Dein Archetyp                     │
/// │                                     │
/// │ Die großzügige Perfektionistin      │ ← Zeile 1 aus signature_text
/// │                                     │
/// │ "Alles in dir will nach vorne —     │ ← Zeile 3+ aus signature_text
/// │  Schütze-Feuer, Löwe-Aszendent..."  │
/// │                                     │
/// │              Tippe für Details  →   │ ← Hint
/// └─────────────────────────────────────┘
/// ```
class ArchetypeHeader extends StatelessWidget {
  final Archetype archetype;
  final VoidCallback onTap;
  final bool showSynthesis;

  const ArchetypeHeader({
    super.key,
    required this.archetype,
    required this.onTap,
    this.showSynthesis = true, // Default: Synthese anzeigen
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // DEBUG: Was kommt im Widget an?
    print('🎨 [ArchetypeHeader] hasSignature: ${archetype.hasSignature}');
    print('🎨 [ArchetypeHeader] signatureText: "${archetype.signatureText}"');

    // Parse Titel und Synthese aus signature_text
    // Neuer Prompt generiert: Zeile 1 = Titel, Zeile 2 = leer, Zeile 3+ = Synthese
    String displayTitle;
    String displaySynthesis;

    if (archetype.hasSignature) {
      final lines = archetype.signatureText!.split('\n');

      // Zeile 1 = Titel (z.B. "Die großzügige Perfektionistin")
      displayTitle = lines.first.trim();
      print('🎨 [ArchetypeHeader] displayTitle: "$displayTitle"');

      // Zeile 3+ = Synthese (Zeile 2 ist leer)
      // Filtere leere Zeilen und join mit Leerzeichen
      final synthesisLines = lines.skip(2).where((line) => line.trim().isNotEmpty);
      displaySynthesis = synthesisLines.join(' ').trim();
    } else {
      // Fallback für User ohne neue Signatur (alte Kombination)
      final archetypeName = _getLocalizedName(l10n, archetype.nameKey);
      final baziAdjective = _getLocalizedAdjective(l10n, archetype.adjectiveKey);
      final nameWithoutArticle = archetypeName.replaceFirst('Die ', '');
      displayTitle = 'Die $baziAdjective $nameWithoutArticle';
      displaySynthesis = l10n.archetypeNoSignature;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFD4AF37), // Gold
              Color(0xFFF5E6D3), // Champagner
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + "Dein Archetyp"
            Row(
              children: [
                const Text(
                  '✨',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.archetypeSectionTitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF8B7355), // Bronze
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Archetyp-Titel (groß, bold)
            Text(
              displayTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF2C2416), // Dunkelbraun
                fontWeight: FontWeight.bold,
              ),
            ),

            // Synthese-Text + Tap-Hint (nur wenn showSynthesis = true)
            if (showSynthesis) ...[
              const SizedBox(height: 12),

              // Synthese-Text (kursiv, weicher)
              Text(
                displaySynthesis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF2C2416).withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),

              // Tap-Hint
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    l10n.archetypeTapForDetails,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8B7355),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Color(0xFF8B7355),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Lokalisiere Archetyp-Namen
  String _getLocalizedName(AppLocalizations l10n, String nameKey) {
    switch (nameKey) {
      case 'pioneer':
        return l10n.archetypePioneer;
      case 'diplomat':
        return l10n.archetypeDiplomat;
      case 'creative':
        return l10n.archetypeCreative;
      case 'architect':
        return l10n.archetypeArchitect;
      case 'adventurer':
        return l10n.archetypeAdventurer;
      case 'mentor':
        return l10n.archetypeMentor;
      case 'seeker':
        return l10n.archetypeSeeker;
      case 'strategist':
        return l10n.archetypeStrategist;
      case 'humanitarian':
        return l10n.archetypeHumanitarian;
      case 'visionary':
        return l10n.archetypeVisionary;
      case 'master_builder':
        return l10n.archetypeMasterBuilder;
      case 'healer':
        return l10n.archetypeHealer;
      default:
        return nameKey;
    }
  }

  /// Lokalisiere Bazi-Adjektive
  String _getLocalizedAdjective(AppLocalizations l10n, String adjectiveKey) {
    switch (adjectiveKey) {
      case 'steadfast':
        return l10n.baziAdjectiveSteadfast;
      case 'adaptable':
        return l10n.baziAdjectiveAdaptable;
      case 'radiant':
        return l10n.baziAdjectiveRadiant;
      case 'perceptive':
        return l10n.baziAdjectivePerceptive;
      case 'grounded':
        return l10n.baziAdjectiveGrounded;
      case 'nurturing':
        return l10n.baziAdjectiveNurturing;
      case 'resolute':
        return l10n.baziAdjectiveResolute;
      case 'refined':
        return l10n.baziAdjectiveRefined;
      case 'flowing':
        return l10n.baziAdjectiveFlowing;
      case 'intuitive':
        return l10n.baziAdjectiveIntuitive;
      default:
        return adjectiveKey;
    }
  }
}
