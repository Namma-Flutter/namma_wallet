import 'package:dart_mappable/dart_mappable.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';

part 'shared_content_result.mapper.dart';

/// Base class for shared content processing results
@MappableClass()
sealed class SharedContentResult with SharedContentResultMappable {
  const SharedContentResult();
}

/// Result when a new ticket is successfully processed.
///
/// Uses generic display-ready fields that work across all ticket types
/// (travel, event, etc.). The [ticketType] field allows the UI to adapt
/// its labels and layout per type.
@MappableClass()
class TicketCreatedResult extends SharedContentResult
    with TicketCreatedResultMappable {
  const TicketCreatedResult({
    required this.ticketId,
    required this.ticketType,
    required this.title,
    this.subtitle,
    this.date,
    this.warning,
    this.isArchived = false,
  });

  /// The unique ticket identifier used for navigation.
  final String? ticketId;

  /// Ticket type — drives adaptive label display on the success screen.
  final TicketType? ticketType;

  /// Primary display text (e.g. "Chennai → Madurai" or "DevFest 2025").
  final String? title;

  /// Secondary display text (e.g. "SETC Sleeper" or "KonfHub").
  final String? subtitle;

  /// Formatted date string for display.
  final String? date;

  final String? warning;

  // Set when the parsed ticket's relevant time has already passed.
  // Drives navigation to the archived list — independent of `warning` so
  // that wording changes never break control flow.
  final bool isArchived;
}

/// Result when an existing ticket is updated
///
/// Consider using an enum for updateType:
/// - Would prevent invalid update type strings
/// - Makes valid update types discoverable at compile time
/// - Easier to extend with new update types
/// Currently kept as String for flexibility with dynamic update types
/// derived from update info maps.
@MappableClass()
class TicketUpdatedResult extends SharedContentResult
    with TicketUpdatedResultMappable {
  const TicketUpdatedResult({
    required this.pnrNumber,
    required this.updateType,
  });

  final String pnrNumber;
  final String updateType;
}

/// Result when processing fails
@MappableClass()
class ProcessingErrorResult extends SharedContentResult
    with ProcessingErrorResultMappable {
  const ProcessingErrorResult({
    required this.message,
    required this.error,
  });

  final String message;
  final String error;
}

/// Result when update SMS is received but ticket not found
@MappableClass()
class TicketNotFoundResult extends SharedContentResult
    with TicketNotFoundResultMappable {
  const TicketNotFoundResult({
    required this.pnrNumber,
  });

  final String pnrNumber;
}
