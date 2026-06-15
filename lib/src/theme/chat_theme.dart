import 'package:flutter/material.dart';

class PomacChatTheme {
  const PomacChatTheme({
    this.primary = const Color(0xFF4535C1),
    this.sentBubble = const Color(0xFFDAD7F3),
    this.receivedBubble = const Color(0xFFF5F5F5),
    this.onlineIndicator = const Color(0xFF008C1E),
    this.tipsGreen = const Color(0xFF47B881),
    this.strokeBorder = const Color(0xFFDEDEDE),
    this.mutedText = const Color(0xFF787878),
    this.activeBg = const Color(0xFFEEEEEE),
    this.backgroundCard = const Color(0xFFFAFAFA),
    this.textPrimary = const Color(0xFF1F1F1F),
    this.textDark = const Color(0xFF333333),
    this.richBlack = const Color(0xFF011627),
    this.fontFamily = 'ProductSans',
  });

  final Color primary;
  final Color sentBubble;
  final Color receivedBubble;
  final Color onlineIndicator;
  final Color tipsGreen;
  final Color strokeBorder;
  final Color mutedText;
  final Color activeBg;
  final Color backgroundCard;
  final Color textPrimary;
  final Color textDark;
  final Color richBlack;
  final String fontFamily;

  TextStyle get nameStyle => TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1.5,
        color: textDark,
      );

  TextStyle get timestampStyle => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 20 / 14,
        color: mutedText,
      );

  TextStyle get previewStyle => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 20 / 14,
        color: textPrimary,
      );

  TextStyle get bubbleTextStyle => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        height: 1.5,
        color: richBlack,
      );

  TextStyle get bubbleTimestampStyle => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 16 / 12,
        color: richBlack,
      );

  TextStyle get headerNameStyle => TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1.5,
        color: textPrimary,
      );

  static PomacChatTheme of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_ChatThemeInherited>();
    return provider?.theme ?? const PomacChatTheme();
  }
}

class PomacChatThemeProvider extends StatelessWidget {
  const PomacChatThemeProvider({
    super.key,
    required this.theme,
    required this.child,
  });

  final PomacChatTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      _ChatThemeInherited(theme: theme, child: child);
}

class _ChatThemeInherited extends InheritedWidget {
  const _ChatThemeInherited({
    required this.theme,
    required super.child,
  });

  final PomacChatTheme theme;

  @override
  bool updateShouldNotify(_ChatThemeInherited old) => theme != old.theme;
}