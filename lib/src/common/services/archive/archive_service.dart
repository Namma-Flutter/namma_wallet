import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/archive/archive_service_interface.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/ticket_change_notifier.dart';

class ArchiveService implements IArchiveService {
  ArchiveService({
    ITicketDAO? ticketDao,
    ILogger? logger,
    TicketChangeNotifier? ticketChangeNotifier,
  }) : _ticketDao = ticketDao ?? getIt<ITicketDAO>(),
       _logger = logger ?? getIt<ILogger>(),
       _ticketChangeNotifier =
           ticketChangeNotifier ?? getIt<TicketChangeNotifier>();

  final ITicketDAO _ticketDao;
  final ILogger _logger;
  final TicketChangeNotifier _ticketChangeNotifier;

  @override
  Future<void> runArchiveMaintenance() async {
    try {
      _logger.info('🗄️ Running archive maintenance...');

      // 1. Archive past tickets
      final archivedCount = await _ticketDao.archivePastTickets();

      // 2. Purge old archived tickets (older than 30 days)
      final purgedCount = await _ticketDao.purgeOldArchivedTickets();

      _logger.success(
        '🗄️ Archive maintenance complete: '
        '$archivedCount archived, $purgedCount purged',
      );

      // 3. Notify UI to refresh if any changes were made
      if (archivedCount > 0 || purgedCount > 0) {
        _ticketChangeNotifier.notifyTicketChanged();
      }
    } on Exception catch (e, stackTrace) {
      // Archive maintenance failure should NOT crash the app
      _logger.error(
        'Archive maintenance failed (non-fatal)',
        e,
        stackTrace,
      );
    }
  }
}
