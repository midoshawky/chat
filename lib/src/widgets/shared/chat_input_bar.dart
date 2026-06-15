import 'package:flutter/material.dart';
import '../../theme/chat_theme.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onTyping,
  });

  final void Function(String text) onSend;
  final VoidCallback? onTyping;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = PomacChatTheme.of(context);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: theme.strokeBorder)),
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
                hintText: 'Typing...',
                hintStyle: TextStyle(
                  fontFamily: theme.fontFamily,
                  fontSize: 16,
                  color: theme.mutedText,
                ),
                border: InputBorder.none,
              ),
              onChanged: (v) {
                final has = v.trim().isNotEmpty;
                if (has != _hasText) setState(() => _hasText = has);
                widget.onTyping?.call();
              },
              onSubmitted: (_) => _handleSend(),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.photo_outlined,
                color: theme.textDark, size: 24),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.send_rounded,
              color: _hasText ? theme.primary : theme.mutedText,
              size: 24,
            ),
            onPressed: _hasText ? _handleSend : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}