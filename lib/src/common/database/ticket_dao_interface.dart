import 'package:namma_wallet/src/common/domain/models/ticket.dart';

/// Abstract interface for Ticket Data Access Object
abstract interface class ITicketDAO {
  /// Insert a ticket into the database
  Future<int> insertTicket(Ticket ticket);

  /// Get Ticket by ID
  Future<Ticket?> getTicketById(String id);

  /// Get all tickets (both active and archived)
  Future<List<Ticket>> getAllTickets();

  /// Get only active (non-archived) tickets
  Future<List<Ticket>> getActiveTickets();

  /// Get only archived tickets
  Future<List<Ticket>> getArchivedTickets();

  /// Get ticket by type
  Future<List<Ticket>> getTicketsByType(String type);

  Future<int> handleTicket(Ticket ticket);

  /// Update by Ticket Id
  Future<int> updateTicketById(String ticketId, Ticket ticket);

  /// Delete a ticket
  Future<int> deleteTicket(String id);

  /// Archive all tickets whose date has passed
  Future<int> archivePastTickets();

  /// Delete archived tickets older than [retentionDays]
  Future<int> purgeOldArchivedTickets({int retentionDays = 30});
}
