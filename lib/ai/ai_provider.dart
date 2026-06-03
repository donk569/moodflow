import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_config_service.dart';
import 'openai_service.dart';
import 'models/ai_models.dart';

final hasApiKeyProvider =
    FutureProvider<bool>((ref) async {
  return ref
      .watch(aiConfigServiceProvider)
      .hasApiKey();
});

final aiDiarySummaryProvider = FutureProvider.autoDispose
    .family<String?, Map<String, dynamic>>(
        (ref, params) async {
  final service = ref.watch(openaiServiceProvider);
  final hasKey =
      await ref.watch(hasApiKeyProvider.future);
  if (!hasKey) return null;

  return service.generateDiarySummary(
    emotion: params['emotion'] as String,
    intensity: params['intensity'] as int,
    userText: params['userText'] as String?,
  );
});

final aiRecommendationProvider = FutureProvider
    .autoDispose
    .family<AiRecommendation?, Map<String, dynamic>>(
        (ref, params) async {
  final service = ref.watch(openaiServiceProvider);
  final hasKey =
      await ref.watch(hasApiKeyProvider.future);
  if (!hasKey) return null;

  return service.generateRecommendation(
    emotion: params['emotion'] as String,
    intensity: params['intensity'] as int,
  );
});
