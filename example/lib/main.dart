import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomac_chat_app/pomac_chat_app.dart';

void main() {
  var token = Uri.base.queryParameters["token"];
  var userId = Uri.base.queryParameters["userId"];
  runApp(
     ProviderScope(
      child: ExampleApp(
        token: token??'',
        currentUserId: userId??'',
      ),
    ),
  );
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({
    super.key,
    required this.token,
    required this.currentUserId,
    this.baseUrl = 'https://dev-backend-shuwier-chat.pomac.info',
    this.socketUrl = 'https://dev-backend-shuwier-chat.pomac.info:443',
  });

  final String token;
  final String currentUserId;
  final String baseUrl;
  final String socketUrl;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomac Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4535C1),
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: PomacChatApp(
            token: token,
            baseUrl: baseUrl,
            socketUrl: socketUrl,
            currentUserId: currentUserId,
            onError: (error) {
              debugPrint('Chat error: $error');
            },
          ),
        ),
      ),
    );
  }
}