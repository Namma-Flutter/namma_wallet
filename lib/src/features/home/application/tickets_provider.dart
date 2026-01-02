/// Ticket providers for home feature with Riverpod.
///
/// Uses @riverpod annotations for code generation.
/// Dependencies come from GetIt.
library;

import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tickets_provider.g.dart';

/// Provider for all tickets (async)
@riverpod
Future<List<Ticket>> allTickets(Ref ref) async {
  final ticketDao = getIt<ITicketDAO>();
  return ticketDao.getAllTickets();
}
