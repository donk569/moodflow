class AppConstants {
  AppConstants._();

  static const List<Map<String, dynamic>> emotions = [
    {'key': 'happy', 'label': '开心', 'emoji': '😊'},
    {'key': 'anxious', 'label': '焦虑', 'emoji': '😰'},
    {'key': 'sad', 'label': '难过', 'emoji': '😢'},
    {'key': 'tired', 'label': '疲惫', 'emoji': '😫'},
    {'key': 'irritated', 'label': '烦躁', 'emoji': '😤'},
    {'key': 'empty', 'label': '空虚', 'emoji': '😶'},
    {'key': 'calm', 'label': '平静', 'emoji': '😌'},
    {'key': 'bored', 'label': '无聊', 'emoji': '😐'},
    {'key': 'excited', 'label': '兴奋', 'emoji': '🤩'},
  ];

  static const Map<String, int> moodColors = {
    'happy': 0xFFf9d56e,
    'anxious': 0xFFe88a5e,
    'sad': 0xFF5c8eb8,
    'tired': 0xFF9e968e,
    'irritated': 0xFFc08068,
    'empty': 0xFFb5b0a8,
    'calm': 0xFF7aaa6e,
    'bored': 0xFFa8a498,
    'excited': 0xFFe87080,
  };

  static const Map<String, Map<String, dynamic>> genderConfig = {
    'male': {'role': 'puppy', 'roleIcon': '🐶', 'bgColor': 0xFFe8f4fd},
    'female': {'role': 'kitty', 'roleIcon': '🐱', 'bgColor': 0xFFffe8f0},
  };
}
