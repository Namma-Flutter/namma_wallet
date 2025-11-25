import 'package:namma_wallet/src/features/tnstc/application/ticket_parser_interface.dart';
import 'package:namma_wallet/src/features/travel/application/travel_text_parser_utils.dart';

/// Base class for travel ticket SMS parsers.
///
/// Provides common utility methods for extracting and parsing data
/// from SMS text. Subclasses should implement [ITicketParser.parseTicket]
/// with provider-specific logic.
abstract class TravelSMSParser implements ITicketParser {
  /// Extracts text matching a regex pattern from input.
  ///
  /// Returns the matched group (default: group 1) or empty string if no match.
  /// Uses shared utility for consistency across all parsers.
  String extractMatch(String pattern, String input, {int groupIndex = 1}) {
    return TravelTextParserUtils.extractMatch(
      pattern,
      input,
      groupIndex: groupIndex,
    );
  }

  /// Parses a date string in DD/MM/YYYY format.
  ///
  /// Returns the parsed [DateTime] or null if parsing fails.
  /// SMS dates are typically in DD/MM/YYYY format.
  /// Uses shared utility for consistency across all parsers.
  DateTime? parseDate(String date) {
    if (date.isEmpty) return null;
    final parts = date.split('/');
    if (parts.length != 3) return null;
    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } on FormatException {
      return null;
    }
  }

  /// Safely parses an integer from a string.
  ///
  /// Returns the parsed integer or [defaultValue] if parsing fails.
  /// Uses shared utility for consistency across all parsers.
  int parseInt(String value, {int defaultValue = 0}) {
    return TravelTextParserUtils.parseInt(value, defaultValue: defaultValue);
  }

  /// Safely parses a double from a string.
  ///
  /// Returns the parsed double or [defaultValue] if parsing fails.
  /// Uses shared utility for consistency across all parsers.
  double parseDouble(String value, {double defaultValue = 0.0}) {
    return TravelTextParserUtils.parseDouble(value, defaultValue: defaultValue);
  }
}
