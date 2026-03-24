import 'package:flutter_test/flutter_test.dart';
import 'package:ai_assistant/models/minimax_config.dart';
import 'package:ai_assistant/services/minimax_service.dart';

/// Integration tests for MiniMax AI provider.
///
/// These tests require a valid MINIMAX_API_KEY environment variable.
/// To run: flutter test test/minimax_integration_test.dart
///
/// Set the environment variable before running:
///   export MINIMAX_API_KEY=your_api_key_here
void main() {
  group('MiniMax API Integration', () {
    late MiniMaxService service;
    final apiKey = const String.fromEnvironment(
      'MINIMAX_API_KEY',
      defaultValue: '',
    );

    setUp(() {
      if (apiKey.isEmpty) return;
      service = MiniMaxService(
        apiKey: apiKey,
        model: 'MiniMax-M2.7',
      );
    });

    test('should send message and receive response', () async {
      if (apiKey.isEmpty) {
        // Skip test if no API key
        return;
      }

      final response = await service.sendMessage(
        'Say "hello" in one word',
        sessionId: 'integration-test-1',
      );

      expect(response, isNotEmpty);
      expect(response, isNot('无回复'));
    }, skip: apiKey.isEmpty ? 'MINIMAX_API_KEY not set' : null);

    test('should maintain conversation history', () async {
      if (apiKey.isEmpty) return;

      await service.sendMessage(
        'My name is TestBot',
        sessionId: 'integration-test-2',
      );

      final response = await service.sendMessage(
        'What is my name?',
        sessionId: 'integration-test-2',
      );

      expect(response.toLowerCase(), contains('testbot'));
    }, skip: apiKey.isEmpty ? 'MINIMAX_API_KEY not set' : null);

    test('should clear conversation history', () async {
      if (apiKey.isEmpty) return;

      await service.sendMessage(
        'Remember the code word: PINEAPPLE',
        sessionId: 'integration-test-3',
      );

      service.clearConversation('integration-test-3');

      final response = await service.sendMessage(
        'What was the code word I told you?',
        sessionId: 'integration-test-3',
      );

      // After clearing, the model should not remember
      expect(response.toLowerCase().contains('pineapple'), isFalse);
    }, skip: apiKey.isEmpty ? 'MINIMAX_API_KEY not set' : null);
  });
}
