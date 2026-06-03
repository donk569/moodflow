import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/database/dao.dart';

final totalRecordsProvider =
    FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final user =
      await ref.watch(currentUserProvider.future);
  if (user == null) return 0;

  final now = DateTime.now();
  final start = DateTime(now.year - 1);
  final records = await db.getRecordsByDateRange(
      user.id, start, now);
  return records.length;
});

final frequentMoodProvider =
    FutureProvider<String?>((ref) async {
  final db = ref.watch(databaseProvider);
  final user =
      await ref.watch(currentUserProvider.future);
  if (user == null) return null;

  final now = DateTime.now();
  final start =
      DateTime(now.year, now.month, now.day - 30);
  final records = await db.getRecordsByDateRange(
      user.id, start, now);

  if (records.isEmpty) return null;

  final moodCount = <String, int>{};
  for (final r in records) {
    moodCount[r.mainMood] =
        (moodCount[r.mainMood] ?? 0) + 1;
  }

  return moodCount.entries
      .reduce(
          (a, b) => a.value > b.value ? a : b)
      .key;
});
