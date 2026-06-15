import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/message.dart';
import '../../theme/chat_theme.dart';
import 'user_avatar.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
  });

  final Message message;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = PomacChatTheme.of(context);
    final isMine = message.isMine(currentUserId);

    if (message.isDeleted) {
      return _DeletedBubble(isMine: isMine, theme: theme);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            UserAvatar(
              name: message.sender.name,
              avatarUrl: message.sender.avatar,
              size: 32,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isMine ? theme.sentBubble : theme.receivedBubble,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (message.replyPreview != null)
                      _ReplyPreview(
                          preview: message.replyPreview!, theme: theme),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        message.content,
                        style: theme.bubbleTextStyle,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(message.createdAt),
                          style: theme.bubbleTimestampStyle,
                        ),
                        if (message.isEdited) ...[
                          const SizedBox(width: 4),
                          Text(
                            'edited',
                            style: theme.bubbleTimestampStyle.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMine) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _DeletedBubble extends StatelessWidget {
  const _DeletedBubble({required this.isMine, required this.theme});

  final bool isMine;
  final PomacChatTheme theme;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment:
              isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.strokeBorder,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'This message was deleted',
                style: TextStyle(
                  fontFamily: theme.fontFamily,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: theme.mutedText,
                ),
              ),
            ),
          ],
        ),
      );
}

class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({required this.preview, required this.theme});

  final Map<String, dynamic> preview;
  final PomacChatTheme theme;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border(
              left: BorderSide(color: theme.primary, width: 3)),
        ),
        child: Text(
          preview['content']?.toString() ?? '',
          style: TextStyle(
            fontFamily: theme.fontFamily,
            fontSize: 13,
            color: theme.mutedText,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
}