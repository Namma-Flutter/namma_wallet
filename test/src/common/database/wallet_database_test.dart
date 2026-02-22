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
        await fakeDb.close();
        FakeDatabase.reset();
      } on Exception {
        // Ignore errors during cleanup
      }
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
    // 5. ERROR HANDLING
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
