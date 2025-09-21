import 'dart:async';
import 'dart:developer' as developer;

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DuplicateTicketException implements Exception {
  const DuplicateTicketException(this.message);
  final String message;

  @override
  String toString() => 'DuplicateTicketException: $message';
}

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'namma_wallet.db';
  static const int _dbVersion = 2;

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (Database db, int version) async {
        await _createSchema(db);
        await _seedDummyData(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          // Drop old tickets table and recreate with new schema
          await db.execute('DROP TABLE IF EXISTS tickets');
          await _createTravelTicketsTable(db);
        }
      },
    );
  }

  Future<void> _createSchema(Database db) async {
    // users table
    await db.execute('''
CREATE TABLE users (
  user_id INTEGER PRIMARY KEY AUTOINCREMENT,
  full_name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT UNIQUE,
  password_hash TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);
''');

    await _createTravelTicketsTable(db);
  }

  Future<void> _createTravelTicketsTable(Database db) async {
    // Enhanced travel tickets table - generic for all travel types
    await db.execute('''
CREATE TABLE travel_tickets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,

  -- Core travel info
  ticket_type TEXT NOT NULL CHECK(ticket_type IN ('BUS','TRAIN','EVENT','FLIGHT','METRO')),
  provider_name TEXT NOT NULL,
  booking_reference TEXT,
  pnr_number TEXT,
  trip_code TEXT,

  -- Journey details
  source_location TEXT,
  destination_location TEXT,
  journey_date TEXT,
  journey_time TEXT,
  departure_time TEXT,
  arrival_time TEXT,

  -- Passenger details
  passenger_name TEXT,
  passenger_age INTEGER,
  passenger_gender TEXT,

  -- Seat/ticket details
  seat_numbers TEXT, -- JSON array or comma-separated
  coach_number TEXT,
  class_of_service TEXT,

  -- Booking details
  booking_date TEXT,
  amount REAL,
  currency TEXT DEFAULT 'INR',
  status TEXT DEFAULT 'CONFIRMED' CHECK(status IN ('CONFIRMED','CANCELLED','PENDING','COMPLETED')),

  -- Additional metadata
  boarding_point TEXT,
  pickup_location TEXT,
  event_name TEXT, -- For event tickets
  venue_name TEXT, -- For event tickets

  -- Source tracking
  source_type TEXT CHECK(source_type IN ('SMS','PDF','MANUAL','CLIPBOARD','QR')),
  raw_data TEXT, -- Store original SMS/PDF content for reference

  -- Timestamps
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now')),

  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
''');

    // Create indexes for better query performance
    await db.execute('''
CREATE INDEX idx_travel_tickets_user_id ON travel_tickets(user_id);
''');
    await db.execute('''
CREATE INDEX idx_travel_tickets_journey_date ON travel_tickets(journey_date);
''');
    await db.execute('''
CREATE INDEX idx_travel_tickets_ticket_type ON travel_tickets(ticket_type);
''');
  }

  Future<void> _seedDummyData(Database db) async {
    // Insert a demo user
    final userId = await db.insert('users', <String, Object?>{
      'full_name': 'Test User',
      'email': 'test@example.com',
      'phone': '+911234567890',
      'password_hash': 'hashed_password',
    });

    // Insert some demo travel tickets with new schema
    final travelTickets = <Map<String, Object?>>[
      {
        'user_id': userId,
        'ticket_type': 'BUS',
        'provider_name': 'TNSTC',
        'booking_reference': 'TNSTC123456',
        'pnr_number': 'PNR123456',
        'trip_code': 'CHN-CBE-001',
        'source_location': 'Chennai',
        'destination_location': 'Coimbatore',
        'journey_date':
            DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'departure_time': '08:30',
        'passenger_name': 'Test User',
        'seat_numbers': '12A,12B',
        'class_of_service': 'AC',
        'booking_date': DateTime.now().toIso8601String(),
        'amount': 599.00,
        'status': 'CONFIRMED',
        'boarding_point': 'Koyambedu Bus Stand',
        'source_type': 'SMS',
      },
      {
        'user_id': userId,
        'ticket_type': 'TRAIN',
        'provider_name': 'IRCTC',
        'booking_reference': 'E-TICKET',
        'pnr_number': '9876543210',
        'source_location': 'Bangalore',
        'destination_location': 'Chennai',
        'journey_date':
            DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        'departure_time': '06:00',
        'arrival_time': '11:30',
        'passenger_name': 'Test User',
        'seat_numbers': 'S2-34',
        'coach_number': 'S2',
        'class_of_service': 'Sleeper',
        'booking_date':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'amount': 450.50,
        'status': 'CONFIRMED',
        'source_type': 'PDF',
      },
      {
        'user_id': userId,
        'ticket_type': 'EVENT',
        'provider_name': 'BookMyShow',
        'booking_reference': 'BMS-2025-ABCD',
        'passenger_name': 'Test User',
        'event_name': 'Music Fest 2025',
        'venue_name': 'Chennai Trade Centre',
        'source_location': 'Chennai Trade Centre',
        'destination_location': 'Chennai Trade Centre',
        'journey_date':
            DateTime.now().add(const Duration(days: 20)).toIso8601String(),
        'journey_time': '19:00',
        'seat_numbers': 'A-10',
        'booking_date': DateTime.now().toIso8601String(),
        'amount': 999.99,
        'status': 'CONFIRMED',
        'source_type': 'MANUAL',
      },
    ];

    for (final ticket in travelTickets) {
      await db.insert('travel_tickets', ticket);
    }
  }

  // Queries
  Future<List<Map<String, Object?>>> fetchAllUsers() async {
    final db = await database;
    return db.query('users', orderBy: 'user_id DESC');
  }

  Future<List<Map<String, Object?>>> fetchAllTravelTickets() async {
    try {
      final db = await database;
      final tickets =
          await db.query('travel_tickets', orderBy: 'created_at DESC');
      developer.log('Successfully fetched ${tickets.length} travel tickets',
          name: 'DatabaseHelper');
      print('✅ DB FETCH: Retrieved ${tickets.length} travel tickets');
      return tickets;
    } catch (e) {
      developer.log('Failed to fetch travel tickets',
          name: 'DatabaseHelper', error: e);
      print('🔴 DB FETCH ERROR: Failed to retrieve travel tickets: $e');
      rethrow;
    }
  }

  Future<List<Map<String, Object?>>> fetchTravelTicketsWithUser() async {
    final db = await database;
    return db.rawQuery('''
SELECT t.*, u.full_name AS user_full_name, u.email AS user_email
FROM travel_tickets t
JOIN users u ON u.user_id = t.user_id
ORDER BY t.created_at DESC
''');
  }

  Future<List<Map<String, Object?>>> fetchTravelTicketsByType(
      String ticketType) async {
    final db = await database;
    return db.query(
      'travel_tickets',
      where: 'ticket_type = ?',
      whereArgs: [ticketType],
      orderBy: 'created_at DESC',
    );
  }

  Future<int> insertTravelTicket(Map<String, Object?> ticket) async {
    try {
      final db = await database;
      // Ensure user_id is set to 1 (single user app)
      ticket['user_id'] = 1;
      ticket['created_at'] = DateTime.now().toIso8601String();
      ticket['updated_at'] = DateTime.now().toIso8601String();

      // Check for duplicates based on PNR number or booking reference
      final pnrNumber = ticket['pnr_number'] as String?;
      final bookingRef = ticket['booking_reference'] as String?;
      final providerName = ticket['provider_name'] as String;

      if (pnrNumber != null && pnrNumber.isNotEmpty) {
        final existing = await db.query(
          'travel_tickets',
          where: 'pnr_number = ? AND provider_name = ?',
          whereArgs: [pnrNumber, providerName],
          limit: 1,
        );
        if (existing.isNotEmpty) {
          developer.log('Duplicate ticket found with PNR: $pnrNumber',
              name: 'DatabaseHelper');
          print('⚠️ DB DUPLICATE: Ticket with PNR $pnrNumber already exists');
          throw DuplicateTicketException(
              'Ticket with PNR $pnrNumber already exists');
        }
      } else if (bookingRef != null && bookingRef.isNotEmpty) {
        final existing = await db.query(
          'travel_tickets',
          where: 'booking_reference = ? AND provider_name = ?',
          whereArgs: [bookingRef, providerName],
          limit: 1,
        );
        if (existing.isNotEmpty) {
          developer.log(
              'Duplicate ticket found with booking reference: $bookingRef',
              name: 'DatabaseHelper');
          print(
              '⚠️ DB DUPLICATE: Ticket with booking reference $bookingRef already exists');
          throw DuplicateTicketException(
              'Ticket with booking reference $bookingRef already exists');
        }
      }

      final id = await db.insert('travel_tickets', ticket);
      developer.log('Successfully inserted travel ticket with ID: $id',
          name: 'DatabaseHelper');
      print('✅ DB INSERT: Travel ticket saved with ID: $id');
      return id;
    } catch (e) {
      if (e is DuplicateTicketException) {
        rethrow;
      }
      developer.log('Failed to insert travel ticket',
          name: 'DatabaseHelper', error: e);
      print('🔴 DB INSERT ERROR: Failed to save travel ticket: $e');
      rethrow;
    }
  }

  Future<int> updateTravelTicket(int id, Map<String, Object?> ticket) async {
    final db = await database;
    // Update timestamp
    ticket['updated_at'] = DateTime.now().toIso8601String();
    return db.update(
      'travel_tickets',
      ticket,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTravelTicket(int id) async {
    final db = await database;
    return db.delete(
      'travel_tickets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, Object?>?> getTravelTicketById(int id) async {
    final db = await database;
    final results = await db.query(
      'travel_tickets',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }
}
