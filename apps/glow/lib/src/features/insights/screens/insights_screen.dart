import 'package:flutter/material.dart';

/// Insights Screen — Report-Katalog & Deep-Dive Analysen
/// Alle 10 OTP Reports aus Beyond Horoscope
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5), // AppColors.background
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Entdecke deine Tiefen',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2C2C),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Personalisierte Reports für tiefe Einblicke',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Report-Katalog
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Category: Beziehungen
                  _buildCategoryHeader('💖 Beziehungen'),
                  const SizedBox(height: 12),
                  _buildReportCard(
                    context,
                    title: 'SoulMate Finder',
                    subtitle: 'Partner-Check',
                    description: 'Passen wir wirklich zusammen? Analysiere deine Beziehung aus 3 Perspektiven.',
                    price: '4,99 €',
                    icon: Icons.favorite_outline,
                    color: const Color(0xFFE91E63), // Pink
                  ),
                  const SizedBox(height: 24),

                  // Category: Seele & Purpose
                  _buildCategoryHeader('💫 Seele & Purpose'),
                  const SizedBox(height: 12),
                  _buildReportCard(
                    context,
                    title: 'Soul Purpose',
                    subtitle: 'Deine Seelenmission',
                    description: 'Wozu bist du hier? Entdecke deine kosmische Bestimmung.',
                    price: '7,99 €',
                    icon: Icons.psychology_outlined,
                    color: const Color(0xFF9C27B0), // Purple
                  ),
                  const SizedBox(height: 16),
                  _buildReportCard(
                    context,
                    title: 'Shadow & Light',
                    subtitle: 'Schatten-Integration',
                    description: 'Verwandle deine Schatten in deine Superkraft.',
                    price: '7,99 €',
                    icon: Icons.contrast_outlined,
                    color: const Color(0xFF673AB7), // Deep Purple
                  ),
                  const SizedBox(height: 24),

                  // Category: Berufung & Erfolg
                  _buildCategoryHeader('💼 Berufung & Erfolg'),
                  const SizedBox(height: 12),
                  _buildReportCard(
                    context,
                    title: 'The Purpose Path',
                    subtitle: 'Deine Berufung',
                    description: 'Finde deinen authentischen Erfolgsweg.',
                    price: '6,99 €',
                    icon: Icons.compass_calibration_outlined,
                    color: const Color(0xFF3F51B5), // Indigo
                  ),
                  const SizedBox(height: 24),

                  // Category: Geld & Erfolg
                  _buildCategoryHeader('💰 Geld & Erfolg'),
                  const SizedBox(height: 12),
                  _buildReportCard(
                    context,
                    title: 'Golden Money Blueprint',
                    subtitle: 'Deine Geld-Energie',
                    description: 'Entdecke deine finanzielle Blaupause und Wohlstands-Potential.',
                    price: '7,99 €',
                    icon: Icons.attach_money_outlined,
                    color: const Color(0xFFFFB300), // Amber
                  ),
                  const SizedBox(height: 24),

                  // Category: Gesundheit & Energie
                  _buildCategoryHeader('🌱 Gesundheit & Energie'),
                  const SizedBox(height: 12),
                  _buildReportCard(
                    context,
                    title: 'Body Vitality',
                    subtitle: 'Deine Lebensenergie',
                    description: 'Optimiere deine Gesundheit nach deinem Chart.',
                    price: '5,99 €',
                    icon: Icons.spa_outlined,
                    color: const Color(0xFF4CAF50), // Green
                  ),
                  const SizedBox(height: 24),

                  // Category: Lifestyle & Entwicklung
                  _buildCategoryHeader('✨ Lifestyle & Entwicklung'),
                  const SizedBox(height: 12),
                  _buildReportCard(
                    context,
                    title: 'Aesthetic Style Guide',
                    subtitle: 'Dein kosmischer Stil',
                    description: 'Deine Venus-Signatur: Farben, Stil, Ästhetik.',
                    price: '5,99 €',
                    icon: Icons.palette_outlined,
                    color: const Color(0xFFE91E63), // Pink
                  ),
                  const SizedBox(height: 16),
                  _buildReportCard(
                    context,
                    title: 'Cosmic Parenting',
                    subtitle: 'Elternschaft nach den Sternen',
                    description: 'Verstehe dein Kind durch seine astrologische Blaupause.',
                    price: '6,99 €',
                    icon: Icons.family_restroom_outlined,
                    color: const Color(0xFF00BCD4), // Cyan
                  ),
                  const SizedBox(height: 24),

                  // Category: Ortswechsel & Veränderung
                  _buildCategoryHeader('🌍 Ortswechsel & Veränderung'),
                  const SizedBox(height: 12),
                  _buildReportCard(
                    context,
                    title: 'Relocation Astrology',
                    subtitle: 'Dein idealer Ort',
                    description: 'Wo auf der Welt entfaltest du dein volles Potential?',
                    price: '7,99 €',
                    icon: Icons.public_outlined,
                    color: const Color(0xFF009688), // Teal
                  ),
                  const SizedBox(height: 24),

                  // Category: Prognosen
                  _buildCategoryHeader('📅 Prognosen'),
                  const SizedBox(height: 12),
                  _buildReportCard(
                    context,
                    title: 'Yearly Energy Forecast',
                    subtitle: 'Dein persönliches Jahr',
                    description: '12 Monate Prognose: Chancen, Herausforderungen, Timing.',
                    price: '9,99 €',
                    icon: Icons.calendar_month_outlined,
                    color: const Color(0xFFFF9800), // Orange
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2C2C2C),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String price,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to Report Preview Screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title - Coming Soon!'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Price & Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        price,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD4AF37), // Gold
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Coming Soon',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
