import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/chat_error.dart';
import '../models/room.dart';
import '../models/message.dart';
import '../models/message_deleted.dart';
import '../models/paginated_result.dart';


class HttpService {
  HttpService({required String baseUrl, required String token}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    _dio.interceptors.add(_BearerTokenInterceptor(token));
    _dio.interceptors.add(_ErrorInterceptor());
    _dio.interceptors.add(PrettyDioLogger());
  }

  late final Dio _dio;

  void updateToken(String token) {
    _dio.interceptors.removeWhere((i) => i is _BearerTokenInterceptor);
    _dio.interceptors.add(_BearerTokenInterceptor(token));
    _dio.interceptors.add(PrettyDioLogger());
  }

  Future<PaginatedResult<Room>> fetchRooms({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final res = await _dio.get('/rooms', queryParameters: params);
    return PaginatedResult.fromJson(
      res.data as Map<String, dynamic>,
      Room.fromJson,
    );
  }

  Future<PaginatedResult<Message>> fetchMessages(
    String roomId, {
    int page = 1,
    int perPage = 30,
  }) async {
    final res = await _dio.get(
      '/rooms/$roomId/messages',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return PaginatedResult.fromJson(
      res.data as Map<String, dynamic>,
      Message.fromJson,
    );
  }

  Future<Message> fetchMessage(String roomId, String messageId) async {
    final res = await _dio.get('/rooms/$roomId/messages/$messageId');
    return Message.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Message> sendMessage(
    String roomId, {
    required String content,
    String type = 'text',
    String? replyTo,
    List<Map<String, String>>? attachments,
  }) async {
    final res = await _dio.post(
      '/rooms/$roomId/messages',
      data: {
        'type': type,
        'content': content,
        if (replyTo != null) 'replyTo': replyTo,
        if (attachments != null) 'attachments': attachments,
      },
    );
    return Message.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Message> editMessage(
      String roomId, String messageId, String content) async {
    final res = await _dio.patch(
      '/rooms/$roomId/messages/$messageId',
      data: {'content': content},
    );
    return Message.fromJson(res.data as Map<String, dynamic>);
  }

  Future<MessageDeleted> deleteMessage(
      String roomId, String messageId) async {
    final res = await _dio.delete('/rooms/$roomId/messages/$messageId');
    return MessageDeleted.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> uploadFiles(
    List<String> filePaths,
  ) async {
    final formData = FormData();
    formData.fields.add(const MapEntry('category', 'message'));
    for (final path in filePaths) {
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(path),
      ));
    }
    final res = await _dio.post('/files/upload', data: formData);
    return (res.data as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}

class _BearerTokenInterceptor extends Interceptor {
  _BearerTokenInterceptor(this.token);
  final String token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final message = _extractMessage(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: ChatError(
          message: message,
          statusCode: statusCode,
          originalException: err,
        ),
        response: err.response,
        type: err.type,
      ),
    );
  }

  String _extractMessage(DioException err) {
    try {
      final data = err.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}
    return err.message ?? 'Unknown error';
  }
}