import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jovial_svg/jovial_svg.dart';

import '../../state/providers.dart';
import '../../theme/chat_theme.dart';

final _emailRegex = RegExp(
  r"[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+",
);
final _phoneRegex = RegExp(r'(\+?\d[\d\-.\s()]{6,}\d)');

bool _containsContactInfo(String text) =>
    _emailRegex.hasMatch(text) || _phoneRegex.hasMatch(text);

class ChatInputBar extends ConsumerStatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onTyping,
  });

  final void Function(String text, List<Map<String, String>> attachments, {String type}) onSend;
  final VoidCallback? onTyping;

  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _PendingAttachment {
  _PendingAttachment({required this.file});
  final XFile file;
  Map<String, dynamic>? uploadedData;
  bool hasError = false;
  bool get isUploading => uploadedData == null && !hasError;
  bool get isReady => uploadedData != null;
}

class _ChatInputBarState extends ConsumerState<ChatInputBar> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  bool _hasText = false;
  bool _hasInvalidContent = false;
  final List<_PendingAttachment> _attachments = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSend =>
      (_hasText || _attachments.any((a) => a.isReady)) &&
      !_hasInvalidContent;

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;

    final newAttachments = picked.map((f) => _PendingAttachment(file: f)).toList();
    setState(() => _attachments.addAll(newAttachments));

    final service = ref.read(chatServiceProvider);
    for (final attachment in newAttachments) {
      try {
        final bytes = await attachment.file.readAsBytes();
        final results = await service.uploadFiles([
          (filename: attachment.file.name, bytes: bytes),
        ]);
        if (results.isNotEmpty) {
          setState(() => attachment.uploadedData = results.first);
        } else {
          setState(() => attachment.hasError = true);
        }
      } catch (e, st) {
        debugPrint('Upload failed: $e\n$st');
        setState(() => attachment.hasError = true);
      }
    }
  }

  void _removeAttachment(_PendingAttachment attachment) {
    setState(() => _attachments.remove(attachment));
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (!_canSend) return;

    final uploaded = _attachments
        .where((a) => a.isReady)
        .map((a) => {
              'fileUrl': (a.uploadedData!['fileUrl'] ??
                      a.uploadedData!['url'] ?? '')
                  .toString(),
            })
        .toList();

    final type = text.isEmpty && uploaded.isNotEmpty ? 'image' : 'text';
    widget.onSend(text, uploaded, type: type);
    _controller.clear();
    setState(() {
      _hasText = false;
      _hasInvalidContent = false;
      _attachments.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = PomacChatTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_hasInvalidContent) _ContactInfoWarningBanner(theme: theme),
        if (_attachments.isNotEmpty) _AttachmentPreviewStrip(
          attachments: _attachments,
          onRemove: _removeAttachment,
          theme: theme,
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: theme.strokeBorder)),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(
                    fontFamily: theme.fontFamily,
                    fontSize: 16,
                    color: theme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Message',
                    hintStyle: TextStyle(
                      fontFamily: theme.fontFamily,
                      fontSize: 16,
                      color: theme.mutedText,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (v) {
                    final has = v.trim().isNotEmpty;
                    final invalid = _containsContactInfo(v);
                    if (has != _hasText || invalid != _hasInvalidContent) {
                      setState(() {
                        _hasText = has;
                        _hasInvalidContent = invalid;
                      });
                    }
                    widget.onTyping?.call();
                  },
                  onSubmitted: (_) => _handleSend(),
                  textInputAction: TextInputAction.send,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: SizedBox(
                  width: 24,
                  height: 24,
                  child: ScalableImageWidget.fromSISource(
                    si: ScalableImageSource.fromSvg(
                      rootBundle,
                      'packages/pomac_chat_app/assets/icons/pick_image.svg',
                    ),
                    currentColor: theme.textDark,
                  ),
                ),
                onPressed: _pickImages,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: SizedBox(
                  width: 24,
                  height: 24,
                  child: ScalableImageWidget.fromSISource(
                    si: ScalableImageSource.fromSvg(
                      rootBundle,
                      'packages/pomac_chat_app/assets/icons/send_icon.svg',
                    ),
                    currentColor: _canSend ? theme.primary : theme.mutedText,
                  ),
                ),
                onPressed: _canSend ? _handleSend : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactInfoWarningBanner extends StatelessWidget {
  const _ContactInfoWarningBanner({required this.theme});

  static const _errorColor = Color(0xFFE57373);

  final PomacChatTheme theme;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: theme.backgroundCard,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          'Messages cannot contain email addresses or phone numbers',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: theme.fontFamily,
            fontSize: 13,
            color: _errorColor,
          ),
        ),
      );
}

class _AttachmentPreviewStrip extends StatelessWidget {
  const _AttachmentPreviewStrip({
    required this.attachments,
    required this.onRemove,
    required this.theme,
  });

  final List<_PendingAttachment> attachments;
  final void Function(_PendingAttachment) onRemove;
  final PomacChatTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: theme.strokeBorder)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: attachments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _AttachmentThumbnail(
          attachment: attachments[i],
          onRemove: () => onRemove(attachments[i]),
          theme: theme,
        ),
      ),
    );
  }
}

class _AttachmentThumbnail extends StatelessWidget {
  const _AttachmentThumbnail({
    required this.attachment,
    required this.onRemove,
    required this.theme,
  });

  final _PendingAttachment attachment;
  final VoidCallback onRemove;
  final PomacChatTheme theme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 64,
            height: 64,
            child: kIsWeb
                ? Image.network(attachment.file.path, fit: BoxFit.cover)
                : Image.file(File(attachment.file.path), fit: BoxFit.cover),
          ),
        ),
        if (attachment.isUploading)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.black38,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (attachment.hasError)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.red.withValues(alpha: 0.6),
                child: const Center(
                  child: Icon(Icons.error_outline, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }
}
