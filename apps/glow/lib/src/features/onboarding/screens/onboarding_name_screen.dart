import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';

/// Onboarding Schritt 1: Name-Eingabe (3 Felder gemäß GLOW_SPEC_V2)
class OnboardingNameScreen extends StatefulWidget {
  final String? initialDisplayName;
  final String? initialFullFirstNames; // War: fullBirthName (Geburtsname lt. Geburtsurkunde)
  final String? initialLastName; // War: currentLastName (aktueller Nachname)
  final String? initialBirthName; // Wird nicht mehr verwendet, behalten für Migration
  final Function(String displayName, String? fullBirthName, String? currentLastName, String? deprecated) onNext;

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
  late final TextEditingController _displayNameController; // Rufname/Username (PFLICHT)
  late final TextEditingController _fullBirthNameController; // Voller Geburtsname (OPTIONAL)
  late final TextEditingController _currentLastNameController; // Aktueller Nachname (OPTIONAL)

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.initialDisplayName);
    _fullBirthNameController = TextEditingController(text: widget.initialFullFirstNames);
    _currentLastNameController = TextEditingController(text: widget.initialLastName);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _fullBirthNameController.dispose();
    _currentLastNameController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    widget.onNext(
      _displayNameController.text.trim(),
      _fullBirthNameController.text.trim().isEmpty
          ? null
          : _fullBirthNameController.text.trim(),
      _currentLastNameController.text.trim().isEmpty
          ? null
          : _currentLastNameController.text.trim(),
      null, // birthName (deprecated)
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

            // 2. Voller Geburtsname (optional)
            TextFormField(
              controller: _fullBirthNameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Voller Geburtsname (optional)',
                hintText: 'z.B. Natalie Frauke Günes',
                prefixIcon: Icon(Icons.badge_outlined),
                helperText: 'Lt. Geburtsurkunde, für präzise Numerologie',
              ),
            ),
            const SizedBox(height: 20),

            // 3. Nachname aktuell (optional)
            TextFormField(
              controller: _currentLastNameController,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nachname aktuell (optional)',
                hintText: 'z.B. Schmidt',
                prefixIcon: Icon(Icons.person_outline),
                helperText: 'Falls geändert nach Heirat/Namensänderung',
              ),
              onFieldSubmitted: (_) => _handleNext(),
            ),
            const SizedBox(height: 24),

            const SizedBox(height: 8),

            // Hinweis (gekürzt)
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
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Dein voller Geburtsname wird für präzise Numerologie-Berechnungen verwendet. '
                      'Der aktuelle Nachname beeinflusst deine gegenwärtige Energie.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
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
