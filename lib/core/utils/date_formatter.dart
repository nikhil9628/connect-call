import 'package:intl/intl.dart';

class DateFormatter {
  /// Converts DateTime to user-friendly human string e.g. "Today, 11:45 AM", "Yesterday, 6:20 PM"
  static String formatCallTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final callDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    final timeStr = DateFormat('h:mm a').format(timestamp);

    if (callDate == today) {
      return 'Today, $timeStr';
    } else if (callDate == yesterday) {
      return 'Yesterday, $timeStr';
    } else if (now.difference(timestamp).inDays < 7) {
      final dayName = DateFormat('EEEE').format(timestamp);
      return '$dayName, $timeStr';
    } else {
      final dateStr = DateFormat('MMM d, yyyy').format(timestamp);
      return '$dateStr, $timeStr';
    }
  }
}
