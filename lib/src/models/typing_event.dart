class TypingEvent {
  const TypingEvent({
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.isTyping,
    this.userAvatar,
  });

  final String roomId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final bool isTyping;

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return TypingEvent(
      roomId: json['roomId'] as String,
      userId: user['userId'] as String? ?? '',
      userName: user['name'] as String? ?? '',
      userAvatar: user['avatar'] as String?,
      isTyping: json['isTyping'] as bool? ?? false,
    );
  }
}
