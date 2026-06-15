import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/message.dart';
import '../models/message_deleted.dart';
import '../models/typing_event.dart';
import '../models/chat_error.dart';

class MessageDelivered {
  const MessageDelivered({
    required this.messageId,
    required this.roomId,
    required this.userId,
  });
  final String messageId;
  final String roomId;
  final String userId;
}

class MessageRead {
  const MessageRead({required this.roomId, required this.userId});
  final String roomId;
  final String userId;
}

class SocketService {
  SocketService({required String socketUrl, required String token})
      : _socketUrl = socketUrl,
        _token = token;

  final String _socketUrl;
  final String _token;
  io.Socket? _socket;

  final _messageCreatedCtrl =
      StreamController<Message>.broadcast();
  final _messageUpdatedCtrl =
      StreamController<Message>.broadcast();
  final _messageDeletedCtrl =
      StreamController<MessageDeleted>.broadcast();
  final _messageDeliveredCtrl =
      StreamController<MessageDelivered>.broadcast();
  final _messageReadCtrl =
      StreamController<MessageRead>.broadcast();
  final _typingCtrl = StreamController<TypingEvent>.broadcast();
  final _roomJoinedCtrl = StreamController<String>.broadcast();
  final _connectedCtrl = StreamController<void>.broadcast();
  final _disconnectedCtrl = StreamController<void>.broadcast();
  final _errorCtrl = StreamController<ChatError>.broadcast();

  Stream<Message> get onMessageCreated => _messageCreatedCtrl.stream;
  Stream<Message> get onMessageUpdated => _messageUpdatedCtrl.stream;
  Stream<MessageDeleted> get onMessageDeleted =>
      _messageDeletedCtrl.stream;
  Stream<MessageDelivered> get onMessageDelivered =>
      _messageDeliveredCtrl.stream;
  Stream<MessageRead> get onMessageRead => _messageReadCtrl.stream;
  Stream<TypingEvent> get onTyping => _typingCtrl.stream;
  Stream<String> get onRoomJoined => _roomJoinedCtrl.stream;
  Stream<void> get onConnected => _connectedCtrl.stream;
  Stream<void> get onDisconnected => _disconnectedCtrl.stream;
  Stream<ChatError> get onError => _errorCtrl.stream;

  bool get isConnected => _socket?.connected ?? false;

  String get _wsUrl {
    final uri = Uri.parse(_socketUrl);
    return Uri(scheme: uri.scheme, host: uri.host, port: 443).toString();
  }

  void connect() {
    _socket = io.io(
      'https://dev-backend-shuwier-chat.pomac.info/',
      io.OptionBuilder()
      .setPath('/socket.io/')
          .setTransports([ 'polling','websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(double.infinity)
          .setReconnectionDelay(2000)
          .enableForceNew()
          .setAuth({'token': _token})
          .build(),
    );

    debugPrint('[Socket] Connecting to $_wsUrl');

    _socket!
      ..onConnect((_) {
        print('[Socket] Connected');
        _connectedCtrl.add(null);
      })
      ..onDisconnect((_) {
        print('[Socket] Disconnected');
        _disconnectedCtrl.add(null);
      })
      ..on('connect_error', (data) {
        print('[Socket] connect_error: $data');
        _errorCtrl.add(ChatError(message: data?.toString() ?? 'Connection error'));
      })
      ..on('error', (data) {
        final msg = data is Map
            ? data['message']?.toString() ?? 'Socket error'
            : data?.toString() ?? 'Socket error';
        print('[Socket] error: $msg');
        _errorCtrl.add(ChatError(message: msg));
      })
      ..on('room:joined', (data) {
        final d = _toMap(data);
        final roomId = d['roomId'] as String? ?? '';
        print('[Socket] room:joined roomId=$roomId');
        _roomJoinedCtrl.add(roomId);
      })
      ..on('message:created', (data) {
        try {
          final msg = Message.fromJson(_toMap(data));
          print('[Socket] message:created id=${msg.id} roomId=${msg.roomId}');
          _messageCreatedCtrl.add(msg);
        } catch (e) {
          print('[Socket] message:created parse error: $e | raw: $data');
        }
      })
      ..on('message:updated', (data) {
        try {
          final msg = Message.fromJson(_toMap(data));
          print('[Socket] message:updated id=${msg.id} roomId=${msg.roomId}');
          _messageUpdatedCtrl.add(msg);
        } catch (e) {
          print('[Socket] message:updated parse error: $e | raw: $data');
        }
      })
      ..on('message:deleted', (data) {
        try {
          final msg = MessageDeleted.fromJson(_toMap(data));
          print('[Socket] message:deleted id=${msg.messageId}');
          _messageDeletedCtrl.add(msg);
        } catch (e) {
          print('[Socket] message:deleted parse error: $e | raw: $data');
        }
      })
      ..on('message:delivered', (data) {
        try {
          final d = _toMap(data);
          final delivered = MessageDelivered(
            messageId: d['messageId'] as String,
            roomId: d['roomId'] as String,
            userId: d['userId'] as String,
          );
          print('[Socket] message:delivered messageId=${delivered.messageId} userId=${delivered.userId}');
          _messageDeliveredCtrl.add(delivered);
        } catch (e) {
          print('[Socket] message:delivered parse error: $e | raw: $data');
        }
      })
      ..on('message:read', (data) {
        try {
          final d = _toMap(data);
          final read = MessageRead(
            roomId: d['roomId'] as String,
            userId: d['userId'] as String,
          );
          print('[Socket] message:read roomId=${read.roomId} userId=${read.userId}');
          _messageReadCtrl.add(read);
        } catch (e) {
          print('[Socket] message:read parse error: $e | raw: $data');
        }
      })
      ..on('typing', (data) {
        try {
          final event = TypingEvent.fromJson(_toMap(data));
          print('[Socket] typing roomId=${event.roomId} userId=${event.userId} isTyping=${event.isTyping}');
          _typingCtrl.add(event);
        } catch (e) {
          print('[Socket] typing parse error: $e | raw: $data');
        }
      });
  }

  void disconnect() {
    print('[Socket] Disconnecting');
    _socket?.disconnect();
  }

  void joinRoom(String roomId) {
    print('[Socket] emit room:join roomId=$roomId');
    _socket?.emit('room:join', {'roomId': roomId});
  }

  void sendMessage({
    required String roomId,
    required String content,
    String type = 'text',
    String? replyTo,
    List<Map<String, String>>? attachments,
  }) {
    print('[Socket] emit message:send roomId=$roomId type=$type content=$content');
    _socket?.emit('message:send', {
      'roomId': roomId,
      'type': type,
      'content': content,
      if (replyTo != null) 'replyTo': replyTo,
      if (attachments != null) 'attachments': attachments,
    });
  }

  void markRead(String roomId) {
    print('[Socket] emit message:read roomId=$roomId');
    _socket?.emit('message:read', {'roomId': roomId});
  }

  void sendTyping(String roomId, {required bool isTyping}) {
    print('[Socket] emit typing roomId=$roomId isTyping=$isTyping');
    _socket?.emit('typing', {'roomId': roomId, 'isTyping': isTyping});
  }

  void updateMessage(String messageId, String roomId, String content) {
    print('[Socket] emit message:update messageId=$messageId roomId=$roomId');
    _socket?.emit('message:update', {
      'messageId': messageId,
      'roomId': roomId,
      'content': content,
    });
  }

  void deleteMessage(String messageId, String roomId) {
    print('[Socket] emit message:delete messageId=$messageId roomId=$roomId');
    _socket?.emit('message:delete', {
      'messageId': messageId,
      'roomId': roomId,
    });
  }

  void dispose() {
    _socket?.dispose();
    _messageCreatedCtrl.close();
    _messageUpdatedCtrl.close();
    _messageDeletedCtrl.close();
    _messageDeliveredCtrl.close();
    _messageReadCtrl.close();
    _typingCtrl.close();
    _roomJoinedCtrl.close();
    _connectedCtrl.close();
    _disconnectedCtrl.close();
    _errorCtrl.close();
  }

  static Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}