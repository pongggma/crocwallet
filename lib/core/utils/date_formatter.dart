import 'package:intl/intl.dart';

class DateFormatter {
  static String date(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  static String monthShort(DateTime d) => DateFormat('MMM').format(d);
  static String monthYear(DateTime d) => DateFormat('MMM yyyy').format(d);

  static int daysLeft(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(deadline.year, deadline.month, deadline.day);
    return end.difference(today).inDays;
  }

  static String deadlineText(DateTime? deadline) {
    if (deadline == null) return 'No deadline';
    final left = daysLeft(deadline);
    if (left < 0) return 'Overdue by ${-left} days';
    if (left == 0) return 'Due today';
    return '$left days left';
  }
}
