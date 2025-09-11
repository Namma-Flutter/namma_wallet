import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'namma_wallet.db';
  static const int _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    final Database? existing = _database;
    if (existing != null) return existing;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (Database db, int version) async {
        await _createSchema(db);
        await _seedDummyData(db);
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

    // tickets table
    await db.execute('''
CREATE TABLE tickets (
  ticket_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  ticket_type TEXT NOT NULL CHECK(ticket_type IN ('BUS','TRAIN','EVENT')),
  provider TEXT NOT NULL,
  booking_ref TEXT,
  passenger_name TEXT,
  source TEXT,
  destination TEXT,
  event_name TEXT,
  seat_number TEXT,
  coach_or_bus TEXT,
  journey_date TEXT,
  booking_date TEXT,
  amount REAL,
  status TEXT DEFAULT 'CONFIRMED' CHECK(status IN ('CONFIRMED','CANCELLED','PENDING')),
  created_at TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
''');
  }

  Future<void> _seedDummyData(Database db) async {
    // Insert a demo user
    final int userId = await db.insert('users', <String, Object?>{
      'full_name': 'Test User',
      'email': 'test@example.com',
      'phone': '+911234567890',
      'password_hash': 'hashed_password',
    });

    // Insert some demo tickets (BUS, TRAIN, EVENT)
    final List<Map<String, Object?>> tickets = <Map<String, Object?>>[
      {
        'user_id': userId,
        'ticket_type': 'BUS',
        'provider': 'SETC',
        'booking_ref': 'BUS123456',
        'passenger_name': 'Test User',
        'source': 'Chennai',
        'destination': 'Coimbatore',
        'seat_number': '12A',
        'coach_or_bus': 'Volvo AC',
        'journey_date': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'booking_date': DateTime.now().toIso8601String(),
        'amount': 599.00,
        'status': 'CONFIRMED',
      },
      {
        'user_id': userId,
        'ticket_type': 'TRAIN',
        'provider': 'IRCTC',
        'booking_ref': 'PNR9876543',
        'passenger_name': 'Test User',
        'source': 'Bangalore',
        'destination': 'Chennai',
        'seat_number': 'S2-34',
        'coach_or_bus': 'S2',
        'journey_date': DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        'booking_date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'amount': 450.50,
        'status': 'CONFIRMED',
      },
      {
        'user_id': userId,
        'ticket_type': 'EVENT',
        'provider': 'BookMyShow',
        'booking_ref': 'BMS-2025-ABCD',
        'passenger_name': 'Test User',
        'event_name': 'Music Fest 2025',
        'source': 'Chennai Trade Centre',
        'destination': 'Chennai Trade Centre',
        'seat_number': 'A-10',
        'coach_or_bus': 'Hall 1',
        'journey_date': DateTime.now().add(const Duration(days: 20)).toIso8601String(),
        'booking_date': DateTime.now().toIso8601String(),
        'amount': 999.99,
        'status': 'PENDING',
      },
    ];

    for (final Map<String, Object?> ticket in tickets) {
      await db.insert('tickets', ticket);
    }
  }

  // Queries
  Future<List<Map<String, Object?>>> fetchAllUsers() async {
    final Database db = await database;
    return db.query('users', orderBy: 'user_id DESC');
  }

  Future<List<Map<String, Object?>>> fetchAllTickets() async {
    final Database db = await database;
    return db.query('tickets', orderBy: 'ticket_id DESC');
  }

  Future<List<Map<String, Object?>>> fetchTicketsWithUser() async {
    final Database db = await database;
    return db.rawQuery('''
SELECT t.*, u.full_name AS user_full_name, u.email AS user_email
FROM tickets t
JOIN users u ON u.user_id = t.user_id
ORDER BY t.ticket_id DESC
''');
  }
}


