class RoomLastMessage {
  const RoomLastMessage({
    required this.messageId,
    required this.text,
    required this.senderId,
    required this.createdAt,
  });

  final String messageId;
  final String text;
  final String senderId;
  final DateTime createdAt;

  factory RoomLastMessage.fromJson(Map<String, dynamic> json) =>
      RoomLastMessage(
        messageId: json['messageId'] as String,
        text: json['text'] as String,
        senderId: json['senderId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'text': text,
        'senderId': senderId,
        'createdAt': createdAt.toIso8601String(),
      };
}
