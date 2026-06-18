import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';

final chatServiceProvider = Provider<ChatService>(
  (ref) => throw UnimplementedError(
      'chatServiceProvider must be overridden in ProviderScope'),
);

final currentUserIdProvider = Provider<String>(
  (ref) => throw UnimplementedError(
      'currentUserIdProvider must be overridden in ProviderScope'),
);

final currentUserNameProvider = Provider<String?>((ref) => null);

final currentUserAvatarProvider = Provider<String?>((ref) => null);