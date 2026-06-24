import 'room_member.dart';
import 'room_last_message.dart';

class Room {
  const Room({
    required this.id,
    required this.name,
    required this.type,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.lastMessageAt,
    this.countUnreadedMessage
  });

  final String id;
  final String name;
  final String type;
  final int? countUnreadedMessage;
  final List<RoomMember> members;
  final RoomLastMessage? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoomMember? otherMember(String currentUserId) {
    try {
      return members.firstWhere((m) => m.userId != currentUserId);
    } catch (_) {
      return members.isNotEmpty ? members.first : null;
    }
  }

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Unknown',
        type: json['type'] as String,
        countUnreadedMessage : json['countUnreadedMessage'] as int?,
        members: (json['members'] as List<dynamic>)
            .map((e) => RoomMember.fromJson(e as Map<String, dynamic>))
            .toList(),
        lastMessage: json['lastMessage'] != null
            ? RoomLastMessage.fromJson(
                json['lastMessage'] as Map<String, dynamic>)
            : null,
        lastMessageAt: json['lastMessageAt'] != null
            ? DateTime.parse(json['lastMessageAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'members': members.map((m) => m.toJson()).toList(),
        'lastMessage': lastMessage?.toJson(),
        'countUnreadedMessage' : countUnreadedMessage,
        'lastMessageAt': lastMessageAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Room copyWith({
    String? id,
    String? name,
    String? type,
    int? countUnreadedMessage,
    List<RoomMember>? members,
    RoomLastMessage? lastMessage,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Room(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        members: members ?? this.members,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        countUnreadedMessage : countUnreadedMessage ?? this.countUnreadedMessage
      );
}
