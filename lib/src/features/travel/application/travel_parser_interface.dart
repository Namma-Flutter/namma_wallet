import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/source_type.dart';

/// Information about a ticket update (e.g., conductor details, vehicle number).
class TicketUpdateInfo {
  TicketUpdateInfo({
    required this.pnrNumber,
    required this.providerName,
    required this.updates,
  });

  final String pnrNumber;
  final String providerName;
  final Map<String, Object?> updates;
}

/// Interface for travel ticket parsing service.
///
/// Defines the contract for parsing travel tickets from various text sources.
abstract interface class ITravelParser {
  /// Attempts to parse ticket from text using all available parsers.
  ///
  /// Returns null if no parser can handle the text.
  /// Logs success/failure outcomes.
  Ticket? parseTicketFromText(
    String text, {
    SourceType? sourceType,
  });

  /// Checks if the text is an update SMS (conductor details, bus info, etc.).
  ///
  /// Returns [TicketUpdateInfo] if it's an update SMS, null otherwise.
  TicketUpdateInfo? parseUpdateSMS(String content);
}
