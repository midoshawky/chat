import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomac_chat_app/pomac_chat_app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ExampleApp(
        token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2Rldi1iYWNrZW5kLXNodXdpZXIucG9tYWMuaW5mby9hcGkvYXV0aC9sb2dpbiIsImlhdCI6MTc4MTUxNzA0MiwiZXhwIjoxNzgxNTQ5NDQyLCJuYmYiOjE3ODE1MTcwNDIsImp0aSI6Ikw2REgxWHJyNXR1bzYyODkiLCJzdWIiOiIxOTIiLCJwcnYiOiIyM2JkNWM4OTQ5ZjYwMGFkYjM5ZTcwMWM0MDA4NzJkYjdhNTk3NmY3IiwiaWQiOjE5MiwidXNlcm5hbWUiOiJuZXdfdGVzdDEyNTgiLCJ0b2tlbl92ZXJzaW9uIjoxLCJ0eXBlIjoiZnJlZWxhbmNlciIsIm5hbWUiOiJBaG1lZCIsImF2YXRhciI6Imh0dHBzOi8vZGV2LWJhY2tlbmQtc2h1d2llci5wb21hYy5pbmZvL3N0b3JhZ2UvcHJvZmlsZXMvNjliN2UwY2Q1ZDQ1Mi5qcGcifQ.Rai_IxJw2qrKhfT_Cr3t9hT1Ung4UZd-uvK7HBueB-s',
        currentUserId: '192',
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