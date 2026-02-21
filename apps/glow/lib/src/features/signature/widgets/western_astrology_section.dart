import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuuray_core/nuuray_core.dart';
import '../../../core/widgets/expandable_card.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/language_provider.dart';

/// Western Astrology Section
///
/// Zeigt Sonne, Mond, Aszendent mit Content aus Content Library
class WesternAstrologySection extends ConsumerWidget {
  const WesternAstrologySection({
    required this.birthChart,
    super.key,
  });

  final BirthChart birthChart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentService = ref.watch(contentLibraryServiceProvider);
    final locale = ref.watch(currentLocaleProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Westliche Astrologie',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Deine grundlegende kosmische Identität',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Sonne Card
        _buildSignCard(
          context: context,
          contentService: contentService,
          locale: locale,
          icon: '☀️',
          category: 'sun_sign',
          sign: birthChart.sunSign,
          degree: birthChart.sunDegree,
          label: 'Sonne',
        ),

        // Mond Card (falls vorhanden)
        if (birthChart.moonSign != null)
          _buildSignCard(
            context: context,
            contentService: contentService,
            locale: locale,
            icon: '🌙',
            category: 'moon_sign',
            sign: birthChart.moonSign!,
            degree: birthChart.moonDegree,
            label: 'Mond',
          ),

        // Aszendent Card (falls vorhanden)
        if (birthChart.ascendantSign != null)
          _buildSignCard(
            context: context,
            contentService: contentService,
            locale: locale,
            icon: '⬆️',
            category: 'rising_sign',
            sign: birthChart.ascendantSign!,
            degree: birthChart.ascendantDegree,
            label: 'Aszendent',
          ),

        // Hinweis wenn Geburtszeit fehlt (Mond UND Aszendent nicht berechenbar)
        if (birthChart.moonSign == null && birthChart.ascendantSign == null)
          _buildMissingBirthTimeHint(context),
      ],
    );
  }

  /// Dezenter Hinweis: Geburtszeit fehlt → Mond + Aszendent nicht berechenbar
  Widget _buildMissingBirthTimeHint(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8E3D8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 18,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                children: const [
                  TextSpan(
                    text: 'Mond & Aszendent fehlen. ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: 'Ergänze deine Geburtszeit im Profil für ein vollständiges Bild.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignCard({
    required BuildContext context,
    required dynamic contentService,
    required String locale,
    required String icon,
    required String category,
    required String sign,
    required double? degree,
    required String label,
  }) {
    return FutureBuilder<String?>(
      future: contentService.getDescription(
        category: category,
        key: sign.toLowerCase(),
        locale: locale,
      ),
      builder: (context, snapshot) {
        final description = snapshot.data;

        final localizedSign = ZodiacNames.getName(sign, locale);

        return ExpandableCard(
          icon: icon,
          title: '$localizedSign in $label',
          subtitle: '${degree?.toStringAsFixed(1) ?? "–"}° $localizedSign',
          content: _buildContent(description),
        );
      },
    );
  }

  Widget _buildContent(String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        if (description != null)
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.6,
            ),
          )
        else
          Text(
            'Lädt Beschreibung...',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}
