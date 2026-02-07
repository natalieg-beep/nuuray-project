import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../services/daily_horoscope_service.dart';

/// Provider für DailyHoroscopeService
final dailyHoroscopeServiceProvider = Provider<DailyHoroscopeService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final claudeService = ref.watch(claudeApiServiceProvider);

  return DailyHoroscopeService(
    supabase: supabase,
    claudeService: claudeService, // Kann null sein (dann nur gecachte Horoskope)
  );
});

/// Provider für Tageshoroskop (gecacht, Variante A)
///
/// Lädt Basis-Horoskop aus Supabase Cache.
/// Parameter: zodiacSign (en: "aries", "taurus", ...)
final dailyHoroscopeProvider =
    FutureProvider.family<String, String>((ref, zodiacSign) async {
  final service = ref.watch(dailyHoroscopeServiceProvider);

  return await service.getBaseHoroscope(
    zodiacSign: zodiacSign,
    language: 'de',
  );
});
