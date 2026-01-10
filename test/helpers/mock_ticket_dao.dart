import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';

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

  /// Store tickets that have been inserted (Acts as our in-memory DB)
  final List<Ticket> insertedTickets = [];

  /// Store update calls for verification
  /// Changed from `Map<String, dynamic>` to `Ticket` to match new interface
  final List<MapEntry<String, Ticket>> updateCalls = [];

  /// Whether delete should succeed
  bool deleteSuccess = true;

  /// Whether to throw an error on operations
  bool shouldThrow = false;

  @override
  Future<int> handleTicket(Ticket ticket) async {
    if (shouldThrow) throw Exception('Mock handle error');

    final pnr = ticket.ticketId;
    if (pnr == null) return -1;

    final existing = await getTicketById(pnr);

    if (existing == null) {
      // mimic Insert
      return insertTicket(ticket);
    } else {
      // mimic Update/Merge
      // Use real Factory to ensure tests verify merge logic
      final merged = Ticket.mergeTickets(existing, ticket);
      return updateTicketById(pnr, merged);
    }
  }

  @override
  Future<int> insertTicket(Ticket ticket) async {
    if (shouldThrow) throw Exception('Mock insert error');
    // Compare enum name to filter by type
    insertedTickets.add(ticket);
    return 1;
  }

  @override
  Future<int> updateTicketById(String ticketId, Ticket ticket) async {
    if (shouldThrowOnUpdate) {
      throw Exception('Mock update error');
    }

    // 1. Log the call
    updateCalls.add(MapEntry(ticketId, ticket));

    // 2. Actually update the "In-Memory DB" so subsequent gets work
    final index = insertedTickets.indexWhere((t) => t.ticketId == ticketId);
    if (index != -1) {
      insertedTickets[index] = ticket;
    }

    return updateReturnCount;
  }

  @override
  Future<List<Ticket>> getAllTickets() async {
    if (shouldThrow) throw Exception('Mock get error');
    return insertedTickets;
  }

  @override
  Future<Ticket?> getTicketById(String ticketId) async {
    if (shouldThrow) throw Exception('Mock get error');
    return insertedTickets.where((t) => t.ticketId == ticketId).firstOrNull;
  }

  @override
  Future<List<Ticket>> getTicketsByType(String type) async {
    if (shouldThrow) throw Exception('Mock get error');
    // Assuming TicketType is an enum,
    // we compare names or convert string to enum
    return insertedTickets.where((t) => (t.type?.name ?? '') == type).toList();
  }

  @override
  Future<int> deleteTicket(String ticketId) async {
    if (shouldThrow) {
      throw Exception('Mock delete error');
    }
    if (!deleteSuccess) {
      return 0;
    }
    final initialLength = insertedTickets.length;
    insertedTickets.removeWhere((t) => t.ticketId == ticketId);
    return initialLength - insertedTickets.length;
  }
}
