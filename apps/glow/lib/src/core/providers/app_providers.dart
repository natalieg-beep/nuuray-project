import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Client Provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Current User Provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((event) => event.session?.user);
});

/// Auth State Provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// Is Authenticated Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session != null,
    loading: () => false,
    error: (_, __) => false,
  );
});
