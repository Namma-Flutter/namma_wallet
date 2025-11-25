import 'package:namma_wallet/src/features/tnstc/application/ticket_parser_interface.dart';

/// Base class for travel ticket SMS parsers.
///
/// Provides common utility methods for extracting and parsing data
/// from SMS text. Subclasses should implement [ITicketParser.parseTicket]
/// with provider-specific logic.
abstract class TravelSMSParser implements ITicketParser {
  /// Extracts text matching a regex pattern from input.
  ///
  /// Returns the matched group (default: group 1) or empty string if no match.
  /// This is a common utility for parsing structured text data.
  String extractMatch(String pattern, String input, {int groupIndex = 1}) {
    final regex = RegExp(pattern, multiLine: true);
    final match = regex.firstMatch(input);
    if (match != null && groupIndex <= match.groupCount) {
      return match.group(groupIndex)?.trim() ?? '';
    }
    return '';
  }

  /// Parses a date string in DD/MM/YYYY format.
  ///
  /// Returns the parsed [DateTime] or [DateTime.now()] as fallback on error.
  /// SMS dates are typically in DD/MM/YYYY format.
  DateTime parseDate(String date) {
    if (date.isEmpty) return DateTime.now();
    final parts = date.split('/');
    if (parts.length != 3) return DateTime.now();
    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } on FormatException {
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
