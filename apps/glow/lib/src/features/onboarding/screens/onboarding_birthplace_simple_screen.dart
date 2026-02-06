import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';

/// Onboarding Schritt 3: Geburtsort (Simple Version ohne Google Places)
class OnboardingBirthplaceSimpleScreen extends StatefulWidget {
  final String? initialBirthPlace;
  final Function(String place) onComplete;
  final VoidCallback onBack;

  const OnboardingBirthplaceSimpleScreen({
    super.key,
    this.initialBirthPlace,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<OnboardingBirthplaceSimpleScreen> createState() => _OnboardingBirthplaceSimpleScreenState();
}

class _OnboardingBirthplaceSimpleScreenState extends State<OnboardingBirthplaceSimpleScreen> {
  final TextEditingController _placeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.initialBirthPlace != null) {
      _placeController.text = widget.initialBirthPlace!;
    }
  }

  @override
  void dispose() {
    _placeController.dispose();
    super.dispose();
  }

  void _handleComplete() {
    if (!_formKey.currentState!.validate()) return;
    widget.onComplete(_placeController.text.trim());
  }

  void _handleSkip() {
    widget.onComplete('Unbekannt');
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
              'Wo wurdest du geboren?',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Untertitel
            Text(
              'Der Geburtsort hilft uns, dein Geburtshoroskop präzise zu berechnen.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // Textfeld für Geburtsort
            TextFormField(
              controller: _placeController,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Geburtsort',
                hintText: 'z.B. München, Deutschland',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              onFieldSubmitted: (_) => _handleComplete(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte gib deinen Geburtsort ein (oder überspringe diesen Schritt)';
                }
                return null;
              },
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
                      'Gib deinen Geburtsort im Format "Stadt, Land" ein. '
                      'Für genauere astrologische Berechnungen kannst du später '
                      'auch den genauen Ort in deinem Profil ergänzen.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Buttons
            Row(
              children: [
                // Zurück-Button
                OutlinedButton(
                  onPressed: widget.onBack,
                  child: const Text('Zurück'),
                ),
                const SizedBox(width: 16),

                // Überspringen-Button
                TextButton(
                  onPressed: _handleSkip,
                  child: const Text('Überspringen'),
                ),
                const SizedBox(width: 8),

                // Fertig-Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleComplete,
                    child: const Text('Fertig'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
