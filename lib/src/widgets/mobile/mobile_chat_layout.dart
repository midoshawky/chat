import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/room_notifier.dart';
import 'mobile_room_list_screen.dart';
import 'mobile_chat_screen.dart';

class MobileChatLayout extends ConsumerStatefulWidget {
  const MobileChatLayout({super.key});

  @override
  ConsumerState<MobileChatLayout> createState() => _MobileChatLayoutState();
}

class _MobileChatLayoutState extends ConsumerState<MobileChatLayout> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _autoOpened = false;

  void _openRoom(String roomId) {
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => MobileChatScreen(
          roomId: roomId,
          onBack: () => _navigatorKey.currentState?.pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<RoomListState>>(roomNotifierProvider, (prev, next) {
      final activeRoomId = next.valueOrNull?.activeRoomId;
      if (!_autoOpened && activeRoomId != null) {
        _autoOpened = true;
        _openRoom(activeRoomId);
      }
    });

    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => MobileRoomListScreen(
          onRoomTap: _openRoom,
        ),
      ),
    );
  }
}
