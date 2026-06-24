import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/room.dart';
import '../../theme/chat_theme.dart';
import 'user_avatar.dart';

class RoomItem extends StatelessWidget {
  const RoomItem({
    super.key,
    required this.room,
    required this.currentUserId,
    required this.onTap,
    this.isActive = false,
    this.isMobile = false,
  });

  final Room room;
  final String currentUserId;
  final VoidCallback onTap;
  final bool isActive;
  final bool isMobile;
  
  @override
  Widget build(BuildContext context) {
    final theme = PomacChatTheme.of(context);
    final other = room.otherMember(currentUserId);
    final lastMsgText = room.lastMessage?.text ?? '';
    final timestamp = room.lastMessageAt != null
        ? _formatTime(room.lastMessageAt!)
        : '';
    final hasNewMessage = (room.countUnreadedMessage??0) > 0;
    print('Room $lastMsgText $hasNewMessage');
    Widget content = InkWell(
      onTap: onTap,
      child: Container(
        height: isMobile ? 92 : 92,
        color: hasNewMessage || (isActive && !isMobile) ? theme.activeBg : Colors.transparent,
        child: Row(
          children: [
            if (isActive && !isMobile)
              Container(
                width: 6,
                height: isMobile ? 76 : 92,
                color: theme.primary,
              ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: theme.strokeBorder),
                  ),
                  color: hasNewMessage || (isActive && !isMobile)
                      ? theme.activeBg
                      : theme.backgroundCard,
                ),
                child: Row(
                  children: [
                    UserAvatar(
                      name: other?.name ?? room.name,
                      avatarUrl: other?.avatar,
                      size: 40,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  other?.name ?? room.name,
                                  style: theme.nameStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (timestamp.isNotEmpty)
                                Text(timestamp,
                                    style: theme.timestampStyle),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lastMsgText,
                            style: theme.previewStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return content;
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return DateFormat('HH:mm').format(dt);
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}