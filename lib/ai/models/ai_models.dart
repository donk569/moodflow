class ChatMessage {
  final String role;
  final String content;

  const ChatMessage(
      {required this.role, required this.content});

  Map<String, dynamic> toJson() =>
      {'role': role, 'content': content};
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
