import 'package:namma_wallet/src/common/database/proto/namma_wallet.pb.dart' show Ticket;

/// Abstract interface for Ticket Backup & Restore
abstract interface class ITicketBackupDAO {
  Future<List<Ticket>> fetchAllTickets();
  Future<void> restoreTickets(List<Ticket> tickets);
}
