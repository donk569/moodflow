import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class RecommendNotifier
    extends StateNotifier<RecommendState> {
  RecommendNotifier() : super(const RecommendState());

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
    final nextIndex =
        (state.currentIndex + 1) % state.activities.length;
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
    final minimalActions =
        RecommendEngine.getMinimalActions();
    state = state.copyWith(
      isMinimalMode: true,
      activities: minimalActions,
      currentActivity: minimalActions.first,
      currentIndex: 0,
    );
  }
}

final recommendProvider = StateNotifierProvider<
    RecommendNotifier, RecommendState>((ref) {
  return RecommendNotifier();
});
