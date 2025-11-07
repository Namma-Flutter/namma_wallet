import 'dart:async';

import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DuplicateTicketException implements Exception {
  const DuplicateTicketException(this.message);
  final String message;

  @override
  String toString() => 'DuplicateTicketException: $message';
}

class WalletDatabase {
  final ILogger _logger;

  WalletDatabase({ILogger? logger})
      : _logger = logger ?? getIt<ILogger>();

  final String _dbName = 'namma_wallet.db';
  final int _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    _logger.info('Initializing database...');
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    _logger.logDatabase('Init', 'Database path: $path');

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (Database db, int version) async {
        _logger.logDatabase('Create', 'Creating database schema v$version');
        await _createSchema(db);
        _logger.success('Database schema created successfully');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        _logger.logDatabase(
          'Upgrade',
          'Upgrading from v$oldVersion to v$newVersion',
        );
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
  contact_mobile TEXT, -- Contact number for conductor/operator

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

  // Queries
  Future<List<Map<String, Object?>>> fetchAllUsers() async {
    final db = await database;
    return db.query('users', orderBy: 'user_id DESC');
  }

  Future<List<Map<String, Object?>>> fetchAllTravelTickets() async {
    try {
      _logger.logDatabase('Query', 'Fetching all travel tickets');
      final db = await database;
      final tickets = await db.query(
        'travel_tickets',
        orderBy: 'created_at DESC',
      );
      _logger.logDatabase(
        'Success',
        'Fetched ${tickets.length} travel tickets',
      );
      return tickets;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch travel tickets',
        e,
        stackTrace,
      );
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
    String ticketType,
  ) async {
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
      _logger.logDatabase('Insert', 'Inserting travel ticket');
      final db = await database;
      // Ensure user_id is set to 1 (single user app)
      ticket['user_id'] = 1;
      ticket['created_at'] = DateTime.now().toIso8601String();
      ticket['updated_at'] = DateTime.now().toIso8601String();

      // Check for duplicates based on PNR number or booking reference
      final pnrNumber = ticket['pnr_number'] as String?;
      final bookingRef = ticket['booking_reference'] as String?;

      if (pnrNumber != null && pnrNumber.isNotEmpty) {
        final existing = await db.query(
          'travel_tickets',
          where: 'pnr_number = ?',
          whereArgs: [pnrNumber],
          limit: 1,
        );
        if (existing.isNotEmpty) {
          _logger.warning('Duplicate ticket found with PNR: $pnrNumber');
          throw DuplicateTicketException(
            'Ticket with PNR $pnrNumber already exists',
          );
        }
      } else if (bookingRef != null && bookingRef.isNotEmpty) {
        final existing = await db.query(
          'travel_tickets',
          where: 'booking_reference = ?',
          whereArgs: [bookingRef],
          limit: 1,
        );
        if (existing.isNotEmpty) {
          _logger.warning(
            'Duplicate ticket found with booking reference: $bookingRef',
          );
          throw DuplicateTicketException(
            'Ticket with booking reference $bookingRef already exists',
          );
        }
      }

      final id = await db.insert('travel_tickets', ticket);
      _logger.logDatabase('Success', 'Inserted travel ticket with ID: $id');
      return id;
    } catch (e, stackTrace) {
      if (e is DuplicateTicketException) {
        rethrow;
      }
      _logger.error(
        'Failed to insert travel ticket',
        e,
        stackTrace,
      );
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

  Future<Map<String, Object?>?> getTravelTicketByPNR(String pnrNumber) async {
    final db = await database;
    final results = await db.query(
      'travel_tickets',
      where: 'pnr_number = ?',
      whereArgs: [pnrNumber],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateTravelTicketByPNR(
    String pnrNumber,
    Map<String, Object?> updates,
  ) async {
    try {
      _logger.logDatabase('Update', 'Updating ticket with PNR: $pnrNumber');
      final db = await database;
      updates['updated_at'] = DateTime.now().toIso8601String();

      final count = await db.update(
        'travel_tickets',
        updates,
        where: 'pnr_number = ?',
        whereArgs: [pnrNumber],
      );

      if (count > 0) {
        _logger.logDatabase(
          'Success',
          'Updated ticket with PNR: $pnrNumber',
        );
      } else {
        _logger.warning('No ticket found with PNR: $pnrNumber');
      }

      return count;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update ticket by PNR: $pnrNumber',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
