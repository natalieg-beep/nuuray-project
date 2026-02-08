import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';
import 'package:nuuray_ui/nuuray_ui.dart';

/// Archetyp-Header: Zeigt Name + Adjektiv + Signatur-Satz prominent
///
/// Layout:
/// ```
/// ┌─────────────────────────────────────┐
/// │ ✨ Dein Archetyp                     │
/// │                                     │
/// │ Die intuitive Strategin             │ ← Groß, bold
/// │                                     │
/// │ "In dir verbindet sich die präzise  │ ← Kursiv, weicher
/// │  Kraft des Metalls mit einer..."    │
/// │                                     │
/// │              Tippe für Details  →   │ ← Hint
/// └─────────────────────────────────────┘
/// ```
class ArchetypeHeader extends StatelessWidget {
  final Archetype archetype;
  final VoidCallback onTap;

  const ArchetypeHeader({
    super.key,
    required this.archetype,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Lokalisiere Name + Adjektiv
    // Namen haben Artikel: "Die Strategin"
    // Adjektive ohne Artikel: "feine"
    // → "Die feine Strategin"
    final archetypeName = _getLocalizedName(l10n, archetype.nameKey);
    final baziAdjective = _getLocalizedAdjective(l10n, archetype.adjectiveKey);

    // Kombiniere: Entferne "Die" vom Namen, füge "Die [Adjektiv]" hinzu
    // "Die Strategin" → "Strategin" → "Die feine Strategin"
    final nameWithoutArticle = archetypeName.replaceFirst('Die ', '');
    final fullTitle = 'Die $baziAdjective $nameWithoutArticle';

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

            // Archetyp-Name (groß)
            Text(
              fullTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF2C2416), // Dunkelbraun
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Signatur-Satz (kursiv, weicher)
            if (archetype.hasSignature)
              Text(
                archetype.signatureText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF2C2416).withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              )
            else
              Text(
                l10n.archetypeNoSignature,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8B7355),
                  fontStyle: FontStyle.italic,
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
