import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/database/dao.dart';
import '../../emotion/domain/emotion_provider.dart';
import '../../recommend/engine/recommend_engine.dart';

class RecordNotifier extends StateNotifier<RecordState> {
  final Ref _ref;

  RecordNotifier(this._ref) : super(const RecordState());

  Future<void> submitRecord({
    String? textContent,
    String? imagePath,
    String? audioPath,
    Activity? activity,
  }) async {
    final db = _ref.read(databaseProvider);
    final user =
        await _ref.read(currentUserProvider.future);
    if (user == null) return;

    final emotion = _ref.read(emotionProvider);

    state = state.copyWith(isSubmitting: true);

    try {
      final now = DateTime.now();
      final dateStr =
          DateFormat('yyyy-MM-dd').format(now);

      final moodRecord = await db.createMoodRecord(
        userId: user.id,
        mainMood: emotion.mainEmotion!.key,
        subMood: emotion.subEmotion?.key,
        intensity: emotion.intensity,
        note: textContent,
      );

      if (activity != null) {
        await db.createActivityLog(
          moodRecordId: moodRecord.id,
          activityName: activity.name,
          category: activity.category,
        );
      }

      if (textContent != null ||
          imagePath != null ||
          audioPath != null) {
        await db.createDiaryEntry(
          moodRecordId: moodRecord.id,
          textContent: textContent,
          imagePath: imagePath,
          audioPath: audioPath,
        );
      }

      await db.upsertCheckin(
          userId: user.id, date: dateStr);

      state = state.copyWith(
          isSubmitting: false, isComplete: true);

      _ref.read(emotionProvider.notifier).reset();
    } catch (e) {
      state = state.copyWith(
          isSubmitting: false, error: e.toString());
    }
  }

  void reset() => state = const RecordState();
}

class RecordState {
  final bool isSubmitting;
  final bool isComplete;
  final String? error;

  const RecordState({
    this.isSubmitting = false,
    this.isComplete = false,
    this.error,
  });

  RecordState copyWith({
    bool? isSubmitting,
    bool? isComplete,
    String? error,
  }) {
    return RecordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
    );
  }
}

final recordProvider =
    StateNotifierProvider<RecordNotifier, RecordState>(
        (ref) {
  return RecordNotifier(ref);
});
