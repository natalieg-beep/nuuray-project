import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';
import 'package:nuuray_ui/nuuray_ui.dart';

/// Drei Dashboard Mini-Widgets (Western / Bazi / Numerologie)
///
/// Layout nach DASHBOARD_WIDGETS_SPEC.md:
/// ```
/// ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
/// │  ♐ SCHÜTZE       │  │  CHINESISCH      │  │  NUMEROLOGIE     │
/// │  Mond: Waage     │  │  Gui · Yin-Metall│  │  Lebenszahl: 8   │
/// │  Aszendent: Löwe │  │  Element: Wasser  │  │  Namenszahl: 8   │
/// │  Element: Feuer  │  │  Tier: Schwein    │  │  Erfolg ·        │
/// │                  │  │                  │  │  Manifestation   │
/// └──────────────────┘  └──────────────────┘  └──────────────────┘
/// ```
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
    final isGerman = l10n.localeName.startsWith('de');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: IntrinsicHeight(
        // Sorgt dafür dass alle Cards gleich hoch werden
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Western Astrology Card
            Expanded(
              child: _WesternCard(
                birthChart: birthChart,
                isGerman: isGerman,
                l10n: l10n,
                onTap: onWesternTap,
              ),
            ),
            const SizedBox(width: 12),

            // Bazi Card
            Expanded(
              child: _BaziCard(
                birthChart: birthChart,
                isGerman: isGerman,
                l10n: l10n,
                onTap: onBaziTap,
              ),
            ),
            const SizedBox(width: 12),

            // Numerology Card
            Expanded(
              child: _NumerologyCard(
                birthChart: birthChart,
                isGerman: isGerman,
                l10n: l10n,
                onTap: onNumerologyTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Western Astrology Card
class _WesternCard extends StatelessWidget {
  final BirthChart birthChart;
  final bool isGerman;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _WesternCard({
    required this.birthChart,
    required this.isGerman,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sunSign = birthChart.sunSign ?? 'aries';
    final moonSign = birthChart.moonSign;
    final ascendant = birthChart.ascendantSign;

    // Lokalisiere Sternzeichen
    final sunSignName = _getLocalizedZodiacSign(sunSign, isGerman);
    final moonSignName =
        moonSign != null ? _getLocalizedZodiacSign(moonSign, isGerman) : null;
    final ascendantName = ascendant != null
        ? _getLocalizedZodiacSign(ascendant, isGerman)
        : null;

    // Western Element (aus Sonnenzeichen)
    final element = DashboardHelpers.getWesternElement(sunSign);
    final elementName = _getLocalizedWesternElement(element, isGerman);

    // Icon: Sternzeichen-Emoji
    final icon = DashboardHelpers.getZodiacEmoji(sunSign);

    return _MiniCard(
      icon: icon,
      title: isGerman ? 'WESTERN' : 'WESTERN',
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sonnenzeichen (GROSS)
          Text(
            sunSignName.toUpperCase(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2416), // Dunkelbraun
            ),
          ),
          const SizedBox(height: 6),

          // Mond (optional)
          if (moonSignName != null) ...[
            Text(
              '${isGerman ? 'Mond' : 'Moon'}: $moonSignName',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8B7355), // Bronze
              ),
            ),
            const SizedBox(height: 2),
          ],

          // Aszendent (optional)
          if (ascendantName != null) ...[
            Text(
              '${isGerman ? 'Aszendent' : 'Ascendant'}: $ascendantName',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8B7355),
              ),
            ),
            const SizedBox(height: 2),
          ],

          // Element
          Text(
            '${isGerman ? 'Element' : 'Element'}: $elementName',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8B7355),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedZodiacSign(String signKey, bool isGerman) {
    switch (signKey.toLowerCase()) {
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

  String _getLocalizedWesternElement(WesternElement element, bool isGerman) {
    switch (element) {
      case WesternElement.fire:
        return isGerman ? 'Feuer' : 'Fire';
      case WesternElement.earth:
        return isGerman ? 'Erde' : 'Earth';
      case WesternElement.air:
        return isGerman ? 'Luft' : 'Air';
      case WesternElement.water:
        return isGerman ? 'Wasser' : 'Water';
    }
  }
}

/// Bazi Card
class _BaziCard extends StatelessWidget {
  final BirthChart birthChart;
  final bool isGerman;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _BaziCard({
    required this.birthChart,
    required this.isGerman,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayStem = birthChart.baziDayStem ?? 'Jia';
    final dominantElement = birthChart.baziElement ?? 'Wood';
    final yearBranch = birthChart.baziYearBranch ?? 'Rat';

    // Day Master formatiert: "Gui · Yin-Wasser"
    final dayMasterFormatted = DashboardHelpers.formatDayMaster(dayStem);

    // Dominantes Element lokalisiert
    final elementName = _getLocalizedBaziElement(dominantElement, isGerman);

    // Jahrestier lokalisiert
    final yearAnimal =
        DashboardHelpers.getYearAnimal(yearBranch, isGerman: isGerman);

    // Icon: Jahrestier-Emoji
    final icon = DashboardHelpers.getYearAnimalEmoji(yearBranch);

    return _MiniCard(
      icon: icon,
      title: isGerman ? 'CHINESISCH' : 'CHINESE',
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Master
          Text(
            dayMasterFormatted,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2416),
            ),
          ),
          const SizedBox(height: 6),

          // Dominantes Element
          Text(
            '${isGerman ? 'Element' : 'Element'}: $elementName',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8B7355),
            ),
          ),
          const SizedBox(height: 2),

          // Jahrestier
          Text(
            '${isGerman ? 'Tier' : 'Animal'}: $yearAnimal',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8B7355),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedBaziElement(String element, bool isGerman) {
    switch (element.toLowerCase()) {
      case 'wood':
        return isGerman ? 'Holz' : 'Wood';
      case 'fire':
        return isGerman ? 'Feuer' : 'Fire';
      case 'earth':
        return isGerman ? 'Erde' : 'Earth';
      case 'metal':
        return isGerman ? 'Metall' : 'Metal';
      case 'water':
        return isGerman ? 'Wasser' : 'Water';
      default:
        return element;
    }
  }
}

/// Numerology Card
class _NumerologyCard extends StatelessWidget {
  final BirthChart birthChart;
  final bool isGerman;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _NumerologyCard({
    required this.birthChart,
    required this.isGerman,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lifePathNumber = birthChart.lifePathNumber ?? 1;
    final displayNameNumber = birthChart.displayNameNumber;

    // Keywords
    final keywords = DashboardHelpers.getLifePathKeywords(
      lifePathNumber,
      isGerman: isGerman,
    );

    // Icon: Zahlen-Emoji
    final icon = DashboardHelpers.getNumberEmoji(lifePathNumber);

    return _MiniCard(
      icon: icon,
      title: isGerman ? 'NUMEROLOGIE' : 'NUMEROLOGY',
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Zahlen (kompakt: "8 · 8")
          if (displayNameNumber != null) ...[
            Text(
              '$lifePathNumber · $displayNameNumber',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2416),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isGerman ? 'Lebens- und Namenszahl' : 'Life Path & Name Number',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8B7355),
              ),
            ),
          ] else ...[
            // Nur Lebenszahl (wenn keine Namenszahl)
            Text(
              '$lifePathNumber',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2416),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isGerman ? 'Lebenszahl' : 'Life Path',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8B7355),
              ),
            ),
          ],
          const SizedBox(height: 6),

          // Keywords
          Text(
            keywords,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8B7355),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Basis-Widget für Mini-Cards
class _MiniCard extends StatelessWidget {
  final String icon;
  final String title;
  final Widget child;
  final VoidCallback onTap;

  const _MiniCard({
    required this.icon,
    required this.title,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // IntrinsicHeight in der Parent-Row sorgt für gleiche Höhe
        padding: const EdgeInsets.all(14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max, // Wichtig: Column nimmt volle Höhe
          children: [
            // Icon (größer)
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B7355), // Bronze
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Content
            child,
          ],
        ),
      ),
    );
  }
}
