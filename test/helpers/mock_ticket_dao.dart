import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';

/// Mock TicketDAO for testing purposes
class MockTicketDAO implements ITicketDAO {
  MockTicketDAO({
    this.updateReturnCount = 1,
    this.shouldThrowOnUpdate = false,
  });

  /// Number of rows to return from updateTicketById
  final int updateReturnCount;

  /// Whether to throw an error on update
  final bool shouldThrowOnUpdate;

  /// Store tickets that have been inserted
  final List<Ticket> insertedTickets = [];

  /// Store update calls
  final List<MapEntry<String, Map<String, dynamic>>> updateCalls = [];

  @override
  Future<int> updateTicketById(
    String ticketId,
    Map<String, dynamic> updates,
  ) async {
    if (shouldThrowOnUpdate) {
      throw Exception('Mock update error');
    }

    updateCalls.add(MapEntry(ticketId, updates));
    return updateReturnCount;
  }

  @override
  Future<int> insertTicket(Ticket ticket) async {
    insertedTickets.add(ticket);
    return 1;
  }

  @override
  Future<List<Ticket>> getAllTickets() async {
    return insertedTickets;
  }

  @override
  Future<Ticket?> getTicketById(String ticketId) async {
    return insertedTickets.where((t) => t.ticketId == ticketId).firstOrNull;
  }

  @override
  Future<List<Ticket>> getTicketsByType(String type) async {
    return insertedTickets.where((t) => t.type.name == type).toList();
  }

  @override
  Future<int> deleteTicket(String ticketId) async {
    final initialLength = insertedTickets.length;
    insertedTickets.removeWhere((t) => t.ticketId == ticketId);
    return initialLength - insertedTickets.length;
  }
}
