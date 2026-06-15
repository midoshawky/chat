import 'message_sender.dart';
import 'message_attachment.dart';

enum MessageType { text, image, file, system }

MessageType _parseType(String? raw) {
  switch (raw) {
    case 'image':
      return MessageType.image;
    case 'file':
      return MessageType.file;
    case 'system':
      return MessageType.system;
    default:
      return MessageType.text;
  }
}

class Message {
  const Message({
    required this.id,
    required this.roomId,
    required this.type,
    required this.content,
    required this.sender,
    required this.attachments,
    required this.receipts,
    required this.createdAt,
    required this.updatedAt,
    this.replyPreview,
    this.editedAt,
    this.deletedAt,
  });

  final String id;
  final String roomId;
  final MessageType type;
  final String content;
  final MessageSender sender;
  final List<MessageAttachment> attachments;
  final List<dynamic> receipts;
  final Map<String, dynamic>? replyPreview;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDeleted => deletedAt != null;
  bool get isEdited => editedAt != null;
  bool isMine(String currentUserId) => sender.userId == currentUserId;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as String,
        roomId: json['roomId'] as String,
        type: _parseType(json['type'] as String?),
        content: json['content'] as String? ?? '',
        sender:
            MessageSender.fromJson(json['sender'] as Map<String, dynamic>),
        attachments: (json['attachments'] as List<dynamic>? ?? [])
            .map((e) =>
                MessageAttachment.fromJson(e as Map<String, dynamic>))
            .toList(),
        receipts: json['receipts'] as List<dynamic>? ?? [],
        replyPreview: json['replyPreview'] as Map<String, dynamic>?,
        editedAt: json['editedAt'] != null
            ? DateTime.parse(json['editedAt'] as String)
            : null,
        deletedAt: json['deletedAt'] != null
            ? DateTime.parse(json['deletedAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'roomId': roomId,
        'type': type.name,
        'content': content,
        'sender': sender.toJson(),
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'receipts': receipts,
        'replyPreview': replyPreview,
        'editedAt': editedAt?.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Message copyWith({
    String? id,
    String? roomId,
    MessageType? type,
    String? content,
    MessageSender? sender,
    List<MessageAttachment>? attachments,
    List<dynamic>? receipts,
    Map<String, dynamic>? replyPreview,
    DateTime? editedAt,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Message(
        id: id ?? this.id,
        roomId: roomId ?? this.roomId,
        type: type ?? this.type,
        content: content ?? this.content,
        sender: sender ?? this.sender,
        attachments: attachments ?? this.attachments,
        receipts: receipts ?? this.receipts,
        replyPreview: replyPreview ?? this.replyPreview,
        editedAt: editedAt ?? this.editedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
