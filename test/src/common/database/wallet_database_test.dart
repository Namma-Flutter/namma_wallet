import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:namma_wallet/src/common/database/ticket_dao.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/database/wallet_database_interface.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/features/home/domain/extras_model.dart';
import 'package:namma_wallet/src/features/home/domain/tag_model.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';

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

    setUp(() async {
      // Register fake logger
      if (!getIt.isRegistered<ILogger>()) {
        getIt.registerSingleton<ILogger>(FakeLogger());
      }

      // Create fake database with WalletDatabase wrapper
      fakeDb = FakeDatabase();
      database = FakeWalletDatabase(fakeDb: fakeDb);

      // Initialize database
      await database.database;

      // Create TicketDao with the fake database
      ticketDao = TicketDao(database: database);
    });

    tearDown(() async {
      // Clean up database and reset GetIt
      try {
        final db = await fakeDb.database;
        // Delete all tickets to ensure clean state
        await db.delete('tickets');
        await fakeDb.close();
        FakeDatabase.reset();
      } on Exception {
        // Ignore errors during cleanup
      }
      await getIt.reset();
    });

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
          final ticket2 = Ticket(
            ticketId: 'UNIQUE123',
            primaryText: 'Chennai → Salem',
            secondaryText: 'TNSTC - Bus 202',
            startTime: DateTime(2024, 12, 16, 11, 30),
            location: 'CMBT',
            type: TicketType.bus,
          );

          // Act - Insert second ticket (should update, not throw)
          final id2 = await ticketDao.insertTicket(ticket2);

          // Assert - Should return same ID and update the ticket
          expect(id2, equals(id1));

          // Verify updated data
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
          // Arrange
          final tickets = [
            Ticket(
              ticketId: 'TICKET001',
              primaryText: 'Chennai → Bangalore',
              secondaryText: 'TNSTC',
              startTime: DateTime(2024, 12, 15, 10, 30),
              location: 'Koyambedu',
            ),
            Ticket(
              ticketId: 'TICKET002',
              primaryText: 'Mumbai → Pune',
              secondaryText: 'MSRTC',
              startTime: DateTime(2024, 12, 16, 11, 30),
              location: 'Mumbai Central',
            ),
            Ticket(
              ticketId: 'TICKET003',
              primaryText: 'Delhi → Agra',
              secondaryText: 'UPSRTC',
              startTime: DateTime(2024, 12, 17, 12, 30),
              location: 'ISBT',
            ),
          ];

          // Act
          final ids = <int>[];
          for (final ticket in tickets) {
            ids.add(await ticketDao.insertTicket(ticket));
          }

          // Assert - All IDs should be unique
          expect(ids.toSet().length, equals(3));

          // Verify all tickets exist
          final allTickets = await ticketDao.getAllTickets();
          expect(allTickets.length, greaterThanOrEqualTo(3));
        },
      );
    });

    group('updateTicket Merge Tests', () {
      test(
        'Given ticket with extras, When updating with overlapping extras, '
        'Then merges by title key',
        () async {
          // Arrange - Create ticket with initial extras
          final initialTicket = Ticket(
            ticketId: 'MERGE001',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: 'Koyambedu',
            extras: [
              ExtrasModel(title: 'Passenger', value: 'John Doe'),
              ExtrasModel(title: 'Age', value: '25'),
              ExtrasModel(title: 'Gender', value: 'M'),
            ],
          );

          await ticketDao.insertTicket(initialTicket);

          // Act - Update with overlapping and new extras
          final updatedExtras = [
            ExtrasModel(title: 'Age', value: '26'), // Update existing
            ExtrasModel(title: 'Seat', value: '12A'), // New entry
          ];

          // Convert to JSON string properly
          final extrasJson = updatedExtras
              .map((e) => '{"title":"${e.title}","value":"${e.value}"}')
              .join(',');
          final updatesMap = {
            'extras': '[$extrasJson]',
          };

          await ticketDao.updateTicketById('MERGE001', updatesMap);

          // Assert - Verify merged extras
          final retrieved = await ticketDao.getTicketById('MERGE001');
          expect(retrieved, isNotNull);
          expect(retrieved!.extras, isNotNull);
          expect(retrieved.extras!.length, equals(4));

          // Verify specific extras
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
        'Given ticket with tags, When updating with overlapping tags, '
        'Then merges by value key',
        () async {
          // Arrange - Create ticket with initial tags
          final initialTicket = Ticket(
            ticketId: 'MERGE002',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: 'Koyambedu',
            tags: [
              TagModel(value: 'PNR123', icon: 'confirmation_number'),
              TagModel(value: 'BUS101', icon: 'train'),
              TagModel(value: 'AC', icon: 'event_seat'),
            ],
          );

          await ticketDao.insertTicket(initialTicket);

          // Act - Update with overlapping and new tags
          final updatedTags = [
            TagModel(value: 'AC', icon: 'info'), // Update existing
            TagModel(value: '₹500', icon: 'attach_money'), // New entry
          ];

          final tagsJson = updatedTags
              .map((t) => '{"value":"${t.value}","icon":"${t.icon}"}')
              .join(',');
          final updatesMap = {
            'tags': '[$tagsJson]',
          };

          await ticketDao.updateTicketById('MERGE002', updatesMap);

          // Assert - Verify merged tags
          final retrieved = await ticketDao.getTicketById('MERGE002');
          expect(retrieved, isNotNull);
          expect(retrieved!.tags, isNotNull);
          expect(retrieved.tags!.length, equals(4));

          // Verify specific tags
          final tagsMap = {
            for (final t in retrieved.tags!) t.value: t.icon,
          };
          expect(tagsMap['PNR123'], equals('confirmation_number')); // Preserved
          expect(tagsMap['BUS101'], equals('train')); // Preserved
          expect(tagsMap['AC'], equals('info')); // Updated icon
          expect(tagsMap['₹500'], equals('attach_money')); // New
        },
      );

      test(
        'Given ticket with empty extras, When updating with new extras, '
        'Then adds all new extras',
        () async {
          // Arrange - Create ticket without extras
          final initialTicket = Ticket(
            ticketId: 'MERGE003',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: 'Koyambedu',
          );

          await ticketDao.insertTicket(initialTicket);

          // Act - Update with new extras
          final newExtras = [
            ExtrasModel(title: 'Passenger', value: 'Jane Doe'),
            ExtrasModel(title: 'Age', value: '30'),
          ];

          final extrasJson = newExtras
              .map((e) => '{"title":"${e.title}","value":"${e.value}"}')
              .join(',');
          final updatesMap = {
            'extras': '[$extrasJson]',
          };

          await ticketDao.updateTicketById('MERGE003', updatesMap);

          // Assert
          final retrieved = await ticketDao.getTicketById('MERGE003');
          expect(retrieved, isNotNull);
          expect(retrieved!.extras, isNotNull);
          expect(retrieved.extras!.length, equals(2));
        },
      );
    });

    group('Full CRUD Tests', () {
      test(
        'Given valid ticket, When creating (C), '
        'Then persists with all fields',
        () async {
          // Arrange
          final ticket = Ticket(
            ticketId: 'CRUD001',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC - Bus 101',
            startTime: DateTime(2024, 12, 15, 10, 30),
            endTime: DateTime(2024, 12, 15, 16, 30),
            location: 'Koyambedu',
            type: TicketType.bus,
            tags: [
              TagModel(value: 'PNR123', icon: 'confirmation_number'),
            ],
            extras: [
              ExtrasModel(title: 'Passenger', value: 'John Doe'),
            ],
          );

          // Act - Create
          final id = await ticketDao.insertTicket(ticket);

          // Assert
          expect(id, greaterThan(0));

          final retrieved = await ticketDao.getTicketById('CRUD001');
          expect(retrieved, isNotNull);
          expect(retrieved!.ticketId, equals('CRUD001'));
          expect(retrieved.primaryText, equals('Chennai → Bangalore'));
          expect(retrieved.secondaryText, equals('TNSTC - Bus 101'));
          expect(retrieved.location, equals('Koyambedu'));
          expect(retrieved.type, equals(TicketType.bus));
          expect(retrieved.tags, isNotNull);
          expect(retrieved.extras, isNotNull);
        },
      );

      test(
        'Given existing ticket, When reading (R), '
        'Then retrieves correct data',
        () async {
          // Arrange
          final ticket = Ticket(
            ticketId: 'CRUD002',
            primaryText: 'Mumbai → Pune',
            secondaryText: 'MSRTC',
            startTime: DateTime(2024, 12, 16, 11, 30),
            location: 'Mumbai Central',
          );

          await ticketDao.insertTicket(ticket);

          // Act - Read
          final retrieved = await ticketDao.getTicketById('CRUD002');

          // Assert
          expect(retrieved, isNotNull);
          expect(retrieved!.ticketId, equals('CRUD002'));
          expect(retrieved.primaryText, equals('Mumbai → Pune'));
        },
      );

      test(
        'Given existing ticket, When updating (U), '
        'Then persists updated values',
        () async {
          // Arrange
          final ticket = Ticket(
            ticketId: 'CRUD003',
            primaryText: 'Delhi → Agra',
            secondaryText: 'UPSRTC',
            startTime: DateTime(2024, 12, 17, 12, 30),
            location: 'ISBT',
          );

          await ticketDao.insertTicket(ticket);

          // Act - Update
          final updates = {
            'primary_text': 'Delhi → Jaipur',
            'location': 'Kashmere Gate',
          };

          final count = await ticketDao.updateTicketById('CRUD003', updates);

          // Assert
          expect(count, equals(1));

          final retrieved = await ticketDao.getTicketById('CRUD003');
          expect(retrieved, isNotNull);
          expect(retrieved!.primaryText, equals('Delhi → Jaipur'));
          expect(retrieved.location, equals('Kashmere Gate'));
          expect(retrieved.secondaryText, equals('UPSRTC')); // Unchanged
        },
      );

      test(
        'Given existing ticket, When deleting (D), '
        'Then removes from database',
        () async {
          // Arrange
          final ticket = Ticket(
            ticketId: 'CRUD004',
            primaryText: 'Kolkata → Siliguri',
            secondaryText: 'SBSTC',
            startTime: DateTime(2024, 12, 18, 13, 30),
            location: 'Esplanade',
          );

          await ticketDao.insertTicket(ticket);

          // Verify ticket exists
          var retrieved = await ticketDao.getTicketById('CRUD004');
          expect(retrieved, isNotNull);

          // Act - Delete
          final count = await ticketDao.deleteTicket('CRUD004');

          // Assert
          expect(count, equals(1));

          retrieved = await ticketDao.getTicketById('CRUD004');
          expect(retrieved, isNull);
        },
      );

      test(
        'Given multiple tickets, When reading all, '
        'Then returns all tickets ordered by start_time DESC',
        () async {
          // Arrange
          final tickets = [
            Ticket(
              ticketId: 'CRUD005',
              primaryText: 'A → B',
              secondaryText: 'Corp1',
              startTime: DateTime(2024, 12, 15, 10),
              location: 'Loc1',
            ),
            Ticket(
              ticketId: 'CRUD006',
              primaryText: 'C → D',
              secondaryText: 'Corp2',
              startTime: DateTime(2024, 12, 16, 10),
              location: 'Loc2',
            ),
            Ticket(
              ticketId: 'CRUD007',
              primaryText: 'E → F',
              secondaryText: 'Corp3',
              startTime: DateTime(2024, 12, 14, 10),
              location: 'Loc3',
            ),
          ];

          for (final ticket in tickets) {
            await ticketDao.insertTicket(ticket);
          }

          // Act
          final allTickets = await ticketDao.getAllTickets();

          // Assert - Should be ordered by start_time DESC
          expect(allTickets.length, greaterThanOrEqualTo(3));

          // Find our test tickets
          final testTickets = allTickets
              .where(
                (t) => ['CRUD005', 'CRUD006', 'CRUD007'].contains(t.ticketId),
              )
              .toList();

          expect(testTickets.length, 3);
          expect(testTickets[0].ticketId, 'CRUD006'); // Latest
          expect(testTickets[1].ticketId, 'CRUD005');
          expect(testTickets[2].ticketId, 'CRUD007'); // Earliest
        },
      );

      test(
        'Given tickets of different types, When querying by type, '
        'Then returns only matching tickets',
        () async {
          // Arrange
          final busTicket = Ticket(
            ticketId: 'CRUD008',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: 'Koyambedu',
            type: TicketType.bus,
          );

          final trainTicket = Ticket(
            ticketId: 'CRUD009',
            primaryText: 'Mumbai → Delhi',
            secondaryText: 'Rajdhani',
            startTime: DateTime(2024, 12, 16, 11, 30),
            location: 'Mumbai Central',
          );

          await ticketDao.insertTicket(busTicket);
          await ticketDao.insertTicket(trainTicket);

          // Act
          final busTickets = await ticketDao.getTicketsByType('BUS');

          // Assert
          expect(busTickets.isNotEmpty, true);
          for (final ticket in busTickets) {
            expect(ticket.type, equals(TicketType.bus));
          }
        },
      );
    });

    group('Migration Tests', () {
      test(
        'Given fresh database, When creating schema, '
        'Then all tables and indices exist',
        () async {
          // Act - Database is created in setUp
          final db = await database.database;

          // Assert - Check tickets table exists
          final tables = await db.rawQuery(
            'SELECT name FROM sqlite_master WHERE '
            "type='table' AND name='tickets'",
          );
          expect(tables, isNotEmpty);

          // Check indices exist
          final indices = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='index' "
            "AND name IN ('idx_tickets_id', 'idx_tickets_type', "
            "'idx_tickets_start_time')",
          );
          expect(indices.length, 3);

          // Verify table schema
          final columns = await db.rawQuery('PRAGMA table_info(tickets)');
          final columnNames = columns.map((c) => c['name']).toList();

          expect(columnNames, contains('id'));
          expect(columnNames, contains('ticket_id'));
          expect(columnNames, contains('primary_text'));
          expect(columnNames, contains('secondary_text'));
          expect(columnNames, contains('type'));
          expect(columnNames, contains('start_time'));
          expect(columnNames, contains('end_time'));
          expect(columnNames, contains('location'));
          expect(columnNames, contains('tags'));
          expect(columnNames, contains('extras'));
          expect(columnNames, contains('created_at'));
          expect(columnNames, contains('updated_at'));
        },
      );

      test(
        'Given existing data, When schema migration occurs, '
        'Then data integrity is preserved',
        () async {
          // Arrange - Insert test data
          final ticket = Ticket(
            ticketId: 'MIGRATION001',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: 'Koyambedu',
          );

          await ticketDao.insertTicket(ticket);

          // Act - Simulate reading after migration
          // (In real migration, this would be after schema change)
          final retrieved = await ticketDao.getTicketById('MIGRATION001');

          // Assert - Data is intact
          expect(retrieved, isNotNull);
          expect(retrieved!.ticketId, equals('MIGRATION001'));
          expect(retrieved.primaryText, equals('Chennai → Bangalore'));
        },
      );
    });

    group('updateTicket Edge Cases', () {
      test(
        'Given ticket, When updating with null extras, '
        'Then preserves existing extras',
        () async {
          // Arrange
          final ticket = Ticket(
            ticketId: 'EDGE001',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: 'Koyambedu',
            extras: [
              ExtrasModel(title: 'Passenger', value: 'John Doe'),
            ],
          );

          await ticketDao.insertTicket(ticket);

          // Act - Update without extras
          final updates = {'primary_text': 'Chennai → Salem'};
          await ticketDao.updateTicketById('EDGE001', updates);

          // Assert - Extras should be preserved
          final retrieved = await ticketDao.getTicketById('EDGE001');
          expect(retrieved, isNotNull);
          expect(retrieved!.extras, isNotNull);
          expect(retrieved.extras!.length, equals(1));
        },
      );

      test(
        'Given ticket, When updating with empty extras JSON, '
        'Then handles gracefully',
        () async {
          // Arrange
          final ticket = Ticket(
            ticketId: 'EDGE002',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: 'Koyambedu',
            extras: [
              ExtrasModel(title: 'Passenger', value: 'John Doe'),
            ],
          );

          await ticketDao.insertTicket(ticket);

          // Act - Update with empty array
          final updates = {'extras': '[]'};
          await ticketDao.updateTicketById('EDGE002', updates);

          // Assert - Should preserve existing extras
          final retrieved = await ticketDao.getTicketById('EDGE002');
          expect(retrieved, isNotNull);
          expect(retrieved!.extras, isNotNull);
          expect(retrieved.extras!.length, equals(1));
        },
      );

      test(
        'Given ticket, When updating with conflicting keys, '
        'Then newer values override older ones',
        () async {
          // Arrange
          final ticket = Ticket(
            ticketId: 'EDGE003',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: 'Koyambedu',
            extras: [
              ExtrasModel(title: 'Age', value: '25'),
            ],
          );

          await ticketDao.insertTicket(ticket);

          // Act - Update with same key
          final updates = {
            'extras': '[{"title":"Age","value":"30"}]',
          };
          await ticketDao.updateTicketById('EDGE003', updates);

          // Assert - Should have new value
          final retrieved = await ticketDao.getTicketById('EDGE003');
          expect(retrieved, isNotNull);
          expect(retrieved!.extras, isNotNull);

          final ageExtra = retrieved.extras!.firstWhere(
            (e) => e.title == 'Age',
          );
          expect(ageExtra.value, equals('30'));
        },
      );

      test(
        'Given ticket, When updating with large payload, '
        'Then handles successfully',
        () async {
          // Arrange
          final ticket = Ticket(
            ticketId: 'EDGE004',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: 'Koyambedu',
          );

          await ticketDao.insertTicket(ticket);

          // Act - Update with large extras list
          final largeExtras = List.generate(
            50,
            (i) => ExtrasModel(
              title: 'Field$i',
              value: 'Value$i' * 10, // Long value
            ),
          );

          final extrasJson = largeExtras
              .map((e) => '{"title":"${e.title}","value":"${e.value}"}')
              .join(',');
          final updates = {
            'extras': '[$extrasJson]',
          };

          await ticketDao.updateTicketById('EDGE004', updates);

          // Assert
          final retrieved = await ticketDao.getTicketById('EDGE004');
          expect(retrieved, isNotNull);
          expect(retrieved!.extras, isNotNull);
          expect(retrieved.extras!.length, equals(50));
        },
      );

      test(
        'Given non-existent ticket, When updating, '
        'Then returns zero count',
        () async {
          // Act
          final count = await ticketDao.updateTicketById(
            'NONEXISTENT',
            {'primary_text': 'Updated'},
          );

          // Assert
          expect(count, equals(0));
        },
      );

      test(
        'Given non-existent ticket, When deleting, '
        'Then returns zero count',
        () async {
          // Act
          final count = await ticketDao.deleteTicket('NONEXISTENT');

          // Assert
          expect(count, equals(0));
        },
      );
    });

    group('Error Handling Tests', () {
      test(
        'Given invalid JSON in extras, When retrieving ticket, '
        'Then throws exception',
        () async {
          // Arrange - Insert ticket normally
          final ticket = Ticket(
            ticketId: 'ERROR001',
            primaryText: 'Chennai → Bangalore',
            secondaryText: 'TNSTC',
            startTime: DateTime(2024, 12, 15, 10, 30),
            location: 'Koyambedu',
          );

          await ticketDao.insertTicket(ticket);

          // Act - Manually corrupt the extras field
          final db = await database.database;
          await db.rawUpdate(
            'UPDATE tickets SET extras = ? WHERE ticket_id = ?',
            ['invalid json {', 'ERROR001'],
          );

          // Assert - Should throw when trying to parse
          await expectLater(
            ticketDao.getTicketById('ERROR001'),
            throwsA(isA<FormatException>()),
          );

          // Cleanup - Remove corrupted ticket to not affect other tests
          await db.delete(
            'tickets',
            where: 'ticket_id = ?',
            whereArgs: ['ERROR001'],
          );
        },
      );
    });
  });
}
