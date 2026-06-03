import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'database.dart';

const _uuid = Uuid();

extension UserDao on AppDatabase {
  Future<User> createUser({
    required String nickname,
    required String gender,
    required String role,
  }) {
    final user = UsersCompanion.insert(
      id: _uuid.v4(),
      nickname: nickname,
      gender: gender,
      role: role,
      createdAt: DateTime.now(),
    );
    return into(users).insertReturning(user);
  }

  Future<User?> getCurrentUser() {
    return (select(users)
          ..orderBy([(u) => OrderingTerm.desc(u.createdAt)]))
        .getSingleOrNull();
  }

  Future<int> updateUserRole(String userId, String newRole) {
    return (update(users)..where((u) => u.id.equals(userId)))
        .write(UsersCompanion(role: Value(newRole)));
  }
}

extension MoodRecordDao on AppDatabase {
  Future<MoodRecord> createMoodRecord({
    required String userId,
    required String mainMood,
    String? subMood,
    required int intensity,
    String? note,
  }) {
    final now = DateTime.now();
    final record = MoodRecordsCompanion.insert(
      id: _uuid.v4(),
      userId: userId,
      mainMood: mainMood,
      subMood: Value(subMood),
      intensity: intensity,
      note: Value(note),
      updatedAt: now,
      createdAt: now,
    );
    return into(moodRecords).insertReturning(record);
  }

  Future<List<MoodRecord>> getRecordsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return (select(moodRecords)
          ..where((m) =>
              m.userId.equals(userId) &
              m.createdAt.isBiggerOrEqualValue(start) &
              m.createdAt.isSmallerOrEqualValue(end))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
        .get();
  }

  Future<List<MoodRecord>> getRecordsByMonth(
    String userId,
    int year,
    int month,
  ) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    return getRecordsByDateRange(userId, start, end);
  }

  Future<MoodRecord?> getRecordById(String id) {
    return (select(moodRecords)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
  }

  Future<MoodRecord?> getLatestRecord(String userId) {
    return (select(moodRecords)
          ..where((m) => m.userId.equals(userId))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }
}

extension ActivityLogDao on AppDatabase {
  Future<ActivityLog> createActivityLog({
    required String moodRecordId,
    required String activityName,
    required String category,
  }) {
    final now = DateTime.now();
    final log = ActivityLogsCompanion.insert(
      id: _uuid.v4(),
      moodRecordId: moodRecordId,
      activityName: activityName,
      category: category,
      updatedAt: now,
      completedAt: now,
    );
    return into(activityLogs).insertReturning(log);
  }

  Future<ActivityLog?> getActivityByMoodRecordId(
      String moodRecordId) {
    return (select(activityLogs)
          ..where((a) => a.moodRecordId.equals(moodRecordId)))
        .getSingleOrNull();
  }
}

extension DiaryEntryDao on AppDatabase {
  Future<DiaryEntry> createDiaryEntry({
    required String moodRecordId,
    String? textContent,
    String? imagePath,
    String? audioPath,
    String? aiSummary,
  }) {
    final now = DateTime.now();
    final entry = DiaryEntriesCompanion.insert(
      id: _uuid.v4(),
      moodRecordId: moodRecordId,
      textContent: Value(textContent),
      imagePath: Value(imagePath),
      audioPath: Value(audioPath),
      aiSummary: Value(aiSummary),
      updatedAt: now,
      createdAt: now,
    );
    return into(diaryEntries).insertReturning(entry);
  }

  Future<DiaryEntry?> getEntryByMoodRecordId(
      String moodRecordId) {
    return (select(diaryEntries)
          ..where((d) => d.moodRecordId.equals(moodRecordId)))
        .getSingleOrNull();
  }
}

extension DailyCheckinDao on AppDatabase {
  Future<DailyCheckin> upsertCheckin({
    required String userId,
    required String date,
  }) {
    return into(dailyCheckins).insertReturning(
      DailyCheckinsCompanion.insert(
        date: date,
        userId: userId,
        moodCount: 1,
        createdAt: DateTime.now(),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<DailyCheckin?> getCheckinByDate(
      String date, String userId) {
    return (select(dailyCheckins)
          ..where((d) =>
              d.date.equals(date) & d.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<List<DailyCheckin>> getCheckinsByMonth(
    String userId,
    int year,
    int month,
  ) {
    final prefix =
        '$year-${month.toString().padLeft(2, '0')}';
    return (select(dailyCheckins)
          ..where((d) =>
              d.userId.equals(userId) & d.date.like('$prefix%')))
        .get();
  }
}

extension RecommendationPrefDao on AppDatabase {
  Future<void> togglePreference({
    required String userId,
    required String mood,
    required String activityName,
    bool? isHidden,
    bool? isFavorite,
  }) async {
    final existing = await (select(recommendationPrefs)
          ..where((r) =>
              r.userId.equals(userId) &
              r.mood.equals(mood) &
              r.activityName.equals(activityName)))
        .getSingleOrNull();

    if (existing != null) {
      final builder = RecommendationPrefsCompanion(
        updatedAt: Value(DateTime.now()),
        isHidden: isHidden != null ? Value(isHidden) : const Value.absent(),
        isFavorite: isFavorite != null ? Value(isFavorite) : const Value.absent(),
        count: Value(existing.count + 1),
      );
      await (update(recommendationPrefs)
            ..where((r) => r.id.equals(existing.id)))
          .write(builder);
    } else {
      await into(recommendationPrefs).insert(
        RecommendationPrefsCompanion.insert(
          userId: userId,
          mood: mood,
          activityName: activityName,
          isHidden: Value(isHidden ?? false),
          isFavorite: Value(isFavorite ?? false),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<List<RecommendationPref>> getPreferences(
      String userId) {
    return (select(recommendationPrefs)
          ..where((r) => r.userId.equals(userId)))
        .get();
  }
}
