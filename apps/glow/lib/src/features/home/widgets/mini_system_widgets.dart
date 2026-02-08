import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';
import 'package:nuuray_ui/nuuray_ui.dart';

/// Drei kompakte System-Cards (Western / Bazi / Numerologie)
///
/// Layout:
/// ```
/// ┌──────────┬──────────┬──────────┐
/// │  ☀️      │  🔥      │  🔢      │
/// │ Western  │  Bazi    │  Numero  │
/// │ Schütze  │  Gui     │  LP 8    │
/// └──────────┴──────────┴──────────┘
/// ```
///
/// Jede Card ist tappbar und navigiert zur Detail-Ansicht des jeweiligen Systems.
class MiniSystemWidgets extends StatelessWidget {
  final BirthChart birthChart;
  final VoidCallback onWesternTap;
  final VoidCallback onBaziTap;
  final VoidCallback onNumerologyTap;

  const MiniSystemWidgets({
    super.key,
    required this.birthChart,
    required this.onWesternTap,
    required this.onBaziTap,
    required this.onNumerologyTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Lokalisiere Sternzeichen
    final sunSignLocalized = _getLocalizedZodiacSign(birthChart.sunSign, l10n);

    // Bazi: Day Master = Stem + Branch (z.B. "Xin-Schwein")
    final isGerman = l10n.localeName.startsWith('de');
    final baziStem = birthChart.baziDayStem ?? '?';
    final baziBranch = birthChart.baziDayBranch != null
        ? _getLocalizedBaziBranch(birthChart.baziDayBranch!, isGerman)
        : '?';
    final baziDayMaster = '$baziStem-$baziBranch';

    // Numerologie: "Lebenspfad X"
    final lifePathText = isGerman
        ? 'Lebenspfad ${birthChart.lifePathNumber ?? "?"}'
        : 'Life Path ${birthChart.lifePathNumber ?? "?"}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: _MiniCard(
              icon: '☀️',
              title: l10n.signatureWesternTitle,
              subtitle: sunSignLocalized,
              onTap: onWesternTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniCard(
              icon: '🔥',
              title: isGerman ? 'Bazi Daymaster' : 'Bazi Day Master',
              subtitle: baziDayMaster,
              onTap: onBaziTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniCard(
              icon: '🔢',
              title: l10n.signatureNumerologyTitle,
              subtitle: lifePathText,
              onTap: onNumerologyTap,
            ),
          ),
        ],
      ),
    );
  }

  /// Lokalisiere Sternzeichen-Namen
  String _getLocalizedZodiacSign(String signKey, AppLocalizations l10n) {
    final isGerman = l10n.localeName.startsWith('de');

    switch (signKey) {
      case 'aries':
        return isGerman ? 'Widder' : 'Aries';
      case 'taurus':
        return isGerman ? 'Stier' : 'Taurus';
      case 'gemini':
        return isGerman ? 'Zwillinge' : 'Gemini';
      case 'cancer':
        return isGerman ? 'Krebs' : 'Cancer';
      case 'leo':
        return isGerman ? 'Löwe' : 'Leo';
      case 'virgo':
        return isGerman ? 'Jungfrau' : 'Virgo';
      case 'libra':
        return isGerman ? 'Waage' : 'Libra';
      case 'scorpio':
        return isGerman ? 'Skorpion' : 'Scorpio';
      case 'sagittarius':
        return isGerman ? 'Schütze' : 'Sagittarius';
      case 'capricorn':
        return isGerman ? 'Steinbock' : 'Capricorn';
      case 'aquarius':
        return isGerman ? 'Wassermann' : 'Aquarius';
      case 'pisces':
        return isGerman ? 'Fische' : 'Pisces';
      default:
        return signKey;
    }
  }

  /// Lokalisiere Bazi Branch (Tierzeichen)
  String _getLocalizedBaziBranch(String branch, bool isGerman) {
    switch (branch) {
      case 'Rat':
        return isGerman ? 'Ratte' : 'Rat';
      case 'Ox':
        return isGerman ? 'Büffel' : 'Ox';
      case 'Tiger':
        return isGerman ? 'Tiger' : 'Tiger';
      case 'Rabbit':
        return isGerman ? 'Hase' : 'Rabbit';
      case 'Dragon':
        return isGerman ? 'Drache' : 'Dragon';
      case 'Snake':
        return isGerman ? 'Schlange' : 'Snake';
      case 'Horse':
        return isGerman ? 'Pferd' : 'Horse';
      case 'Goat':
        return isGerman ? 'Ziege' : 'Goat';
      case 'Monkey':
        return isGerman ? 'Affe' : 'Monkey';
      case 'Rooster':
        return isGerman ? 'Hahn' : 'Rooster';
      case 'Dog':
        return isGerman ? 'Hund' : 'Dog';
      case 'Pig':
        return isGerman ? 'Schwein' : 'Pig';
      default:
        return branch;
    }
  }
}

/// Einzelne Mini-Card
class _MiniCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MiniCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFF5E6D3), // Champagner
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon
            Text(
              icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: const Color(0xFF8B7355), // Bronze
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF2C2416), // Dunkelbraun
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
