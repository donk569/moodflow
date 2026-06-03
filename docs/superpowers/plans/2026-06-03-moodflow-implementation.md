# MoodFlow 心情记录 App 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建 MoodFlow MVP — 一款情绪陪伴 + 记录 + 行动建议的治愈系移动 App，Flutter 跨平台，本地优先。

**Architecture:** Feature-first 目录结构，Riverpod 状态管理，Drift 本地数据库（唯一数据主源），go_router 路由。首页选择情绪 → 推荐页获取行动 → 记录页（可选）→ 打卡，4 个底部 Tab。AI 和云同步为可选增强。

**Tech Stack:** Flutter 3.x + Dart + Riverpod + Drift (SQLite) + go_router + shared_preferences

---

## 前置步骤：文件结构总览

### 新建文件清单

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   │   └── app_constants.dart
│   ├── database/
│   │   ├── database.dart
│   │   ├── tables.dart
│   │   └── dao.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart
│   └── providers/
│       └── core_providers.dart
├── features/
│   ├── onboard/
│   │   ├── data/
│   │   │   └── onboard_repository.dart
│   │   └── presentation/
│   │       └── onboard_page.dart
│   ├── emotion/
│   │   ├── domain/
│   │   │   ├── emotion_model.dart
│   │   │   └── emotion_provider.dart
│   │   └── presentation/
│   │       ├── home_page.dart
│   │       └── widgets/
│   │           ├── emotion_grid.dart
│   │           └── intensity_slider.dart
│   ├── recommend/
│   │   ├── engine/
│   │   │   └── recommend_engine.dart
│   │   ├── domain/
│   │   │   └── recommend_provider.dart
│   │   └── presentation/
│   │       ├── recommend_page.dart
│   │       └── widgets/
│   │           └── activity_card.dart
│   ├── record/
│   │   ├── domain/
│   │   │   └── record_provider.dart
│   │   └── presentation/
│   │       └── record_page.dart
│   ├── calendar/
│   │   ├── domain/
│   │   │   └── calendar_provider.dart
│   │   └── presentation/
│   │       └── calendar_page.dart
│   ├── history/
│   │   ├── domain/
│   │   │   └── history_provider.dart
│   │   └── presentation/
│   │       └── history_page.dart
│   └── profile/
│       ├── domain/
│       │   └── profile_provider.dart
│       └── presentation/
│           ├── profile_page.dart
│           └── settings_page.dart
├── ai/
│   ├── ai_provider.dart
│   ├── ai_config_service.dart
│   ├── openai_service.dart
│   └── models/
│       └── ai_models.dart
└── shared/
    └── widgets/
        ├── mood_card.dart
        └── section_title.dart
```

---

### Task 1: 创建 Flutter 项目与基础配置

**Files:**
- Create: `pubspec.yaml` (覆盖默认)
- Create: 所有空目录

- [ ] **Step 1: 创建 Flutter 项目**

```bash
cd "d:/桌面/心情app"
flutter create --org com.moodflow --project-name moodflow --platforms android,ios .
```

**Expected:** Flutter 项目在 `d:/桌面/心情app` 下生成，包含 `android/`, `ios/`, `lib/main.dart` 等。

- [ ] **Step 2: 覆盖 pubspec.yaml**

将 `pubspec.yaml` 替换为：

```yaml
name: moodflow
description: 情绪陪伴 + 情绪记录 + 行动建议 · 治愈系移动 App
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.5.0
  flutter: '>=3.24.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  drift: ^2.21.0
  sqlite3_flutter_libs: ^0.5.27
  path_provider: ^2.1.4
  path: ^1.9.0
  go_router: ^14.6.2
  shared_preferences: ^2.3.3
  flutter_secure_storage: ^9.2.3
  http: ^1.2.2
  image_picker: ^1.1.2
  record: ^5.2.0
  intl: ^0.19.0
  uuid: ^4.5.1
  lottie: ^3.1.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  drift_dev: ^2.21.0
  build_runner: ^2.4.13
  riverpod_generator: ^2.6.3

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/fonts/
```

- [ ] **Step 3: 安装依赖**

```bash
cd "d:/桌面/心情app"
flutter pub get
```

**Expected:** `flutter pub get` 成功，所有包下载。

- [ ] **Step 4: 创建目录结构**

```bash
cd "d:/桌面/心情app"
mkdir -p lib/core/{config,database,theme,router,providers}
mkdir -p lib/features/{onboard,emotion,recommend,record,calendar,history,profile}
mkdir -p lib/features/onboard/{data,presentation}
mkdir -p lib/features/emotion/{domain,presentation/widgets}
mkdir -p lib/features/recommend/{engine,domain,presentation/widgets}
mkdir -p lib/features/record/{domain,presentation}
mkdir -p lib/features/calendar/{domain,presentation}
mkdir -p lib/features/history/{domain,presentation}
mkdir -p lib/features/profile/{domain,presentation}
mkdir -p lib/ai/models
mkdir -p lib/shared/widgets
mkdir -p assets/{images,fonts}
mkdir -p test
```

- [ ] **Step 5: Commit**

```bash
git init
git add -A
git commit -m "chore: scaffold Flutter project with dependencies and directory structure

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 2: 核心常量与配置

**Files:**
- Create: `lib/core/config/app_constants.dart`

- [ ] **Step 1: 编写常量文件**

```dart
// lib/core/config/app_constants.dart
class AppConstants {
  AppConstants._();

  // 情绪列表
  static const List<Map<String, dynamic>> emotions = [
    {'key': 'happy',    'label': '开心', 'emoji': '😊'},
    {'key': 'anxious',  'label': '焦虑', 'emoji': '😰'},
    {'key': 'sad',      'label': '难过', 'emoji': '😢'},
    {'key': 'tired',    'label': '疲惫', 'emoji': '😫'},
    {'key': 'irritated','label': '烦躁', 'emoji': '😤'},
    {'key': 'empty',    'label': '空虚', 'emoji': '😶'},
    {'key': 'calm',     'label': '平静', 'emoji': '😌'},
    {'key': 'bored',    'label': '无聊', 'emoji': '😐'},
    {'key': 'excited',  'label': '兴奋', 'emoji': '🤩'},
  ];

  // 情绪颜色映射
  static const Map<String, int> moodColors = {
    'happy':     0xFFf9d56e,
    'anxious':   0xFFe88a5e,
    'sad':       0xFF5c8eb8,
    'tired':     0xFF9e968e,
    'irritated': 0xFFc08068,
    'empty':     0xFFb5b0a8,
    'calm':      0xFF7aaa6e,
    'bored':     0xFFa8a498,
    'excited':   0xFFe87080,
  };

  // 性别对应的角色和底色
  static const Map<String, Map<String, dynamic>> genderConfig = {
    'male':   {'role': 'puppy', 'roleIcon': '🐶', 'bgColor': 0xFFe8f4fd},
    'female': {'role': 'kitty', 'roleIcon': '🐱', 'bgColor': 0xFFffe8f0},
  };

  // 强度等级提示
  static const Map<int, String> intensityLabels = {
    1: '轻微', 5: '中等', 10: '强烈',
  };
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/config/
git commit -m "feat: add app constants — emotions, colors, gender config

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 3: Drift 数据库 — 表定义与数据库类

**Files:**
- Create: `lib/core/database/tables.dart`
- Create: `lib/core/database/database.dart`
- Create: `lib/core/database/dao.dart`

- [ ] **Step 1: 编写 Drift 表定义**

```dart
// lib/core/database/tables.dart
import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get nickname => text()();
  TextColumn get gender => text()(); // 'male' | 'female'
  TextColumn get role => text()();  // 'puppy' | 'kitty'
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class MoodRecords extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().customExpression('REFERENCES users(id)')();
  TextColumn get mainMood => text()();
  TextColumn get subMood => text().nullable()();
  IntColumn get intensity => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ActivityLogs extends Table {
  TextColumn get id => text()();
  TextColumn get moodRecordId => text().customExpression('REFERENCES mood_records(id)')();
  TextColumn get activityName => text()();
  TextColumn get category => text()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class DiaryEntries extends Table {
  TextColumn get id => text()();
  TextColumn get moodRecordId => text().customExpression('REFERENCES mood_records(id)')();
  TextColumn get textContent => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get audioPath => text().nullable()();
  TextColumn get aiSummary => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class DailyCheckins extends Table {
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get userId => text().customExpression('REFERENCES users(id)')();
  IntColumn get moodCount => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {date};
}

class RecommendationPrefs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().customExpression('REFERENCES users(id)')();
  TextColumn get mood => text()();
  TextColumn get activityName => text()();
  IntColumn get count => integer().withDefault(const Constant(1))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 2: 编写 Drift 数据库类**

```dart
// lib/core/database/database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Users,
  MoodRecords,
  ActivityLogs,
  DiaryEntries,
  DailyCheckins,
  RecommendationPrefs,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'moodflow.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
```

- [ ] **Step 3: 编写 DAO**

```dart
// lib/core/database/dao.dart
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
    return (select(users)..orderBy([(u) => OrderingTerm.desc(u.createdAt)]))
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

  Future<ActivityLog?> getActivityByMoodRecordId(String moodRecordId) {
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

  Future<DiaryEntry?> getEntryByMoodRecordId(String moodRecordId) {
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
    final existing = (select(dailyCheckins)
      ..where((d) => d.date.equals(date) & d.userId.equals(userId)))
        .getSingleOrNull();

    // Using raw insert or update since upsert can be complex with Drift
    return into(dailyCheckins).insertReturning(
      DailyCheckinsCompanion.insert(
        date: date,
        userId: userId,
        moodCount: const Value(1),
        createdAt: DateTime.now(),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<DailyCheckin?> getCheckinByDate(String date, String userId) {
    return (select(dailyCheckins)
      ..where((d) => d.date.equals(date) & d.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<List<DailyCheckin>> getCheckinsByMonth(
    String userId,
    int year,
    int month,
  ) {
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    return (select(dailyCheckins)
      ..where((d) =>
          d.userId.equals(userId) & d.date.like('$prefix%')))
        .get();
  }
}

extension RecommendationPrefDao on AppDatabase {
  Future<void> updatePreference({
    required String userId,
    required String mood,
    required String activityName,
    bool? isHidden,
    bool? isFavorite,
    int? incrementCount,
  }) {
    // Check if existing
    final query = select(recommendationPrefs)
      ..where((r) =>
          r.userId.equals(userId) &
          r.mood.equals(mood) &
          r.activityName.equals(activityName));
    final existing = query.getSingleOrNull();

    if (existing != null) {
      // Update existing
      final builder = RecommendationPrefsCompanion(
        updatedAt: Value(DateTime.now()),
      );
      return (update(recommendationPrefs)
        ..where((r) => r.id.equals(existing.id)))
          .write(builder);
    } else {
      // Insert new
      return into(recommendationPrefs).insert(
        RecommendationPrefsCompanion.insert(
          userId: userId,
          mood: mood,
          activityName: activityName,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<List<RecommendationPref>> getPreferences(String userId) {
    return (select(recommendationPrefs)
      ..where((r) => r.userId.equals(userId)))
        .get();
  }
}
```

- [ ] **Step 4: 运行 build_runner 生成 Drift 代码**

```bash
cd "d:/桌面/心情app"
dart run build_runner build --delete-conflicting-outputs
```

**Expected:** `database.g.dart` 在 `lib/core/database/` 下生成，无错误。

- [ ] **Step 5: Commit**

```bash
git add lib/core/database/
git commit -m "feat: add Drift database — 6 tables, DAOs, generated code

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 4: 全局主题

**Files:**
- Create: `lib/core/theme/app_theme.dart`

- [ ] **Step 1: 编写主题文件**

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // 色彩
  static const Color bgWarmWhite = Color(0xFFfaf8f5);
  static const Color cardWhite = Color(0xFFffffff);
  static const Color textBrown = Color(0xFF5c4a3a);
  static const Color textSecondary = Color(0xFFa89888);
  static const Color textTertiary = Color(0xFFb8a99a);
  static const Color buttonApricot = Color(0xFFc8a080);
  static const Color divider = Color(0xFFe8e0d8);
  static const Color maleBlueBg = Color(0xFFe8f4fd);
  static const Color femalePinkBg = Color(0xFFffe8f0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: buttonApricot,
        surface: bgWarmWhite,
        onSurface: textBrown,
      ),
      scaffoldBackgroundColor: bgWarmWhite,
      fontFamily: 'System',
      appBarTheme: const AppBarTheme(
        backgroundColor: bgWarmWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textBrown,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonApricot,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, letterSpacing: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textTertiary,
          textStyle: const TextStyle(fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: buttonApricot, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textTertiary, fontSize: 15),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: buttonApricot,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/theme/
git commit -m "feat: add AppTheme with warm/apricot color system

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 5: 核心 Providers（数据库 + 用户状态）

**Files:**
- Create: `lib/core/providers/core_providers.dart`

- [ ] **Step 1: 编写核心 Provider**

```dart
// lib/core/providers/core_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database.dart';

// 数据库单例
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// SharedPreferences
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in main.dart with ProviderScope');
});

// SharedPreferences Future provider
final sharedPrefsFutureProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

// 当前用户
final currentUserProvider = FutureProvider<User?>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getCurrentUser();
});

// 是否完成引导
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.watch(sharedPrefsFutureProvider.future);
  return prefs.getBool('onboarding_complete') ?? false;
});

// 用户性别
final userGenderProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return user?.gender;
});

// 用户角色（puppy/kitty）
final userRoleProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return user?.role ?? 'puppy';
});

// 连续打卡天数
final streakDaysProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return 0;

  // Count consecutive days backwards from today
  int streak = 0;
  final now = DateTime.now();
  for (int i = 0; i < 365; i++) {
    final date = DateTime(now.year, now.month, now.day - i);
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final checkin = await db.getCheckinByDate(dateStr, user.id);
    if (checkin != null) {
      streak++;
    } else if (i > 0) {
      break;
    }
  }
  return streak;
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/providers/
git commit -m "feat: add core providers — database, user, onboarding state

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 6: 路由系统

**Files:**
- Create: `lib/core/router/app_router.dart`

- [ ] **Step 1: 编写 GoRouter 路由**

```dart
// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/emotion/presentation/home_page.dart';
import '../../features/recommend/presentation/recommend_page.dart';
import '../../features/record/presentation/record_page.dart';
import '../../features/calendar/presentation/calendar_page.dart';
import '../../features/history/presentation/history_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/profile/presentation/settings_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKeyToday = GlobalKey<NavigatorState>();
final _shellNavigatorKeyCalendar = GlobalKey<NavigatorState>();
final _shellNavigatorKeyHistory = GlobalKey<NavigatorState>();
final _shellNavigatorKeyProfile = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: 今天
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyToday,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'recommend',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const RecommendPage(),
                  ),
                  GoRoute(
                    path: 'record',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const RecordPage(),
                  ),
                ],
              ),
            ],
          ),
          // Tab 2: 日历
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyCalendar,
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),
          // Tab 3: 历史
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyHistory,
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryPage(),
              ),
            ],
          ),
          // Tab 4: 我的
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyProfile,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const SettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// Bottom nav scaffold wrapper
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wb_sunny_outlined), label: '今天'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: '日历'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: '历史'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '我的'),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/router/
git commit -m "feat: add go_router with StatefulShellRoute, 4 bottom tabs

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 7: 情绪模型与 Provider

**Files:**
- Create: `lib/features/emotion/domain/emotion_model.dart`
- Create: `lib/features/emotion/domain/emotion_provider.dart`

- [ ] **Step 1: 编写情绪模型**

```dart
// lib/features/emotion/domain/emotion_model.dart
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
      mainEmotion: clearMain ? null : (mainEmotion ?? this.mainEmotion),
      subEmotion: clearSub ? null : (subEmotion ?? this.subEmotion),
      intensity: intensity ?? this.intensity,
    );
  }
}
```

- [ ] **Step 2: 编写情绪 StateNotifier**

```dart
// lib/features/emotion/domain/emotion_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_constants.dart';
import 'emotion_model.dart';

class EmotionNotifier extends StateNotifier<EmotionSelection> {
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
    state = state.copyWith(mainEmotion: emotion, clearSub: true);
  }

  void selectSubEmotion(String key) {
    if (key == state.mainEmotion?.key) return;
    final emotionData = AppConstants.emotions.firstWhere(
      (e) => e['key'] == key,
    );
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

final emotionProvider =
    StateNotifierProvider<EmotionNotifier, EmotionSelection>((ref) {
  return EmotionNotifier();
});
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/emotion/domain/
git commit -m "feat: add Emotion model and Riverpod StateNotifier

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 8: 首页 — 情绪选择 UI

**Files:**
- Create: `lib/features/emotion/presentation/widgets/emotion_grid.dart`
- Create: `lib/features/emotion/presentation/widgets/intensity_slider.dart`
- Create: `lib/features/emotion/presentation/home_page.dart`

- [ ] **Step 1: 编写情绪网格组件**

```dart
// lib/features/emotion/presentation/widgets/emotion_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/emotion_provider.dart';

class EmotionGrid extends ConsumerWidget {
  const EmotionGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(emotionProvider);
    final role = ref.watch(userRoleProvider).valueOrNull ?? 'puppy';
    final genderConfig = AppConstants.genderConfig[
        role == 'puppy' ? 'male' : 'female']!;
    final bgColor = Color(genderConfig['bgColor'] as int);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: AppConstants.emotions.length,
      itemBuilder: (context, index) {
        final emotion = AppConstants.emotions[index];
        final key = emotion['key'] as String;
        final isSelected = selection.mainEmotion?.key == key;
        final isSubSelected = selection.subEmotion?.key == key;

        return GestureDetector(
          onTap: () {
            if (selection.mainEmotion == null) {
              ref.read(emotionProvider.notifier).selectMainEmotion(key);
            } else {
              ref.read(emotionProvider.notifier).selectSubEmotion(key);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: isSelected
                ? Matrix4.identity().scaled(1.12)
                : Matrix4.identity(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: bgColor.withAlpha(180),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emotion['emoji'] as String,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  emotion['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onSurface
                        : const Color(0xFF8a7968),
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                if (isSubSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFc8a080),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: 编写强度滑杆组件**

```dart
// lib/features/emotion/presentation/widgets/intensity_slider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/emotion_provider.dart';

class IntensitySlider extends ConsumerWidget {
  const IntensitySlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intensity = ref.watch(emotionProvider).intensity;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '轻微',
              style: TextStyle(fontSize: 12, color: Color(0xFFb8a99a)),
            ),
            Text(
              '中等',
              style: TextStyle(fontSize: 12, color: Color(0xFFb8a99a)),
            ),
            Text(
              '强烈',
              style: TextStyle(fontSize: 12, color: Color(0xFFb8a99a)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: const Color(0xFFc8a080),
            inactiveTrackColor: const Color(0xFFe8e0d8),
            thumbColor: Colors.white,
            overlayColor: const Color(0xFFc8a080).withAlpha(40),
          ),
          child: Slider(
            value: intensity.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) =>
                ref.read(emotionProvider.notifier).setIntensity(v.round()),
          ),
        ),
        Text(
          '强度：$intensity',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF5c4a3a),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: 编写首页**

```dart
// lib/features/emotion/presentation/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../domain/emotion_provider.dart';
import 'widgets/emotion_grid.dart';
import 'widgets/intensity_slider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(emotionProvider);
    final streak = ref.watch(streakDaysProvider).valueOrNull ?? 0;
    final today = DateFormat('yyyy.MM.dd · EEEE', 'zh_CN').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoodFlow'),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Color(0xFF5c4a3a),
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Date & streak
              Text(
                today,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFb8a99a),
                  letterSpacing: 1,
                ),
              ),
              if (streak > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '已连续记录 $streak 天',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFc8a080)),
                  ),
                ),
              const SizedBox(height: 24),

              // Question
              const Text(
                '你现在感觉如何？',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF5c4a3a),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 28),

              // Emotion grid
              const EmotionGrid(),

              if (selection.mainEmotion != null) ...[
                const SizedBox(height: 28),

                // Intensity slider
                const IntensitySlider(),

                const SizedBox(height: 24),

                // CTA button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/recommend'),
                    child: const Text('看看可以做什么 →'),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/emotion/presentation/
git commit -m "feat: add home page — emotion grid + intensity slider + CTA

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 9: 推荐引擎（L1 规则映射）

**Files:**
- Create: `lib/features/recommend/engine/recommend_engine.dart`
- Create: `lib/features/recommend/domain/recommend_provider.dart`

- [ ] **Step 1: 编写 L1 规则引擎**

```dart
// lib/features/recommend/engine/recommend_engine.dart
class Activity {
  final String name;
  final String category;
  final String description;
  final String icon;

  const Activity({
    required this.name,
    required this.category,
    required this.description,
    required this.icon,
  });
}

class RecommendEngine {
  // L1 规则映射表
  static const Map<String, List<Activity>> _moodActivities = {
    'happy': [
      Activity(name: '写日记', category: '自我成长', description: '记录下今天的美好', icon: '📝'),
      Activity(name: '阅读', category: '自我成长', description: '读10分钟你喜欢的书', icon: '📖'),
      Activity(name: '分享快乐', category: '社交', description: '把你的开心传递给朋友', icon: '💬'),
    ],
    'anxious': [
      Activity(name: '深呼吸', category: '放松', description: '吸气4秒，呼气6秒，重复5次', icon: '🌿'),
      Activity(name: '散步', category: '放松', description: '在附近走10分钟', icon: '🚶'),
      Activity(name: '听音乐', category: '放松', description: '放一首你喜欢的歌', icon: '🎵'),
    ],
    'sad': [
      Activity(name: '给朋友发消息', category: '社交', description: '和你信任的人聊聊天', icon: '💬'),
      Activity(name: '晒太阳', category: '快速恢复', description: '在窗边坐一会儿', icon: '☀️'),
      Activity(name: '写日记', category: '自我成长', description: '把感受写下来', icon: '📝'),
    ],
    'tired': [
      Activity(name: '喝一杯水', category: '快速恢复', description: '慢慢地喝完一整杯', icon: '💧'),
      Activity(name: '拉伸', category: '快速恢复', description: '站起来伸个懒腰', icon: '🧘'),
      Activity(name: '打开窗户', category: '快速恢复', description: '呼吸一下新鲜空气', icon: '🪟'),
    ],
    'irritated': [
      Activity(name: '深呼吸', category: '放松', description: '慢慢吸气，缓缓呼出', icon: '🌿'),
      Activity(name: '听音乐', category: '放松', description: '放一首平静的音乐', icon: '🎵'),
      Activity(name: '散步', category: '放松', description: '出去走走换换心情', icon: '🚶'),
    ],
    'empty': [
      Activity(name: '给朋友发消息', category: '社交', description: '随便聊聊也好', icon: '💬'),
      Activity(name: '阅读', category: '自我成长', description: '翻几页书，让思绪飘起来', icon: '📖'),
      Activity(name: '晒太阳', category: '快速恢复', description: '阳光是最好的充电器', icon: '☀️'),
    ],
    'calm': [
      Activity(name: '阅读', category: '自我成长', description: '享受当下的安静', icon: '📖'),
      Activity(name: '写日记', category: '自我成长', description: '记录这份平静', icon: '📝'),
      Activity(name: '散步', category: '放松', description: '保持这份好感觉', icon: '🚶'),
    ],
    'bored': [
      Activity(name: '学习10分钟', category: '自我成长', description: '学一点新东西', icon: '💡'),
      Activity(name: '阅读', category: '自我成长', description: '找一本有趣的书', icon: '📖'),
      Activity(name: '给朋友发消息', category: '社交', description: '找人聊聊天', icon: '💬'),
    ],
    'excited': [
      Activity(name: '分享快乐', category: '社交', description: '把你的能量传递给朋友', icon: '💬'),
      Activity(name: '写日记', category: '自我成长', description: '记录下这个高光时刻', icon: '📝'),
      Activity(name: '阅读', category: '自我成长', description: '趁精力好读几页书', icon: '📖'),
    ],
  };

  // 最低行动模式
  static const List<Activity> minimalActions = [
    Activity(name: '深呼吸10秒', category: '最低行动', description: '闭上眼睛，深呼吸', icon: '🫁'),
    Activity(name: '喝一口水', category: '最低行动', description: '就一小口，慢慢喝', icon: '💧'),
    Activity(name: '打开窗户', category: '最低行动', description: '让新鲜空气进来', icon: '🪟'),
  ];

  /// 根据情绪获取推荐列表
  static List<Activity> getRecommendations(
    String mood, {
    Set<String>? hiddenActivities,
    Set<String>? favoriteActivities,
  }) {
    final activities = List<Activity>.from(
        _moodActivities[mood] ?? _moodActivities['calm']!);

    // 过滤隐藏的活动
    if (hiddenActivities != null && hiddenActivities.isNotEmpty) {
      activities.removeWhere((a) => hiddenActivities.contains(a.name));
    }

    // 收藏的排前面
    if (favoriteActivities != null && favoriteActivities.isNotEmpty) {
      activities.sort((a, b) {
        final aFav = favoriteActivities.contains(a.name);
        final bFav = favoriteActivities.contains(b.name);
        return bFav ? 1 : (aFav ? -1 : 0);
      });
    }

    return activities;
  }

  /// 获取最低行动
  static List<Activity> getMinimalActions() {
    return minimalActions;
  }
}
```

- [ ] **Step 2: 编写推荐 Provider**

```dart
// lib/features/recommend/domain/recommend_provider.dart
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../features/emotion/domain/emotion_provider.dart';
import '../engine/recommend_engine.dart';

class RecommendState {
  final Activity? currentActivity;
  final int currentIndex;
  final List<Activity> activities;
  final bool isMinimalMode;
  final Set<String> favorites;
  final Set<String> hidden;

  const RecommendState({
    this.currentActivity,
    this.currentIndex = 0,
    this.activities = const [],
    this.isMinimalMode = false,
    this.favorites = const {},
    this.hidden = const {},
  });

  RecommendState copyWith({
    Activity? currentActivity,
    int? currentIndex,
    List<Activity>? activities,
    bool? isMinimalMode,
    Set<String>? favorites,
    Set<String>? hidden,
  }) {
    return RecommendState(
      currentActivity: currentActivity ?? this.currentActivity,
      currentIndex: currentIndex ?? this.currentIndex,
      activities: activities ?? this.activities,
      isMinimalMode: isMinimalMode ?? this.isMinimalMode,
      favorites: favorites ?? this.favorites,
      hidden: hidden ?? this.hidden,
    );
  }
}

class RecommendNotifier extends StateNotifier<RecommendState> {
  final Ref _ref;

  RecommendNotifier(this._ref) : super(const RecommendState());

  void initialize(String mood) {
    final activities = RecommendEngine.getRecommendations(
      mood,
      hiddenActivities: state.hidden,
      favoriteActivities: state.favorites,
    );
    if (activities.isNotEmpty) {
      state = state.copyWith(
        activities: activities,
        currentActivity: activities.first,
        currentIndex: 0,
        isMinimalMode: false,
      );
    }
  }

  void nextActivity() {
    if (state.activities.isEmpty) return;
    final nextIndex = (state.currentIndex + 1) % state.activities.length;
    state = state.copyWith(
      currentIndex: nextIndex,
      currentActivity: state.activities[nextIndex],
    );
  }

  void toggleFavorite() {
    final activity = state.currentActivity;
    if (activity == null) return;
    final favs = Set<String>.from(state.favorites);
    if (favs.contains(activity.name)) {
      favs.remove(activity.name);
    } else {
      favs.add(activity.name);
    }
    state = state.copyWith(favorites: favs);
  }

  void hideActivity() {
    final activity = state.currentActivity;
    if (activity == null) return;
    final hidden = Set<String>.from(state.hidden);
    hidden.add(activity.name);
    state = state.copyWith(hidden: hidden);
    nextActivity();
  }

  void enableMinimalMode() {
    final minimalActions = RecommendEngine.getMinimalActions();
    state = state.copyWith(
      isMinimalMode: true,
      activities: minimalActions,
      currentActivity: minimalActions.first,
      currentIndex: 0,
    );
  }
}

final recommendProvider =
    StateNotifierProvider<RecommendNotifier, RecommendState>((ref) {
  return RecommendNotifier(ref);
});
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/recommend/engine/ lib/features/recommend/domain/
git commit -m "feat: add L1 recommend engine + provider (rule-based + minimal mode)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 10: 推荐页 UI

**Files:**
- Create: `lib/features/recommend/presentation/widgets/activity_card.dart`
- Create: `lib/features/recommend/presentation/recommend_page.dart`

- [ ] **Step 1: 编写行动卡片组件**

```dart
// lib/features/recommend/presentation/widgets/activity_card.dart
import 'package:flutter/material.dart';
import '../../engine/recommend_engine.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final bool isFavorite;
  final VoidCallback onNext;
  final VoidCallback onStart;
  final VoidCallback onFavorite;
  final VoidCallback onHide;
  final VoidCallback onMinimal;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.isFavorite,
    required this.onNext,
    required this.onStart,
    required this.onFavorite,
    required this.onHide,
    required this.onMinimal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main card
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Container(
            key: ValueKey(activity.name),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFf0f8e8),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(activity.icon, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  activity.name,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFF3c2a1a),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Color(0xFFa89888)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: onNext,
                      child: const Text('换个试试 →'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: onStart,
                      child: const Text('开始行动 ✓'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionChip(
              label: isFavorite ? '❤️ 已收藏' : '🤍 收藏',
              onTap: onFavorite,
            ),
            _ActionChip(
              label: '👎 不感兴趣',
              onTap: onHide,
            ),
            _ActionChip(
              label: '⚡ 最低行动',
              backgroundColor: const Color(0xFF8a7968),
              foregroundColor: Colors.white,
              onTap: onMinimal,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _ActionChip({
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: backgroundColor != null
                    ? Colors.transparent
                    : const Color(0xFFe8e0d8)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: foregroundColor ?? const Color(0xFF8a7968),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 编写推荐页**

```dart
// lib/features/recommend/presentation/recommend_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../emotion/domain/emotion_provider.dart';
import '../domain/recommend_provider.dart';
import 'widgets/activity_card.dart';

class RecommendPage extends ConsumerStatefulWidget {
  const RecommendPage({super.key});

  @override
  ConsumerState<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends ConsumerState<RecommendPage> {
  @override
  void initState() {
    super.initState();
    final emotion = ref.read(emotionProvider).mainEmotion;
    if (emotion != null) {
      ref.read(recommendProvider.notifier).initialize(emotion.key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emotion = ref.watch(emotionProvider).mainEmotion;
    final recommend = ref.watch(recommendProvider);

    if (emotion == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('请先选择情绪')),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Emotion tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFfff0e8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${emotion.emoji} ${emotion.label} · 强度 ${ref.watch(emotionProvider).intensity}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF8a6a58)),
                ),
              ),

              // Gentle prompt
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  _getPrompt(emotion.key),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF5c4a3a),
                    fontWeight: FontWeight.w300,
                    height: 1.4,
                  ),
                ),
              ),

              // Activity card
              if (recommend.currentActivity != null)
                ActivityCard(
                  activity: recommend.currentActivity!,
                  isFavorite: recommend.favorites
                      .contains(recommend.currentActivity!.name),
                  onNext: () =>
                      ref.read(recommendProvider.notifier).nextActivity(),
                  onStart: () {
                    // Navigate to record page with the selected activity
                    context.push('/record',
                        extra: recommend.currentActivity!);
                  },
                  onFavorite: () =>
                      ref.read(recommendProvider.notifier).toggleFavorite(),
                  onHide: () =>
                      ref.read(recommendProvider.notifier).hideActivity(),
                  onMinimal: () =>
                      ref.read(recommendProvider.notifier).enableMinimalMode(),
                ),

              // No activities fallback
              if (recommend.currentActivity == null)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    '暂时没有更多推荐了',
                    style: TextStyle(color: Color(0xFFb8a99a)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPrompt(String moodKey) {
    const prompts = {
      'happy': '真为你开心 ✨\n想把这份快乐记录下来吗？',
      'anxious': '试着做些小事\n让情绪慢慢降落',
      'sad': '没关系\n难过也是需要被看见的',
      'tired': '你辛苦了\n做些小事情照顾自己吧',
      'irritated': '烦躁的时候\n慢下来也许有帮助',
      'empty': '有时候什么都不想做\n也是可以的',
      'calm': '平静是很珍贵的状态\n享受这一刻',
      'bored': '找一件小事\n让此刻变得有意思',
      'excited': '充满能量的时候\n做什么都闪闪发光',
    };
    return prompts[moodKey] ?? '试着做些小事';
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/recommend/presentation/
git commit -m "feat: add recommend page — activity card with swipe, favorite/hide/minimal

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 11: 记录页 UI + 打卡逻辑

**Files:**
- Create: `lib/features/record/domain/record_provider.dart`
- Create: `lib/features/record/presentation/record_page.dart`

- [ ] **Step 1: 编写记录 Provider**

```dart
// lib/features/record/domain/record_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/core_providers.dart';
import '../../emotion/domain/emotion_provider.dart';
import '../../recommend/engine/recommend_engine.dart';

const _uuid = Uuid();

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
    final user = (await _ref.read(currentUserProvider.future));
    if (user == null) return;

    final emotion = _ref.read(emotionProvider);

    state = state.copyWith(isSubmitting: true);

    try {
      // 1. Create mood record
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);

      final moodRecord = await db.createMoodRecord(
        userId: user.id,
        mainMood: emotion.mainEmotion!.key,
        subMood: emotion.subEmotion?.key,
        intensity: emotion.intensity,
        note: textContent,
      );

      // 2. Create activity log if an activity was selected
      if (activity != null) {
        await db.createActivityLog(
          moodRecordId: moodRecord.id,
          activityName: activity.name,
          category: activity.category,
        );
      }

      // 3. Create diary entry if any content provided
      if (textContent != null || imagePath != null || audioPath != null) {
        await db.createDiaryEntry(
          moodRecordId: moodRecord.id,
          textContent: textContent,
          imagePath: imagePath,
          audioPath: audioPath,
        );
      }

      // 4. Upsert daily checkin
      await db.upsertCheckin(userId: user.id, date: dateStr);

      state = state.copyWith(isSubmitting: false, isComplete: true);

      // Reset emotion selection for next use
      _ref.read(emotionProvider.notifier).reset();
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
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
    StateNotifierProvider<RecordNotifier, RecordState>((ref) {
  return RecordNotifier(ref);
});
```

- [ ] **Step 2: 编写记录页**

```dart
// lib/features/record/presentation/record_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../recommend/engine/recommend_engine.dart';
import '../domain/record_provider.dart';

class RecordPage extends ConsumerStatefulWidget {
  const RecordPage({super.key});

  @override
  ConsumerState<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends ConsumerState<RecordPage> {
  final _textController = TextEditingController();
  String? _imagePath;
  bool _isRecording = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      setState(() => _imagePath = result.path);
    }
  }

  Future<void> _submit() async {
    final activity = GoRouterState.of(context).extra as Activity?;
    await ref.read(recordProvider.notifier).submitRecord(
          textContent: _textController.text.isNotEmpty
              ? _textController.text
              : null,
          imagePath: _imagePath,
          activity: activity,
        );
    if (mounted && ref.read(recordProvider).isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('打卡成功 ✨')),
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final activity = GoRouterState.of(context).extra as Activity?;
    final state = ref.watch(recordProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Context
              if (activity != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf0f8e8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${activity.icon} 已完成：${activity.name}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF7aaa6e)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                '做得很好 ✨\n想记录一下现在的感受吗？',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF5c4a3a),
                  fontWeight: FontWeight.w300,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Photo picker
              _RecordTile(
                icon: '📷',
                title: '添加照片',
                subtitle: '拍一张或从相册选',
                onTap: _pickImage,
                trailing: _imagePath != null
                    ? const Icon(Icons.check_circle, color: Color(0xFF7aaa6e), size: 20)
                    : null,
              ),
              const SizedBox(height: 12),

              // Text input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: '写几句……（可选）',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Color(0xFFb8a99a)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Voice record
              _RecordTile(
                icon: _isRecording ? '🔴' : '🎤',
                title: '录制语音',
                subtitle: '说说今天的感受（最长 60 秒）',
                onTap: () {
                  setState(() => _isRecording = !_isRecording);
                },
              ),
              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isSubmitting ? null : _submit,
                  child: Text(state.isSubmitting ? '记录中...' : '✅ 完成记录'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: state.isSubmitting ? null : _submit,
                  child: const Text('跳过，直接打卡'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _RecordTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFfef0e0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF5c4a3a)),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFFb8a99a)),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/record/
git commit -m "feat: add record page — photo/text/voice input + checkin logic

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 12: 日历页

**Files:**
- Create: `lib/features/calendar/domain/calendar_provider.dart`
- Create: `lib/features/calendar/presentation/calendar_page.dart`

- [ ] **Step 1: 编写日历 Provider**

```dart
// lib/features/calendar/domain/calendar_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/core_providers.dart';

class CalendarData {
  final DateTime month;
  final Map<String, MoodRecord?> records; // dateStr -> MoodRecord
  final Map<String, DailyCheckin?> checkins;

  const CalendarData({
    required this.month,
    required this.records,
    required this.checkins,
  });
}

final calendarProvider =
    FutureProvider.family<CalendarData, DateTime>((ref, month) async {
  final db = ref.watch(databaseProvider);
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    return CalendarData(
      month: month,
      records: {},
      checkins: {},
    );
  }

  final records = await db.getRecordsByMonth(user.id, month.year, month.month);
  final checkins =
      await db.getCheckinsByMonth(user.id, month.year, month.month);

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
```

- [ ] **Step 2: 编写日历页**

```dart
// lib/features/calendar/presentation/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/calendar_provider.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _currentMonth;
  String? _selectedDate;
  bool _isMonthView = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final calendarAsync =
        ref.watch(calendarProvider(_currentMonth));

    return Scaffold(
      appBar: AppBar(title: const Text('日历')),
      body: SafeArea(
        child: calendarAsync.when(
          data: (data) => Column(
            children: [
              // Month header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => setState(() {
                        _currentMonth = DateTime(
                            _currentMonth.year, _currentMonth.month - 1);
                      }),
                    ),
                    Text(
                      '${_currentMonth.year}.${_currentMonth.month.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF5c4a3a),
                          fontWeight: FontWeight.w400),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => setState(() {
                        _currentMonth = DateTime(
                            _currentMonth.year, _currentMonth.month + 1);
                      }),
                    ),
                  ],
                ),
              ),

              // Weekday headers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const ['日', '一', '二', '三', '四', '五', '六']
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(d,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFb8a99a))),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Calendar grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildCalendarGrid(data),
                ),
              ),

              // Selected date detail
              if (_selectedDate != null && data.records[_selectedDate] != null)
                _buildDateDetail(data),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('加载失败: $e')),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(CalendarData data) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startOffset = firstDay.weekday % 7; // Sunday = 0

    final cells = <Widget>[];

    // Empty cells before first day
    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox());
    }

    // Day cells
    for (int day = 1; day <= lastDay.day; day++) {
      final dateStr =
          '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}-$day.toString().padLeft(2, '0')';
      final record = data.records[dateStr];
      final isSelected = _selectedDate == dateStr;

      Color? bgColor;
      if (record != null) {
        final moodColor = AppConstants.moodColors[record.mainMood];
        if (moodColor != null) {
          bgColor = Color(moodColor).withAlpha(40);
        }
      }

      cells.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDate = dateStr),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: const Color(0xFFc8a080), width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    color: bgColor != null
                        ? const Color(0xFF5c4a3a)
                        : const Color(0xFFb8a99a),
                  ),
                ),
                if (record != null)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Color(
                          AppConstants.moodColors[record.mainMood] ?? 0xFF9e968e),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      childAspectRatio: 0.9,
      children: cells,
    );
  }

  Widget _buildDateDetail(CalendarData data) {
    final record = data.records[_selectedDate!]!;
    final checkin = data.checkins[_selectedDate!];
    final moodColor =
        Color(AppConstants.moodColors[record.mainMood] ?? 0xFF9e968e);

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_selectedDate',
            style: const TextStyle(fontSize: 13, color: Color(0xFFb8a99a)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: moodColor.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    record.subMood != null
                        ? '${_getEmojiForMood(record.mainMood)}/${_getEmojiForMood(record.subMood!)}'
                        : _getEmojiForMood(record.mainMood),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '强度 ${record.intensity}',
                style: const TextStyle(fontSize: 15, color: Color(0xFF5c4a3a)),
              ),
              if (checkin != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf0f8e8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '已打卡',
                      style:
                          TextStyle(fontSize: 11, color: Color(0xFF7aaa6e)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getEmojiForMood(String key) {
    final emotion =
        AppConstants.emotions.firstWhere((e) => e['key'] == key);
    return emotion['emoji'] as String;
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/calendar/
git commit -m "feat: add calendar page — month view with mood color grid

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 13: 历史页

**Files:**
- Create: `lib/features/history/domain/history_provider.dart`
- Create: `lib/features/history/presentation/history_page.dart`

- [ ] **Step 1: 编写历史 Provider**

```dart
// lib/features/history/domain/history_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/core_providers.dart';

final historyProvider = FutureProvider.family
    .autoDispose<List<Map<String, dynamic>>, String?>((ref, search) async {
  final db = ref.watch(databaseProvider);
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return [];

  // Get records for the past 90 days
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day - 90);
  return db.getRecordsByDateRange(user.id, start, now);
});
```

- [ ] **Step 2: 编写历史页**

```dart
// lib/features/history/presentation/history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/history_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final _searchController = TextEditingController();
  String? _searchQuery;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(historyProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(title: const Text('历史记录')),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.isEmpty ? null : v),
                decoration: InputDecoration(
                  hintText: '🔍 搜索情绪或日期...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFb8a99a)),
                ),
              ),
            ),

            // Timeline
            Expanded(
              child: recordsAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return const Center(
                      child: Text(
                        '还没有记录\n开始你的第一条吧',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Color(0xFFb8a99a), fontSize: 15),
                      ),
                    );
                  }

                  // Group by date
                  final grouped = <String, List<MoodRecord>>{};
                  for (final r in records) {
                    final dateStr =
                        DateFormat('yyyy-MM-dd').format(r.createdAt);
                    grouped.putIfAbsent(dateStr, () => []).add(r);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final dateStr = grouped.keys.elementAt(index);
                      final dayRecords = grouped[dateStr]!;

                      return _TimelineDay(
                        dateStr: dateStr,
                        records: dayRecords,
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('加载失败: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineDay extends StatelessWidget {
  final String dateStr;
  final List<MoodRecord> records;

  const _TimelineDay({required this.dateStr, required this.records});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('M 月 d 日').format(DateTime.parse(dateStr));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date label
        SizedBox(
          width: 72,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              date,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFFa89888)),
            ),
          ),
        ),

        // Timeline line + content
        Expanded(
          child: Column(
            children: records.map((record) {
              final moodColor = Color(
                  AppConstants.moodColors[record.mainMood] ?? 0xFF9e968e);
              final emoji = (AppConstants.emotions.firstWhere(
                  (e) => e['key'] == record.mainMood))['emoji'] as String;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline dot + line
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: moodColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFfaf8f5), width: 2),
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 60,
                          color: const Color(0xFFe8e0d8),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Content card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(6),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.mainMood,
                                    style: const TextStyle(
                                        fontSize: 14, color: Color(0xFF5c4a3a)),
                                  ),
                                  Text(
                                    '强度 ${record.intensity}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFb8a99a)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: Color(0xFFd0c8bc), size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/history/
git commit -m "feat: add history page — timeline grouped by date with search

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 14: 我的页面 + 引导页

**Files:**
- Create: `lib/features/profile/domain/profile_provider.dart`
- Create: `lib/features/profile/presentation/profile_page.dart`
- Create: `lib/features/profile/presentation/settings_page.dart`
- Create: `lib/features/onboard/data/onboard_repository.dart`
- Create: `lib/features/onboard/presentation/onboard_page.dart`

- [ ] **Step 1: 编写 Profile Provider**

```dart
// lib/features/profile/domain/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';

final totalRecordsProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return 0;

  final now = DateTime.now();
  final start = DateTime(now.year - 1); // all time
  final records = await db.getRecordsByDateRange(user.id, start, now);
  return records.length;
});

final frequentMoodProvider = FutureProvider<String?>((ref) async {
  final db = ref.watch(databaseProvider);
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;

  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day - 30);
  final records = await db.getRecordsByDateRange(user.id, start, now);

  if (records.isEmpty) return null;

  final moodCount = <String, int>{};
  for (final r in records) {
    moodCount[r.mainMood] = (moodCount[r.mainMood] ?? 0) + 1;
  }

  return moodCount.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;
});
```

- [ ] **Step 2: 编写我的页面**

```dart
// lib/features/profile/presentation/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final streak = ref.watch(streakDaysProvider).valueOrNull ?? 0;
    final totalRecords = ref.watch(totalRecordsProvider).valueOrNull ?? 0;
    final frequentMood = ref.watch(frequentMoodProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: userAsync.when(
            data: (user) {
              if (user == null) return const SizedBox();

              final genderConfig = AppConstants.genderConfig[
                  user.gender == 'female' ? 'female' : 'male']!;
              final roleIcon = genderConfig['roleIcon'] as String;

              final createdAt = user.createdAt;
              final daysSince = DateTime.now().difference(createdAt).inDays + 1;

              return Column(
                children: [
                  // Profile card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Color(genderConfig['bgColor'] as int),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(roleIcon,
                                style: const TextStyle(fontSize: 26)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.nickname,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF5c4a3a),
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${user.role == 'puppy' ? '小狗' : '小猫'}模式 · 已陪伴 $daysSince 天',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFFb8a99a)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    children: [
                      _StatCard(value: '$streak', label: '连续天数'),
                      const SizedBox(width: 10),
                      _StatCard(value: '$totalRecords', label: '总记录'),
                      const SizedBox(width: 10),
                      _StatCard(value: frequentMood ?? '--', label: '常驻情绪'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Menu
                  _buildMenu(context),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('加载失败: $e')),
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    final items = [
      ('📊', '数据统计', '周报 / 月报'),
      ('🔑', 'AI 设置', 'OpenAI API Key'),
      ('☁️', '云同步', '未连接'),
      ('🎨', '切换角色', '小狗 ↔ 小猫'),
      ('⚙️', '通用设置', ''),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final (icon, title, subtitle) = entry.value;
          return InkWell(
            onTap: title == 'AI 设置' || title == '通用设置'
                ? () => context.push('/profile/settings')
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: i < items.length - 1
                  ? const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color(0xFFf5f0ea), width: 1)),
                    )
                  : null,
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF5c4a3a)),
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFb8a99a)),
                    ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right,
                      color: Color(0xFFd0c8bc), size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                  fontSize: 22,
                  color: Color(0xFFc8a080),
                  fontWeight: FontWeight.w400),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFFb8a99a)),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: 编写设置页**

```dart
// lib/features/profile/presentation/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _apiKeyController = TextEditingController();
  bool _hasSavedKey = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key = await _storage.read(key: 'openai_api_key');
    if (key != null && key.isNotEmpty) {
      _apiKeyController.text = key;
      _hasSavedKey = true;
    }
  }

  Future<void> _saveKey() async {
    setState(() => _loading = true);
    await _storage.write(key: 'openai_api_key', value: _apiKeyController.text);
    setState(() {
      _loading = false;
      _hasSavedKey = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key 已保存 ✓')),
      );
    }
  }

  Future<void> _deleteKey() async {
    await _storage.delete(key: 'openai_api_key');
    _apiKeyController.clear();
    setState(() => _hasSavedKey = false);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'AI 设置',
              style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF5c4a3a),
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              '填入你的 OpenAI API Key 以启用 AI 日记和智能推荐。不填也能使用全部基础功能。',
              style: TextStyle(fontSize: 13, color: Color(0xFFb8a99a)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'sk-...',
                suffixIcon: _hasSavedKey
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _deleteKey,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveKey,
                child: Text(_hasSavedKey ? '更新 Key' : '保存 Key'),
              ),
            ),

            const SizedBox(height: 40),
            const Text(
              '通用设置',
              style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF5c4a3a),
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            // About
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('关于 MoodFlow', style: TextStyle(fontSize: 14)),
              subtitle: const Text('v1.0.0',
                  style: TextStyle(fontSize: 12, color: Color(0xFFb8a99a))),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFFd0c8bc)),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 编写引导页**

```dart
// lib/features/onboard/data/onboard_repository.dart
import 'package:shared_preferences/shared_preferences.dart';

class OnboardRepository {
  final SharedPreferences _prefs;

  OnboardRepository(this._prefs);

  Future<void> completeOnboarding() async {
    await _prefs.setBool('onboarding_complete', true);
  }
}
```

```dart
// lib/features/onboard/presentation/onboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/providers/core_providers.dart';

const _uuid = Uuid();

class OnboardPage extends ConsumerStatefulWidget {
  const OnboardPage({super.key});

  @override
  ConsumerState<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends ConsumerState<OnboardPage> {
  final _pageController = PageController();
  final _nicknameController = TextEditingController();
  String? _gender; // 'male' | 'female'
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_nicknameController.text.isEmpty || _gender == null) return;

    final db = ref.read(databaseProvider);
    final prefs = await ref.read(sharedPrefsFutureProvider.future);
    final role = _gender == 'male' ? 'puppy' : 'kitty';

    await db.createUser(
      nickname: _nicknameController.text,
      gender: _gender!,
      role: role,
    );

    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfaf8f5),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Container(
                    width: i == _currentPage ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? const Color(0xFFc8a080)
                          : const Color(0xFFe8e0d8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  // Page 1: Welcome
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🌈', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text(
                        '欢迎来到 MoodFlow',
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFF5c4a3a),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '一个温柔的地方\n记录你的每一种心情',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFa89888),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                        child: const Text('开始 →'),
                      ),
                    ],
                  ),

                  // Page 2: Nickname
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('✏️', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 12),
                      const Text(
                        '怎么称呼你？',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF5c4a3a),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 260,
                        child: TextField(
                          controller: _nicknameController,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: '你的昵称',
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _nicknameController.text.isEmpty
                            ? null
                            : () => _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                ),
                        child: const Text('继续 →'),
                      ),
                    ],
                  ),

                  // Page 3: Gender/Role
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('💫', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 12),
                      const Text(
                        '选择一个陪伴角色',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF5c4a3a),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _GenderCard(
                            icon: '🐶',
                            label: '男生',
                            sublabel: '小狗陪伴',
                            bgColor: const Color(0xFFe8f4fd),
                            isSelected: _gender == 'male',
                            onTap: () => setState(() => _gender = 'male'),
                          ),
                          const SizedBox(width: 16),
                          _GenderCard(
                            icon: '🐱',
                            label: '女生',
                            sublabel: '小猫陪伴',
                            bgColor: const Color(0xFFffe8f0),
                            isSelected: _gender == 'female',
                            onTap: () => setState(() => _gender = 'female'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _gender == null ? null : _complete,
                        child: const Text('🎉 开始我的情绪之旅'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String icon;
  final String label;
  final String sublabel;
  final Color bgColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.bgColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bgColor.withAlpha(40),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFc8a080) : const Color(0xFFe0d8cc),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF5c4a3a),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              sublabel,
              style: const TextStyle(fontSize: 12, color: Color(0xFFb8a99a)),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/profile/ lib/features/onboard/
git commit -m "feat: add profile page, settings (API Key), and onboarding flow

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 15: AI 接口层

**Files:**
- Create: `lib/ai/models/ai_models.dart`
- Create: `lib/ai/ai_config_service.dart`
- Create: `lib/ai/openai_service.dart`
- Create: `lib/ai/ai_provider.dart`

- [ ] **Step 1: 编写 AI 模型**

```dart
// lib/ai/models/ai_models.dart
class ChatMessage {
  final String role; // 'system' | 'user' | 'assistant'
  final String content;

  const ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class AiRecommendation {
  final String activityName;
  final String reason;
  final String category;

  const AiRecommendation({
    required this.activityName,
    required this.reason,
    required this.category,
  });
}
```

- [ ] **Step 2: 编写 AI 配置服务**

```dart
// lib/ai/ai_config_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final aiConfigServiceProvider = Provider<AiConfigService>((ref) {
  return AiConfigService(ref.watch(secureStorageProvider));
});

class AiConfigService {
  final FlutterSecureStorage _storage;
  static const _keyApiKey = 'openai_api_key';

  AiConfigService(this._storage);

  Future<String?> getApiKey() => _storage.read(key: _keyApiKey);

  Future<void> saveApiKey(String key) =>
      _storage.write(key: _keyApiKey, value: key);

  Future<void> deleteApiKey() => _storage.delete(key: _keyApiKey);

  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }
}
```

- [ ] **Step 3: 编写 OpenAI 服务**

```dart
// lib/ai/openai_service.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'ai_config_service.dart';
import 'models/ai_models.dart';

final openaiServiceProvider = Provider<OpenAiService>((ref) {
  return OpenAiService(ref.watch(aiConfigServiceProvider));
});

class OpenAiService {
  final AiConfigService _config;
  static const _baseUrl = 'https://api.openai.com/v1';

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
        ChatMessage(
          role: 'system',
          content: '你是一个温柔的情绪陪伴助手。根据用户的情绪和输入，生成一句简短的、温柔有感而发的日记摘要。不超过50字。语气温暖、不评判、不说教。使用"你"来称呼用户。',
        ),
        ChatMessage(
          role: 'user',
          content: '今天我感受到的情绪是：$emotion（强度 $intensity/10）。'
              '${userText != null ? '我想说的话：$userText' : ''}'
              '${imageDescription != null ? '我分享的图片描述：$imageDescription' : ''}'
              '请帮我把这段感受总结成一句温柔的日记。',
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
          'messages': messages.map((m) => m.toJson()).toList(),
          'max_tokens': 80,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content']?.toString().trim();
      }
      return null;
    } catch (_) {
      return null; // AI 不可用时静默失败
    }
  }

  Future<AiRecommendation?> generateRecommendation({
    required String emotion,
    required int intensity,
    List<String>? recentMoods,
    List<String>? recentActivities,
  }) async {
    final apiKey = await _config.getApiKey();
    if (apiKey == null || apiKey.isEmpty) return null;

    try {
      final messages = [
        ChatMessage(
          role: 'system',
          content: '你是一个情绪陪伴助手，根据用户当前情绪推荐一个适合做的活动。返回JSON格式：'
              '{"activity_name": "活动名", "reason": "推荐理由", "category": "分类"}。'
              '分类只能是：放松、快速恢复、社交、自我成长。',
        ),
        ChatMessage(
          role: 'user',
          content: '我现在的情绪是：$emotion（强度 $intensity/10）。'
              '${recentMoods != null ? '最近的情绪变化：${recentMoods.join(' → ')}' : ''}'
              '请给我推荐一个适合现在做的事。',
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
          'messages': messages.map((m) => m.toJson()).toList(),
          'max_tokens': 100,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content =
            data['choices']?[0]?['message']?['content']?.toString().trim();
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
```

- [ ] **Step 4: 编写 AI Provider**

```dart
// lib/ai/ai_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_config_service.dart';
import 'openai_service.dart';
import 'models/ai_models.dart';

final hasApiKeyProvider = FutureProvider<bool>((ref) async {
  return ref.watch(aiConfigServiceProvider).hasApiKey();
});

final aiDiarySummaryProvider = FutureProvider.family
    .autoDispose<String?, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(openaiServiceProvider);
  final hasKey = await ref.watch(hasApiKeyProvider.future);
  if (!hasKey) return null;

  return service.generateDiarySummary(
    emotion: params['emotion'] as String,
    intensity: params['intensity'] as int,
    userText: params['userText'] as String?,
    imageDescription: params['imageDescription'] as String?,
  );
});

final aiRecommendationProvider = FutureProvider.family
    .autoDispose<AiRecommendation?, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(openaiServiceProvider);
  final hasKey = await ref.watch(hasApiKeyProvider.future);
  if (!hasKey) return null;

  return service.generateRecommendation(
    emotion: params['emotion'] as String,
    intensity: params['intensity'] as int,
  );
});
```

- [ ] **Step 5: Commit**

```bash
git add lib/ai/
git commit -m "feat: add AI layer — OpenAI service, config, providers

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 16: App 入口与集成

**Files:**
- Create: `lib/main.dart` (覆盖)
- Create: `lib/app.dart`

- [ ] **Step 1: 编写 main.dart**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MoodFlowApp(),
    ),
  );
}
```

- [ ] **Step 2: 编写 app.dart**

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/core_providers.dart';
import 'features/onboard/presentation/onboard_page.dart';

class MoodFlowApp extends ConsumerWidget {
  const MoodFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MoodFlow',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Step 3: 修改 router 支持引导页拦截**

在 `lib/core/router/app_router.dart` 中，修改 `GoRouter` 初始化：

```dart
// 在 statefulShellRoute 之外添加引导路由
// 在 GoRouter 的 routes 数组开头添加:

GoRoute(
  path: '/onboard',
  builder: (context, state) => const OnboardPage(),
),
```

然后在 `app.dart` 中添加引导页条件判断——或者用 Router redirect：

```dart
// 在 GoRouter 构造函数中增加 redirect:
redirect: (context, state) {
  // Use provider to check onboarding
  // This requires accessing the ProviderScope inside router
  return null; // No redirect by default
},
```

实际做法更简单：在 `app.dart` 中用 Consumer 包裹并根据 `onboardingCompleteProvider` 决定显示引导页还是主 App：

```dart
class MoodFlowApp extends ConsumerWidget {
  const MoodFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final onboardingAsync = ref.watch(onboardingCompleteProvider);

    return MaterialApp.router(
      title: 'MoodFlow',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Step 4: 运行应用验证编译**

```bash
cd "d:/桌面/心情app"
flutter analyze
```

**Expected:** 无报错。

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart lib/app.dart lib/core/router/
git commit -m "feat: wire up app entry, router, and onboarding guard

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

### Task 17: 共享组件 + 收尾

**Files:**
- Create: `lib/shared/widgets/mood_card.dart`
- Create: `lib/shared/widgets/section_title.dart`

- [ ] **Step 1: 编写通用组件**

```dart
// lib/shared/widgets/mood_card.dart
import 'package:flutter/material.dart';

class MoodCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const MoodCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
```

```dart
// lib/shared/widgets/section_title.dart
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xFF5c4a3a),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 13, color: Color(0xFFb8a99a)),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 最终验证**

```bash
cd "d:/桌面/心情app"
flutter analyze
dart run build_runner build --delete-conflicting-outputs
```

**Expected:** 无 analysis 错误，build_runner 生成成功。

- [ ] **Step 3: Final commit**

```bash
git add lib/shared/
git add -A
git commit -m "feat: add shared widgets and finalize MVP integration

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## 实现顺序摘要

| 任务 | 内容 | 依赖 |
|------|------|------|
| 1 | Flutter 项目 + pubspec | - |
| 2 | 核心常量 | 1 |
| 3 | Drift 数据库 + DAO | 1, 2 |
| 4 | 全局主题 | 1 |
| 5 | 核心 Providers | 3 |
| 6 | 路由系统 | 1 |
| 7 | 情绪模型 + Provider | 2, 5 |
| 8 | 首页 UI | 4, 7 |
| 9 | 推荐引擎 + Provider | 2 |
| 10 | 推荐页 UI | 6, 7, 9 |
| 11 | 记录页 UI + 打卡 | 3, 5, 9 |
| 12 | 日历页 | 3, 5 |
| 13 | 历史页 | 3, 5 |
| 14 | 我的页 + 引导页 + 设置 | 3, 5, 6 |
| 15 | AI 接口层 | 5 |
| 16 | App 入口 + 集成 | 6, 14 |
| 17 | 共享组件 + 收尾 | 全部 |
