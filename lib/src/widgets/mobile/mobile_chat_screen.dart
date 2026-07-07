import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/chat_notifier.dart';
import '../../state/providers.dart';
import '../../theme/chat_theme.dart';
import '../shared/user_avatar.dart';
import '../shared/message_bubble.dart';
import '../shared/date_separator.dart';
import '../shared/chat_input_bar.dart';
import '../shared/typing_indicator.dart';

class MobileChatScreen extends ConsumerStatefulWidget {
  const MobileChatScreen({
    super.key,
    required this.roomId,
    required this.onBack,
  });

  final String roomId;
  final VoidCallback onBack;

  @override
  ConsumerState<MobileChatScreen> createState() => _MobileChatScreenState();
}

class _MobileChatScreenState extends ConsumerState<MobileChatScreen> {
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
      ref
          .read(chatNotifierProvider(widget.roomId).notifier)
          .loadMoreMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = PomacChatTheme.of(context);
    final currentUserId = ref.watch(currentUserIdProvider);
    final chatAsync = ref.watch(chatNotifierProvider(widget.roomId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: chatAsync.when(
        loading: () => AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(onPressed: widget.onBack),
        ),
        error: (_, __) => AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(onPressed: widget.onBack),
        ),
        data: (chatState) {
          final other = chatState.room.otherMember(currentUserId);
          final name = other?.name ?? chatState.room.name;
          return AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: BackButton(
              onPressed: widget.onBack,
              color: theme.textPrimary,
            ),
            title: Row(
              children: [
                UserAvatar(
                  name: name,
                  avatarUrl: other?.avatar,
                  size: 36,
                  showOnline: true,
                  isOnline: true,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: theme.headerNameStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      body: chatAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (chatState) => Column(
          children: [
            Expanded(
              child: chatState.messages.isEmpty && !chatState.isTyping
                  ? _EmptyChatPlaceholder(theme: theme)
                  : ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                itemCount: chatState.messages.length +
                    (chatState.isTyping ? 1 : 0) +
                    (chatState.hasMore ? 1 : 0),
                itemBuilder: (ctx, index) {
                  if (chatState.isTyping && index == 0) {
                    return TypingIndicator(
                        userName: chatState.typingUser?.userName);
                  }

                  final msgIndex =
                      index - (chatState.isTyping ? 1 : 0);

                  if (msgIndex >= chatState.messages.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child:
                          Center(child: CircularProgressIndicator()),
                    );
                  }

                  final msg = chatState.messages[msgIndex];
                  final showDate = msgIndex ==
                          chatState.messages.length - 1 ||
                      !_isSameDay(
                          msg.createdAt,
                          chatState
                              .messages[msgIndex + 1].createdAt);

                  return Column(
                    children: [
                      if (showDate)
                        DateSeparator(date: msg.createdAt),
                      MessageBubble(
                        message: msg,
                        currentUserId: currentUserId,
                      ),
                    ],
                  );
                },
              ),
            ),
            ChatInputBar(
              onSend: (text, attachments, {type = 'text'}) => ref
                  .read(
                      chatNotifierProvider(widget.roomId).notifier)
                  .sendMessage(
                    text,
                    type: type,
                    attachments: attachments.isEmpty ? null : attachments,
                  ),
              onTyping: () => ref
                  .read(
                      chatNotifierProvider(widget.roomId).notifier)
                  .notifyTyping(),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _EmptyChatPlaceholder extends StatelessWidget {
  const _EmptyChatPlaceholder({required this.theme});

  final PomacChatTheme theme;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: theme.mutedText,
              ),
              const SizedBox(height: 12),
              Text(
                'No messages yet',
                style: TextStyle(
                  fontFamily: theme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Say hello to start the conversation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: theme.fontFamily,
                  fontSize: 13,
                  color: theme.mutedText,
                ),
              ),
            ],
          ),
        ),
      );
}