import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:namma_wallet/src/common/database/platform/platform_db.dart';
import 'package:namma_wallet/src/common/database/wallet_database_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class WalletDatabase implements IWalletDatabase {
  WalletDatabase({ILogger? logger}) : _logger = logger ?? getIt<ILogger>();
  final ILogger _logger;

  static const String _dbName = 'namma_wallet.db';
  static const int _dbVersion = 2;

  Database? _database;

  @override
  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    _logger.info('Initializing database...');
    await initDatabaseFactory();

    String path;
    if (kIsWeb) {
      path = _dbName;
    } else {
      final dbPath = await getDatabasesPath();
      path = p.join(dbPath, _dbName);
    }
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
        if (oldVersion < 2) {
          // Robust migration for v2: Adding 'journey_date' and relaxing 'start_time' NOT NULL
          // SQLite requires a table rebuild for changing column constraints.

          _logger.logDatabase('Upgrade', 'Rebuilding tickets table...');

          // 1. Create the new table with updated schema
          await db.execute('''
            CREATE TABLE tickets_new (
               id INTEGER PRIMARY KEY AUTOINCREMENT,
               ticket_id TEXT NOT NULL UNIQUE,
               primary_text TEXT NOT NULL,
               secondary_text TEXT NOT NULL,
               type TEXT NOT NULL,
               start_time TEXT DEFAULT NULL,
               end_time TEXT DEFAULT NULL,
               location TEXT NOT NULL,
               tags TEXT,
               extras TEXT,
               journey_date TEXT DEFAULT NULL,
               created_at TEXT DEFAULT CURRENT_TIMESTAMP,
               updated_at TEXT DEFAULT NULL
            );
          ''');

          // 2. Copy data from old table to new table
          // Note: journey_date is new, so it will be NULL for existing records.
          await db.execute('''
            INSERT INTO tickets_new (
              id, ticket_id, primary_text, secondary_text, type, 
              start_time, end_time, location, tags, extras, created_at, updated_at
            )
            SELECT 
              id, ticket_id, primary_text, secondary_text, type, 
              start_time, end_time, location, tags, extras, created_at, updated_at
            FROM tickets;
          ''');

          // 3. Drop the old table
          await db.execute('DROP TABLE tickets;');

          // 4. Rename the new table to 'tickets'
          await db.execute('ALTER TABLE tickets_new RENAME TO tickets;');

          // 5. Recreate indices
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_tickets_id ON tickets (id);',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_tickets_type ON tickets (type);',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_tickets_start_time ON tickets (start_time);',
          );

          _logger.success('Database migration to v2 completed successfully');
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

    await _createTicketTable(db);
  }

  /// function [_createTicketTable] will helps to create
  /// table generic_model in the database
  Future<void> _createTicketTable(Database db) async {
    const query = '''
      CREATE TABLE tickets (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         ticket_id TEXT NOT NULL UNIQUE,
         primary_text TEXT NOT NULL,
         secondary_text TEXT NOT NULL,
         type TEXT NOT NULL,
         start_time TEXT DEFAULT NULL,
         end_time TEXT DEFAULT NULL,
         location TEXT NOT NULL,
         tags TEXT,
         extras TEXT,
         journey_date TEXT DEFAULT NULL,
         created_at TEXT DEFAULT CURRENT_TIMESTAMP,
         updated_at TEXT DEFAULT NULL
      );
    ''';

    await db.execute(query);

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
  }

  /// Close the database connection
  @override
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      _logger.logDatabase('Close', 'Database connection closed');
    }
  }
}
