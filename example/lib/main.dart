import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomac_chat_app/pomac_chat_app.dart';

void main() {
  String? token, userId, name, avatar, roomId;
  if (kIsWeb) {
    final params = Uri.base.queryParameters;
    token = params['token'];
    userId = params['user_id'];
    name = params['user_name'];
    avatar = params['avatar_url'];
    roomId = params['room_id'];
  }
  runApp(
     ProviderScope(
      child: ExampleApp(
        token: token??'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2Rldi1iYWNrZW5kLXNodXdpZXIucG9tYWMuaW5mby9hcGkvYXV0aC9sb2dpbiIsImlhdCI6MTc4MjI4NTUzNSwiZXhwIjoxNzgyMzE3OTM1LCJuYmYiOjE3ODIyODU1MzUsImp0aSI6IlJPUU5vUWNMYm1aSXprd00iLCJzdWIiOiIxOTIiLCJwcnYiOiIyM2JkNWM4OTQ5ZjYwMGFkYjM5ZTcwMWM0MDA4NzJkYjdhNTk3NmY3IiwiaWQiOjE5MiwidXNlcm5hbWUiOiJuZXdfdGVzdDEyNTgiLCJ0b2tlbl92ZXJzaW9uIjoxLCJ0eXBlIjoiZnJlZWxhbmNlciIsIm5hbWUiOiJBaG1lZCIsImF2YXRhciI6Imh0dHBzOi8vZGV2LWJhY2tlbmQtc2h1d2llci5wb21hYy5pbmZvL3N0b3JhZ2UvcHJvZmlsZXMvNjliN2UwY2Q1ZDQ1Mi5qcGcifQ.aDJ-zJy-hQmGStLPR5LEtRJv-_cqVt9F4eJyVLRJgYU',
        currentUserId: userId??'192',
        currentUserName: name,
        currentUserAvatar: avatar,
        roomId:roomId
      ),
    ),
  );
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({
    super.key,
    required this.token,
    required this.currentUserId,
    this.currentUserName,
    this.currentUserAvatar,
    this.roomId,
    this.baseUrl = 'https://dev-backend-shuwier-chat.pomac.info',
    this.socketUrl = 'https://dev-backend-shuwier-chat.pomac.info:443',
  });

  final String token;
  final String currentUserId;
  final String? currentUserName;
  final String? currentUserAvatar;
  final String? roomId;
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
            currentUserName: currentUserName,
            currentUserAvatar: currentUserAvatar,
            roomId: roomId,
            onError: (error) {
              debugPrint('Chat error: $error');
            },
          ),
        ),
      ),
    );
  }
}