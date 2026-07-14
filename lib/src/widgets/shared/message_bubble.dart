import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/message.dart';
import '../../models/message_attachment.dart';
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
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isMine ? theme.sentBubble : theme.receivedBubble,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (message.replyPreview != null) _ReplyPreview(preview: message.replyPreview!, theme: theme),
                    if (message.attachments.isNotEmpty)
                      ConstrainedBox(
                          constraints: BoxConstraints(minWidth: 300),
                          child: _AttachmentList(
                            attachments: message.attachments,
                            theme: theme,
                          )),
                    if (message.content.isNotEmpty)
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
          mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          border: Border(left: BorderSide(color: theme.primary, width: 3)),
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

class _AttachmentList extends StatelessWidget {
  const _AttachmentList({required this.attachments, required this.theme});

  final List<MessageAttachment> attachments;
  final PomacChatTheme theme;

  static bool _isImage(MessageAttachment a) {
    final mime = a.mimeType?.toLowerCase() ?? '';
    if (mime.startsWith('image/')) return true;
    final url = a.url.toLowerCase().split('?').first;
    return url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.png') ||
        url.endsWith('.gif') ||
        url.endsWith('.webp');
  }

  static String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    final images = attachments.where(_isImage).toList();
    final files = attachments.where((a) => !_isImage(a)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _ImageGrid(images: images),
          ),
        ...files.map((a) => _FileAttachment(
              attachment: a,
              theme: theme,
              formatSize: _formatSize,
            )),
      ],
    );
  }
}

// ── Image grid ────────────────────────────────────────────────────────────────

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({required this.images});

  final List<MessageAttachment> images;

  static const double _gap = 3;
  static const double _size = 290; // total grid width/height anchor
  static const double _cellSm = (_size - _gap) / 2; // half-size cell

  void _openSlider(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _ImageSliderDialog(
        urls: images.map((i) => i.url).toList(),
        initialIndex: initialIndex,
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    int index, {
    double width = _cellSm,
    double height = _cellSm,
    int? extraCount,
  }) {
    return GestureDetector(
      onTap: () => _openSlider(context, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: images[index].url,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ColoredBox(color: Color(0xFFE0E0E0)),
              errorWidget: (_, __, ___) => const ColoredBox(
                color: Color(0xFFE0E0E0),
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
            if (extraCount != null)
              ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: Text(
                    '+$extraCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = images.length;

    if (count == 1) {
      return SizedBox(
        width: _size,
        height: _size,
        child: _cell(context, 0, width: _size, height: _size),
      );
    }

    if (count == 2) {
      return SizedBox(
        width: _size,
        height: _cellSm,
        child: Row(
          children: [
            SizedBox(width: _cellSm, height: _cellSm, child: _cell(context, 0)),
            const SizedBox(width: _gap),
            SizedBox(width: _cellSm, height: _cellSm, child: _cell(context, 1)),
          ],
        ),
      );
    }

    if (count == 3) {
      return SizedBox(
        width: _size,
        height: _size,
        child: Row(
          children: [
            SizedBox(
              width: _cellSm,
              height: _size,
              child: _cell(context, 0, width: _cellSm, height: _size),
            ),
            const SizedBox(width: _gap),
            Column(
              children: [
                SizedBox(width: _cellSm, height: _cellSm, child: _cell(context, 1)),
                const SizedBox(height: _gap),
                SizedBox(width: _cellSm, height: _cellSm, child: _cell(context, 2)),
              ],
            ),
          ],
        ),
      );
    }

    // 4+
    final extra = count > 4 ? count - 4 : 0;
    return SizedBox(
      width: _size,
      height: _size,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: _cellSm, height: _cellSm, child: _cell(context, 0)),
              const SizedBox(width: _gap),
              SizedBox(width: _cellSm, height: _cellSm, child: _cell(context, 1)),
            ],
          ),
          const SizedBox(height: _gap),
          Row(
            children: [
              SizedBox(width: _cellSm, height: _cellSm, child: _cell(context, 2)),
              const SizedBox(width: _gap),
              SizedBox(
                width: _cellSm,
                height: _cellSm,
                child: _cell(context, 3, extraCount: extra > 0 ? extra : null),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Full-screen slider dialog ──────────────────────────────────────────────────

class _ImageSliderDialog extends StatefulWidget {
  const _ImageSliderDialog({
    required this.urls,
    required this.initialIndex,
  });

  final List<String> urls;
  final int initialIndex;

  @override
  State<_ImageSliderDialog> createState() => _ImageSliderDialogState();
}

class _ImageSliderDialogState extends State<_ImageSliderDialog> {
  late final PageController _ctrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => InteractiveViewer(
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.urls[i],
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          if (widget.urls.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${_current + 1} / ${widget.urls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          PositionedDirectional(
            start: 18,
            end: 18,
            top: MediaQuery.of(context).size.height / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ///     prev
                IconButton(
                  onPressed: () => _ctrl.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
                  icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
                ),

                ///     next
                IconButton(
                  onPressed: () => _ctrl.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
                  icon: Icon(Icons.arrow_forward_ios_outlined, color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _FileAttachment extends StatelessWidget {
  const _FileAttachment({
    required this.attachment,
    required this.theme,
    required this.formatSize,
  });

  final MessageAttachment attachment;
  final PomacChatTheme theme;
  final String Function(int?) formatSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file_outlined, size: 20, color: theme.mutedText),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.name ?? 'File',
                    style: TextStyle(
                      fontFamily: theme.fontFamily,
                      fontSize: 13,
                      color: theme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (attachment.size != null)
                    Text(
                      formatSize(attachment.size),
                      style: TextStyle(
                        fontFamily: theme.fontFamily,
                        fontSize: 11,
                        color: theme.mutedText,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
