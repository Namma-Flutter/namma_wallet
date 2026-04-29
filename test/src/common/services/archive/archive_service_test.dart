import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/services/archive/archive_service.dart';
import 'package:namma_wallet/src/common/services/ticket_change_notifier.dart';

import '../../../../helpers/fake_logger.dart';
import '../../../../helpers/mock_ticket_dao.dart';

class _CountingTicketDao extends MockTicketDAO {
  _CountingTicketDao({this.archiveCount = 0, this.purgeCount = 0, this.throws});
  final int archiveCount;
  final int purgeCount;
  final Exception? throws;
  int archiveCalls = 0;
  int purgeCalls = 0;

  @override
  Future<int> archivePastTickets() async {
    archiveCalls++;
    if (throws != null) throw throws!;
    return archiveCount;
  }

  @override
  Future<int> purgeOldArchivedTickets({int retentionDays = 30}) async {
    purgeCalls++;
    if (throws != null) throw throws!;
    return purgeCount;
  }
}

void main() {
  group('ArchiveService.runArchiveMaintenance', () {
    test('calls archive then purge on the DAO', () async {
      final dao = _CountingTicketDao();
      final notifier = TicketChangeNotifier();
      final service = ArchiveService(
        ticketDao: dao,
        logger: FakeLogger(),
        ticketChangeNotifier: notifier,
      );

      await service.runArchiveMaintenance();

      expect(dao.archiveCalls, equals(1));
      expect(dao.purgeCalls, equals(1));
    });

    test('notifies listeners when work was performed', () async {
      final dao = _CountingTicketDao(archiveCount: 2);
      final notifier = TicketChangeNotifier();
      var notified = 0;
      notifier.addListener(() => notified++);
      final service = ArchiveService(
        ticketDao: dao,
        logger: FakeLogger(),
        ticketChangeNotifier: notifier,
      );

      await service.runArchiveMaintenance();

      expect(notified, equals(1));
    });

    test('does not notify when nothing was archived or purged', () async {
      final dao = _CountingTicketDao();
      final notifier = TicketChangeNotifier();
      var notified = 0;
      notifier.addListener(() => notified++);
      final service = ArchiveService(
        ticketDao: dao,
        logger: FakeLogger(),
        ticketChangeNotifier: notifier,
      );

      await service.runArchiveMaintenance();

      expect(notified, equals(0));
    });

    test('also notifies when only purges happened', () async {
      final dao = _CountingTicketDao(purgeCount: 3);
      final notifier = TicketChangeNotifier();
      var notified = 0;
      notifier.addListener(() => notified++);
      final service = ArchiveService(
        ticketDao: dao,
        logger: FakeLogger(),
        ticketChangeNotifier: notifier,
      );

      await service.runArchiveMaintenance();

      expect(notified, equals(1));
    });

    test('swallows DAO exceptions and never throws', () async {
      final dao = _CountingTicketDao(throws: Exception('db down'));
      final notifier = TicketChangeNotifier();
      final service = ArchiveService(
        ticketDao: dao,
        logger: FakeLogger(),
        ticketChangeNotifier: notifier,
      );

      await expectLater(service.runArchiveMaintenance(), completes);
    });
  });
}
