import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';

Future<void> checkAndUpdateTNSTCTicket(Ticket ticket) async {
  final db = getIt<WalletDatabase>();

  if (ticket.ticketId == null) {
    // Or handle this case appropriately
    return;
  }

  // Delegate to database's upsert logic
  // insertTicket handles both insert and update based on ticketId
  await db.insertTicket(ticket);
}
