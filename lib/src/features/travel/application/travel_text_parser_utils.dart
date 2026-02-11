import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';

/// Shared utility class for parsing text patterns from travel tickets.
///
/// Provides common methods for extracting data from structured text formats
/// used by various travel providers (SMS, PDF, etc.).
class TravelTextParserUtils {
  /// Extracts text matching a regex pattern from input.
  ///
  /// Returns the matched group (default: group 1) or empty string if no match.
  /// This is a common utility for parsing structured text data.
  static String extractMatch(
    String pattern,
    String? input, {
    int groupIndex = 1,
  }) {
    if (input == null || input.isEmpty) return '';
    final regex = RegExp(pattern, multiLine: true, caseSensitive: false);
    final match = regex.firstMatch(input);

    if (match != null && groupIndex <= match.groupCount) {
      // Safely extract the matched group, or return empty string if null
      return match.group(groupIndex)?.trim() ?? '';
    }
    // Return empty string if the match or group is invalid
    return '';
  }

  /// Parses a date string in DD/MM/YYYY or DD-MM-YYYY format.
  ///
  /// Returns the parsed [DateTime] or null if parsing fails.
  /// Logs warnings for invalid date formats.
  static DateTime? parseDate(String? date, {required ILogger logger}) {
    if (date == null || date.isEmpty) {
      if (date != null) logger.warning('Empty date string provided');
      return null;
    }

    // Handle both '-' and '/' separators
    final parts = date.contains('/') ? date.split('/') : date.split('-');
    if (parts.length != 3) {
      logger.warning(
        'Invalid date format encountered: $date',
      );
      return null;
    }

    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Validate that this is DD/MM/YYYY format, not YYYY-MM-DD
      // Day should be <= 31, month should be <= 12
      // Year should be >= 1000 (4 digits)
      if (day > 31 || day < 1) {
        logger.warning('Invalid day value in date: $date');
        return null;
      }
      if (month > 12 || month < 1) {
        logger.warning('Invalid month value in date: $date');
        return null;
      }
      if (year < 1000 || year > 9999) {
        logger.warning('Invalid year value in date: $date');
        return null;
      }

      return DateTime.utc(year, month, day);
    } on FormatException catch (e) {
      logger.warning('Failed to parse date: $e');
      return null;
    }
  }

  /// Parses a datetime string in "DD/MM/YYYY HH:mm" or "DD-MM-YYYY HH:mm Hrs." format.
  ///
  /// Returns the parsed [DateTime] or null if parsing fails.
  /// Logs warnings for invalid datetime formats.
  static DateTime? parseDateTime(String? dateTime, {required ILogger logger}) {
    if (dateTime == null || dateTime.isEmpty) {
      if (dateTime != null) logger.warning('Empty datetime string provided');
      return null;
    }

    final parts = dateTime.split(' '); // Split into date and time
    if (parts.length < 2) {
      logger.warning('Invalid datetime format encountered: $dateTime');
      return null;
    }

    try {
      // Handle both '-' and '/' separators for date
      final dateParts = parts[0].contains('/')
          ? parts[0].split('/')
          : parts[0].split('-');
      if (dateParts.length != 3) {
        logger.warning('Invalid date part in datetime: $dateTime');
        return null;
      }

      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      // Extract time part (might have "Hrs." suffix)
      final timePart = parts[1].replaceAll(RegExp(r'\s*Hrs\.?'), '');
      final timeParts = timePart.split(':'); // Split the time by ':'
      if (timeParts.length != 2) {
        logger.warning('Invalid time part in datetime: $dateTime');
        return null;
      }

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return DateTime(year, month, day, hour, minute);
    } on FormatException catch (e) {
      logger.warning('Failed to parse datetime: $e');
      return null;
    }
  }

  /// Safely parses an integer from a string.
  ///
  /// Returns the parsed integer or [defaultValue] if parsing fails.
  static int parseInt(String? value, {int defaultValue = 0}) {
    if (value == null || value.isEmpty) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Safely parses a double from a string.
  ///
  /// Returns the parsed double or [defaultValue] if parsing fails.
  static double parseDouble(String? value, {double defaultValue = 0.0}) {
    if (value == null || value.isEmpty) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }
}
