// models/message_model.dart
class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          isUser == other.isUser &&
          timestamp == other.timestamp;

  @override
  int get hashCode => text.hashCode ^ isUser.hashCode ^ timestamp.hashCode;
}