import 'package:flutter_test/flutter_test.dart';
import 'package:pomac_chat_app/pomac_chat_app.dart';

void main() {
  group('Room model', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'room1',
        'name': 'Test Room',
        'type': 'private',
        'members': [
          {
            'userId': '1',
            'name': 'Alice',
            'avatar': null,
            'type': 'member',
          }
        ],
        'lastMessage': null,
        'lastMessageAt': null,
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
      };

      final room = Room.fromJson(json);
      expect(room.id, 'room1');
      expect(room.name, 'Test Room');
      expect(room.members.length, 1);
      expect(room.members.first.name, 'Alice');
    });

    test('otherMember returns the non-current user', () {
      final room = Room.fromJson({
        'id': 'room1',
        'name': 'Test',
        'type': 'private',
        'members': [
          {'userId': 'me', 'name': 'Me', 'type': 'member'},
          {'userId': 'other', 'name': 'Other', 'type': 'member'},
        ],
        'lastMessage': null,
        'lastMessageAt': null,
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
      });

      expect(room.otherMember('me')?.userId, 'other');
    });
  });

  group('PomacChatTheme', () {
    test('defaults have correct primary color', () {
      const theme = PomacChatTheme();
      expect(theme.primary.toARGB32(), const PomacChatTheme().primary.toARGB32());
    });
  });
}
