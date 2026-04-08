/// Represents a single message in the AI chat
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.user(String text) => ChatMessage(
        text: text,
        isUser: true,
      );

  factory ChatMessage.ai(String text) => ChatMessage(
        text: text,
        isUser: false,
      );
}
