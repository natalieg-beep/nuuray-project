import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

/// Provider für den Auth Service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider für den aktuellen User (null wenn nicht eingeloggt)
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);

  return authService.authStateChanges.map((state) {
    return state.session?.user;
  });
});

/// Provider um zu prüfen ob User eingeloggt ist
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});
