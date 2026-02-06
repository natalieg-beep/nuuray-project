import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/constants/app_colors.dart';

/// Onboarding Schritt 2: Geburtsdatum & -zeit
class OnboardingBirthdateScreen extends StatefulWidget {
  final DateTime? initialBirthDate;
  final TimeOfDay? initialBirthTime;
  final bool initialHasBirthTime;
  final Function(DateTime birthDate, TimeOfDay? birthTime, bool hasBirthTime) onNext;
  final VoidCallback onBack;

  const OnboardingBirthdateScreen({
    super.key,
    this.initialBirthDate,
    this.initialBirthTime,
    this.initialHasBirthTime = false,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<OnboardingBirthdateScreen> createState() => _OnboardingBirthdateScreenState();
}

class _OnboardingBirthdateScreenState extends State<OnboardingBirthdateScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _hasBirthTime = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialBirthDate;
    _selectedTime = widget.initialBirthTime;
    _hasBirthTime = widget.initialHasBirthTime;
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? DateTime(now.year - 25, now.month, now.day);

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

  void _handleNext() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wähle dein Geburtsdatum'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    widget.onNext(_selectedDate!, _selectedTime, _hasBirthTime);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy', 'de_DE');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titel
          Text(
            'Wann wurdest du geboren?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Untertitel
          Text(
            'Dein Geburtsdatum und -zeitpunkt bestimmen deine kosmische Signatur.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Geburtsdatum-Auswahl
          _buildSelectionCard(
            icon: Icons.calendar_today_outlined,
            label: 'Geburtsdatum *',
            value: _selectedDate != null
                ? dateFormat.format(_selectedDate!)
                : 'Datum wählen',
            onTap: _selectDate,
            isSelected: _selectedDate != null,
          ),
          const SizedBox(height: 16),

          // Geburtszeit-Auswahl
          _buildSelectionCard(
            icon: Icons.access_time_outlined,
            label: 'Geburtszeit (optional)',
            value: _hasBirthTime && _selectedTime != null
                ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')} Uhr'
                : 'Zeit wählen',
            onTap: _selectTime,
            isSelected: _hasBirthTime && _selectedTime != null,
          ),
          const SizedBox(height: 16),

          // "Geburtszeit unbekannt" Checkbox
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
                      'Geburtszeit ist mir nicht bekannt',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
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
                  Icons.star_outline,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Die Geburtszeit ist wichtig für die präzise Berechnung deines Aszendenten '
                    'und der Häuser in deinem Chart. Ohne Geburtszeit sind die Berechnungen '
                    'weniger genau, aber immer noch sehr aussagekräftig.',
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

              // Weiter-Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleNext,
                  child: const Text('Weiter'),
                ),
              ),
            ],
          ),
        ],
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
