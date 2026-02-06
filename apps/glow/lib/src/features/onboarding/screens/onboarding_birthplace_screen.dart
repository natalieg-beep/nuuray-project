import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../../shared/constants/app_colors.dart';

/// Onboarding Schritt 3: Geburtsort mit Google Places
class OnboardingBirthplaceScreen extends StatefulWidget {
  final String? initialBirthPlace;
  final double? initialLatitude;
  final double? initialLongitude;
  final String googlePlacesApiKey;
  final Function(String place, double latitude, double longitude, String timezone) onComplete;
  final VoidCallback onBack;

  const OnboardingBirthplaceScreen({
    super.key,
    this.initialBirthPlace,
    this.initialLatitude,
    this.initialLongitude,
    required this.googlePlacesApiKey,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<OnboardingBirthplaceScreen> createState() => _OnboardingBirthplaceScreenState();
}

class _OnboardingBirthplaceScreenState extends State<OnboardingBirthplaceScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedPlace;
  double? _selectedLatitude;
  double? _selectedLongitude;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialBirthPlace != null) {
      _searchController.text = widget.initialBirthPlace!;
      _selectedPlace = widget.initialBirthPlace;
      _selectedLatitude = widget.initialLatitude;
      _selectedLongitude = widget.initialLongitude;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handlePlaceSelected(Prediction prediction) async {
    setState(() => _isLoading = true);

    // Hier würden wir normalerweise Place Details abrufen für Lat/Lng
    // Für MVP nutzen wir erstmal die Prediction-Daten
    // TODO: Implementiere Place Details API Call für genaue Koordinaten

    setState(() {
      _selectedPlace = prediction.description ?? '';
      // Placeholder Koordinaten - in Produktion via Place Details API
      _selectedLatitude = 0.0;
      _selectedLongitude = 0.0;
      _searchController.text = prediction.description ?? '';
      _isLoading = false;
    });
  }

  void _handleSkip() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ohne Geburtsort sind einige Berechnungen weniger präzise'),
        duration: Duration(seconds: 2),
      ),
    );

    // Ohne Geburtsort fortfahren (mit Dummy-Daten)
    widget.onComplete('Unbekannt', 0.0, 0.0, 'UTC');
  }

  void _handleComplete() {
    if (_selectedPlace == null || _selectedLatitude == null || _selectedLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wähle deinen Geburtsort aus'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // TODO: Timezone aus Koordinaten bestimmen (via TimeZone API)
    final timezone = 'Europe/Berlin'; // Placeholder

    widget.onComplete(
      _selectedPlace!,
      _selectedLatitude!,
      _selectedLongitude!,
      timezone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 8),

          // DEBUG: API Key anzeigen
          if (widget.googlePlacesApiKey.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⚠️ Google Places API Key fehlt!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '✓ API Key geladen: ${widget.googlePlacesApiKey.substring(0, 20)}...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade700,
                    ),
              ),
            ),
          const SizedBox(height: 16),

          // Google Places Autocomplete
          GooglePlaceAutoCompleteTextField(
            textEditingController: _searchController,
            googleAPIKey: widget.googlePlacesApiKey,
            inputDecoration: InputDecoration(
              labelText: 'Geburtsort',
              hintText: 'z.B. München, Deutschland',
              prefixIcon: const Icon(Icons.location_on_outlined),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _selectedPlace = null;
                          _selectedLatitude = null;
                          _selectedLongitude = null;
                        });
                      },
                    )
                  : null,
            ),
            debounceTime: 600,
            countries: const ["de", "at", "ch"], // DACH-Region bevorzugen
            isLatLngRequired: true,
            getPlaceDetailWithLatLng: (Prediction prediction) {
              _handlePlaceSelected(prediction);
            },
            itemClick: (Prediction prediction) {
              _searchController.text = prediction.description ?? '';
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description?.length ?? 0),
              );
            },
            seperatedBuilder: const Divider(),
            containerHorizontalPadding: 0,
            itemBuilder: (context, index, Prediction prediction) {
              return Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 20, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        prediction.description ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            },
            isCrossBtnShown: false,
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
                  Icons.public_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Der Geburtsort wird benötigt, um dein Geburtshoroskop '
                    'mit den genauen planetaren Positionen zu berechnen. '
                    'Ohne diese Angabe sind einige astrologische Berechnungen '
                    'nicht möglich.',
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
                  onPressed: _isLoading ? null : _handleComplete,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Fertig'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
