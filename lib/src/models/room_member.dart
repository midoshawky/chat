class RoomMember {
  const RoomMember({
    required this.userId,
    required this.name,
    this.username,
    this.avatar,
    this.type = 'member',
  });

  final String userId;
  final String? username;
  final String name;
  final String? avatar;
  final String type;

  factory RoomMember.fromJson(Map<String, dynamic> json) => RoomMember(
        userId: json['userId'] as String,
        username: json['username'] as String?,
        name: json['name'] as String,
        avatar: json['avatar'] as String?,
        type: json['type'] as String? ?? 'member',
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'name': name,
        'avatar': avatar,
        'type': type,
      };
}
