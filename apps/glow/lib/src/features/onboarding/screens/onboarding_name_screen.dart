import 'package:flutter/material.dart';
import 'package:nuuray_ui/nuuray_ui.dart';

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
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Titel
            Text(
              l10n.onboardingNameTitle,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Untertitel
            Text(
              l10n.onboardingNameSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // 1. Rufname / Username (Pflichtfeld)
            TextFormField(
              controller: _displayNameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.onboardingNameDisplayNameLabel,
                hintText: l10n.onboardingNameDisplayNameHint,
                prefixIcon: const Icon(Icons.person_outline),
                helperText: l10n.onboardingNameDisplayNameHelper,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.onboardingNameDisplayNameRequired;
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
              decoration: InputDecoration(
                labelText: l10n.onboardingNameFullFirstNamesLabel,
                hintText: l10n.onboardingNameFullFirstNamesHint,
                prefixIcon: const Icon(Icons.badge_outlined),
                helperText: l10n.onboardingNameFullFirstNamesHelper,
              ),
            ),
            const SizedBox(height: 20),

            // 3. Geburtsname / Maiden Name (optional)
            TextFormField(
              controller: _birthNameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.onboardingNameBirthNameLabel,
                hintText: l10n.onboardingNameBirthNameHint,
                prefixIcon: const Icon(Icons.family_restroom_outlined),
                helperText: l10n.onboardingNameBirthNameHelper,
              ),
            ),
            const SizedBox(height: 20),

            // 4. Aktueller Nachname (optional)
            TextFormField(
              controller: _lastNameController,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.onboardingNameLastNameLabel,
                hintText: l10n.onboardingNameLastNameHint,
                prefixIcon: const Icon(Icons.person_outline),
                helperText: l10n.onboardingNameLastNameHelper,
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
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.onboardingNameNumerologyHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Weiter-Button
            ElevatedButton(
              onPressed: _handleNext,
              child: Text(l10n.generalNext),
            ),
            const SizedBox(height: 24), // Extra Padding am Ende
            ],
          ),
        ),
      ),
    );
  }
}
