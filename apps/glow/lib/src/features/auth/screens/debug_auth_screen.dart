import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/app_colors.dart';
import '../providers/auth_provider.dart';

/// Debug-Screen um Auth-Status zu prüfen
class DebugAuthScreen extends ConsumerWidget {
  const DebugAuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Debug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auth Status',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 24),

            _buildInfoRow('Eingeloggt:', authService.isAuthenticated ? 'Ja' : 'Nein'),
            const SizedBox(height: 16),

            if (currentUser != null) ...[
              _buildInfoRow('User ID:', currentUser.id),
              const SizedBox(height: 16),
              _buildInfoRow('Email:', currentUser.email ?? 'N/A'),
              const SizedBox(height: 16),
              _buildInfoRow('Email bestätigt:', currentUser.emailConfirmedAt != null ? 'Ja' : 'Nein'),
              const SizedBox(height: 16),
              _buildInfoRow('Erstellt am:', currentUser.createdAt.toString()),
            ],

            const Spacer(),

            if (authService.isAuthenticated)
              ElevatedButton(
                onPressed: () async {
                  await authService.signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Logout'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
