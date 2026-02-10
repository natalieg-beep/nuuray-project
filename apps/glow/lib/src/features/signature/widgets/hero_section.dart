import 'package:flutter/material.dart';

/// Hero Section — Archetyp-Titel + Mini-Synthese
///
/// Zeigt den personalisierten Archetyp-Titel und eine kurze Synthese (1 Satz).
class HeroSection extends StatelessWidget {
  const HeroSection({
    required this.archetypeTitle,
    this.miniSynthesis,
    super.key,
  });

  final String archetypeTitle;
  final String? miniSynthesis;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF8E7), // Helles Gold
            Color(0xFFFFFBF5), // Creme
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sparkle Icon
          const Text(
            '✨',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 16),
          // Archetyp-Titel
          Text(
            archetypeTitle,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C2C2C),
              height: 1.3,
            ),
          ),
          // Mini-Synthese (optional)
          if (miniSynthesis != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE8E3D8),
                  width: 1,
                ),
              ),
              child: Text(
                miniSynthesis!,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
