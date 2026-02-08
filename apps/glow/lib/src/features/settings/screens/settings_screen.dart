import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nuuray_ui/nuuray_ui.dart';

import '../../../core/providers/language_provider.dart';
import '../../../shared/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

/// Settings Screen
///
/// Zeigt App-Einstellungen inkl. Sprach-Auswahl
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Sprache Section
            _buildSectionHeader(context, l10n.settingsLanguage),
            const SizedBox(height: 12),
            _buildLanguageCard(context, ref, currentLocale, languageNotifier),
            const SizedBox(height: 32),

            // Benachrichtigungen Section
            _buildSectionHeader(context, l10n.settingsNotifications),
            const SizedBox(height: 12),
            _buildSwitchTile(
              context,
              title: l10n.settingsDailyReminder,
              subtitle: 'Tägliches Horoskop um 8:00 Uhr',
              value: false, // TODO: Aus Einstellungen laden
              onChanged: (value) {
                // TODO: Speichern
              },
            ),
            const SizedBox(height: 32),

            // Account Section
            _buildSectionHeader(context, 'Account'),
            const SizedBox(height: 12),
            _buildListTile(
              context,
              icon: Icons.person_outline,
              title: 'Profil bearbeiten',
              subtitle: 'Name und Geburtsdaten ändern',
              onTap: () {
                context.push('/edit-profile');
              },
            ),
            const SizedBox(height: 32),

            // Info Section
            _buildSectionHeader(context, 'Information'),
            const SizedBox(height: 12),
            _buildListTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: l10n.settingsPrivacy,
              onTap: () {
                // TODO: Show privacy policy
              },
            ),
            _buildListTile(
              context,
              icon: Icons.description_outlined,
              title: l10n.settingsTerms,
              onTap: () {
                // TODO: Show terms
              },
            ),
            _buildListTile(
              context,
              icon: Icons.info_outline,
              title: l10n.settingsAbout,
              onTap: () {
                // TODO: Show about dialog
              },
            ),
            const SizedBox(height: 32),

            // Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                // Show confirmation dialog
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.settingsLogout),
                    content: const Text('Möchtest du dich wirklich abmelden?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.generalCancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(l10n.settingsLogout),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true && context.mounted) {
                  await ref.read(authServiceProvider).signOut();
                  // Router handled automatisch durch GoRouter Auth-Listener
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.settingsLogout),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 40),

            // Version Info
            Center(
              child: Text(
                'Nuuray Glow v0.1.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
    LanguageNotifier languageNotifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceDark),
      ),
      child: Column(
        children: LanguageNotifier.supportedLocales.map((locale) {
          final isSelected = locale.languageCode == currentLocale.languageCode;
          final flag = languageNotifier.getLanguageFlag(locale);
          final name = languageNotifier.getLanguageName(locale);

          return InkWell(
            onTap: () {
              if (!isSelected) {
                languageNotifier.setLanguage(locale);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: locale != LanguageNotifier.supportedLocales.last
                    ? const Border(
                        bottom: BorderSide(color: AppColors.surfaceDark))
                    : null,
              ),
              child: Row(
                children: [
                  Text(flag, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceDark),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceDark),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
