class ChatError {
  const ChatError({
    required this.message,
    this.statusCode,
    this.originalException,
  });

  final String message;
  final int? statusCode;
  final Object? originalException;

  @override
  String toString() => 'ChatError($statusCode): $message';
}
