import 'package:intl/intl.dart';

/// Formats a DateTime as time string (e.g., "01:15 pm").
/// Converts to local time before formatting to handle
/// UTC datetimes from database.
String formatTime(DateTime dt) {
  final local = dt.toLocal();
  return DateFormat('hh:mm a').format(local).toLowerCase();
}

/// Formats a DateTime as date string (e.g., "18/01/2026").
/// Converts to local time before formatting to handle
/// UTC datetimes from database.
String formatDate(DateTime dt) {
  final local = dt.toLocal();
  return DateFormat('dd/MM/yyyy').format(local);
}

/// Formats a DateTime as full date-time string
/// (e.g., "18-01-2026 01:15 PM").
/// Converts to local time before formatting to handle
/// UTC datetimes from database.
String formatFullDateTime(DateTime dt) {
  final local = dt.toLocal();
  return DateFormat('dd-MM-yyyy hh:mm a').format(local);
}

/// Formats a time string from 24-hour format to 12-hour format with AM/PM.
/// Input format: "HH:mm" (e.g., "13:15")
/// Output format: "hh:mm AM/PM" (e.g., "01:15 PM")
/// Returns the original string if parsing fails.
String formatTimeString(String timeStr) {
  if (timeStr.isEmpty) return timeStr;

  try {
    final parts = timeStr.split(':');
    if (parts.length != 2) return timeStr;

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Validate hour and minute ranges
    if (hour < 0 || hour >= 24 || minute < 0 || minute >= 60) {
      return timeStr;
    }

    // Create a DateTime object to use DateFormat
    final dt = DateTime(2000, 1, 1, hour, minute);
    return DateFormat('hh:mm a').format(dt);
  } on FormatException {
    return timeStr;
  }
}
