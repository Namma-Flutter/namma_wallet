import 'package:namma_wallet/src/features/irctc/application/irctc_scanner_service.dart';

/// Interface for IRCTC ticket scanning service.
///
/// Defines the contract for scanning, parsing, and saving IRCTC tickets
/// from QR codes.
// More methods may be added in the future.
// ignore: one_member_abstracts
abstract interface class IIRCTCScannerService {
  /// Parses IRCTC QR code data and saves the ticket to the database.
  ///
  /// Returns [IRCTCScannerResult] with success status and ticket data,
  /// or error message if parsing/saving fails.
  Future<IRCTCScannerResult> parseAndSaveIRCTCTicket(String qrData);
}
