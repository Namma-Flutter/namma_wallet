import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';

Future<void> checkAndUpdateTNSTCTicket(Ticket ticket) async {
  final ticketDao = getIt<ITicketDAO>();

  final id = ticket.ticketId;
  if (id == null || id.trim().isEmpty) {
    // Skip tickets with null or empty/whitespace ticketId
    return;
  }

  // Delegate to DAO's upsert logic
  // insertTicket handles both insert and update based on ticketId
  await ticketDao.insertTicket(ticket);
}
