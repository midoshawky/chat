class MessageSender {
  const MessageSender({
    required this.userId,
    required this.name,
    this.avatar,
  });

  final String userId;
  final String name;
  final String? avatar;

  factory MessageSender.fromJson(Map<String, dynamic> json) => MessageSender(
        userId: json['userId'] as String,
        name: json['name'] as String,
        avatar: json['avatar'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'avatar': avatar,
      };
}
