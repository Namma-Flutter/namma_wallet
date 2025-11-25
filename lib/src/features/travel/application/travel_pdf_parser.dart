import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/ticket_parser_interface.dart';

/// Base class for travel ticket PDF parsers.
///
/// Provides common utility methods for extracting and parsing data
/// from PDF text. Subclasses should implement [ITicketParser.parseTicket]
/// with provider-specific logic.
abstract class TravelPDFParser implements ITicketParser {
  TravelPDFParser({required ILogger logger}) : _logger = logger;

  final ILogger _logger;

  /// Logger instance for subclasses
  ILogger get logger => _logger;

  /// Extracts text matching a regex pattern from input.
  ///
  /// Returns the matched group (default: group 1) or empty string if no match.
  /// This is a common utility for parsing structured text data.
  String extractMatch(String pattern, String input, {int groupIndex = 1}) {
    final regex = RegExp(pattern, multiLine: true);
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
  /// Returns the parsed [DateTime] or [DateTime.now()] as fallback on error.
  /// Logs warnings for invalid date formats.
  DateTime parseDate(String date) {
    if (date.isEmpty) return DateTime.now();

    // Handle both '-' and '/' separators
    final parts = date.contains('/') ? date.split('/') : date.split('-');
    if (parts.length != 3) {
      _logger.warning(
        'Invalid date format encountered in PDF: $date',
      );
      return DateTime.now();
    }

    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } on FormatException catch (e) {
      _logger.warning('Failed to parse date in PDF: $e');
      return DateTime.now();
    }
  }

  /// Parses a datetime string in "DD/MM/YYYY HH:mm" or "DD-MM-YYYY HH:mm Hrs." format.
  ///
  /// Returns the parsed [DateTime] or [DateTime.now()] as fallback on error.
  /// Logs warnings for invalid datetime formats.
  DateTime parseDateTime(String dateTime) {
    if (dateTime.isEmpty) return DateTime.now();

    final parts = dateTime.split(' '); // Split into date and time
    if (parts.length < 2) {
      _logger.warning('Invalid datetime format encountered in PDF: $dateTime');
      return DateTime.now();
    }

    try {
      // Handle both '-' and '/' separators for date
      final dateParts = parts[0].contains('/')
          ? parts[0].split('/')
          : parts[0].split('-');
      if (dateParts.length != 3) {
        _logger.warning('Invalid date part in datetime: $dateTime');
        return DateTime.now();
      }

      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      // Extract time part (might have "Hrs." suffix)
      final timePart = parts[1].replaceAll(RegExp(r'\s*Hrs\.?'), '');
      final timeParts = timePart.split(':'); // Split the time by ':'
      if (timeParts.length != 2) {
        _logger.warning('Invalid time part in datetime: $dateTime');
        return DateTime.now();
      }

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return DateTime(year, month, day, hour, minute);
    } on FormatException catch (e) {
      _logger.warning('Failed to parse datetime in PDF: $e');
      return DateTime.now();
    }
  }

  /// Safely parses an integer from a string.
  ///
  /// Returns the parsed integer or [defaultValue] if parsing fails.
  int parseInt(String value, {int defaultValue = 0}) {
    if (value.isEmpty) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Safely parses a double from a string.
  ///
  /// Returns the parsed double or [defaultValue] if parsing fails.
  double parseDouble(String value, {double defaultValue = 0.0}) {
    if (value.isEmpty) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }
}
