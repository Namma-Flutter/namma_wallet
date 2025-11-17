import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';

Future<void> checkAndUpdateTNSTCTicket(TNSTCTicketModel ticket) async {
  final db = getIt<WalletDatabase>();

  if (ticket.pnrNumber == null || ticket.corporation == null) {
    // Or handle this case appropriately
    return;
  }

  final existingTicket = await db.getTicketById(
    ticket.pnrNumber ?? '',
  );

  if (existingTicket != null) {
    final updates = <String, Object?>{};
    if (ticket.busIdNumber?.isNotEmpty ?? false) {
      updates['trip_code'] = ticket.busIdNumber;
    }
    if (ticket.conductorMobileNo?.isNotEmpty ?? false) {
      updates['contact_mobile'] = ticket.conductorMobileNo;
    }

    if (updates.isNotEmpty) {
      await db.updateTicketById(ticket.pnrNumber ?? '', updates);
    }
  } else {
    await db.insertTicket(Ticket.fromTNSTC(ticket));
  }
}
