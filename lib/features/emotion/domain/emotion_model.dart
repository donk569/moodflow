class Emotion {
  final String key;
  final String label;
  final String emoji;
  final int colorValue;

  const Emotion({
    required this.key,
    required this.label,
    required this.emoji,
    required this.colorValue,
  });
}

class EmotionSelection {
  final Emotion? mainEmotion;
  final Emotion? subEmotion;
  final int intensity;

  const EmotionSelection({
    this.mainEmotion,
    this.subEmotion,
    this.intensity = 5,
  });

  bool get isValid => mainEmotion != null;

  EmotionSelection copyWith({
    Emotion? mainEmotion,
    Emotion? subEmotion,
    int? intensity,
    bool clearSub = false,
    bool clearMain = false,
  }) {
    return EmotionSelection(
      mainEmotion:
          clearMain ? null : (mainEmotion ?? this.mainEmotion),
      subEmotion:
          clearSub ? null : (subEmotion ?? this.subEmotion),
      intensity: intensity ?? this.intensity,
    );
  }
}
