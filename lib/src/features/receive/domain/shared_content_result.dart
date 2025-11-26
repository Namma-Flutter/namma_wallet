import 'package:dart_mappable/dart_mappable.dart';

part 'shared_content_result.mapper.dart';

/// Base class for shared content processing results
@MappableClass()
sealed class SharedContentResult with SharedContentResultMappable {
  const SharedContentResult();
}

/// Result when a new ticket is successfully processed
///
/// Consider stronger domain types for fields:
/// - fare: Could be numeric type (double/int) instead of String
/// - date: Could be DateTime instead of String
/// This would align with domain models and reduce parsing/validation errors.
/// Currently kept as Strings to match Ticket model's extras structure
/// and simplify UI display.
@MappableClass()
class TicketCreatedResult extends SharedContentResult
    with TicketCreatedResultMappable {
  const TicketCreatedResult({
    required this.pnrNumber,
    required this.from,
    required this.to,
    required this.fare,
    required this.date,
  });

  final String pnrNumber;
  final String from;
  final String to;
  final String fare;
  final String date;
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
