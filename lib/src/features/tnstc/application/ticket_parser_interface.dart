// We will add more methods in the future.
// ignore_for_file: one_member_abstracts

import 'package:namma_wallet/src/features/home/domain/ticket.dart';

/// Abstract interface for ticket parsers.
///
/// Defines the contract for parsing raw text (PDF, SMS, etc.)
/// into structured [Ticket] objects.
///
/// Implementations should:
/// - Never throw exceptions - handle errors gracefully
/// - Return a [Ticket] with partial data if parsing fails
/// - Use appropriate fallback values for missing fields
abstract class ITicketParser {
  /// Parses the given raw text and returns a [Ticket].
  ///
  /// The [rawText] can be from any source (PDF content, SMS message, etc.).
  /// Implementations should handle malformed or incomplete data gracefully.
  ///
  /// Returns a [Ticket] with extracted data, using defaults for missing fields.
  Ticket parseTicket(String rawText);
}
