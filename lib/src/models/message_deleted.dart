class MessageDeleted {
  const MessageDeleted({
    required this.messageId,
    required this.roomId,
    required this.deletedAt,
  });

  final String messageId;
  final String roomId;
  final DateTime deletedAt;

  factory MessageDeleted.fromJson(Map<String, dynamic> json) =>
      MessageDeleted(
        messageId: json['messageId'] as String,
        roomId: json['roomId'] as String,
        deletedAt: DateTime.parse(json['deletedAt'] as String),
      );
}
