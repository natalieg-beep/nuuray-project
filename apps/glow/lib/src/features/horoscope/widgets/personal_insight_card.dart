import 'package:flutter/material.dart';

/// Personal Insight Card für Bazi/Numerologie-Insights
///
/// Zeigt statische Insights die das User-Profil mit der
/// Tagesenergie verbinden (Variante A - UI-Synthese).
///
/// Kosten: $0 (clientseitig gemappt)
class PersonalInsightCard extends StatelessWidget {
  final String title;
  final String insight;
  final String emoji;
  final Color accentColor;

  const PersonalInsightCard({
    super.key,
    required this.title,
    required this.insight,
    required this.emoji,
    this.accentColor = const Color(0xFFC8956E),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.1),
            accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.9)
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Connector Arrow Widget (visualisiert die Synthese)
class SynthesisConnector extends StatelessWidget {
  final Color color;

  const SynthesisConnector({
    super.key,
    this.color = const Color(0xFFC8956E),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_downward_rounded,
            color: color.withOpacity(0.5),
            size: 20,
          ),
        ],
      ),
    );
  }
}
