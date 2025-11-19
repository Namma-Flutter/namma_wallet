import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';

Future<void> checkAndUpdateTNSTCTicket(Ticket ticket) async {
  final db = getIt<WalletDatabase>();

  if (ticket.ticketId == null) {
    // Or handle this case appropriately
    return;
  }

  final existingTicket = await db.getTicketById(
    ticket.ticketId!,
  );

  if (existingTicket != null) {
    // Extract updates from ticket extras
    final updates = <String, Object?>{};

    // Check for trip code/bus ID
    final busIdExtra = ticket.extras
        ?.where((e) => e.title == 'Bus ID')
        .firstOrNull;
    if (busIdExtra?.value != null && busIdExtra!.value!.isNotEmpty) {
      updates['trip_code'] = busIdExtra.value;
    }

    // Check for conductor mobile
    final conductorExtra = ticket.extras
        ?.where((e) => e.title == 'Conductor Contact')
        .firstOrNull;
    if (conductorExtra?.value != null && conductorExtra!.value!.isNotEmpty) {
      updates['contact_mobile'] = conductorExtra.value;
    }

    if (updates.isNotEmpty) {
      await db.updateTicketById(ticket.ticketId!, updates);
    }
  } else {
    await db.insertTicket(ticket);
  }
}
