import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';

/// Onboarding Schritt 1: Name-Eingabe (4 Felder)
///
/// **Konzept für Numerologie:**
/// - **Birth Energy** (Urenergie): fullFirstNames + birthName
/// - **Current Energy** (aktuelle Energie): fullFirstNames + lastName
///
/// **Beispiel:**
/// - Rufname: "Natalie"
/// - Vornamen: "Natalie Frauke"
/// - Geburtsname: "Pawlowski"
/// - Aktueller Nachname: "Günes"
/// → Birth Energy: "Natalie Frauke Pawlowski"
/// → Current Energy: "Natalie Frauke Günes"
class OnboardingNameScreen extends StatefulWidget {
  final String? initialDisplayName;
  final String? initialFullFirstNames;
  final String? initialBirthName;
  final String? initialLastName;
  final Function(
    String displayName,
    String? fullFirstNames,
    String? birthName,
    String? lastName,
  ) onNext;

  const OnboardingNameScreen({
    super.key,
    this.initialDisplayName,
    this.initialFullFirstNames,
    this.initialBirthName,
    this.initialLastName,
    required this.onNext,
  });

  @override
  State<OnboardingNameScreen> createState() => _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends State<OnboardingNameScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _fullFirstNamesController;
  late final TextEditingController _birthNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.initialDisplayName);
    _fullFirstNamesController = TextEditingController(text: widget.initialFullFirstNames);
    _birthNameController = TextEditingController(text: widget.initialBirthName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _fullFirstNamesController.dispose();
    _birthNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    widget.onNext(
      _displayNameController.text.trim(),
      _fullFirstNamesController.text.trim().isEmpty
          ? null
          : _fullFirstNamesController.text.trim(),
      _birthNameController.text.trim().isEmpty
          ? null
          : _birthNameController.text.trim(),
      _lastNameController.text.trim().isEmpty
          ? null
          : _lastNameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titel
            Text(
              'Wie heißt du?',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Untertitel
            Text(
              'Dein vollständiger Name hilft uns, deine numerologische Energie zu verstehen.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // 1. Rufname / Username (Pflichtfeld)
            TextFormField(
              controller: _displayNameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Rufname / Username *',
                hintText: 'z.B. Natalie',
                prefixIcon: Icon(Icons.person_outline),
                helperText: 'Wie sollen wir dich nennen?',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte gib deinen Rufnamen ein';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // 2. Vollständige Vornamen (optional, aber empfohlen)
            TextFormField(
              controller: _fullFirstNamesController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Vornamen lt. Geburtsurkunde (optional)',
                hintText: 'z.B. Natalie Frauke',
                prefixIcon: Icon(Icons.badge_outlined),
                helperText: 'Alle Vornamen aus der Geburtsurkunde',
              ),
            ),
            const SizedBox(height: 20),

            // 3. Geburtsname / Maiden Name (optional)
            TextFormField(
              controller: _birthNameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Geburtsname (optional)',
                hintText: 'z.B. Pawlowski',
                prefixIcon: Icon(Icons.family_restroom_outlined),
                helperText: 'Nachname bei Geburt (Maiden Name)',
              ),
            ),
            const SizedBox(height: 20),

            // 4. Aktueller Nachname (optional)
            TextFormField(
              controller: _lastNameController,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nachname aktuell (optional)',
                hintText: 'z.B. Günes',
                prefixIcon: Icon(Icons.person_outline),
                helperText: 'Aktueller Nachname (falls geändert)',
              ),
              onFieldSubmitted: (_) => _handleNext(),
            ),
            const SizedBox(height: 24),

            // Hinweis
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Für präzise Numerologie empfehlen wir, alle Felder auszufüllen. '
                      'Besonders wichtig: Vornamen + Geburtsname zeigen deine Urenergie.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Weiter-Button
            ElevatedButton(
              onPressed: _handleNext,
              child: const Text('Weiter'),
            ),
          ],
        ),
      ),
    );
  }
}
