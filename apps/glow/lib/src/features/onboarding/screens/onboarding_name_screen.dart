import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';

/// Onboarding Schritt 1: Name-Eingabe
class OnboardingNameScreen extends StatefulWidget {
  final String? initialDisplayName;
  final String? initialFullFirstNames;
  final String? initialLastName;
  final String? initialBirthName;
  final Function(String displayName, String? fullFirstNames, String? lastName, String? birthName) onNext;

  const OnboardingNameScreen({
    super.key,
    this.initialDisplayName,
    this.initialFullFirstNames,
    this.initialLastName,
    this.initialBirthName,
    required this.onNext,
  });

  @override
  State<OnboardingNameScreen> createState() => _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends State<OnboardingNameScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _fullFirstNamesController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _birthNameController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.initialDisplayName);
    _fullFirstNamesController = TextEditingController(text: widget.initialFullFirstNames);
    _lastNameController = TextEditingController(text: widget.initialLastName);
    _birthNameController = TextEditingController(text: widget.initialBirthName);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _fullFirstNamesController.dispose();
    _lastNameController.dispose();
    _birthNameController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    widget.onNext(
      _displayNameController.text.trim(),
      _fullFirstNamesController.text.trim().isEmpty
          ? null
          : _fullFirstNamesController.text.trim(),
      _lastNameController.text.trim().isEmpty
          ? null
          : _lastNameController.text.trim(),
      _birthNameController.text.trim().isEmpty
          ? null
          : _birthNameController.text.trim(),
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
              'Dein Name hilft uns, deine Energie zu verstehen.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // Rufname (Pflichtfeld)
            TextFormField(
              controller: _displayNameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Rufname *',
                hintText: 'z.B. Maria',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte gib deinen Rufnamen ein';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Vornamen lt. Geburtsurkunde (optional)
            TextFormField(
              controller: _fullFirstNamesController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Vornamen lt. Geburtsurkunde (optional)',
                hintText: 'z.B. Anna Maria Theresa',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Nachname (optional)
            TextFormField(
              controller: _lastNameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nachname (optional)',
                hintText: 'z.B. Müller',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Geburtsname (optional)
            TextFormField(
              controller: _birthNameController,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Geburtsname (optional)',
                hintText: 'z.B. Schmidt',
                prefixIcon: Icon(Icons.family_restroom_outlined),
              ),
              onFieldSubmitted: (_) => _handleNext(),
            ),
            const SizedBox(height: 24),

            // Hinweis
            Container(
              padding: const EdgeInsets.all(16),
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
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Für besonders genaue Berechnungen verwenden wir deinen vollständigen Namen. '
                      'Diese Angaben sind optional, erhöhen aber die Präzision deiner persönlichen Energien.',
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
