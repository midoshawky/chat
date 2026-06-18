import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jovial_svg/jovial_svg.dart';
import '../../state/room_notifier.dart';
import '../../state/providers.dart';
import '../../theme/chat_theme.dart';
import '../shared/room_item.dart';
import '../shared/user_avatar.dart';

class MobileRoomListScreen extends ConsumerStatefulWidget {
  const MobileRoomListScreen({super.key, required this.onRoomTap});

  final void Function(String roomId) onRoomTap;

  @override
  ConsumerState<MobileRoomListScreen> createState() =>
      _MobileRoomListScreenState();
}

class _MobileRoomListScreenState
    extends ConsumerState<MobileRoomListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = PomacChatTheme.of(context);
    final currentUserId = ref.watch(currentUserIdProvider);
    final currentUserName = ref.watch(currentUserNameProvider);
    final currentUserAvatar = ref.watch(currentUserAvatarProvider);
    final roomState = ref.watch(roomNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: UserAvatar(
            name: currentUserName ?? currentUserId,
            avatarUrl: currentUserAvatar,
            size: 40,
          ),
        ),
        title: Text(
          'Messages',
          style: TextStyle(
            fontFamily: theme.fontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: theme.textPrimary,
          ),
        ),
        actions: [
          _IconCircleButton(
            icon: Icons.search,
            theme: theme,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _IconCircleButton(
            icon: Icons.notifications_none_outlined,
            theme: theme,
            onTap: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: roomState.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (state) {
                if (state.rooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                  width: 120,
                  height: 120,
                  child: ScalableImageWidget.fromSISource(
                    si: ScalableImageSource.fromSvg(
                      rootBundle,
                      'packages/pomac_chat_app/assets/icons/no_conversations.svg',
                    ),
                    currentColor: theme.textDark,
                  ),
                ),
                SizedBox(height: 12,),
                        Text(
                      'No conversations yet',
                      style: TextStyle(
                          fontFamily: theme.fontFamily,
                          color: theme.mutedText),
                    )
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: state.rooms.length,
                  itemBuilder: (ctx, i) {
                    final room = state.rooms[i];
                    return RoomItem(
                      room: room,
                      currentUserId: currentUserId,
                      isMobile: true,
                      onTap: () {
                        print("ROOM TAPPED ${room.id}");
                        ref
                            .read(roomNotifierProvider.notifier)
                            .selectRoom(room.id);
                        widget.onRoomTap(room.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    required this.icon,
    required this.theme,
    required this.onTap,
  });

  final IconData icon;
  final PomacChatTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: theme.textPrimary),
        ),
      );
}