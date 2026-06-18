import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/chat_service.dart';
import 'state/providers.dart';
import 'theme/chat_theme.dart';
import 'widgets/web/web_chat_layout.dart';
import 'widgets/mobile/mobile_chat_layout.dart';

class PomacChatApp extends StatefulWidget {
  const PomacChatApp({
    super.key,
    required this.token,
    required this.baseUrl,
    required this.socketUrl,
    required this.currentUserId,
    this.currentUserName,
    this.currentUserAvatar,
    this.roomId,
    this.onError,
    this.theme,
  });

  final String token;
  final String baseUrl;
  final String socketUrl;
  final String currentUserId;
  final String? currentUserName;
  final String? currentUserAvatar;
  final String? roomId;
  final void Function(Object error)? onError;
  final PomacChatTheme? theme;

  @override
  State<PomacChatApp> createState() => _PomacChatAppState();
}

class _PomacChatAppState extends State<PomacChatApp> {
  late ChatService _chatService;
  late ProviderContainer _container;

  @override
  void initState() {
    super.initState();
    _chatService = _buildService();
    _container = _buildContainer();
    _chatService.initialize();

    print("Current User Avatar ${widget.currentUserAvatar}");
  }

  @override
  void didUpdateWidget(PomacChatApp old) {
    super.didUpdateWidget(old);
    final credentialsChanged = widget.token != old.token ||
        widget.baseUrl != old.baseUrl ||
        widget.socketUrl != old.socketUrl;

    if (credentialsChanged) {
      _chatService.dispose();
      _container.dispose();
      _chatService = _buildService();
      _container = _buildContainer();
      _chatService.initialize();
    } else if (widget.currentUserId != old.currentUserId ||
        widget.currentUserName != old.currentUserName ||
        widget.currentUserAvatar != old.currentUserAvatar ||
        widget.roomId != old.roomId) {
      // Only user identity fields changed — update overrides in place
      // without reconnecting.
      _container.updateOverrides([
        chatServiceProvider.overrideWithValue(_chatService),
        currentUserIdProvider.overrideWithValue(widget.currentUserId),
        currentUserNameProvider.overrideWithValue(widget.currentUserName),
        currentUserAvatarProvider.overrideWithValue(widget.currentUserAvatar),
        currentRoomIdProvider.overrideWithValue(widget.roomId),
      ]);
    }
  }

  @override
  void dispose() {
    _chatService.dispose();
    _container.dispose();
    super.dispose();
  }

  ChatService _buildService() => ChatService(
        baseUrl: widget.baseUrl,
        socketUrl: widget.socketUrl,
        token: widget.token,
      );

  ProviderContainer _buildContainer() => ProviderContainer(
        overrides: [
          chatServiceProvider.overrideWithValue(_chatService),
          currentUserIdProvider.overrideWithValue(widget.currentUserId),
          currentUserNameProvider.overrideWithValue(widget.currentUserName),
          currentUserAvatarProvider.overrideWithValue(widget.currentUserAvatar),
          currentRoomIdProvider.overrideWithValue(widget.roomId),
        ],
      );

  @override
  Widget build(BuildContext context) {
    // UncontrolledProviderScope exposes the manually-managed container to the
    // subtree without creating a new parent-linked container. This fully
    // isolates the package's Riverpod state from any ProviderScope the host
    // app may have, eliminating the "must be overridden" UnimplementedError.
    return UncontrolledProviderScope(
      container: _container,
      child: PomacChatThemeProvider(
        theme: widget.theme ?? const PomacChatTheme(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white
          ),
          child: LayoutBuilder(
          builder: (ctx, constraints) {
            final isWide = kIsWeb && constraints.maxWidth >= 900;
            return isWide
                ? const WebChatLayout()
                : const MobileChatLayout();
          },
        ),),
      ),
    );
  }
}