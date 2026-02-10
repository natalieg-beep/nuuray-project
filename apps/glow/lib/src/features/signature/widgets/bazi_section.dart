import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';
import '../../../core/widgets/expandable_card.dart';

class BaziSection extends StatelessWidget {
  const BaziSection({required this.birthChart, super.key});
  final BirthChart birthChart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16, top: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chinesisches Bazi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Deine Vier Säulen des Schicksals', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
        ExpandableCard(
          icon: '🐷',
          title: 'Day Master',
          subtitle: birthChart.baziElement ?? 'Wird berechnet...',
          content: Text('Detaillierte Bazi-Beschreibung folgt', style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }
}
