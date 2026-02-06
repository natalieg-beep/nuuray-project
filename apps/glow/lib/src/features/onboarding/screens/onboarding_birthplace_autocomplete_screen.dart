import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../core/config/app_config.dart';

/// Onboarding Schritt 3: Geburtsort mit Autocomplete
///
/// Nutzt Supabase Edge Function für sicheres Geocoding via Google Places API.
/// LIVE-Suche während der Eingabe (Debounced).
class OnboardingBirthplaceAutocompleteScreen extends ConsumerStatefulWidget {
  final String? initialBirthPlace;
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialTimezone;
  final Function(String place, double latitude, double longitude, String timezone) onComplete;
  final VoidCallback onBack;

  const OnboardingBirthplaceAutocompleteScreen({
    super.key,
    this.initialBirthPlace,
    this.initialLatitude,
    this.initialLongitude,
    this.initialTimezone,
    required this.onComplete,
    required this.onBack,
  });

  @override
  ConsumerState<OnboardingBirthplaceAutocompleteScreen> createState() =>
      _OnboardingBirthplaceAutocompleteScreenState();
}

class _OnboardingBirthplaceAutocompleteScreenState
    extends ConsumerState<OnboardingBirthplaceAutocompleteScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  String? _selectedPlace;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedTimezone;
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    if (widget.initialBirthPlace != null) {
      _searchController.text = widget.initialBirthPlace!;
      _selectedPlace = widget.initialBirthPlace;
      _selectedLatitude = widget.initialLatitude;
      _selectedLongitude = widget.initialLongitude;
      _selectedTimezone = widget.initialTimezone;
    }

    // LIVE-Suche: Bei jeder Texteingabe mit 800ms Debounce
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel vorheriger Timer
    _debounceTimer?.cancel();

    // Nur suchen wenn mind. 3 Zeichen
    if (_searchController.text.trim().length < 3) {
      setState(() {
        _selectedPlace = null;
        _selectedLatitude = null;
        _selectedLongitude = null;
        _selectedTimezone = null;
        _errorMessage = null;
      });
      return;
    }

    // Debounce: Warte 800ms nach letzter Eingabe
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _performSearch(_searchController.text.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 3) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      // FIX: Verwende den globalen Supabase-Client
      // Der ist bereits authentifiziert (auch wenn noch kein vollständiges Profil existiert)
      final supabase = Supabase.instance.client;

      final response = await supabase.functions.invoke(
        'geocode-place',
        body: {'query': query},
      );

      if (!mounted) return;

      if (response.status == 404) {
        setState(() {
          _isSearching = false;
          _errorMessage = 'Kein Ort gefunden. Versuche "Stadt, Land" (z.B. "Ravensburg, Deutschland")';
          _selectedPlace = null;
          _selectedLatitude = null;
          _selectedLongitude = null;
          _selectedTimezone = null;
        });
        return;
      }

      if (response.status != 200) {
        setState(() {
          _isSearching = false;
          _errorMessage = 'Fehler ${response.status}: ${response.data}';
        });
        return;
      }

      final data = response.data as Map<String, dynamic>;

      setState(() {
        _selectedPlace = data['place'] as String;
        _selectedLatitude = (data['latitude'] as num).toDouble();
        _selectedLongitude = (data['longitude'] as num).toDouble();
        _selectedTimezone = data['timezone'] as String;
        _isSearching = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _errorMessage = 'Netzwerkfehler: $e';
      });
    }
  }

  void _handleNext() {
    if (_selectedPlace == null ||
        _selectedLatitude == null ||
        _selectedLongitude == null ||
        _selectedTimezone == null) {
      setState(() {
        _errorMessage = 'Bitte gib deinen Geburtsort ein und warte auf die Ergebnisse';
      });
      return;
    }

    widget.onComplete(
      _selectedPlace!,
      _selectedLatitude!,
      _selectedLongitude!,
      _selectedTimezone!,
    );
  }

  void _handleSkip() {
    // Überspringen: Leerer Ort, keine Koordinaten
    // Aszendent kann dann nicht berechnet werden
    widget.onComplete('', 0.0, 0.0, 'UTC');
  }

  @override
  Widget build(BuildContext context) {
    final canProceed = _selectedPlace != null &&
        _selectedLatitude != null &&
        _selectedLongitude != null &&
        !_isSearching;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back Button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack,
            ),
          ),
          const SizedBox(height: 8),

          // Titel
          Text(
            'Wo bist du geboren?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Untertitel
          Text(
            'Gib deinen Geburtsort ein. Nach 3 Zeichen suchen wir automatisch.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Autocomplete Text Field
          TextFormField(
            controller: _searchController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Geburtsort',
              hintText: 'z.B. Ravensburg, Deutschland',
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _selectedPlace != null
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
            ),
          ),

          const SizedBox(height: 16),

          // Ergebnis-Anzeige
          if (_selectedPlace != null && !_isSearching) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedPlace!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Koordinaten: ${_selectedLatitude!.toStringAsFixed(4)}, ${_selectedLongitude!.toStringAsFixed(4)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Zeitzone: $_selectedTimezone',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Error Message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Info-Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dein Geburtsort wird benötigt, um deinen Aszendenten zu berechnen.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Buttons
          ElevatedButton(
            onPressed: canProceed ? _handleNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Weiter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          // Überspringen Button
          TextButton(
            onPressed: _handleSkip,
            child: Text(
              'Überspringen (Aszendent fehlt dann)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
