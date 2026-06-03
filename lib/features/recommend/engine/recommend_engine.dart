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

  static const List<Activity> minimalActions = [
    Activity(name: '深呼吸10秒', category: '最低行动', description: '闭上眼睛，深呼吸', icon: '🫁'),
    Activity(name: '喝一口水', category: '最低行动', description: '就一小口，慢慢喝', icon: '💧'),
    Activity(name: '打开窗户', category: '最低行动', description: '让新鲜空气进来', icon: '🪟'),
  ];

  static List<Activity> getRecommendations(
    String mood, {
    Set<String>? hiddenActivities,
    Set<String>? favoriteActivities,
  }) {
    final activities = List<Activity>.from(
        _moodActivities[mood] ?? _moodActivities['calm']!);

    if (hiddenActivities != null &&
        hiddenActivities.isNotEmpty) {
      activities.removeWhere(
          (a) => hiddenActivities.contains(a.name));
    }

    if (favoriteActivities != null &&
        favoriteActivities.isNotEmpty) {
      activities.sort((a, b) {
        final aFav = favoriteActivities.contains(a.name);
        final bFav = favoriteActivities.contains(b.name);
        return bFav ? 1 : (aFav ? -1 : 0);
      });
    }

    return activities;
  }

  static List<Activity> getMinimalActions() => minimalActions;
}
