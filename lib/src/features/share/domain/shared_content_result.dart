import 'package:dart_mappable/dart_mappable.dart';

part 'shared_content_result.mapper.dart';

/// Base class for shared content processing results
@MappableClass()
sealed class SharedContentResult with SharedContentResultMappable {
  const SharedContentResult();
}

/// Result when a new ticket is successfully processed
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
