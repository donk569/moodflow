import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'ai_config_service.dart';
import 'models/ai_models.dart';

final openaiServiceProvider =
    Provider<OpenAiService>((ref) {
  return OpenAiService(
      ref.watch(aiConfigServiceProvider));
});

class OpenAiService {
  final AiConfigService _config;
  static const _baseUrl =
      'https://api.openai.com/v1';

  OpenAiService(this._config);

  Future<String?> generateDiarySummary({
    required String emotion,
    required int intensity,
    String? userText,
    String? imageDescription,
  }) async {
    final apiKey = await _config.getApiKey();
    if (apiKey == null || apiKey.isEmpty) return null;

    try {
      final messages = [
        const ChatMessage(
          role: 'system',
          content:
              '你是一个温柔的情绪陪伴助手。根据用户的情绪和输入，生成一句简短的、温柔有感而发的日记摘要。不超过50字。语气温暖、不评判、不说教。使用"你"来称呼用户。',
        ),
        ChatMessage(
          role: 'user',
          content:
              '今天我感受到的情绪是：$emotion（强度 $intensity/10）。${userText != null ? '我想说的话：$userText' : ''}${imageDescription != null ? '我分享的图片描述：$imageDescription' : ''}请帮我把这段感受总结成一句温柔的日记。',
        ),
      ];

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages':
              messages.map((m) => m.toJson()).toList(),
          'max_tokens': 80,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']
                ?['content']
            ?.toString()
            .trim();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<AiRecommendation?> generateRecommendation({
    required String emotion,
    required int intensity,
    List<String>? recentMoods,
  }) async {
    final apiKey = await _config.getApiKey();
    if (apiKey == null || apiKey.isEmpty) return null;

    try {
      final messages = [
        const ChatMessage(
          role: 'system',
          content:
              '你是一个情绪陪伴助手，根据用户当前情绪推荐一个适合做的活动。返回JSON格式：{"activity_name": "活动名", "reason": "推荐理由", "category": "分类"}。分类只能是：放松、快速恢复、社交、自我成长。',
        ),
        ChatMessage(
          role: 'user',
          content:
              '我现在的情绪是：$emotion（强度 $intensity/10）。${recentMoods != null ? '最近的情绪变化：${recentMoods.join(' → ')}' : ''}请给我推荐一个适合现在做的事。',
        ),
      ];

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages':
              messages.map((m) => m.toJson()).toList(),
          'max_tokens': 100,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]
                ?['message']?['content']
            ?.toString()
            .trim();
        if (content != null) {
          final json = jsonDecode(content);
          return AiRecommendation(
            activityName: json['activity_name'],
            reason: json['reason'],
            category: json['category'],
          );
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
