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

/// @deprecated Use formatTime instead. This function name is misleading.
String getDate(DateTime dt) => formatTime(dt);

/// @deprecated Use formatDate instead. This function name is misleading.
String getTime(DateTime dt) => formatDate(dt);
