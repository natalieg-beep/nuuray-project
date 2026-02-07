import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../services/claude_api_service.dart';

/// Supabase Client Provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Claude API Service Provider
final claudeApiServiceProvider = Provider<ClaudeApiService?>((ref) {
  final apiKey = dotenv.env['ANTHROPIC_API_KEY'];

  developer.log(
    'ClaudeApiService Provider: API Key loaded = ${apiKey != null && apiKey.isNotEmpty ? "YES (${apiKey.substring(0, 10)}...)" : "NO"}',
    name: 'ClaudeApiProvider',
  );

  if (apiKey == null || apiKey.isEmpty) {
    developer.log('⚠️ Kein API Key → kein Service (Fallback auf gecachte Horoskope)', name: 'ClaudeApiProvider');
    return null;
  }

  return ClaudeApiService(apiKey: apiKey);
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
