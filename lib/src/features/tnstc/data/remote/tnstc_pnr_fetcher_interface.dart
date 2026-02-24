import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

/// Interface for fetching TNSTC ticket details from the TNSTC website
/// using PNR.
///
/// This service makes HTTP requests to the TNSTC online portal to
/// retrieve ticket information for a given PNR number.
abstract interface class ITNSTCPNRFetcher {
  /// Fetches ticket details from TNSTC website using the provided PNR number.
  /// Returns ticket data only if the provided phone number matches the
  /// passenger phone returned by the API.
  ///
  /// Returns a [TNSTCTicketModel] if the PNR is valid and ticket data
  /// is successfully fetched and parsed. Returns `null` if:
  /// - The PNR is invalid or not found
  /// - Network error occurs
  /// - HTML parsing fails
  ///
  /// **Error Handling:**
  /// - Never throws exceptions
  /// - Returns null on any error
  /// - Logs errors internally
  ///
  /// Example:
  /// ```dart
  /// final ticket = await fetcher.fetchTicketByPNR('T76296906', '9876543210');
  /// if (ticket != null) {
  ///   print('Found ticket: ${ticket.displayPnr}');
  /// }
  /// ```
  Future<TNSTCTicketModel?> fetchTicketByPNR(String pnr, String phoneNumber);
}
