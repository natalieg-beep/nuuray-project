import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nuuray_ui/nuuray_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../profile/providers/user_profile_provider.dart';
import '../../profile/services/user_profile_service.dart';
import '../../signature/providers/signature_provider.dart';
import '../../signature/services/archetype_signature_service.dart';

/// Edit Profile Screen - Ermöglicht Änderungen an Profil-Daten
///
/// WICHTIG: Nutzt inline Form-Felder (wie Onboarding-Screen)
/// statt eigenständiger Widgets, da diese nicht existieren.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Name-Felder
  late TextEditingController _displayNameController;
  late TextEditingController _fullFirstNamesController;
  late TextEditingController _birthNameController;
  late TextEditingController _lastNameController;

  // Geburtsdaten
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  bool _hasBirthTime = false;

  // Geburtsort Autocomplete
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String? _selectedPlace;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedTimezone;
  bool _isSearching = false;
  String? _errorMessage;

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    _displayNameController = TextEditingController();
    _fullFirstNamesController = TextEditingController();
    _birthNameController = TextEditingController();
    _lastNameController = TextEditingController();

    // Lade aktuelle Daten
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());

    // Autocomplete Listener
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _displayNameController.dispose();
    _fullFirstNamesController.dispose();
    _birthNameController.dispose();
    _lastNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profileAsync = ref.read(userProfileProvider);
    profileAsync.whenData((profile) {
      if (profile != null) {
        setState(() {
          _displayNameController.text = profile.displayName ?? '';
          _fullFirstNamesController.text = profile.fullFirstNames ?? '';
          _birthNameController.text = profile.birthName ?? '';
          _lastNameController.text = profile.lastName ?? '';
          _birthDate = profile.birthDate;

          // Convert DateTime? to TimeOfDay?
          if (profile.birthTime != null) {
            _birthTime = TimeOfDay(
              hour: profile.birthTime!.hour,
              minute: profile.birthTime!.minute,
            );
            _hasBirthTime = true;
          }

          if (profile.birthCity != null) {
            _searchController.text = profile.birthCity!;
            _selectedPlace = profile.birthCity;
            _selectedLatitude = profile.birthLatitude;
            _selectedLongitude = profile.birthLongitude;
            _selectedTimezone = profile.birthTimezone;
          }
        });
      }
    });
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
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
        final l10n = AppLocalizations.of(context);
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
        setState(() {
          _isSearching = false;
          _errorMessage = 'Error ${response.status}';
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
        _searchController.text = _selectedPlace!;
      });
      _markChanged();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _birthDate ?? DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
      _markChanged();
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _birthTime ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _birthTime = picked;
        _hasBirthTime = true;
      });
      _markChanged();
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentProfile = ref.read(userProfileProvider).value;
      if (currentProfile == null) {
        _showError('Profil konnte nicht geladen werden');
        return;
      }

      // Convert TimeOfDay to DateTime
      DateTime? birthTimeAsDateTime;
      if (_birthTime != null && _hasBirthTime) {
        birthTimeAsDateTime = DateTime(
          2000, 1, 1,
          _birthTime!.hour,
          _birthTime!.minute,
        );
      }

      final updatedProfile = currentProfile.copyWith(
        displayName: _displayNameController.text.trim(),
        fullFirstNames: _fullFirstNamesController.text.trim().isEmpty
            ? null
            : _fullFirstNamesController.text.trim(),
        birthName: _birthNameController.text.trim().isEmpty
            ? null
            : _birthNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        birthDate: _birthDate,
        birthTime: birthTimeAsDateTime,
        birthCity: _selectedPlace,
        birthLatitude: _selectedLatitude,
        birthLongitude: _selectedLongitude,
        birthTimezone: _selectedTimezone,
      );

      final service = UserProfileService();
      final success = await service.updateUserProfile(updatedProfile);

      if (!success) {
        _showError('Fehler beim Speichern');
        return;
      }
      log('✅ [EditProfile] Profil gespeichert');

      // WICHTIG: Lösche signature_text, damit es neu generiert wird
      // (BirthChart wird automatisch per UPSERT überschrieben)
      try {
        final supabase = Supabase.instance.client;

        await supabase
            .from('profiles')
            .update({'signature_text': null})
            .eq('id', currentProfile.id);
        log('✅ [EditProfile] Signature Text gelöscht (Chart wird per UPSERT aktualisiert)');
      } catch (e) {
        log('⚠️  [EditProfile] Fehler beim Löschen: $e');
      }

      // Invalidiere Provider → Chart wird neu berechnet
      ref.invalidate(userProfileProvider);
      ref.invalidate(signatureProvider);

      // Warte bis Chart neu berechnet wurde
      log('⏳ [EditProfile] Warte auf Chart-Neuberechnung...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Lade neu berechnetes Chart
      final newChartAsync = await ref.read(signatureProvider.future);
      
      if (newChartAsync != null) {
        log('✅ [EditProfile] Chart neu berechnet, generiere Signatur...');
        
        // Generiere Archetyp-Signatur mit neu berechnetem Chart
        final claudeService = ref.read(claudeApiServiceProvider);
        if (claudeService != null) {
          try {
            final supabase = Supabase.instance.client;
            final archetypeService = ArchetypeSignatureService(
              supabase: supabase,
              claudeService: claudeService,
            );
            
            await archetypeService.generateAndCacheArchetypeSignature(
              userId: currentProfile.id,
              birthChart: newChartAsync,
              language: updatedProfile.language,
            );
            
            log('✅ [EditProfile] Archetyp-Signatur neu generiert!');
          } catch (e) {
            log('⚠️  [EditProfile] Fehler bei Signatur-Generierung: $e');
          }
        }
      } else {
        log('⚠️  [EditProfile] Chart konnte nicht neu berechnet werden');
      }

      // Final invalidation um UI zu aktualisieren
      ref.invalidate(userProfileProvider);
      ref.invalidate(signatureProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(signatureProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil gespeichert! Chart und Archetyp wurden aktualisiert.'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      log('❌ [EditProfile] Fehler: $e');
      _showError('Fehler beim Speichern');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil bearbeiten'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_hasChanges && !_isLoading)
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                l10n.generalSave,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Info Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Änderungen werden gespeichert. Chart und Archetyp werden automatisch neu berechnet.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name Section
                    Text(
                      'Name',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(labelText: 'Rufname *'),
                      onChanged: (_) => _markChanged(),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Pflichtfeld' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fullFirstNamesController,
                      decoration: const InputDecoration(labelText: 'Vornamen (optional)'),
                      onChanged: (_) => _markChanged(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _birthNameController,
                      decoration: const InputDecoration(labelText: 'Geburtsname (optional)'),
                      onChanged: (_) => _markChanged(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Nachname (optional)'),
                      onChanged: (_) => _markChanged(),
                    ),
                    const SizedBox(height: 32),

                    // Geburtsdaten Section
                    Text(
                      'Geburtsdaten',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Datum
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Geburtsdatum *'),
                        child: Text(
                          _birthDate != null
                              ? DateFormat('dd.MM.yyyy').format(_birthDate!)
                              : 'Tippen zum Auswählen',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Zeit
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: _hasBirthTime ? _selectTime : null,
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Geburtszeit (optional)'),
                            child: Text(
                              _birthTime != null && _hasBirthTime
                                  ? _birthTime!.format(context)
                                  : 'Unbekannt',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          title: const Text('Geburtszeit unbekannt'),
                          value: !_hasBirthTime,
                          onChanged: (val) {
                            setState(() {
                              _hasBirthTime = !(val ?? false);
                              if (!_hasBirthTime) _birthTime = null;
                            });
                            _markChanged();
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Ort
                    TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Geburtsort (optional)',
                        hintText: 'z.B. München, Deutschland',
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
                      onChanged: (_) => _markChanged(),
                    ),

                    // Geocoding Result
                    if (_selectedPlace != null && _errorMessage == null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedPlace!,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lat: ${_selectedLatitude!.toStringAsFixed(4)}, '
                              'Lng: ${_selectedLongitude!.toStringAsFixed(4)}',
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

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_errorMessage!)),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _hasChanges ? _saveProfile : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor: AppColors.surfaceDark,
                      ),
                      child: Text(
                        l10n.generalSave,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
