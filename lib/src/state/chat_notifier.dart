import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../models/room.dart';
import '../models/typing_event.dart';
import 'providers.dart';

class ChatState {
  const ChatState({
    required this.room,
    required this.messages,
    required this.currentPage,
    required this.hasMore,
    this.isTyping = false,
    this.typingUser,
  });

  final Room room;
  final List<Message> messages;
  final int currentPage;
  final bool hasMore;
  final bool isTyping;
  final TypingEvent? typingUser;

  ChatState copyWith({
    Room? room,
    List<Message>? messages,
    int? currentPage,
    bool? hasMore,
    bool? isTyping,
    TypingEvent? typingUser,
    bool clearTyping = false,
  }) =>
      ChatState(
        room: room ?? this.room,
        messages: messages ?? this.messages,
        currentPage: currentPage ?? this.currentPage,
        hasMore: hasMore ?? this.hasMore,
        isTyping: clearTyping ? false : (isTyping ?? this.isTyping),
        typingUser: clearTyping ? null : (typingUser ?? this.typingUser),
      );
}

class ChatNotifier extends AutoDisposeFamilyAsyncNotifier<ChatState, String> {
  StreamSubscription<Message>? _createdSub;
  StreamSubscription<Message>? _updatedSub;
  StreamSubscription<dynamic>? _deletedSub;
  StreamSubscription<TypingEvent>? _typingSub;
  Timer? _typingDebounce;
  Timer? _typingClearTimer;
  String? _currentRoomId;

  @override
  Future<ChatState> build(String arg) async {
    ref.onDispose(_cleanup);
    return _loadRoom(arg);
  }

  Future<ChatState> _loadRoom(String roomId) async {
    _cleanup();
    _currentRoomId = roomId;

    final service = ref.read(chatServiceProvider);
    service.socket.joinRoom(roomId);

    final roomResult = await service.getRooms(perPage: 100);
    final room = roomResult.data.firstWhere(
      (r) => r.id == roomId,
      orElse: () => Room(
        id: roomId,
        name: roomId,
        type: 'private',
        members: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final msgResult = await service.getMessages(roomId);
    service.socket.markRead(roomId);

    _subscribeToSocket(roomId);
    
    return ChatState(
      room: room.copyWith(countUnreadedMessage: 0),
      messages: msgResult.data,
      currentPage: 1,
      hasMore: msgResult.hasNext,
    );
  }

  void _subscribeToSocket(String roomId) {
    final service = ref.read(chatServiceProvider);

    _createdSub = service.onMessageCreated.listen((msg) {
      if (msg.roomId != roomId) return;
      final current = state.valueOrNull;
      if (current == null) return;
      final exists = current.messages.any((m) => m.id == msg.id);
      if (exists) return;
      state = AsyncData(
          current.copyWith(messages: [msg, ...current.messages]));
    });

    _updatedSub = service.onMessageUpdated.listen((msg) {
      if (msg.roomId != roomId) return;
      final current = state.valueOrNull;
      if (current == null) return;
      final updated = current.messages
          .map((m) => m.id == msg.id ? msg : m)
          .toList();
      state = AsyncData(current.copyWith(messages: updated));
    });

    _deletedSub = service.onMessageDeleted.listen((del) {
      if (del.roomId != roomId) return;
      final current = state.valueOrNull;
      if (current == null) return;
      final updated = current.messages.map((m) {
        if (m.id == del.messageId) {
          return m.copyWith(deletedAt: del.deletedAt);
        }
        return m;
      }).toList();
      state = AsyncData(current.copyWith(messages: updated));
    });

    _typingSub = service.onTyping.listen((event) {
      if (event.roomId != roomId) return;
      final current = state.valueOrNull;
      if (current == null) return;

      _typingClearTimer?.cancel();

      if (event.isTyping) {
        state = AsyncData(current.copyWith(
          isTyping: true,
          typingUser: event,
        ));
        _typingClearTimer = Timer(const Duration(seconds: 3), () {
          final s = state.valueOrNull;
          if (s != null) {
            state = AsyncData(s.copyWith(clearTyping: true));
          }
        });
      } else {
        state = AsyncData(current.copyWith(clearTyping: true));
      }
    });
  }

  Future<void> loadMoreMessages() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore) return;

    final nextPage = current.currentPage + 1;
    final service = ref.read(chatServiceProvider);
    final result =
        await service.getMessages(_currentRoomId!, page: nextPage);

    final combined = [...current.messages, ...result.data];
    state = AsyncData(current.copyWith(
      messages: combined,
      currentPage: nextPage,
      hasMore: result.hasNext,
    ));
  }

  void sendMessage(
    String content, {
    String type = 'text',
    String? replyTo,
    List<Map<String, String>>? attachments,
  }) {
    final service = ref.read(chatServiceProvider);
    service.socket.sendMessage(
      roomId: _currentRoomId!,
      content: content,
      type: type,
      replyTo: replyTo,
      attachments: attachments,
    );
  }

  void editMessage(String messageId, String content) {
    final service = ref.read(chatServiceProvider);
    service.socket.updateMessage(messageId, _currentRoomId!, content);
  }

  void deleteMessage(String messageId) {
    final service = ref.read(chatServiceProvider);
    service.socket.deleteMessage(messageId, _currentRoomId!);
  }

  void markRead() {
    final service = ref.read(chatServiceProvider);
    service.socket.markRead(_currentRoomId!);
  }

  void notifyTyping() {
    _typingDebounce?.cancel();
    final service = ref.read(chatServiceProvider);
    service.socket.sendTyping(_currentRoomId!, isTyping: true);
    _typingDebounce = Timer(const Duration(seconds: 2), () {
      service.socket.sendTyping(_currentRoomId!, isTyping: false);
    });
  }

  void _cleanup() {
    _createdSub?.cancel();
    _updatedSub?.cancel();
    _deletedSub?.cancel();
    _typingSub?.cancel();
    _typingDebounce?.cancel();
    _typingClearTimer?.cancel();
  }
}

final chatNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<ChatNotifier, ChatState, String>(
  ChatNotifier.new,
);