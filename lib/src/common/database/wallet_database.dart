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
  static const int _dbVersion = 3;

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
          await db.execute(
            'ALTER TABLE tickets ADD COLUMN image_path TEXT;',
          );
          _logger.success('Database migrated to v2: Added image_path');
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE tickets ADD COLUMN directions_url TEXT;',
          );
          _logger.success('Database migrated to v3: Added directions_url');
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
         start_time TEXT NOT NULL,
         end_time TEXT,
         location TEXT NOT NULL,
         tags TEXT,
         extras TEXT,
         image_path TEXT,
         directions_url TEXT,
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
