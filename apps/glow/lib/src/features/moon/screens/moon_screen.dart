import 'package:flutter/material.dart';

/// Moon Screen — Mondphasen-Kalender (Placeholder)
class MoonScreen extends StatelessWidget {
  const MoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Moon Icon
              const Text(
                '🌙',
                style: TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 24),
              // Coming Soon Text
              const Text(
                'Mondkalender',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Demnächst verfügbar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
