import 'dart:async';
import 'dart:convert';

import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DuplicateTicketException implements Exception {
  const DuplicateTicketException(this.message);

  final String message;

  @override
  String toString() => 'DuplicateTicketException: $message';
}

class WalletDatabase {
  WalletDatabase({ILogger? logger}) : _logger = logger ?? getIt<ILogger>();
  final ILogger _logger;

  static const String _dbName = 'namma_wallet.db';
  static const int _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;
    _database = await _initDatabase();
    return _database!;
  }

  /// Masks PNR for safe logging by showing only the last 3 characters
  String _maskTicketId(String ticketId) {
    if (ticketId.length <= 3) return ticketId;
    return '''${'*' * (ticketId.length - 3)}${ticketId.substring(ticketId.length - 3)}''';
  }

  /// Masks booking reference for safe logging by showing
  ///  only the last 3 characters
  // ignore: unused_element
  String _maskBookingRef(String bookingRef) {
    if (bookingRef.length <= 3) return bookingRef;
    return '''${'*' * (bookingRef.length - 3)}${bookingRef.substring(bookingRef.length - 3)}''';
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

    await _createTicketTable(db);
  }

  // Queries
  Future<List<Map<String, Object?>>> fetchAllUsers() async {
    final db = await database;
    return db.query('users', orderBy: 'user_id DESC');
  }

  /// Generic Model UseCase

  /// function [_createTicketTable] will helps to create
  /// table generic_model in the database
  Future<void> _createTicketTable(Database db) async {
    const query = '''
      CREATE TABLE tickets (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         ticket_id TEXT NOT NULL,
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

  Future<int> insertTicket(Ticket ticket) async {
    try {
      _logger.logDatabase('Insert', 'Inserting ticket: ${ticket.primaryText}');

      // Check if ticket with same PNR already exists
      if (ticket.ticketId != null && ticket.ticketId!.isNotEmpty) {
        final existing = await getTicketById(ticket.ticketId!);

        if (existing != null) {
          _logger.logDatabase(
            'Update',
            'Ticket with PNR ${_maskTicketId(ticket.ticketId!)} already exists, updating instead',
          );

          // Prepare updates map with new data
          final updates = <String, Object?>{};

          // Update basic fields if they have meaningful values
          if (ticket.primaryText.isNotEmpty &&
              ticket.primaryText != 'Unknown → Unknown') {
            updates['primary_text'] = ticket.primaryText;
          }
          if (ticket.secondaryText.isNotEmpty) {
            updates['secondary_text'] = ticket.secondaryText;
          }
          if (ticket.location.isNotEmpty && ticket.location != 'Unknown') {
            updates['location'] = ticket.location;
          }

          // Merge tags
          if (ticket.tags != null && ticket.tags!.isNotEmpty) {
            updates['tags'] = jsonEncode(
              ticket.tags!.map((e) => e.toMap()).toList(),
            );
          }

          // Merge extras
          if (ticket.extras != null && ticket.extras!.isNotEmpty) {
            updates['extras'] = jsonEncode(
              ticket.extras!.map((e) => e.toMap()).toList(),
            );
          }

          // Update the existing ticket
          await updateTicketById(ticket.ticketId!, updates);

          // Return the existing ticket's database ID
          final db = await database;
          final result = await db.query(
            'tickets',
            columns: ['id'],
            where: 'ticket_id = ?',
            whereArgs: [ticket.ticketId],
            limit: 1,
          );

          if (result.isNotEmpty) {
            final id = result.first['id'] as int;
            _logger.logDatabase(
              'Success',
              'Updated existing ticket with database ID: $id',
            );
            return id;
          }
        }
      }

      // No existing ticket found, insert as new
      final db = await database;

      final map = ticket.toEntity()
        ..remove('tags')
        ..remove('extras');

      if (ticket.tags != null && ticket.tags!.isNotEmpty) {
        map['tags'] = jsonEncode(
          ticket.tags!.map((e) => e.toMap()).toList(),
        );
      }

      if (ticket.extras != null && ticket.extras!.isNotEmpty) {
        map['extras'] = jsonEncode(
          ticket.extras!.map((e) => e.toMap()).toList(),
        );
      }

      map['created_at'] = DateTime.now().toIso8601String();
      map['updated_at'] = DateTime.now().toIso8601String();

      final id = await db.insert(
        'tickets',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (id > 0) {
        _logger.logDatabase('Success', 'Inserted ticket with ID: $id');
      } else {
        _logger.warning(
          'Insert operation completed but no row ID returned for ticket:'
          '${ticket.primaryText}',
        );
      }

      return id;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to insert ticket: ${ticket.primaryText}',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Get Ticket by ID
  Future<Ticket?> getTicketById(String id) async {
    try {
      _logger.logDatabase(
        'Query',
        'Fetching ticket with ID: ${_maskTicketId(id)}',
      );

      final db = await database;
      final result = await db.query(
        'tickets',
        where: 'ticket_id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) {
        _logger.warning('No ticket found with ID: $id');
        return null;
      }

      _logger.logDatabase(
        'Success',
        'Fetched ticket with ID: ${_maskTicketId(id)}',
      );

      final map = result.first;

      // Decode JSON fields back to List<Map<String, dynamic>>
      final decodedMap = {
        ...map,
        'tags': map['tags'] == null || (map['tags']! as String).isEmpty
            ? null
            : (jsonDecode(map['tags']! as String) as List)
                  .cast<Map<String, dynamic>>(),
        'extras': map['extras'] == null || (map['extras']! as String).isEmpty
            ? null
            : (jsonDecode(map['extras']! as String) as List)
                  .cast<Map<String, dynamic>>(),
      };

      return TicketMapper.fromMap(decodedMap);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch ticket with ID: ${_maskTicketId(id)}',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Get all tickets
  Future<List<Ticket>> getAllTickets() async {
    try {
      _logger.logDatabase('Query', 'Fetching all tickets');

      final db = await database;
      final result = await db.query('tickets', orderBy: 'start_time DESC');

      if (result.isEmpty) {
        _logger.warning('No tickets found in database');
        return [];
      }

      _logger.logDatabase(
        'Success',
        'Fetched ${result.length} tickets from database',
      );

      final tickets = result.map((map) {
        final decodedMap = {
          ...map,
          'tags': map['tags'] == null || (map['tags']! as String).isEmpty
              ? null
              : (jsonDecode(map['tags']! as String) as List)
                    .cast<Map<String, dynamic>>(),
          'extras': map['extras'] == null || (map['extras']! as String).isEmpty
              ? null
              : (jsonDecode(map['extras']! as String) as List)
                    .cast<Map<String, dynamic>>(),
        };

        return TicketMapper.fromMap(decodedMap);
      }).toList();

      return tickets;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch all tickets from database',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Get ticket by type
  Future<List<Ticket>> getTicketsByType(String type) async {
    try {
      _logger.logDatabase('Query', 'Fetching tickets of type: $type');

      final db = await database;
      final result = await db.query(
        'tickets',
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'start_time DESC',
      );

      if (result.isEmpty) {
        _logger.warning('No tickets found for type: $type');
        return [];
      }

      _logger.logDatabase(
        'Success',
        'Fetched ${result.length} tickets of type: $type',
      );

      final tickets = result.map((map) {
        final decodedMap = {
          ...map,
          'tags': map['tags'] == null || (map['tags']! as String).isEmpty
              ? null
              : (jsonDecode(map['tags']! as String) as List)
                    .cast<Map<String, dynamic>>(),
          'extras': map['extras'] == null || (map['extras']! as String).isEmpty
              ? null
              : (jsonDecode(map['extras']! as String) as List)
                    .cast<Map<String, dynamic>>(),
        };
        return TicketMapper.fromMap(decodedMap);
      }).toList();

      return tickets;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch tickets of type: $type',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Update by Ticket Id
  Future<int> updateTicketById(
    String ticketId,
    Map<String, Object?> updates,
  ) async {
    try {
      _logger.logDatabase(
        'Update',
        'Updating ticket with ID: ${_maskTicketId(ticketId)}',
      );

      final db = await database;

      // Step 1: If updating extras or tags, merge them with existing
      if (updates.containsKey('extras') || updates.containsKey('tags')) {
        final existingResult = await db.query(
          'tickets',
          where: 'ticket_id = ?',
          whereArgs: [ticketId],
          limit: 1,
        );

        if (existingResult.isNotEmpty) {
          final existing = existingResult.first;

          // --- Merge extras ---
          if (updates.containsKey('extras')) {
            final existingExtras =
                existing['extras'] != null &&
                    (existing['extras']! as String).isNotEmpty
                ? (jsonDecode(existing['extras']! as String) as List)
                      .cast<Map<String, dynamic>>()
                : <Map<String, dynamic>>[];

            final newExtras = (jsonDecode(updates['extras']! as String) as List)
                .cast<Map<String, dynamic>>();

            // Merge based on unique "title" keys (replace if same title)
            final mergedExtras = {
              ...{
                for (final e in existingExtras) e['title']: e,
              },
            };

            for (final newE in newExtras) {
              mergedExtras[newE['title']] = newE;
            }

            updates['extras'] = jsonEncode(mergedExtras.values.toList());
          }

          // --- Merge tags (if needed) ---
          if (updates.containsKey('tags')) {
            final existingTags =
                existing['tags'] != null &&
                    (existing['tags']! as String).isNotEmpty
                ? (jsonDecode(existing['tags']! as String) as List)
                      .cast<Map<String, dynamic>>()
                : <Map<String, dynamic>>[];

            final newTags = (jsonDecode(updates['tags']! as String) as List)
                .cast<Map<String, dynamic>>();

            final mergedTags = {
              ...{
                for (final t in existingTags) t['value']: t,
              },
            };

            for (final newT in newTags) {
              mergedTags[newT['value']] = newT;
            }

            updates['tags'] = jsonEncode(mergedTags.values.toList());
          }
        }
      }

      // Step 2: Update timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      // Step 3: Run update
      final count = await db.update(
        'tickets',
        updates,
        where: 'ticket_id = ?',
        whereArgs: [ticketId],
      );

      if (count > 0) {
        _logger.logDatabase(
          'Success',
          'Updated ticket with ID: ${_maskTicketId(ticketId)}',
        );
      } else {
        _logger.warning(
          'No ticket found with ID: ${_maskTicketId(ticketId)}',
        );
      }

      return count;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update ticket with ID: '
        '${_maskTicketId(ticketId)}',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Delete a ticket
  Future<int> deleteTicket(String id) async {
    try {
      _logger.logDatabase(
        'Delete',
        'Deleting ticket with ID: ${_maskTicketId(id)}',
      );

      final db = await database;

      final count = await db.delete(
        'tickets',
        where: 'ticket_id = ?',
        whereArgs: [id],
      );

      if (count > 0) {
        _logger.logDatabase(
          'Success',
          'Deleted ticket with ID: ${_maskTicketId(id)}',
        );
      } else {
        _logger.warning(
          'No ticket found to delete with ID: ${_maskTicketId(id)}',
        );
      }

      return count;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete ticket with ID: ${_maskTicketId(id)}',
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
