import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

/// MiniMax AI service using OpenAI-compatible Chat Completions API.
///
/// API Base URL: https://api.minimax.io/v1
/// Supported models: MiniMax-M2.7, MiniMax-M2.5, MiniMax-M2.5-highspeed
class MiniMaxService {
  final String apiKey;
  final String model;

  static const String _baseUrl = 'https://api.minimax.io/v1';

  // Store conversation history per session for multi-turn support
  final Map<String, List<Map<String, String>>> _sessionHistory = {};

  MiniMaxService({
    required this.apiKey,
    required this.model,
  });

  /// Send a message and get a blocking response.
  Future<String> sendMessage(
    String message, {
    String sessionId = 'default_session',
    bool forceNewConversation = false,
  }) async {
    try {
      if (forceNewConversation) {
        _sessionHistory.remove(sessionId);
        print('MiniMaxService: 强制创建新会话，清除历史');
      }

      // Get or create history for this session
      final history = _sessionHistory.putIfAbsent(sessionId, () => []);

      // Add user message to history
      history.add({'role': 'user', 'content': message});

      final requestUrl = '$_baseUrl/chat/completions';

      print('MiniMaxService: 发送请求到 $requestUrl');
      print(
        'MiniMaxService: API Key = ${apiKey.substring(0, math.min(5, apiKey.length))}...',
      );
      print('MiniMaxService: 模型 = $model');
      print('MiniMaxService: 会话 ID = $sessionId');

      // Clamp temperature to MiniMax's valid range (0, 1]
      final double temperature = 0.7;

      final requestBody = jsonEncode({
        'model': model,
        'messages': history,
        'temperature': temperature,
        'max_tokens': 4096,
      });

      final response = await http.post(
        Uri.parse(requestUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          String content =
              choices[0]['message']?['content'] as String? ?? '无回复';

          // Strip thinking tags if present (MiniMax M2.5+ may include them)
          content = _stripThinkingTags(content);

          // Add assistant response to history
          history.add({'role': 'assistant', 'content': content});

          return content;
        }
        return '无回复';
      } else {
        throw Exception(
          'API 请求失败: ${response.statusCode}, 响应: ${response.body}',
        );
      }
    } catch (e) {
      print('MiniMaxService 错误: $e');
      throw Exception('发送消息失败: $e');
    }
  }

  /// Send a message and stream the response.
  Stream<String> sendMessageStream(
    String message, {
    String sessionId = 'default_session',
    bool forceNewConversation = false,
  }) async* {
    try {
      if (forceNewConversation) {
        _sessionHistory.remove(sessionId);
        print('MiniMaxService Stream: 强制创建新会话，清除历史');
      }

      // Get or create history for this session
      final history = _sessionHistory.putIfAbsent(sessionId, () => []);

      // Add user message to history
      history.add({'role': 'user', 'content': message});

      final requestUrl = '$_baseUrl/chat/completions';

      print('MiniMaxService Stream: 发送请求到 $requestUrl');
      print(
        'MiniMaxService Stream: API Key = ${apiKey.substring(0, math.min(5, apiKey.length))}...',
      );
      print('MiniMaxService Stream: 模型 = $model');
      print('MiniMaxService Stream: 会话 ID = $sessionId');

      final request = http.Request('POST', Uri.parse(requestUrl));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      });

      final requestBody = jsonEncode({
        'model': model,
        'messages': history,
        'temperature': 0.7,
        'max_tokens': 4096,
        'stream': true,
      });

      request.body = requestBody;

      final streamedResponse = await http.Client().send(request);
      print(
        'MiniMaxService Stream: 响应状态码 = ${streamedResponse.statusCode}',
      );

      if (streamedResponse.statusCode != 200) {
        final responseBody = await streamedResponse.stream.bytesToString();
        print('MiniMaxService Stream: 错误响应体 = $responseBody');
        throw Exception(
          'API 请求失败: ${streamedResponse.statusCode}, 响应: $responseBody',
        );
      }

      final StringBuffer fullContent = StringBuffer();
      bool isFirstChunk = true;

      await for (final chunk in streamedResponse.stream.transform(
        utf8.decoder,
      )) {
        for (final line in chunk.split('\n')) {
          if (line.startsWith('data: ')) {
            final dataStr = line.substring(6).trim();
            if (dataStr == '[DONE]') continue;

            try {
              final event = jsonDecode(dataStr);

              if (isFirstChunk) {
                print('MiniMaxService Stream: 首个事件');
                isFirstChunk = false;
              }

              final delta =
                  event['choices']?[0]?['delta']?['content'] as String?;
              if (delta != null && delta.isNotEmpty) {
                fullContent.write(delta);
                yield delta;
              }
            } catch (e) {
              // Skip malformed JSON lines
              continue;
            }
          }
        }
      }

      // Strip thinking tags from full content and add to history
      final cleanContent = _stripThinkingTags(fullContent.toString());
      history.add({'role': 'assistant', 'content': cleanContent});
    } catch (e) {
      print('MiniMaxService Stream 错误: $e');
      yield '【服务响应异常】';
    }
  }

  /// Clear conversation history for a specific session.
  void clearConversation(String sessionId) {
    _sessionHistory.remove(sessionId);
    print('MiniMaxService: 已清除会话 $sessionId 的历史');
  }

  /// Clear all conversation histories.
  void clearAllConversations() {
    _sessionHistory.clear();
    print('MiniMaxService: 已清除所有会话历史');
  }

  /// Strip <think>...</think> tags from response content.
  String _stripThinkingTags(String content) {
    return content.replaceAll(RegExp(r'<think>[\s\S]*?</think>'), '').trim();
  }
}
