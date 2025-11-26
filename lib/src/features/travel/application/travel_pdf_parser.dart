import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/tnstc/application/ticket_parser_interface.dart';
import 'package:namma_wallet/src/features/travel/application/travel_text_parser_utils.dart';

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
  /// Uses shared utility for consistency across all parsers.
  String extractMatch(String pattern, String input, {int groupIndex = 1}) {
    return TravelTextParserUtils.extractMatch(
      pattern,
      input,
      groupIndex: groupIndex,
    );
  }

  /// Parses a date string in DD/MM/YYYY or DD-MM-YYYY format.
  ///
  /// Returns the parsed [DateTime] or null if parsing fails.
  /// Uses shared utility for consistency across all parsers.
  DateTime? parseDate(String date) {
    return TravelTextParserUtils.parseDate(date, logger: logger);
  }

  /// Parses a datetime string in "DD/MM/YYYY HH:mm" or "DD-MM-YYYY HH:mm Hrs." format.
  ///
  /// Returns the parsed [DateTime] or null if parsing fails.
  /// Uses shared utility for consistency across all parsers.
  DateTime? parseDateTime(String dateTime) {
    return TravelTextParserUtils.parseDateTime(dateTime, logger: logger);
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
