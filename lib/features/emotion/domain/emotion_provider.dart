import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_constants.dart';
import 'emotion_model.dart';

class EmotionNotifier
    extends StateNotifier<EmotionSelection> {
  EmotionNotifier() : super(const EmotionSelection());

  void selectMainEmotion(String key) {
    final emotionData = AppConstants.emotions.firstWhere(
      (e) => e['key'] == key,
      orElse: () => AppConstants.emotions[0],
    );
    final emotion = Emotion(
      key: emotionData['key'] as String,
      label: emotionData['label'] as String,
      emoji: emotionData['emoji'] as String,
      colorValue: AppConstants.moodColors[key] ?? 0xFF9e968e,
    );
    state =
        state.copyWith(mainEmotion: emotion, clearSub: true);
  }

  void selectSubEmotion(String key) {
    if (key == state.mainEmotion?.key) return;
    final emotionData = AppConstants.emotions
        .firstWhere((e) => e['key'] == key);
    final emotion = Emotion(
      key: emotionData['key'] as String,
      label: emotionData['label'] as String,
      emoji: emotionData['emoji'] as String,
      colorValue: AppConstants.moodColors[key] ?? 0xFF9e968e,
    );
    state = state.copyWith(subEmotion: emotion);
  }

  void setIntensity(int value) {
    state = state.copyWith(intensity: value.clamp(1, 10));
  }

  void reset() {
    state = const EmotionSelection();
  }
}

final emotionProvider = StateNotifierProvider<
    EmotionNotifier, EmotionSelection>((ref) {
  return EmotionNotifier();
});
