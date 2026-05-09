import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';

const archivedPastTicketMessage = 'This ticket is not upcoming and is archived';

const archiveQueryKey = 'archive';
const archiveQueryValue = '1';

String archivedTicketsLocation() =>
    '${AppRoute.allTickets.path}?$archiveQueryKey=$archiveQueryValue';

bool shouldArchiveTicket(Ticket ticket, {DateTime? now}) {
  final relevantTime = ticket.endTime ?? ticket.startTime;
  if (relevantTime == null) return false;

  return relevantTime.isBefore(now ?? DateTime.now());
}
