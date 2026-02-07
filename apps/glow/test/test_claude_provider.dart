import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nuuray_glow/src/core/providers/app_providers.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // .env laden
  await dotenv.load(fileName: '.env');

  test('ClaudeApiService Provider sollte initialisiert werden', () {
    final container = ProviderContainer();

    final claudeService = container.read(claudeApiServiceProvider);

    print('ClaudeService: $claudeService');
    print('API Key aus .env: ${dotenv.env['ANTHROPIC_API_KEY']?.substring(0, 10)}...');

    expect(claudeService, isNotNull,
        reason: 'ClaudeApiService sollte nicht null sein wenn API Key vorhanden');
  });
}
