## 0.1.0

Initial release.

- Responsive chat UI — 3-column web layout (≥ 900 px) and mobile stacked layout
- Real-time messaging via Socket.IO (`message:created`, `message:updated`, `message:deleted`)
- Typing indicators with animated dots
- Read receipts and delivery status
- Paginated message history with scroll-to-load-more
- Live room search (debounced, calls REST API)
- Message edit and delete over the socket
- Token-based auth — JWT attached to every HTTP request and socket handshake
- Fully themeable via `PomacChatTheme`
- Self-contained Riverpod `ProviderScope` — no setup required in host app
- Bundled Product Sans font
- Runnable `example/` app with config screen
