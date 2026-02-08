import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nuuray_ui/nuuray_ui.dart';

import '../../../shared/constants/app_colors.dart';

/// Onboarding Schritt 2: Geburtsdaten KOMBINIERT (Datum + Zeit + Ort mit Autocomplete)
class OnboardingBirthdataCombinedScreen extends ConsumerStatefulWidget {
  final DateTime? initialBirthDate;
  final TimeOfDay? initialBirthTime;
  final bool initialHasBirthTime;
  final String? initialBirthPlace;
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialTimezone;
  final Function(
    DateTime birthDate,
    TimeOfDay? birthTime,
    bool hasBirthTime,
    String? birthPlace,
    double? latitude,
    double? longitude,
    String? timezone,
  ) onComplete;
  final VoidCallback onBack;

  const OnboardingBirthdataCombinedScreen({
    super.key,
    this.initialBirthDate,
    this.initialBirthTime,
    this.initialHasBirthTime = false,
    this.initialBirthPlace,
    this.initialLatitude,
    this.initialLongitude,
    this.initialTimezone,
    required this.onComplete,
    required this.onBack,
  });

  @override
  ConsumerState<OnboardingBirthdataCombinedScreen> createState() =>
      _OnboardingBirthdataCombinedScreenState();
}

class _OnboardingBirthdataCombinedScreenState
    extends ConsumerState<OnboardingBirthdataCombinedScreen> {
  // Datum & Zeit
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _hasBirthTime = false;

  // Geburtsort mit Autocomplete
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

    _selectedDate = widget.initialBirthDate;
    _selectedTime = widget.initialBirthTime;
    _hasBirthTime = widget.initialHasBirthTime;

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
      final supabase = Supabase.instance.client;

      final response = await supabase.functions.invoke(
        'geocode-place',
        body: {'query': query},
      );

      if (!mounted) return;

      if (response.status == 404) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _isSearching = false;
          _errorMessage = l10n.onboardingPlaceNotFound;
          _selectedPlace = null;
          _selectedLatitude = null;
          _selectedLongitude = null;
          _selectedTimezone = null;
        });
        return;
      }

      if (response.status != 200) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _isSearching = false;
          _errorMessage = '${l10n.generalError} ${response.status}: ${response.data}';
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

        // ✅ NICHT den TextField überschreiben - User-Eingabe bleibt erhalten!
        // Der gefundene Ort wird in der grünen Success-Box angezeigt
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isSearching = false;
        _errorMessage = '${l10n.onboardingPlaceNetworkError}: $e';
      });
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate =
        _selectedDate ?? DateTime(now.year - 25, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('de', 'DE'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final initialTime = _selectedTime ?? const TimeOfDay(hour: 12, minute: 0);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _hasBirthTime = true;
      });
    }
  }

  void _handleComplete() {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.onboardingDateRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Geburtsort ist optional
    widget.onComplete(
      _selectedDate!,
      _selectedTime,
      _hasBirthTime,
      _selectedPlace,
      _selectedLatitude,
      _selectedLongitude,
      _selectedTimezone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat('dd.MM.yyyy', locale.toString());

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titel
            Text(
              l10n.onboardingBirthdataTitle,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            Text(
              l10n.onboardingBirthdataSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // 📅 GEBURTSDATUM
            _buildSelectionCard(
              icon: Icons.calendar_today_outlined,
              label: l10n.onboardingDateLabel,
              value: _selectedDate != null
                  ? dateFormat.format(_selectedDate!)
                  : l10n.onboardingDateSelect,
              onTap: _selectDate,
              isSelected: _selectedDate != null,
            ),
            const SizedBox(height: 16),

            // 🕐 GEBURTSZEIT
            _buildSelectionCard(
              icon: Icons.access_time_outlined,
              label: l10n.onboardingTimeLabel,
              value: _hasBirthTime && _selectedTime != null
                  ? l10n.onboardingTimeValue(_selectedTime!.hour.toString().padLeft(2, '0'), _selectedTime!.minute.toString().padLeft(2, '0'))
                  : l10n.onboardingTimeSelect,
              onTap: _selectTime,
              isSelected: _hasBirthTime && _selectedTime != null,
            ),
            const SizedBox(height: 8),

            // Checkbox
            InkWell(
              onTap: () {
                setState(() {
                  if (_hasBirthTime) {
                    _hasBirthTime = false;
                    _selectedTime = null;
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: !_hasBirthTime,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _hasBirthTime = false;
                            _selectedTime = null;
                          }
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Text(
                        l10n.onboardingTimeUnknown,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 📍 GEBURTSORT
            Text(
              l10n.onboardingPlaceLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.onboardingPlaceHelper,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),

            // Autocomplete-Suchfeld
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.onboardingPlaceSearchLabel,
                hintText: l10n.onboardingPlaceSearchHint,
                helperText: l10n.onboardingPlaceSearchHelper,
                prefixIcon: const Icon(Icons.place_outlined),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Success
            if (_selectedPlace != null && _selectedLatitude != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedPlace!,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade900,
                                    ),
                          ),
                          Text(
                            '${_selectedLatitude!.toStringAsFixed(2)}°, ${_selectedLongitude!.toStringAsFixed(2)}°',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.green.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Error
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red.shade900,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Hinweis: Ort überspringen
            if (_searchController.text.isNotEmpty && _selectedPlace == null)
              TextButton.icon(
                onPressed: () {
                  // User will ohne Ort fortfahren
                  setState(() {
                    _searchController.clear();
                    _errorMessage = null;
                  });
                },
                icon: const Icon(Icons.close, size: 18),
                label: Text(l10n.onboardingPlaceSkip),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),

            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                OutlinedButton(
                  onPressed: widget.onBack,
                  child: Text(l10n.generalBack),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleComplete,
                    child: Text(l10n.generalFinish),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceDark,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
