import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/room_notifier.dart';
import '../../state/chat_notifier.dart';
import '../../state/providers.dart';
import '../../theme/chat_theme.dart';
import '../shared/user_avatar.dart';
import '../shared/message_bubble.dart';
import '../shared/date_separator.dart';
import '../shared/chat_input_bar.dart';
import '../shared/typing_indicator.dart';

class ChatWindowPanel extends ConsumerStatefulWidget {
  const ChatWindowPanel({super.key});

  @override
  ConsumerState<ChatWindowPanel> createState() => _ChatWindowPanelState();
}

class _ChatWindowPanelState extends ConsumerState<ChatWindowPanel> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final roomId =
          ref.read(roomNotifierProvider).valueOrNull?.activeRoomId;
      if (roomId != null) {
        ref.read(chatNotifierProvider(roomId).notifier).loadMoreMessages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = PomacChatTheme.of(context);
    final roomState = ref.watch(roomNotifierProvider).valueOrNull;
    final activeRoomId = roomState?.activeRoomId;

    if (activeRoomId == null) {
      return _EmptyState(theme: theme);
    }

    final chatAsync = ref.watch(chatNotifierProvider(activeRoomId));
    final currentUserId = ref.watch(currentUserIdProvider);

    return Container(
      width: 540,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E1E1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: chatAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (chatState) {
          final other = chatState.room.otherMember(currentUserId);
          return Column(
            children: [
              _ChatHeader(
                name: other?.name ?? chatState.room.name,
                avatarUrl: other?.avatar,
                theme: theme,
              ),
              Expanded(
                child: _MessageList(
                  chatState: chatState,
                  currentUserId: currentUserId,
                  scrollController: _scrollController,
                  theme: theme,
                ),
              ),
              ChatInputBar(
                onSend: (text) => ref
                    .read(chatNotifierProvider(activeRoomId).notifier)
                    .sendMessage(text),
                onTyping: () => ref
                    .read(chatNotifierProvider(activeRoomId).notifier)
                    .notifyTyping(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.name,
    required this.avatarUrl,
    required this.theme,
  });

  final String name;
  final String? avatarUrl;
  final PomacChatTheme theme;

  @override
  Widget build(BuildContext context) => Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: const Color(0xFFE1E1E1))),
        ),
        child: Row(
          children: [
            UserAvatar(
              name: name,
              avatarUrl: avatarUrl,
              size: 40,
              showOnline: true,
              isOnline: true,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                name,
                style: theme.headerNameStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.more_horiz, color: theme.mutedText, size: 24),
          ],
        ),
      );
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.chatState,
    required this.currentUserId,
    required this.scrollController,
    required this.theme,
  });

  final ChatState chatState;
  final String currentUserId;
  final ScrollController scrollController;
  final PomacChatTheme theme;

  @override
  Widget build(BuildContext context) {
    final messages = chatState.messages;

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length +
          (chatState.isTyping ? 1 : 0) +
          (chatState.hasMore ? 1 : 0),
      itemBuilder: (ctx, index) {
        if (chatState.isTyping && index == 0) {
          return TypingIndicator(
              userName: chatState.typingUser?.userName);
        }

        final msgIndex =
            index - (chatState.isTyping ? 1 : 0);

        if (msgIndex >= messages.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final msg = messages[msgIndex];
        final showDate = msgIndex == messages.length - 1 ||
            !_isSameDay(msg.createdAt,
                messages[msgIndex + 1].createdAt);

        return Column(
          children: [
            if (showDate) DateSeparator(date: msg.createdAt),
            MessageBubble(
              message: msg,
              currentUserId: currentUserId,
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});
  final PomacChatTheme theme;

  @override
  Widget build(BuildContext context) => Container(
        width: 540,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE1E1E1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 48, color: theme.strokeBorder),
              const SizedBox(height: 16),
              Text(
                'Select a conversation to start chatting',
                style: TextStyle(
                  fontFamily: theme.fontFamily,
                  color: theme.mutedText,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
}