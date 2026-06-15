import 'package:flutter/material.dart';
import '../../theme/chat_theme.dart';

class CommunicationTipsPanel extends StatelessWidget {
  const CommunicationTipsPanel({super.key});

  static const _tips = [
    'Do not communicate with other users outside the platform.',
    'Do not share your account information with any user under any circumstances.',
    'Sharing details about your device or personal website is your own responsibility.',
    'Messages are intended only for inquiries about the service, not for completing the work.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = PomacChatTheme.of(context);

    return SizedBox(
      width: 333,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.backgroundCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    color: theme.tipsGreen, size: 24),
                const SizedBox(width: 4),
                Text(
                  'Communication Tips',
                  style: TextStyle(
                    fontFamily: theme.fontFamily,
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    height: 1.4,
                    color: theme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '✓  $tip',
                  style: TextStyle(
                    fontFamily: theme.fontFamily,
                    fontSize: 16,
                    height: 1.5,
                    color: theme.tipsGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}