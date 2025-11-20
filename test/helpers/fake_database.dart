import 'package:namma_wallet/src/common/database/i_wallet_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FakeDatabase implements IWalletDatabase {
  FakeDatabase({this.forceException = false});

  static Database? _database;
  final bool forceException;

  Future<Database> initDatabase() async {
    if (forceException) {
      throw Exception('Forced database exception');
    }

    return openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create users table
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

        // Create tickets table
        await db.execute('''
          CREATE TABLE tickets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ticket_id TEXT NOT NULL UNIQUE,
            primary_text TEXT NOT NULL,
            secondary_text TEXT NOT NULL,
            type TEXT NOT NULL,
            start_time TEXT NOT NULL,
            end_time TEXT,
            location TEXT NOT NULL,
            tags TEXT,
            extras TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT DEFAULT NULL
          );
        ''');

        // Create indices
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_tickets_id ON tickets (id);',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_tickets_type ON tickets (type);',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_tickets_start_time ON tickets '
          '(start_time);',
        );
      },
    );
  }

  @override
  Future<Database> get database async {
    if (forceException) {
      throw Exception('Forced database access exception');
    }
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  @override
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  /// Reset the database instance for testing isolation
  static void reset() {
    _database = null;
  }
}
