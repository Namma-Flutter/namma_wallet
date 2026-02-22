import 'package:fixnum/fixnum.dart';
import 'package:namma_wallet/src/common/database/proto/namma_wallet.pb.dart';
import 'package:namma_wallet/src/common/database/ticket_backup_interface.dart';
import 'package:namma_wallet/src/common/database/wallet_database_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:sqflite/sqflite.dart';

class TicketBackupDao implements ITicketBackupDAO {
  TicketBackupDao({IWalletDatabase? database})
      : _database = database ?? getIt<IWalletDatabase>();

  final IWalletDatabase _database;

  @override
  Future<List<Ticket>> fetchAllTickets() async {
    final db = await _database.database;
    final rows = await db.query('tickets');
    return rows.map(_mapRowToProto).toList();
  }

  @override
  Future<void> restoreTickets(List<Ticket> tickets) async {
    final db = await _database.database;

    await db.transaction((txn) async {
      for (final ticket in tickets) {
        await txn.insert(
          'tickets',
          _protoToDbMap(ticket),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // ---------- MAPPERS ----------

  Ticket _mapRowToProto(Map<String, Object?> row) {
    return Ticket()
      ..id = Int64(row['id']! as int)
      ..ticketId = row['ticket_id'] as String? ?? ''
      ..primaryText = row['primary_text'] as String? ?? ''
      ..secondaryText = row['secondary_text'] as String? ?? ''
      ..type = row['type'] as String? ?? ''
      ..startTime = row['start_time'] as String? ?? ''
      ..endTime = (row['end_time'] ?? '') as String
      ..location = row['location'] as String? ?? ''
      ..tags = row['tags'] as String? ?? ''
      ..extras = row['extras'] as String? ?? ''
      ..createdAt = row['created_at'] as String? ?? ''
      ..updatedAt = row['updated_at'] as String? ?? '';
  }

  Map<String, Object?> _protoToDbMap(Ticket ticket) {
    return {
      'ticket_id': ticket.ticketId,
      'primary_text': ticket.primaryText,
      'secondary_text': ticket.secondaryText,
      'type': ticket.type,
      'start_time': ticket.startTime,
      'end_time': ticket.endTime.isEmpty ? null : ticket.endTime,
      'location': ticket.location,
      'tags': ticket.tags.isEmpty ? null : ticket.tags,
      'extras': ticket.extras.isEmpty ? null : ticket.extras,
      'created_at': ticket.createdAt,
      'updated_at': ticket.updatedAt.isEmpty ? null : ticket.updatedAt,
    };
  }
}
