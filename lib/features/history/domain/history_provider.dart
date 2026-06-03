import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/database/database.dart';
import '../../../core/database/dao.dart';

final historyProvider = FutureProvider.autoDispose
    .family<List<MoodRecord>, String?>(
        (ref, search) async {
  final db = ref.watch(databaseProvider);
  final user =
      await ref.watch(currentUserProvider.future);
  if (user == null) return [];

  final now = DateTime.now();
  final start =
      DateTime(now.year, now.month, now.day - 90);
  return db.getRecordsByDateRange(
      user.id, start, now);
});
