import 'http_service.dart';
import 'socket_service.dart';
import '../models/room.dart';
import '../models/message.dart';
import '../models/message_deleted.dart';
import '../models/typing_event.dart';
import '../models/paginated_result.dart';

export 'socket_service.dart' show MessageDelivered, MessageRead;

class ChatService {
  ChatService({
    required String baseUrl,
    required String socketUrl,
    required String token,
  })  : http = HttpService(baseUrl: baseUrl, token: token),
        socket = SocketService(socketUrl: socketUrl, token: token);

  final HttpService http;
  final SocketService socket;

  void initialize() => socket.connect();

  void dispose() => socket.dispose();

  // Rooms
  Future<PaginatedResult<Room>> getRooms({
    int page = 1,
    int perPage = 20,
    String? search,
  }) =>
      http.fetchRooms(page: page, perPage: perPage, search: search);

  // Messages
  Future<PaginatedResult<Message>> getMessages(
    String roomId, {
    int page = 1,
    int perPage = 30,
  }) =>
      http.fetchMessages(roomId, page: page, perPage: perPage);

  Future<MessageDeleted> deleteMessage(
          String roomId, String messageId) =>
      http.deleteMessage(roomId, messageId);

  // Socket stream pass-throughs
  Stream<Message> get onMessageCreated => socket.onMessageCreated;
  Stream<Message> get onMessageUpdated => socket.onMessageUpdated;
  Stream<MessageDeleted> get onMessageDeleted => socket.onMessageDeleted;
  Stream<MessageDelivered> get onMessageDelivered =>
      socket.onMessageDelivered;
  Stream<MessageRead> get onMessageRead => socket.onMessageRead;
  Stream<TypingEvent> get onTyping => socket.onTyping;
  Stream<String> get onRoomNewMessage => socket.onRoomNewMessage;

  Future<List<Map<String, dynamic>>> uploadFiles(
    List<({String filename, List<int> bytes})> files,
  ) =>
      http.uploadFiles(files);
}