import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/chat_theme.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = 40,
    this.showOnline = false,
    this.isOnline = false,
  });

  final String name;
  final String? avatarUrl;
  final double size;
  final bool showOnline;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = PomacChatTheme.of(context);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    Widget avatar = CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.primary.withValues(),
      child: avatarUrl != null && avatarUrl!.isNotEmpty
          ? ClipOval(
              child: kIsWeb
                  ? Image.network(
                      avatarUrl!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                      errorBuilder: (_, __, ___) => _Initial(
                        initial: initial,
                        size: size,
                        theme: theme,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: avatarUrl!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _Initial(
                        initial: initial,
                        size: size,
                        theme: theme,
                      ),
                    ),
            )
          : _Initial(initial: initial, size: size, theme: theme),
    );

    if (!showOnline) return avatar;

    return Stack(
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: BoxDecoration(
              color: isOnline ? theme.onlineIndicator : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({
    required this.initial,
    required this.size,
    required this.theme,
  });

  final String initial;
  final double size;
  final PomacChatTheme theme;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        initial,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: theme.fontFamily,
          fontSize: size * 0.45,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      )
    ],
  );
}