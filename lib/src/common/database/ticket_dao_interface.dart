import 'package:namma_wallet/src/features/home/domain/ticket.dart';

/// Abstract interface for Ticket Data Access Object
abstract interface class ITicketDAO {
  /// Insert a ticket into the database
  Future<int> insertTicket(Ticket ticket);

  /// Get Ticket by ID
  Future<Ticket?> getTicketById(String id);

  /// Get all tickets
  Future<List<Ticket>> getAllTickets();

  /// Get ticket by type
  Future<List<Ticket>> getTicketsByType(String type);

  /// Update by Ticket Id
  Future<int> updateTicketById(
    String ticketId,
    Map<String, Object?> updates,
  );

  /// Delete a ticket
  Future<int> deleteTicket(String id);
}
