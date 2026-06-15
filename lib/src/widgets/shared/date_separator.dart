import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/chat_theme.dart';

class DateSeparator extends StatelessWidget {
  const DateSeparator({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = PomacChatTheme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);

    String label;
    if (d == today) {
      label = 'Today';
    } else if (d == today.subtract(const Duration(days: 1))) {
      label = 'Yesterday';
    } else {
      label = DateFormat('d MMMM yyyy').format(date);
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding:
            const EdgeInsets.symmetric(horizontal: 8.45, vertical: 2.82),
        decoration: BoxDecoration(
          color: const Color(0xFF8E8E8E),
          borderRadius: BorderRadius.circular(8.45),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: theme.fontFamily,
            fontSize: 12,
            height: 16 / 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}