import 'package:flutter_test/flutter_test.dart';
import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize FFI for testing
  sqfliteFfiInit();

  group('WalletDatabase Tests', () {
    late WalletDatabase database;

    setUp(() async {
      // Use in-memory database for testing
      databaseFactory = databaseFactoryFfi;
      database = WalletDatabase.instance;
    });

    tearDown(() async {
      // Clean up after each test
      final db = await database.database;
      await db.close();
      // Reset the singleton instance
      database._database = null;
    });

    test('should be a singleton instance', () {
      final instance1 = WalletDatabase.instance;
      final instance2 = WalletDatabase.instance;
      
      expect(instance1, same(instance2));
    });

    test('should initialize database successfully', () async {
      final db = await database.database;
      
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('should create users table on initialization', () async {
      final db = await database.database;
      
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='users'",
      );
      
      expect(tables, isNotEmpty);
      expect(tables.first['name'], equals('users'));
    });

    test('should create travel_tickets table on initialization', () async {
      final db = await database.database;
      
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='travel_tickets'",
      );
      
      expect(tables, isNotEmpty);
      expect(tables.first['name'], equals('travel_tickets'));
    });

    test('should seed demo user on initialization', () async {
      final users = await database.fetchAllUsers();
      
      expect(users, isNotEmpty);
      expect(users.first['email'], equals('test@example.com'));
      expect(users.first['full_name'], equals('Test User'));
    });

    test('should seed demo travel tickets on initialization', () async {
      final tickets = await database.fetchAllTravelTickets();
      
      expect(tickets, isNotEmpty);
      expect(tickets.length, greaterThanOrEqualTo(3));
    });

    test('should fetch all users successfully', () async {
      final users = await database.fetchAllUsers();
      
      expect(users, isList);
      expect(users, isNotEmpty);
      expect(users.first, containsPair('email', 'test@example.com'));
    });

    test('should fetch all travel tickets successfully', () async {
      final tickets = await database.fetchAllTravelTickets();
      
      expect(tickets, isList);
      expect(tickets, isNotEmpty);
      
      // Verify ticket has required fields
      final firstTicket = tickets.first;
      expect(firstTicket, containsPair('ticket_type', isNotNull));
      expect(firstTicket, containsPair('provider_name', isNotNull));
    });

    test('should fetch travel tickets ordered by created_at DESC', () async {
      final tickets = await database.fetchAllTravelTickets();
      
      expect(tickets.length, greaterThan(1));
      
      // Verify order
      for (int i = 0; i < tickets.length - 1; i++) {
        final current = DateTime.parse(tickets[i]['created_at'] as String);
        final next = DateTime.parse(tickets[i + 1]['created_at'] as String);
        expect(current.isAfter(next) || current.isAtSameMomentAs(next), isTrue);
      }
    });

    test('should insert new travel ticket successfully', () async {
      final newTicket = {
        'ticket_type': 'BUS',
        'provider_name': 'Test Bus Service',
        'booking_reference': 'TEST-REF-001',
        'pnr_number': 'PNR-TEST-001',
        'source_location': 'City A',
        'destination_location': 'City B',
        'journey_date': DateTime.now().toIso8601String(),
        'amount': 250.0,
        'status': 'CONFIRMED',
        'source_type': 'MANUAL',
      };
      
      final ticketId = await database.insertTravelTicket(newTicket);
      
      expect(ticketId, greaterThan(0));
    });

    test('should set user_id to 1 when inserting ticket', () async {
      final newTicket = {
        'ticket_type': 'TRAIN',
        'provider_name': 'Test Train Service',
        'pnr_number': 'TRAIN-001',
      };
      
      final ticketId = await database.insertTravelTicket(newTicket);
      final insertedTicket = await database.getTravelTicketById(ticketId);
      
      expect(insertedTicket, isNotNull);
      expect(insertedTicket!['user_id'], equals(1));
    });

    test('should set created_at and updated_at when inserting ticket', () async {
      final beforeInsert = DateTime.now();
      
      final newTicket = {
        'ticket_type': 'BUS',
        'provider_name': 'Test Service',
        'pnr_number': 'PNR-TIME-001',
      };
      
      final ticketId = await database.insertTravelTicket(newTicket);
      final insertedTicket = await database.getTravelTicketById(ticketId);
      
      expect(insertedTicket, isNotNull);
      expect(insertedTicket!['created_at'], isNotNull);
      expect(insertedTicket['updated_at'], isNotNull);
      
      final createdAt = DateTime.parse(insertedTicket['created_at'] as String);
      expect(createdAt.isAfter(beforeInsert.subtract(const Duration(seconds: 1))), 
             isTrue);
    });

    test('should update travel ticket successfully', () async {
      // First insert a ticket
      final newTicket = {
        'ticket_type': 'BUS',
        'provider_name': 'Original Provider',
        'pnr_number': 'PNR-UPDATE-001',
        'amount': 100.0,
      };
      
      final ticketId = await database.insertTravelTicket(newTicket);
      
      // Update the ticket
      final updatedData = {
        'provider_name': 'Updated Provider',
        'amount': 150.0,
      };
      
      final updateCount = await database.updateTravelTicket(ticketId, updatedData);
      
      expect(updateCount, equals(1));
      
      // Verify the update
      final updatedTicket = await database.getTravelTicketById(ticketId);
      expect(updatedTicket!['provider_name'], equals('Updated Provider'));
      expect(updatedTicket['amount'], equals(150.0));
    });

    test('should update updated_at timestamp when updating ticket', () async {
      final newTicket = {
        'ticket_type': 'BUS',
        'provider_name': 'Test Provider',
        'pnr_number': 'PNR-TIMESTAMP-001',
      };
      
      final ticketId = await database.insertTravelTicket(newTicket);
      final originalTicket = await database.getTravelTicketById(ticketId);
      final originalUpdatedAt = originalTicket!['updated_at'] as String;
      
      // Wait a bit to ensure timestamp difference
      await Future.delayed(const Duration(milliseconds: 10));
      
      await database.updateTravelTicket(ticketId, {'amount': 200.0});
      
      final updatedTicket = await database.getTravelTicketById(ticketId);
      final newUpdatedAt = updatedTicket!['updated_at'] as String;
      
      expect(newUpdatedAt, isNot(equals(originalUpdatedAt)));
    });

    test('should delete travel ticket successfully', () async {
      final newTicket = {
        'ticket_type': 'BUS',
        'provider_name': 'To Be Deleted',
        'pnr_number': 'PNR-DELETE-001',
      };
      
      final ticketId = await database.insertTravelTicket(newTicket);
      
      final deleteCount = await database.deleteTravelTicket(ticketId);
      
      expect(deleteCount, equals(1));
      
      // Verify deletion
      final deletedTicket = await database.getTravelTicketById(ticketId);
      expect(deletedTicket, isNull);
    });

    test('should get travel ticket by ID', () async {
      final newTicket = {
        'ticket_type': 'TRAIN',
        'provider_name': 'Test Railway',
        'pnr_number': 'PNR-GETBYID-001',
        'amount': 450.0,
      };
      
      final ticketId = await database.insertTravelTicket(newTicket);
      final retrievedTicket = await database.getTravelTicketById(ticketId);
      
      expect(retrievedTicket, isNotNull);
      expect(retrievedTicket!['id'], equals(ticketId));
      expect(retrievedTicket['provider_name'], equals('Test Railway'));
      expect(retrievedTicket['amount'], equals(450.0));
    });

    test('should return null when getting non-existent ticket by ID', () async {
      final ticket = await database.getTravelTicketById(99999);
      
      expect(ticket, isNull);
    });

    test('should fetch travel tickets by type', () async {
      // Insert tickets of different types
      await database.insertTravelTicket({
        'ticket_type': 'BUS',
        'provider_name': 'Bus Provider',
        'pnr_number': 'BUS-TYPE-001',
      });
      
      await database.insertTravelTicket({
        'ticket_type': 'TRAIN',
        'provider_name': 'Train Provider',
        'pnr_number': 'TRAIN-TYPE-001',
      });
      
      final busTickets = await database.fetchTravelTicketsByType('BUS');
      
      expect(busTickets, isNotEmpty);
      expect(busTickets.every((t) => t['ticket_type'] == 'BUS'), isTrue);
    });

    test('should fetch travel tickets with user information', () async {
      final tickets = await database.fetchTravelTicketsWithUser();
      
      expect(tickets, isNotEmpty);
      
      final firstTicket = tickets.first;
      expect(firstTicket, containsPair('user_full_name', isNotNull));
      expect(firstTicket, containsPair('user_email', isNotNull));
      expect(firstTicket['user_email'], equals('test@example.com'));
    });
  });

  group('WalletDatabase Duplicate Detection Tests', () {
    late WalletDatabase database;

    setUp(() async {
      databaseFactory = databaseFactoryFfi;
      database = WalletDatabase.instance;
    });

    tearDown(() async {
      final db = await database.database;
      await db.close();
      database._database = null;
    });

    test('should throw DuplicateTicketException for duplicate PNR', () async {
      final ticket1 = {
        'ticket_type': 'BUS',
        'provider_name': 'Test Provider',
        'pnr_number': 'DUPLICATE-PNR-001',
      };
      
      await database.insertTravelTicket(ticket1);
      
      // Try to insert duplicate
      final ticket2 = {
        'ticket_type': 'BUS',
        'provider_name': 'Test Provider',
        'pnr_number': 'DUPLICATE-PNR-001',
      };
      
      expect(
        () => database.insertTravelTicket(ticket2),
        throwsA(isA<DuplicateTicketException>()),
      );
    });

    test('should throw DuplicateTicketException for duplicate booking reference', 
        () async {
      final ticket1 = {
        'ticket_type': 'TRAIN',
        'provider_name': 'Railway',
        'booking_reference': 'BOOKING-DUP-001',
      };
      
      await database.insertTravelTicket(ticket1);
      
      // Try to insert duplicate
      final ticket2 = {
        'ticket_type': 'TRAIN',
        'provider_name': 'Railway',
        'booking_reference': 'BOOKING-DUP-001',
      };
      
      expect(
        () => database.insertTravelTicket(ticket2),
        throwsA(isA<DuplicateTicketException>()),
      );
    });

    test('should allow same PNR for different providers', () async {
      final ticket1 = {
        'ticket_type': 'BUS',
        'provider_name': 'Provider A',
        'pnr_number': 'SAME-PNR-001',
      };
      
      await database.insertTravelTicket(ticket1);
      
      // Different provider, same PNR should be allowed
      final ticket2 = {
        'ticket_type': 'BUS',
        'provider_name': 'Provider B',
        'pnr_number': 'SAME-PNR-001',
      };
      
      final ticketId = await database.insertTravelTicket(ticket2);
      expect(ticketId, greaterThan(0));
    });

    test('should allow tickets with empty PNR', () async {
      final ticket1 = {
        'ticket_type': 'EVENT',
        'provider_name': 'Event Provider',
        'pnr_number': '',
      };
      
      final ticket2 = {
        'ticket_type': 'EVENT',
        'provider_name': 'Event Provider',
        'pnr_number': '',
      };
      
      final id1 = await database.insertTravelTicket(ticket1);
      final id2 = await database.insertTravelTicket(ticket2);
      
      expect(id1, greaterThan(0));
      expect(id2, greaterThan(0));
      expect(id2, isNot(equals(id1)));
    });

    test('should allow tickets with null PNR', () async {
      final ticket1 = {
        'ticket_type': 'EVENT',
        'provider_name': 'Event Provider',
      };
      
      final ticket2 = {
        'ticket_type': 'EVENT',
        'provider_name': 'Event Provider',
      };
      
      final id1 = await database.insertTravelTicket(ticket1);
      final id2 = await database.insertTravelTicket(ticket2);
      
      expect(id1, greaterThan(0));
      expect(id2, greaterThan(0));
    });

    test('DuplicateTicketException should have descriptive message', () {
      const exception = DuplicateTicketException('Test duplicate');
      
      expect(exception.message, equals('Test duplicate'));
      expect(exception.toString(), contains('DuplicateTicketException'));
      expect(exception.toString(), contains('Test duplicate'));
    });
  });

  group('WalletDatabase Edge Cases', () {
    late WalletDatabase database;

    setUp(() async {
      databaseFactory = databaseFactoryFfi;
      database = WalletDatabase.instance;
    });

    tearDown(() async {
      final db = await database.database;
      await db.close();
      database._database = null;
    });

    test('should handle ticket with all fields populated', () async {
      final completeTicket = {
        'ticket_type': 'TRAIN',
        'provider_name': 'Complete Railway',
        'booking_reference': 'COMPLETE-001',
        'pnr_number': 'PNR-COMPLETE-001',
        'trip_code': 'TRIP-001',
        'source_location': 'Source City',
        'destination_location': 'Destination City',
        'journey_date': DateTime.now().toIso8601String(),
        'journey_time': '10:30',
        'departure_time': '10:30',
        'arrival_time': '15:45',
        'passenger_name': 'John Doe',
        'passenger_age': 30,
        'passenger_gender': 'M',
        'seat_numbers': '12A,12B',
        'coach_number': 'S2',
        'class_of_service': 'AC',
        'booking_date': DateTime.now().toIso8601String(),
        'amount': 1500.0,
        'currency': 'INR',
        'status': 'CONFIRMED',
        'boarding_point': 'Platform 3',
        'pickup_location': 'Main Station',
        'source_type': 'SMS',
        'raw_data': 'Raw SMS content here',
      };
      
      final ticketId = await database.insertTravelTicket(completeTicket);
      expect(ticketId, greaterThan(0));
      
      final retrievedTicket = await database.getTravelTicketById(ticketId);
      expect(retrievedTicket, isNotNull);
      expect(retrievedTicket!['passenger_name'], equals('John Doe'));
      expect(retrievedTicket['passenger_age'], equals(30));
      expect(retrievedTicket['seat_numbers'], equals('12A,12B'));
    });

    test('should handle ticket with minimal fields', () async {
      final minimalTicket = {
        'ticket_type': 'BUS',
        'provider_name': 'Minimal Bus Service',
      };
      
      final ticketId = await database.insertTravelTicket(minimalTicket);
      expect(ticketId, greaterThan(0));
      
      final retrievedTicket = await database.getTravelTicketById(ticketId);
      expect(retrievedTicket, isNotNull);
      expect(retrievedTicket!['user_id'], equals(1));
    });

    test('should handle event tickets with venue information', () async {
      final eventTicket = {
        'ticket_type': 'EVENT',
        'provider_name': 'BookMyShow',
        'event_name': 'Rock Concert 2025',
        'venue_name': 'Grand Arena',
        'source_location': 'Grand Arena',
        'journey_date': DateTime.now().add(const Duration(days: 30))
            .toIso8601String(),
        'amount': 2500.0,
      };
      
      final ticketId = await database.insertTravelTicket(eventTicket);
      final retrievedTicket = await database.getTravelTicketById(ticketId);
      
      expect(retrievedTicket!['event_name'], equals('Rock Concert 2025'));
      expect(retrievedTicket['venue_name'], equals('Grand Arena'));
    });

    test('should handle multiple concurrent inserts', () async {
      final futures = List.generate(5, (index) {
        return database.insertTravelTicket({
          'ticket_type': 'BUS',
          'provider_name': 'Provider $index',
          'pnr_number': 'CONCURRENT-$index',
        });
      });
      
      final ids = await Future.wait(futures);
      
      expect(ids, hasLength(5));
      expect(ids.every((id) => id > 0), isTrue);
    });

    test('should handle fetching from empty table', () async {
      // Delete all tickets
      final allTickets = await database.fetchAllTravelTickets();
      for (final ticket in allTickets) {
        await database.deleteTravelTicket(ticket['id'] as int);
      }
      
      final tickets = await database.fetchAllTravelTickets();
      expect(tickets, isEmpty);
    });

    test('should handle invalid ticket ID for delete', () async {
      final deleteCount = await database.deleteTravelTicket(99999);
      expect(deleteCount, equals(0));
    });

    test('should handle invalid ticket ID for update', () async {
      final updateCount = await database.updateTravelTicket(
        99999,
        {'amount': 100.0},
      );
      expect(updateCount, equals(0));
    });

    test('should preserve data types for numeric fields', () async {
      final ticket = {
        'ticket_type': 'TRAIN',
        'provider_name': 'Test Railway',
        'pnr_number': 'TYPE-TEST-001',
        'amount': 1234.56,
        'passenger_age': 42,
      };
      
      final ticketId = await database.insertTravelTicket(ticket);
      final retrievedTicket = await database.getTravelTicketById(ticketId);
      
      expect(retrievedTicket!['amount'], isA<num>());
      expect(retrievedTicket['amount'], equals(1234.56));
      expect(retrievedTicket['passenger_age'], isA<int>());
      expect(retrievedTicket['passenger_age'], equals(42));
    });

    test('should handle various ticket statuses', () async {
      final statuses = ['CONFIRMED', 'CANCELLED', 'PENDING', 'COMPLETED'];
      
      for (final status in statuses) {
        final ticket = {
          'ticket_type': 'BUS',
          'provider_name': 'Status Test',
          'pnr_number': 'STATUS-$status',
          'status': status,
        };
        
        final ticketId = await database.insertTravelTicket(ticket);
        final retrievedTicket = await database.getTravelTicketById(ticketId);
        
        expect(retrievedTicket!['status'], equals(status));
      }
    });

    test('should handle various ticket types', () async {
      final types = ['BUS', 'TRAIN', 'EVENT', 'FLIGHT', 'METRO'];
      
      for (final type in types) {
        final ticket = {
          'ticket_type': type,
          'provider_name': 'Type Test',
          'pnr_number': 'TYPE-$type',
        };
        
        final ticketId = await database.insertTravelTicket(ticket);
        final retrievedTicket = await database.getTravelTicketById(ticketId);
        
        expect(retrievedTicket!['ticket_type'], equals(type));
      }
    });

    test('should handle various source types', () async {
      final sources = ['SMS', 'PDF', 'MANUAL', 'CLIPBOARD', 'QR'];
      
      for (final source in sources) {
        final ticket = {
          'ticket_type': 'BUS',
          'provider_name': 'Source Test',
          'pnr_number': 'SOURCE-$source',
          'source_type': source,
        };
        
        final ticketId = await database.insertTravelTicket(ticket);
        final retrievedTicket = await database.getTravelTicketById(ticketId);
        
        expect(retrievedTicket!['source_type'], equals(source));
      }
    });
  });
}