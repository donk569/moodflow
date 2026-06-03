import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get nickname => text()();
  TextColumn get gender => text()();
  TextColumn get role => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class MoodRecords extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
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
  TextColumn get moodRecordId =>
      text().references(MoodRecords, #id)();
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
  TextColumn get moodRecordId =>
      text().references(MoodRecords, #id)();
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
  TextColumn get date => text()();
  TextColumn get userId => text().references(Users, #id)();
  IntColumn get moodCount => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {date};
}

class RecommendationPrefs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get mood => text()();
  TextColumn get activityName => text()();
  IntColumn get count => integer().withDefault(const Constant(1))();
  BoolColumn get isHidden =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
}
