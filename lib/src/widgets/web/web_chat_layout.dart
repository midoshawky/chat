import 'package:flutter/material.dart';
import 'room_list_panel.dart';
import 'chat_window_panel.dart';
import 'communication_tips_panel.dart';

class WebChatLayout extends StatelessWidget {
  const WebChatLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      minimum: EdgeInsets.all(16),
      child:Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoomListPanel(),
        SizedBox(width: 16),
        ChatWindowPanel(),
        SizedBox(width: 16),
        CommunicationTipsPanel(),
      ],
    ));
  }
}