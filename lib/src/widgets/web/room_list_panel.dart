import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/room_notifier.dart';
import '../../state/providers.dart';
import '../../theme/chat_theme.dart';
import '../shared/room_item.dart';

class RoomListPanel extends ConsumerStatefulWidget {
  const RoomListPanel({super.key});

  @override
  ConsumerState<RoomListPanel> createState() => _RoomListPanelState();
}

class _RoomListPanelState extends ConsumerState<RoomListPanel> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = PomacChatTheme.of(context);
    final currentUserId = ref.watch(currentUserIdProvider);
    final roomState = ref.watch(roomNotifierProvider);

    return SizedBox(
      width: 398,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.strokeBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _SearchBar(
              controller: _searchController,
              theme: theme,
              onChanged: (q) => ref.read(roomNotifierProvider.notifier).search(q),
              onClear: () {
                _searchController.clear();
                ref.read(roomNotifierProvider.notifier).clearSearch();
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: roomState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (state) {
                  if (state.rooms.isEmpty) {
                    return Center(
                      child: Text(
                        'No conversations',
                        style: TextStyle(
                            fontFamily: theme.fontFamily,
                            color: theme.mutedText),
                      ),
                    );
                  }
                  return MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thickness: WidgetStateProperty.all(6),
                          thumbColor: WidgetStateProperty.all(
                              const Color(0xFF3C3C3C)),
                          trackColor: WidgetStateProperty.all(
                              theme.strokeBorder),
                          radius: const Radius.circular(16),
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: state.rooms.length,
                          itemBuilder: (ctx, i) {
                            final room = state.rooms[i];
                            return RoomItem(
                              room: room,
                              currentUserId: currentUserId,
                              isActive: state.activeRoomId == room.id,
                              onTap: () => ref
                                  .read(roomNotifierProvider.notifier)
                                  .selectRoom(room.id),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.theme,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final PomacChatTheme theme;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE1E1E1)),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.search, color: theme.mutedText, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(
                  fontFamily: theme.fontFamily,
                  fontSize: 14,
                  color: theme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    fontFamily: theme.fontFamily,
                    fontSize: 14,
                    color: theme.mutedText,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: onChanged,
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, color: theme.mutedText, size: 18),
              ),
          ],
        ),
      );
}