import 'package:namma_wallet/src/features/irctc/domain/irctc_ticket_model.dart';

/// Interface for IRCTC QR code parsing.
///
/// Defines the contract for parsing IRCTC QR codes and validating QR data.
abstract interface class IIRCTCQRParser {
  /// Parses IRCTC QR code data into a structured ticket model.
  ///
  /// Returns [IRCTCTicket] if parsing succeeds, null otherwise.
  /// Never throws - returns null on any parsing error.
  IRCTCTicket? parseQRCode(String qrData);

  /// Checks if the given QR data is from IRCTC.
  ///
  /// Returns true if the data contains IRCTC-specific patterns.
  bool isIRCTCQRCode(String qrData);
}
