import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/database/dao.dart';
import '../../../core/providers/core_providers.dart';

class CalendarData {
  final DateTime month;
  final Map<String, MoodRecord?> records;
  final Map<String, DailyCheckin?> checkins;

  const CalendarData({
    required this.month,
    required this.records,
    required this.checkins,
  });
}

final calendarProvider = FutureProvider.family<CalendarData,
    DateTime>((ref, month) async {
  final db = ref.watch(databaseProvider);
  final user =
      await ref.watch(currentUserProvider.future);
  if (user == null) {
    return CalendarData(
      month: month,
      records: {},
      checkins: {},
    );
  }

  final records = await db.getRecordsByMonth(
      user.id, month.year, month.month);
  final checkins = await db.getCheckinsByMonth(
      user.id, month.year, month.month);

  final recordMap = <String, MoodRecord?>{};
  for (final r in records) {
    final dateStr =
        '${r.createdAt.year}-${r.createdAt.month.toString().padLeft(2, '0')}-${r.createdAt.day.toString().padLeft(2, '0')}';
    recordMap[dateStr] = r;
  }

  final checkinMap = <String, DailyCheckin?>{};
  for (final c in checkins) {
    checkinMap[c.date] = c;
  }

  return CalendarData(
    month: month,
    records: recordMap,
    checkins: checkinMap,
  );
});
