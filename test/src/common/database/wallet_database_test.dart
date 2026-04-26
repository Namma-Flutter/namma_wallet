import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/database/ticket_dao.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/database/wallet_database_interface.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/tag_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';

import '../../../helpers/fake_database.dart';
import '../../../helpers/fake_logger.dart';
import '../../../helpers/fake_wallet_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WalletDatabase', () {
    final getIt = GetIt.instance;
    late FakeDatabase fakeDb;
    late IWalletDatabase database;
    late ITicketDAO ticketDao;
    late ILogger logger;

    setUp(() async {
      logger = FakeLogger();
      if (!getIt.isRegistered<ILogger>()) {
        getIt.registerSingleton<ILogger>(logger);
      }

      fakeDb = FakeDatabase();
      database = FakeWalletDatabase(fakeDb: fakeDb, logger: logger);
      await database.database;

      ticketDao = TicketDao(database: database, logger: logger);
    });

    tearDown(() async {
      try {
        final db = await fakeDb.database;
        await db.delete('tickets');
      } on Exception {
        // Some tests intentionally drop or corrupt the table.
      }
      try {
        await fakeDb.close();
      } on Exception {
        // ignore
      }
      FakeDatabase.reset();
      await getIt.reset();
    });

    // -----------------------------------------------------------------------
    // 1. UNIQUE CONSTRAINT & INSERT LOGIC
    // -----------------------------------------------------------------------
    group('UNIQUE Constraint Tests', () {
      test(
        'Given duplicate ticket_id, When inserting, '
        'Then updates existing ticket instead of throwing exception',
        () async {
          // Arrange - Create first ticket
          final ticket1 = Ticket(
            ticketId: 'UNIQUE123',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC - Bus 101',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: 'Koyambedu',
            type: TicketType.bus,
          );

          // Act - Insert first ticket
          final id1 = await ticketDao.insertTicket(ticket1);
          expect(id1, greaterThan(0));

          // Arrange - Create second ticket with same ticket_id
          // (Simulating a replacement/update scenario)
          final ticket2 = Ticket(
            ticketId: 'UNIQUE123',
            primaryText: 'Chennai → Salem',
            secondaryText: 'TNSTC - Bus 202',
            startTime: DateTime(2024, 12, 16, 11, 30),
            location: 'CMBT',
            type: TicketType.bus,
          );

          // Act - Insert second ticket (should replace/update)
          final id2 = await ticketDao.insertTicket(ticket2);

          // Assert - Should return valid ID (likely same row
          // ID depending on conflict algo)
          expect(id2, greaterThan(0));

          // Verify updated data (The "Replace" behavior)
          final retrieved = await ticketDao.getTicketById('UNIQUE123');
          expect(retrieved, isNotNull);
          expect(retrieved!.primaryText, equals('Chennai → Salem'));
          expect(retrieved.secondaryText, equals('TNSTC - Bus 202'));
        },
      );

      test(
        'Given multiple tickets with unique IDs, When inserting, '
        'Then creates separate records',
        () async {
          final tickets = [
            Ticket(
              ticketId: 'TICKET001',
              primaryText: 'Chennai → Bangalore',
              secondaryText: 'TNSTC',
              startTime: DateTime(2024, 12, 15, 10, 30),
              location: 'Koyambedu',
              type: TicketType.bus,
            ),
            Ticket(
              ticketId: 'TICKET002',
              primaryText: 'Mumbai → Pune',
              secondaryText: 'MSRTC',
              startTime: DateTime(2024, 12, 16, 11, 30),
              location: 'Mumbai Central',
              type: TicketType.bus,
            ),
            Ticket(
              ticketId: 'TICKET003',
              primaryText: 'Delhi → Agra',
              secondaryText: 'UPSRTC',
              startTime: DateTime(2024, 12, 17, 12, 30),
              location: 'ISBT',
              type: TicketType.bus,
            ),
          ];

          final ids = <int>[];
          for (final ticket in tickets) {
            ids.add(await ticketDao.insertTicket(ticket));
          }

          expect(ids.toSet().length, equals(3));
          final allTickets = await ticketDao.getAllTickets();
          expect(allTickets.length, greaterThanOrEqualTo(3));
        },
      );
    });

    // -----------------------------------------------------------------------
    // 2. MERGE LOGIC TESTS (Using handleTicket)
    // -----------------------------------------------------------------------
    group('handleTicket Merge Tests', () {
      test(
        'Given a past ticket, When handling it, '
        'Then stores it in archived tickets only',
        () async {
          final ticket = Ticket(
            ticketId: 'PAST001',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime.now().subtract(const Duration(days: 1)),
            location: 'Koyambedu',
            type: TicketType.bus,
          );

          await ticketDao.handleTicket(ticket);

          final activeTickets = await ticketDao.getActiveTickets();
          final archivedTickets = await ticketDao.getArchivedTickets();

          expect(
            activeTickets.where((t) => t.ticketId == 'PAST001'),
            isEmpty,
          );
          expect(
            archivedTickets.where((t) => t.ticketId == 'PAST001'),
            hasLength(1),
          );
        },
      );

      test(
        'Given an archived ticket whose end_time shifts to the future, '
        'When updated, Then the ticket is un-archived',
        () async {
          // Insert a ticket already in the past (archives on insert).
          final pastTicket = Ticket(
            ticketId: 'UNARCHIVE001',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime.now().subtract(const Duration(days: 2)),
            endTime: DateTime.now().subtract(const Duration(days: 1)),
            location: 'Koyambedu',
            type: TicketType.bus,
          );
          await ticketDao.insertTicket(pastTicket);

          expect(
            (await ticketDao.getArchivedTickets()).where(
              (t) => t.ticketId == 'UNARCHIVE001',
            ),
            hasLength(1),
          );

          // Reschedule into the future via direct update.
          final rescheduled = Ticket(
            ticketId: 'UNARCHIVE001',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime.now().add(const Duration(days: 1)),
            endTime: DateTime.now().add(const Duration(days: 2)),
            location: 'Koyambedu',
            type: TicketType.bus,
          );
          await ticketDao.updateTicketById('UNARCHIVE001', rescheduled);

          expect(
            (await ticketDao.getArchivedTickets()).where(
              (t) => t.ticketId == 'UNARCHIVE001',
            ),
            isEmpty,
          );
          expect(
            (await ticketDao.getActiveTickets()).where(
              (t) => t.ticketId == 'UNARCHIVE001',
            ),
            hasLength(1),
          );
        },
      );

      test(
        'Given ticket with extras, '
        'When handling update with overlapping extras, '
        'Then merges by title key correctly',
        () async {
          // Arrange - 1. Initial State in DB
          final initialTicket = Ticket(
            ticketId: 'MERGE001',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: 'Koyambedu',
            type: TicketType.bus,
            extras: [
              ExtrasModel(title: 'Passenger', value: 'John Doe'),
              ExtrasModel(title: 'Age', value: '25'),
              ExtrasModel(title: 'Gender', value: 'M'),
            ],
          );
          await ticketDao.insertTicket(initialTicket);

          // Act - 2. Incoming Sparse Update (e.g. from SMS)
          final updateTicket = Ticket(
            ticketId: 'MERGE001',
            primaryText: '',
            // Empty - should be ignored
            secondaryText: '',
            location: '',
            type: TicketType.bus,
            extras: [
              ExtrasModel(title: 'Age', value: '26'), // UPDATE existing
              ExtrasModel(title: 'Seat', value: '12A'), // INSERT new
              // 'Passenger' is missing here, should be PRESERVED
            ],
          );

          // We use handleTicket because that's where the Merge Logic lives
          await ticketDao.handleTicket(updateTicket);

          // Assert
          final retrieved = await ticketDao.getTicketById('MERGE001');
          expect(retrieved, isNotNull);
          expect(retrieved!.extras!.length, equals(4));

          final extrasMap = {
            for (final e in retrieved.extras!) e.title: e.value,
          };
          expect(extrasMap['Passenger'], equals('John Doe')); // Preserved
          expect(extrasMap['Age'], equals('26')); // Updated
          expect(extrasMap['Gender'], equals('M')); // Preserved
          expect(extrasMap['Seat'], equals('12A')); // New
        },
      );

      test(
        'Given ticket with tags, When handling update with overlapping tags, '
        'Then merges by icon key',
        () async {
          // Arrange
          final initialTicket = Ticket(
            ticketId: 'MERGE002',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: 'Koyambedu',
            type: TicketType.bus,
            tags: [
              TagModel(value: 'PNR123', icon: 'confirmation_number'),
              TagModel(value: 'BUS101', icon: 'train'),
              TagModel(value: 'AC', icon: 'event_seat'),
            ],
          );
          await ticketDao.insertTicket(initialTicket);

          // Act - Update
          final updateTicket = Ticket(
            ticketId: 'MERGE002',
            primaryText: '',
            secondaryText: '',
            location: '',
            type: TicketType.bus,
            tags: [
              TagModel(value: 'AC', icon: 'info'),
              // Update existing icon to new 'info' style?
              // (Note: Your merge logic usually matches by ICON.
              // If icons differ, it adds new)
              TagModel(value: '₹500', icon: 'attach_money'),
              // New entry
            ],
          );

          await ticketDao.handleTicket(updateTicket);

          // Assert
          final retrieved = await ticketDao.getTicketById('MERGE002');

          // Based on your specific merge logic:
          // 'info' is a NEW icon, so it's added.
          // 'attach_money' is a NEW icon, so it's added.
          // Existing ones are kept.
          // If you intended to REPLACE based on value,
          // the logic would need to change.
          // Assuming "Add new status tags" behavior:
          expect(retrieved!.tags!.length, greaterThanOrEqualTo(4));

          final tagsValues = retrieved.tags!.map((e) => e.value).toList();
          expect(tagsValues, contains('PNR123'));
          expect(tagsValues, contains('₹500'));
        },
      );
    });

    // -----------------------------------------------------------------------
    // 3. FULL CRUD TESTS (Standard DAO Operations)
    // -----------------------------------------------------------------------
    group('Full CRUD Tests', () {
      test(
        'Given valid ticket, When creating (C), Then persists with all fields',
        () async {
          final ticket = Ticket(
            ticketId: 'CRUD001',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC - Bus 101',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: 'Koyambedu',
            type: TicketType.bus,
            tags: [TagModel(value: 'PNR123', icon: 'confirmation_number')],
            extras: [ExtrasModel(title: 'Passenger', value: 'John Doe')],
          );

          await ticketDao.insertTicket(ticket);

          final retrieved = await ticketDao.getTicketById('CRUD001');
          expect(retrieved, isNotNull);
          expect(retrieved!.ticketId, equals('CRUD001'));
          expect(retrieved.primaryText, equals('Chennai → Bangalore'));
          expect(retrieved.tags!.first.value, 'PNR123');
        },
      );

      test(
        'Given existing ticket, When updating (U) directly, '
        'Then persists updated values',
        () async {
          // Arrange
          final ticket = Ticket(
            ticketId: 'CRUD003',
            primaryText: 'Delhi → Agra',
            secondaryText: 'UPSRTC',
            startTime: DateTime(2024, 12, 17, 12, 30),
            location: 'ISBT',
            type: TicketType.bus,
          );
          await ticketDao.insertTicket(ticket);

          // Act - Direct update via updateTicketById replaces
          // specified fields in DB
          // NOTE: In the new DAO, we pass a Ticket object.
          const updatePayload = Ticket(
            ticketId: 'CRUD003',
            primaryText: 'Delhi → Jaipur', // Changed
            secondaryText: 'UPSRTC', // Kept same
            location: 'Kashmere Gate', // Changed
            type: TicketType.bus,
          );

          await ticketDao.updateTicketById('CRUD003', updatePayload);

          // Assert
          final retrieved = await ticketDao.getTicketById('CRUD003');
          expect(retrieved!.primaryText, equals('Delhi → Jaipur'));
          expect(retrieved.location, equals('Kashmere Gate'));
        },
      );

      test(
        'Given existing ticket, When deleting (D), Then removes from database',
        () async {
          final ticket = Ticket(
            ticketId: 'CRUD004',
            primaryText: 'Kolkata → Siliguri',
            secondaryText: 'SBSTC',
            startTime: DateTime(2024, 12, 18, 13, 30),
            location: 'Esplanade',
            type: TicketType.bus,
          );
          await ticketDao.insertTicket(ticket);

          await ticketDao.deleteTicket('CRUD004');

          final retrieved = await ticketDao.getTicketById('CRUD004');
          expect(retrieved, isNull);
        },
      );

      test(
        'Given multiple tickets, When reading all, '
        'Then returns ordered by start_time DESC',
        () async {
          final tickets = [
            Ticket(
              ticketId: 'CRUD005',
              primaryText: 'A',
              secondaryText: '',
              location: '',
              startTime: DateTime(2024, 12, 15, 10),
              type: TicketType.bus,
            ),
            Ticket(
              ticketId: 'CRUD006',
              primaryText: 'B',
              secondaryText: '',
              location: '',
              startTime: DateTime(2024, 12, 16, 10),
              type: TicketType.bus,
            ), // Latest
            Ticket(
              ticketId: 'CRUD007',
              primaryText: 'C',
              secondaryText: '',
              location: '',
              startTime: DateTime(2024, 12, 14, 10),
              type: TicketType.bus,
            ),
          ];

          for (final t in tickets) {
            await ticketDao.insertTicket(t);
          }

          final allTickets = await ticketDao.getAllTickets();
          final testTickets = allTickets
              .where(
                (t) => ['CRUD005', 'CRUD006', 'CRUD007'].contains(t.ticketId),
              )
              .toList();

          // Expect: Latest date first
          expect(testTickets[0].ticketId, 'CRUD006');
          expect(testTickets[1].ticketId, 'CRUD005');
          expect(testTickets[2].ticketId, 'CRUD007');
        },
      );
    });

    // -----------------------------------------------------------------------
    // 4. EDGE CASE TESTS
    // -----------------------------------------------------------------------
    group('Edge Cases', () {
      test(
        'Given ticket, When updating with NULL extras (via handleTicket),'
        ' Then preserves existing extras',
        () async {
          // Arrange
          final ticket = Ticket(
            ticketId: 'EDGE001',
            primaryText: 'Main',
            secondaryText: '',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: '',
            type: TicketType.bus,
            extras: [ExtrasModel(title: 'Passenger', value: 'John Doe')],
          );
          await ticketDao.insertTicket(ticket);

          // Act - Update coming in with NO extras
          const update = Ticket(
            ticketId: 'EDGE001',
            primaryText: '',
            secondaryText: '',
            location: 'Kashmere Gate',
            type: TicketType.bus,
          );

          await ticketDao.handleTicket(update);

          // Assert - Old extra remains
          final retrieved = await ticketDao.getTicketById('EDGE001');
          expect(retrieved!.extras!.length, equals(1));
          expect(retrieved.extras!.first.value, 'John Doe');
        },
      );

      test(
        'Given ticket, When updating with large payload, '
        'Then handles successfully',
        () async {
          final ticket = Ticket(
            ticketId: 'EDGE004',
            primaryText: 'Large',
            secondaryText: '',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: '',
            type: TicketType.bus,
          );
          await ticketDao.insertTicket(ticket);

          // Act - Update with large object
          final largeExtras = List.generate(
            50,
            (i) => ExtrasModel(title: 'Field$i', value: 'Value$i' * 10),
          );

          // Use direct update to force writing this massive payload
          final updatePayload = Ticket(
            ticketId: 'EDGE004',
            primaryText: 'Large',
            secondaryText: '',
            location: '',
            type: TicketType.bus,
            extras: largeExtras,
          );

          await ticketDao.updateTicketById('EDGE004', updatePayload);

          // Assert
          final retrieved = await ticketDao.getTicketById('EDGE004');
          expect(retrieved!.extras!.length, equals(50));
        },
      );
    });

    // -----------------------------------------------------------------------
    // 5. ARCHIVE TESTS
    // -----------------------------------------------------------------------
    group('Archive Tests', () {
      test(
        'Given a future ticket, When inserting, '
        'Then it lives in active list and not archived',
        () async {
          final ticket = Ticket(
            ticketId: 'FUTURE001',
            primaryText: 'A → B',
            type: TicketType.bus,
            startTime: DateTime.now().add(const Duration(days: 2)),
          );
          await ticketDao.insertTicket(ticket);

          expect(
            (await ticketDao.getActiveTickets()).where(
              (t) => t.ticketId == 'FUTURE001',
            ),
            hasLength(1),
          );
          expect(
            (await ticketDao.getArchivedTickets()).where(
              (t) => t.ticketId == 'FUTURE001',
            ),
            isEmpty,
          );
        },
      );

      test(
        'Given a ticket with no start_time and no end_time, '
        'When inserting, Then it stays in active list',
        () async {
          const ticket = Ticket(
            ticketId: 'NO_TIME_001',
            primaryText: 'A → B',
            type: TicketType.bus,
          );
          await ticketDao.insertTicket(ticket);

          expect(
            (await ticketDao.getActiveTickets()).where(
              (t) => t.ticketId == 'NO_TIME_001',
            ),
            hasLength(1),
          );
          expect(
            (await ticketDao.getArchivedTickets()).where(
              (t) => t.ticketId == 'NO_TIME_001',
            ),
            isEmpty,
          );
        },
      );

      test(
        'Given a mix of active tickets, '
        'When archivePastTickets runs, '
        'Then only past ones move to archived',
        () async {
          // Bypass auto-archive on insert by writing rows directly.
          final db = await database.database;
          final twoDaysAgo = DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String();
          final inTwoDays = DateTime.now()
              .add(const Duration(days: 2))
              .toIso8601String();

          await db.insert('tickets', {
            'ticket_id': 'PAST_BULK_001',
            'type': 'BUS',
            'start_time': twoDaysAgo,
          });
          await db.insert('tickets', {
            'ticket_id': 'FUTURE_BULK_001',
            'type': 'BUS',
            'start_time': inTwoDays,
          });
          await db.insert('tickets', {
            'ticket_id': 'NULL_TIME_BULK_001',
            'type': 'BUS',
            // Intentionally null start_time / end_time.
          });

          final archivedCount = await ticketDao.archivePastTickets();

          expect(archivedCount, equals(1));
          final archivedIds = (await ticketDao.getArchivedTickets())
              .map((t) => t.ticketId)
              .toSet();
          expect(archivedIds, contains('PAST_BULK_001'));
          expect(archivedIds, isNot(contains('FUTURE_BULK_001')));
          expect(archivedIds, isNot(contains('NULL_TIME_BULK_001')));
        },
      );

      test(
        'Given an already-archived ticket, '
        'When archivePastTickets runs again, '
        'Then it is not re-archived',
        () async {
          final ticket = Ticket(
            ticketId: 'PAST_IDEMPOTENT_001',
            primaryText: 'A → B',
            type: TicketType.bus,
            startTime: DateTime.now().subtract(const Duration(days: 1)),
          );
          await ticketDao.insertTicket(ticket); // auto-archives

          final secondRun = await ticketDao.archivePastTickets();

          expect(secondRun, equals(0));
        },
      );

      test(
        'Given archived tickets older and newer than retention, '
        'When purgeOldArchivedTickets runs, '
        'Then only those older than retentionDays are deleted',
        () async {
          final db = await database.database;
          // Old archive: 60 days ago.
          await db.insert('tickets', {
            'ticket_id': 'OLD_ARCHIVED_001',
            'type': 'BUS',
            'archived_at': DateTime.now()
                .subtract(const Duration(days: 60))
                .toIso8601String(),
          });
          // Recent archive: 5 days ago.
          await db.insert('tickets', {
            'ticket_id': 'RECENT_ARCHIVED_001',
            'type': 'BUS',
            'archived_at': DateTime.now()
                .subtract(const Duration(days: 5))
                .toIso8601String(),
          });

          final purged = await ticketDao.purgeOldArchivedTickets();

          expect(purged, equals(1));
          final remaining = (await ticketDao.getArchivedTickets())
              .map((t) => t.ticketId)
              .toSet();
          expect(remaining, contains('RECENT_ARCHIVED_001'));
          expect(remaining, isNot(contains('OLD_ARCHIVED_001')));
        },
      );

      test(
        'Given retentionDays override, '
        'When purgeOldArchivedTickets runs, '
        'Then the override controls the cutoff',
        () async {
          final db = await database.database;
          await db.insert('tickets', {
            'ticket_id': 'TIGHT_RETENTION_001',
            'type': 'BUS',
            'archived_at': DateTime.now()
                .subtract(const Duration(days: 3))
                .toIso8601String(),
          });

          // Default 30-day retention should NOT purge a 3-day-old archive.
          expect(await ticketDao.purgeOldArchivedTickets(), equals(0));

          // 1-day retention SHOULD purge a 3-day-old archive.
          expect(
            await ticketDao.purgeOldArchivedTickets(retentionDays: 1),
            equals(1),
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // 6. SECONDARY DAO METHODS
    // -----------------------------------------------------------------------
    group('Secondary DAO methods', () {
      test('handleTicket returns -1 when ticketId is null', () async {
        const orphan = Ticket(primaryText: 'no id', type: TicketType.bus);

        final result = await ticketDao.handleTicket(orphan);

        expect(result, equals(-1));
      });

      test(
        'handleTicket returns -1 when ticketId is empty',
        () async {
          const orphan = Ticket(
            ticketId: '',
            primaryText: 'empty id',
            type: TicketType.bus,
          );

          final result = await ticketDao.handleTicket(orphan);

          expect(result, equals(-1));
        },
      );

      test(
        'getTicketsByType returns matching tickets ordered by start_time DESC',
        () async {
          await ticketDao.insertTicket(
            Ticket(
              ticketId: 'BUS_OLD',
              primaryText: 'A → B',
              type: TicketType.bus,
              startTime: DateTime(2024, 5),
            ),
          );
          await ticketDao.insertTicket(
            Ticket(
              ticketId: 'BUS_NEW',
              primaryText: 'A → B',
              type: TicketType.bus,
              startTime: DateTime(2024, 6),
            ),
          );
          await ticketDao.insertTicket(
            Ticket(
              ticketId: 'TRAIN_001',
              primaryText: 'A → B',
              type: TicketType.train,
              startTime: DateTime(2024, 5, 15),
            ),
          );

          final buses = await ticketDao.getTicketsByType('BUS');
          expect(buses.map((t) => t.ticketId), ['BUS_NEW', 'BUS_OLD']);
        },
      );

      test(
        'getTicketsByType returns empty list when type has no rows',
        () async {
          final none = await ticketDao.getTicketsByType('NOPE');
          expect(none, isEmpty);
        },
      );

      test('getAllTickets returns empty list when DB has no rows', () async {
        expect(await ticketDao.getAllTickets(), isEmpty);
      });

      test('getActiveTickets returns empty list when no rows', () async {
        expect(await ticketDao.getActiveTickets(), isEmpty);
      });

      test('getArchivedTickets returns empty list when no rows', () async {
        expect(await ticketDao.getArchivedTickets(), isEmpty);
      });

      test('deleteTicket returns 0 when no row matches', () async {
        expect(await ticketDao.deleteTicket('DOES_NOT_EXIST'), equals(0));
      });

      test(
        'getTicketById returns null and warns when no row matches',
        () async {
          expect(await ticketDao.getTicketById('NONE'), isNull);
        },
      );
    });

    // -----------------------------------------------------------------------
    // 7. EXCEPTION RETHROW PATHS
    // -----------------------------------------------------------------------
    group('Exception rethrow paths', () {
      test(
        'getAllTickets rethrows when the underlying table is dropped',
        () async {
          final db = await database.database;
          await db.execute('DROP TABLE tickets;');

          await expectLater(ticketDao.getAllTickets(), throwsA(isA<Object>()));
        },
      );

      test('getActiveTickets rethrows on a broken DB', () async {
        final db = await database.database;
        await db.execute('DROP TABLE tickets;');

        await expectLater(ticketDao.getActiveTickets(), throwsA(isA<Object>()));
      });

      test('getArchivedTickets rethrows on a broken DB', () async {
        final db = await database.database;
        await db.execute('DROP TABLE tickets;');

        await expectLater(
          ticketDao.getArchivedTickets(),
          throwsA(isA<Object>()),
        );
      });

      test('archivePastTickets rethrows on a broken DB', () async {
        final db = await database.database;
        await db.execute('DROP TABLE tickets;');

        await expectLater(
          ticketDao.archivePastTickets(),
          throwsA(isA<Object>()),
        );
      });

      test('purgeOldArchivedTickets rethrows on a broken DB', () async {
        final db = await database.database;
        await db.execute('DROP TABLE tickets;');

        await expectLater(
          ticketDao.purgeOldArchivedTickets(),
          throwsA(isA<Object>()),
        );
      });

      test('getTicketsByType rethrows on a broken DB', () async {
        final db = await database.database;
        await db.execute('DROP TABLE tickets;');

        await expectLater(
          ticketDao.getTicketsByType('BUS'),
          throwsA(isA<Object>()),
        );
      });

      test('deleteTicket rethrows on a broken DB', () async {
        final db = await database.database;
        await db.execute('DROP TABLE tickets;');

        await expectLater(
          ticketDao.deleteTicket('X'),
          throwsA(isA<Object>()),
        );
      });
    });

    // -----------------------------------------------------------------------
    // 8. ERROR HANDLING
    // -----------------------------------------------------------------------
    group('Error Handling Tests', () {
      test(
        'Given invalid JSON in extras, When retrieving ticket, '
        'Then throws exception',
        () async {
          // Arrange
          final ticket = Ticket(
            ticketId: 'ERROR001',
            primaryText: 'Chennai',
            secondaryText: '',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: '',
            type: TicketType.bus,
          );
          await ticketDao.insertTicket(ticket);

          // Act - Manually corrupt DB
          final db = await database.database;
          await db.rawUpdate(
            'UPDATE tickets SET extras = ? WHERE ticket_id = ?',
            ['invalid json {', 'ERROR001'],
          );

          // Assert
          await expectLater(
            ticketDao.getTicketById('ERROR001'),
            throwsA(isA<FormatException>()),
          );

          // Cleanup
          await ticketDao.deleteTicket('ERROR001');
        },
      );
    });
  });
}
