import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room.dart';
import '../models/message.dart';
import '../models/room_last_message.dart';
import 'providers.dart';

class RoomListState {
  const RoomListState({
    required this.rooms,
    this.activeRoomId,
    this.searchQuery = '',
    this.isSearching = false,
  });

  final List<Room> rooms;
  final String? activeRoomId;
  final String searchQuery;
  final bool isSearching;

  RoomListState copyWith({
    List<Room>? rooms,
    String? activeRoomId,
    bool clearActiveRoom = false,
    String? searchQuery,
    bool? isSearching,
  }) =>
      RoomListState(
        rooms: rooms ?? this.rooms,
        activeRoomId:
            clearActiveRoom ? null : (activeRoomId ?? this.activeRoomId),
        searchQuery: searchQuery ?? this.searchQuery,
        isSearching: isSearching ?? this.isSearching,
      );
}

class RoomNotifier extends AutoDisposeAsyncNotifier<RoomListState> {
  Timer? _searchDebounce;
  StreamSubscription<Message>? _msgSub;
  StreamSubscription<String>? _roomNewMsgSub;

  @override
  Future<RoomListState> build() async {
    ref.onDispose(() {
      _searchDebounce?.cancel();
      _msgSub?.cancel();
      _roomNewMsgSub?.cancel();
    });

    final service = ref.read(chatServiceProvider);
    _msgSub = service.onMessageCreated.listen(_onMessageCreated);
    _roomNewMsgSub = service.onRoomNewMessage.listen((_) async {
      // Refresh rooms list when new message arrives in a room (no loading indicator)
      print('[RoomNotifier] room:new-message received, refreshing rooms list');
      await load(showLoading: false);
    });

    final result = await service.getRooms();
    final initialRoomId = ref.read(currentRoomIdProvider);
    final hasInitialRoom =
        initialRoomId != null && result.data.any((r) => r.id == initialRoomId);
    return RoomListState(
      rooms: result.data,
      activeRoomId: hasInitialRoom ? initialRoomId : null,
    );
  }

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) {
      state = const AsyncLoading();
    }
    state = await AsyncValue.guard(() async {
      final service = ref.read(chatServiceProvider);
      final result = await service.getRooms();
      final current = state.valueOrNull;
      return RoomListState(
        rooms: result.data,
        activeRoomId: current?.activeRoomId,
      );
    });
  }

  void search(String query) {
    _searchDebounce?.cancel();
    if (query.isEmpty) {
      clearSearch();
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      final current = state.valueOrNull;
      state = AsyncData(
        (current ?? const RoomListState(rooms: [])).copyWith(
          isSearching: true,
          searchQuery: query,
        ),
      );
      state = await AsyncValue.guard(() async {
        final service = ref.read(chatServiceProvider);
        final result = await service.getRooms(search: query);
        return RoomListState(
          rooms: result.data,
          activeRoomId: current?.activeRoomId,
          searchQuery: query,
          isSearching: false,
        );
      });
    });
  }

  Future<void> clearSearch() async {
    final current = state.valueOrNull;
    state = await AsyncValue.guard(() async {
      final service = ref.read(chatServiceProvider);
      final result = await service.getRooms();
      return RoomListState(
        rooms: result.data,
        activeRoomId: current?.activeRoomId,
      );
    });
  }

  void selectRoom(String roomId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(activeRoomId: roomId));
  }

  void _onMessageCreated(Message msg) {
    final current = state.valueOrNull;
    if (current == null) return;

    final idx = current.rooms.indexWhere((r) => r.id == msg.roomId);
    if (idx == -1) return;

    final updatedRoom = current.rooms[idx].copyWith(
      lastMessage: RoomLastMessage(
        messageId: msg.id,
        text: msg.content,
        senderId: msg.sender.userId,
        createdAt: msg.createdAt,
      ),
      lastMessageAt: msg.createdAt,
      updatedAt: msg.createdAt,
    );

    final updated = List<Room>.from(current.rooms)
      ..removeAt(idx)
      ..insert(0, updatedRoom);

    state = AsyncData(current.copyWith(rooms: updated));
  }
}

final roomNotifierProvider =
    AsyncNotifierProvider.autoDispose<RoomNotifier, RoomListState>(
  RoomNotifier.new,
);
