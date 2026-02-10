import 'package:flutter/material.dart';
import 'package:nuuray_core/nuuray_core.dart';
import '../../../core/widgets/expandable_card.dart';

class NumerologySection extends StatelessWidget {
  const NumerologySection({required this.birthChart, super.key});
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
              const Text('Numerologie', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Die Zahlen deines Lebens', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
        if (birthChart.lifePathNumber != null)
          ExpandableCard(
            icon: '🔢',
            title: 'Lebensweg-Zahl ${birthChart.lifePathNumber}',
            subtitle: 'Dein grundlegender Lebensweg',
            content: Text('Detaillierte Numerologie-Beschreibung folgt', style: TextStyle(color: Colors.grey[700])),
          ),
      ],
    );
  }
}
