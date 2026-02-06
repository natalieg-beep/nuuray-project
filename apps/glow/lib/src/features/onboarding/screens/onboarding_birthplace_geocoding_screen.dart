import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuuray_api/nuuray_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/constants/app_colors.dart';

/// Onboarding Schritt 3: Geburtsort mit Server-seitigem Geocoding
///
/// Nutzt Supabase Edge Function für sicheres Geocoding via Google Places API.
class OnboardingBirthplaceGeocodingScreen extends ConsumerStatefulWidget {
  final String? initialBirthPlace;
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialTimezone;
  final Function(String place, double latitude, double longitude, String timezone) onComplete;
  final VoidCallback onBack;

  const OnboardingBirthplaceGeocodingScreen({
    super.key,
    this.initialBirthPlace,
    this.initialLatitude,
    this.initialLongitude,
    this.initialTimezone,
    required this.onComplete,
    required this.onBack,
  });

  @override
  ConsumerState<OnboardingBirthplaceGeocodingScreen> createState() =>
      _OnboardingBirthplaceGeocodingScreenState();
}

class _OnboardingBirthplaceGeocodingScreenState
    extends ConsumerState<OnboardingBirthplaceGeocodingScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final GeocodingService _geocodingService;

  String? _selectedPlace;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedTimezone;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _geocodingService = GeocodingService(Supabase.instance.client);

    if (widget.initialBirthPlace != null) {
      _searchController.text = widget.initialBirthPlace!;
      _selectedPlace = widget.initialBirthPlace;
      _selectedLatitude = widget.initialLatitude;
      _selectedLongitude = widget.initialLongitude;
      _selectedTimezone = widget.initialTimezone;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Bitte gib einen Ort ein';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _geocodingService.geocodePlace(query);

      if (result == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Kein Ort gefunden. Versuche es mit "Stadt, Land"';
        });
        return;
      }

      setState(() {
        _selectedPlace = result.place;
        _selectedLatitude = result.latitude;
        _selectedLongitude = result.longitude;
        _selectedTimezone = result.timezone;
        _searchController.text = result.place;
        _isLoading = false;
        _errorMessage = null;
      });

      // Erfolgs-Feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Ort gefunden: ${result.place}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Fehler beim Geocoding: $e';
      });
    }
  }

  void _handleSkip() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ohne Geburtsort sind einige Berechnungen weniger präzise'),
        duration: Duration(seconds: 2),
      ),
    );

    // Ohne Geburtsort fortfahren (null-Werte)
    widget.onComplete('Unbekannt', 0.0, 0.0, 'UTC');
  }

  void _handleComplete() {
    if (_selectedPlace == null ||
        _selectedLatitude == null ||
        _selectedLongitude == null ||
        _selectedTimezone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte suche zuerst nach deinem Geburtsort'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    widget.onComplete(
      _selectedPlace!,
      _selectedLatitude!,
      _selectedLongitude!,
      _selectedTimezone!,
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
          const SizedBox(height: 32),

          // Suchfeld
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
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
                          _selectedTimezone = null;
                          _errorMessage = null;
                        });
                      },
                    )
                  : null,
              errorText: _errorMessage,
            ),
            onSubmitted: (_) => _handleSearch(),
            onChanged: (value) {
              // Reset Auswahl wenn Text geändert wird
              if (_selectedPlace != null && value != _selectedPlace) {
                setState(() {
                  _selectedPlace = null;
                  _selectedLatitude = null;
                  _selectedLongitude = null;
                  _selectedTimezone = null;
                  _errorMessage = null;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Such-Button
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleSearch,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.search),
            label: Text(_isLoading ? 'Suche...' : 'Ort suchen'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 24),

          // Ergebnis-Anzeige
          if (_selectedPlace != null && _selectedLatitude != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ort gefunden:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedPlace!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Koordinaten: ${_selectedLatitude!.toStringAsFixed(4)}°, ${_selectedLongitude!.toStringAsFixed(4)}°',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    'Zeitzone: $_selectedTimezone',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

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
                const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Der Geburtsort wird benötigt, um deinen Aszendenten und '
                    'präzise planetare Positionen zu berechnen. '
                    'Gib deinen Ort im Format "Stadt, Land" ein.',
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
                  onPressed: _selectedPlace != null ? _handleComplete : null,
                  child: const Text('Fertig'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
