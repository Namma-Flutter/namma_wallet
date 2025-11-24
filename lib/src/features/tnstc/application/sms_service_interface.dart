import 'package:namma_wallet/src/features/home/domain/ticket.dart';

/// Interface for SMS service operations.
///
/// Defines the contract for parsing SMS content into tickets.
// More methods will be added as needed.
// ignore: one_member_abstracts
abstract interface class ISMSService {
  /// Parses SMS text content into a ticket.
  ///
  /// Throws an exception if parsing fails.
  Ticket parseTicket(String text);
}
