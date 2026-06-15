# pomac_chat_app

A reusable Flutter chat package that works on **web and mobile** out of the box.  
Drop it into any Flutter app, pass a JWT token, and you get a fully functional real-time chat backed by Socket.IO and a REST API.

---

## Features

- **Responsive layout** — 3-column desktop UI on web (≥ 900 px), stacked mobile UI on narrower screens and native platforms
- **Real-time messaging** via Socket.IO (`message:created`, `message:updated`, `message:deleted`)
- **Typing indicators** with animated dots
- **Read receipts & delivery status** handled automatically
- **Paginated message history** — loads older messages as you scroll up
- **Live room search** — debounced API call as you type
- **Message edit & delete** over the socket
- **Token-based auth** — pass your JWT once; the package attaches it to every HTTP request and the socket handshake
- **Themeable** — override any colour or font through `PomacChatTheme`
- **Self-contained** — brings its own `ProviderScope`; no Riverpod setup required in the host app

---

## Installation

Add the package to your app's `pubspec.yaml`:

```yaml
dependencies:
  pomac_chat_app:
    git:
      url: https://github.com/your-org/pomac-chat-app.git
      path: pomac_chat_app
```

Or as a local path dependency during development:

```yaml
dependencies:
  pomac_chat_app:
    path: ../pomac_chat_app
```

Then run:

```bash
flutter pub get
```

> **Font note** — the package bundles the **Product Sans** typeface.  
> Place `ProductSans-Regular.ttf` and `ProductSans-Medium.ttf` inside the `fonts/` directory at the package root (not inside `lib/`). The `pubspec.yaml` already declares them; they will be picked up automatically when you consume the package.

---

## Quick start

```dart
import 'package:pomac_chat_app/pomac_chat_app.dart';

// Inside any widget build() or page:
PomacChatApp(
  token: 'your_jwt_token',
  baseUrl: 'https://api.example.com',
  socketUrl: 'https://socket.example.com',
  currentUserId: '196',          // ID of the logged-in user
)
```

That is the entire integration. `PomacChatApp` is a regular `Widget` — place it wherever you want the chat to appear.

---

## API reference

### `PomacChatApp`

| Parameter | Type | Required | Description |
|---|---|---|---|
| `token` | `String` | ✅ | Bearer JWT attached to every HTTP request and the socket handshake |
| `baseUrl` | `String` | ✅ | Base URL of the REST API (e.g. `https://api.example.com`) |
| `socketUrl` | `String` | ✅ | URL of the Socket.IO server |
| `currentUserId` | `String` | ✅ | ID of the authenticated user — used to align sent/received bubbles |
| `onError` | `void Function(Object)?` | | Called on HTTP or socket errors |
| `theme` | `PomacChatTheme?` | | Override design tokens (see below) |

When `token`, `baseUrl`, or `socketUrl` changes, the widget automatically reconnects with the new credentials — no rebuild required.

---

### `PomacChatTheme`

All parameters are optional; every one has a Figma-matched default.

```dart
PomacChatApp(
  // ...
  theme: PomacChatTheme(
    primary:          Color(0xFF4535C1), // active borders, send button, nav highlight
    sentBubble:       Color(0xFFDAD7F3), // your outgoing message bubble
    receivedBubble:   Color(0xFFF5F5F5), // incoming message bubble
    onlineIndicator:  Color(0xFF008C1E), // green online dot
    tipsGreen:        Color(0xFF47B881), // communication tips text
    strokeBorder:     Color(0xFFDEDEDE), // panel borders
    mutedText:        Color(0xFF787878), // timestamps, placeholders
    activeBg:         Color(0xFFEEEEEE), // selected room row background
    backgroundCard:   Color(0xFFFAFAFA), // card / tips panel background
    fontFamily:       'ProductSans',     // must match the bundled font family name
  ),
)
```

---

## Backend contract

The package is wired against the following API. Your backend must implement these endpoints and socket events.

### REST

All requests carry `Authorization: Bearer <token>`.

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/rooms?page=1&per_page=20&search=<q>` | List / search rooms |
| `POST` | `/rooms` | Create a room |
| `GET` | `/rooms/:roomId/messages?page=1&per_page=30` | Paginated messages |
| `POST` | `/rooms/:roomId/messages` | Send a message |
| `PATCH` | `/rooms/:roomId/messages/:id` | Edit a message |
| `DELETE` | `/rooms/:roomId/messages/:id` | Delete a message |
| `POST` | `/files/upload` | Upload attachments (`multipart/form-data`, `category=message`) |

### Socket.IO — client → server

Auth via handshake: `{ auth: { token } }`

| Event | Payload |
|---|---|
| `room:join` | `{ roomId }` |
| `message:send` | `{ roomId, type, content, replyTo?, attachments? }` |
| `message:read` | `{ roomId }` |
| `typing` | `{ roomId, isTyping }` |
| `message:update` | `{ messageId, roomId, content }` |
| `message:delete` | `{ messageId, roomId }` |

### Socket.IO — server → client

| Event | Payload |
|---|---|
| `room:joined` | `{ roomId }` |
| `message:created` | `MessageResponseDto` |
| `message:updated` | `MessageResponseDto` |
| `message:deleted` | `{ messageId, roomId, deletedAt }` |
| `message:delivered` | `{ messageId, roomId, userId }` |
| `message:read` | `{ roomId, userId }` |
| `typing` | `{ roomId, user: { userId, name, avatar }, isTyping }` |

---

## Running the example

```bash
cd example
flutter pub get

# Web (shows 3-column layout at full width)
flutter run -d chrome

# iOS simulator
flutter run -d iPhone

# Android emulator
flutter run -d emulator-5554
```

The example opens a config screen where you enter your JWT, API URL, socket URL, and user ID. Press **Open Chat** to launch the package.

---

## Project structure

```
lib/
  pomac_chat_app.dart          ← single import for consumers
  src/
    models/                    ← Room, Message, TypingEvent, …
    theme/chat_theme.dart      ← PomacChatTheme + InheritedWidget
    services/
      http_service.dart        ← Dio client with bearer-token interceptor
      socket_service.dart      ← Socket.IO wrapper with typed streams
      chat_service.dart        ← orchestrates HTTP + socket
    state/
      providers.dart           ← chatServiceProvider, currentUserIdProvider
      room_notifier.dart       ← room list, search, active selection
      chat_notifier.dart       ← messages, typing, pagination
    widgets/
      shared/                  ← UserAvatar, MessageBubble, ChatInputBar, …
      web/                     ← 3-column layout (RoomListPanel, ChatWindowPanel, …)
      mobile/                  ← stacked Navigator (list screen + chat screen)
    pomac_chat_widget.dart     ← PomacChatApp entry point
example/
  lib/main.dart                ← runnable demo with config screen
fonts/
  ProductSans-Regular.ttf
  ProductSans-Medium.ttf
```

---

## State management

The package uses [Riverpod](https://riverpod.dev/) internally. It creates its own `ProviderScope` via `overrides`, so **no Riverpod setup is needed** in the host app. If your app already uses Riverpod, the package's inner scope is completely isolated.

---

## Requirements

| | Minimum |
|---|---|
| Dart SDK | 3.4.0 |
| Flutter | 3.19.0 |
| iOS | 12.0 |
| Android | API 21 |

---

## License

MIT — see [LICENSE](LICENSE).
# chat
