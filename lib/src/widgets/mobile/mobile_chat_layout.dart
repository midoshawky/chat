import 'package:flutter/material.dart';
import 'mobile_room_list_screen.dart';
import 'mobile_chat_screen.dart';

class MobileChatLayout extends StatefulWidget {
  const MobileChatLayout({super.key});

  @override
  State<MobileChatLayout> createState() => _MobileChatLayoutState();
}

class _MobileChatLayoutState extends State<MobileChatLayout> {
  final _navigatorKey = GlobalKey<NavigatorState>();

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