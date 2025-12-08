import 'dart:convert';

import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/database/wallet_database_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:sqflite/sqflite.dart';

class TicketDao implements ITicketDAO {
  TicketDao({IWalletDatabase? database, ILogger? logger})
    : _database = database ?? getIt<IWalletDatabase>(),
      _logger = logger ?? getIt<ILogger>();

  final IWalletDatabase _database;
  final ILogger _logger;

  /// Masks PNR for safe logging by showing only the last 3 characters
  String _maskTicketId(String ticketId) {
    if (ticketId.length <= 3) return ticketId;
    final maskLength = ticketId.length - 3;
    final lastThree = ticketId.substring(ticketId.length - 3);
    return '${'*' * maskLength}$lastThree';
  }

  /// --------------------------------------------------------------------------
  /// MAIN LOGIC: HANDLE INCOMING SMS
  /// --------------------------------------------------------------------------

  @override
  Future<int> handleTicket(Ticket ticket) async {
    final pnr = ticket.ticketId;

    // 1. Guard Clause: We cannot merge/save if there is no Unique ID (PNR)
    if (pnr == null || pnr.isEmpty) {
      _logger.warning(
        '⚠️ Parse Error: Incoming ticket has no ID. Cannot save.',
      );
      return -1; // Return error code
    }

    try {
      // 2. Fetch Existing: Check if we already have a ticket with this PNR
      final existingTicket = await getTicketById(pnr);

      if (existingTicket == null) {
        // CASE A: New Ticket
        _logger.logDatabase(
          'Insert',
          'New Ticket Detected: ${_maskTicketId(pnr)}',
        );
        return await insertTicket(ticket);
      } else {
        // CASE B: Update (Partial Data)
        _logger.logDatabase(
          'Update',
          'Existing Ticket Detected. Merging: ${_maskTicketId(pnr)}',
        );

        // Use the Factory method to merge data safely
        final mergedTicket = Ticket.mergeTickets(existingTicket, ticket);

        // Update the database with the fully combined object
        return await updateTicketById(pnr, mergedTicket);
      }
    } on Exception catch (e, stackTrace) {
      _logger.error(
        'Failed to handle incoming ticket: ${_maskTicketId(pnr)}',
        e,
        stackTrace,
      );
      return -1;
    }
  }

  /// --------------------------------------------------------------------------
  /// CRUD OPERATIONS
  /// --------------------------------------------------------------------------

  /// Insert a ticket into the database (Pure Insert)
  @override
  Future<int> insertTicket(Ticket ticket) async {
    try {
      _logger.logDatabase('Insert', 'Inserting ticket: ${ticket.primaryText}');

      final db = await _database.database;

      // Convert to Map and handle JSON encoding
      final map = ticket.toEntity();

      // Clean up fields meant for complex objects
      map.remove('tags');
      map.remove('extras');

      if (ticket.tags != null && ticket.tags!.isNotEmpty) {
        map['tags'] = jsonEncode(ticket.tags!.map((e) => e.toMap()).toList());
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
        _logger.warning('Insert operation completed but no row ID returned.');
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

  /// Update Ticket by ID
  @override
  Future<int> updateTicketById(String ticketId, Ticket ticket) async {
    try {
      _logger.logDatabase(
        'Update',
        'Updating ticket with ID: ${_maskTicketId(ticketId)}',
      );

      final db = await _database.database;

      // Prepare updates map from the Ticket object
      final updates = ticket.toEntity();

      // Remove fields we don't strictly want to overwrite blindly if they are null in the object
      // (Though since we passed a 'merged' ticket, these should be correct).
      updates.remove('id'); // Never update the primary key ID
      updates.remove('created_at'); // Never update creation time

      updates['updated_at'] = DateTime.now().toIso8601String();

      // Handle JSON fields
      updates.remove('tags');
      updates.remove('extras');

      if (ticket.tags != null) {
        updates['tags'] = jsonEncode(
          ticket.tags!.map((e) => e.toMap()).toList(),
        );
      }

      if (ticket.extras != null) {
        updates['extras'] = jsonEncode(
          ticket.extras!.map((e) => e.toMap()).toList(),
        );
      }

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
        _logger.warning('No ticket found with ID: ${_maskTicketId(ticketId)}');
      }

      return count;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update ticket with ID: ${_maskTicketId(ticketId)}',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Get Ticket by ID
  @override
  Future<Ticket?> getTicketById(String id) async {
    try {
      _logger.logDatabase(
        'Query',
        'Fetching ticket with ID: ${_maskTicketId(id)}',
      );

      final db = await _database.database;
      final result = await db.query(
        'tickets',
        where: 'ticket_id = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) {
        _logger.warning('No ticket found with ID: $id');
        return null;
      }

      final map = result.first;
      return _mapToTicket(map);
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
  @override
  Future<List<Ticket>> getAllTickets() async {
    try {
      _logger.logDatabase('Query', 'Fetching all tickets');

      final db = await _database.database;
      final result = await db.query('tickets', orderBy: 'start_time DESC');

      if (result.isEmpty) {
        _logger.warning('No tickets found in database');
        return [];
      }

      return result.map((map) => _mapToTicket(map)).toList();
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch all tickets from database', e, stackTrace);
      rethrow;
    }
  }

  /// Get ticket by type
  @override
  Future<List<Ticket>> getTicketsByType(String type) async {
    try {
      _logger.logDatabase('Query', 'Fetching tickets of type: $type');

      final db = await _database.database;
      final result = await db.query(
        'tickets',
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'start_time DESC',
      );

      if (result.isEmpty) {
        return [];
      }

      return result.map((map) => _mapToTicket(map)).toList();
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch tickets of type: $type', e, stackTrace);
      rethrow;
    }
  }

  /// Delete a ticket
  @override
  Future<int> deleteTicket(String id) async {
    try {
      _logger.logDatabase(
        'Delete',
        'Deleting ticket with ID: ${_maskTicketId(id)}',
      );

      final db = await _database.database;

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

  /// Helper to convert DB Map to Ticket Object
  Ticket _mapToTicket(Map<String, Object?> map) {
    final decodedMap = {
      ...map,
      'tags': map['tags'] == null || (map['tags'] as String).isEmpty
          ? null
          : (jsonDecode(map['tags'] as String) as List)
                .cast<Map<String, dynamic>>(),
      'extras': map['extras'] == null || (map['extras'] as String).isEmpty
          ? null
          : (jsonDecode(map['extras'] as String) as List)
                .cast<Map<String, dynamic>>(),
    };

    return TicketMapper.fromMap(decodedMap);
  }
}
