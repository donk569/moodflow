import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database.dart';
import '../database/dao.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final sharedPrefsFutureProvider =
    FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final currentUserProvider = FutureProvider<User?>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getCurrentUser();
});

final onboardingCompleteProvider =
    FutureProvider<bool>((ref) async {
  final prefs =
      await ref.watch(sharedPrefsFutureProvider.future);
  return prefs.getBool('onboarding_complete') ?? false;
});

final userGenderProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return user?.gender;
});

final userRoleProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return user?.role ?? 'puppy';
});

final streakDaysProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return 0;

  int streak = 0;
  final now = DateTime.now();
  for (int i = 0; i < 365; i++) {
    final date =
        DateTime(now.year, now.month, now.day - i);
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final checkin =
        await db.getCheckinByDate(dateStr, user.id);
    if (checkin != null) {
      streak++;
    } else if (i > 0) {
      break;
    }
  }
  return streak;
});
