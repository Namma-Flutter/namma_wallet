import 'package:namma_wallet/src/common/database/i_ticket_dao.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';

Future<void> checkAndUpdateTNSTCTicket(Ticket ticket) async {
  final ticketDao = getIt<ITicketDao>();

  if (ticket.ticketId == null) {
    // Or handle this case appropriately
    return;
  }

  // Delegate to DAO's upsert logic
  // insertTicket handles both insert and update based on ticketId
  await ticketDao.insertTicket(ticket);
}
