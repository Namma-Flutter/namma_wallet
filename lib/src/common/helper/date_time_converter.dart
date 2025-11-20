import 'package:intl/intl.dart';

/// Abstract interface for date and time formatting operations.
/// Provides methods to format DateTime objects and time strings
/// into user-friendly representations.
abstract class IDateTimeConverter {
  /// Formats a DateTime as time string (e.g., "01:15 pm").
  /// Converts to local time before formatting to handle
  /// UTC datetimes from database.
  String formatTime(DateTime dt);

  /// Formats a DateTime as date string (e.g., "18/01/2026").
  /// Converts to local time before formatting to handle
  /// UTC datetimes from database.
  String formatDate(DateTime dt);

  /// Formats a DateTime as full date-time string
  /// (e.g., "18-01-2026 01:15 PM").
  /// Converts to local time before formatting to handle
  /// UTC datetimes from database.
  String formatFullDateTime(DateTime dt);

  /// Formats a time string from 24-hour format to 12-hour format with AM/PM.
  /// Input format: "HH:mm" (e.g., "13:15")
  /// Output format: "hh:mm AM/PM" (e.g., "01:15 PM")
  /// Returns the original string if parsing fails.
  String formatTimeString(String timeStr);
}

/// Default implementation of [IDateTimeConverter].
/// Uses the intl package's DateFormat for formatting operations.
class DateTimeConverter implements IDateTimeConverter {
  /// Factory constructor to return singleton instance
  factory DateTimeConverter() => instance;

  DateTimeConverter._();

  /// Singleton instance for easy access
  static final DateTimeConverter instance = DateTimeConverter._();

  @override
  String formatTime(DateTime dt) {
    final local = dt.toLocal();
    return DateFormat('hh:mm a').format(local).toLowerCase();
  }

  @override
  String formatDate(DateTime dt) {
    final local = dt.toLocal();
    return DateFormat('dd/MM/yyyy').format(local);
  }

  @override
  String formatFullDateTime(DateTime dt) {
    final local = dt.toLocal();
    return DateFormat('dd-MM-yyyy hh:mm a').format(local);
  }

  @override
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
}

// Backward compatibility: Export top-level functions
// that delegate to the singleton instance

/// Formats a DateTime as time string (e.g., "01:15 pm").
/// Converts to local time before formatting to handle
/// UTC datetimes from database.
String formatTime(DateTime dt) => DateTimeConverter.instance.formatTime(dt);

/// Formats a DateTime as date string (e.g., "18/01/2026").
/// Converts to local time before formatting to handle
/// UTC datetimes from database.
String formatDate(DateTime dt) => DateTimeConverter.instance.formatDate(dt);

/// Formats a DateTime as full date-time string
/// (e.g., "18-01-2026 01:15 PM").
/// Converts to local time before formatting to handle
/// UTC datetimes from database.
String formatFullDateTime(DateTime dt) =>
    DateTimeConverter.instance.formatFullDateTime(dt);

/// Formats a time string from 24-hour format to 12-hour format with AM/PM.
/// Input format: "HH:mm" (e.g., "13:15")
/// Output format: "hh:mm AM/PM" (e.g., "01:15 PM")
/// Returns the original string if parsing fails.
String formatTimeString(String timeStr) =>
    DateTimeConverter.instance.formatTimeString(timeStr);
