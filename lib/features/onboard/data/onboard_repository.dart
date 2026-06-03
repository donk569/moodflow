import 'package:shared_preferences/shared_preferences.dart';

class OnboardRepository {
  final SharedPreferences _prefs;

  OnboardRepository(this._prefs);

  Future<void> completeOnboarding() async {
    await _prefs.setBool('onboarding_complete', true);
  }
}
