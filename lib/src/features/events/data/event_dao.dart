import 'package:namma_wallet/src/common/database/wallet_database_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/events/domain/event_dao_interface.dart';
import 'package:namma_wallet/src/features/events/domain/event_model.dart';

class EventDao implements IEventDAO {
  EventDao({
    IWalletDatabase? database,
    ILogger? logger,
  }) : _db = database ?? getIt<IWalletDatabase>(),
       _logger = logger ?? getIt<ILogger>();

  final IWalletDatabase _db;
  final ILogger _logger;

  static const String _tableName = 'events';

  Map<String, dynamic> _toMap(Event event) {
    return {
      if (event.id != null) 'id': event.id,
      'icon_name': event.iconName,
      'title': event.title,
      'subtitle': event.subtitle,
      'date': event.date.toIso8601String(),
      'price': event.price,
    };
  }

  Event _fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as int?,
      iconName: map['icon_name'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      date: DateTime.parse(map['date'] as String),
      price: map['price'] as String,
    );
  }

  @override
  Future<int> insertEvent(Event event) async {
    try {
      final db = await _db.database;
      final id = await db.insert(_tableName, _toMap(event));
      _logger.logDatabase('Insert', 'Inserted event with ID: $id');
      return id;
    } catch (e, stackTrace) {
      _logger.error('Error inserting event: $e\n$stackTrace');
      rethrow;
    }
  }

  @override
  Future<Event?> getEventById(int id) async {
    try {
      final db = await _db.database;
      final maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return _fromMap(maps.first);
    } catch (e, stackTrace) {
      _logger.error('Error getting event by id: $e\n$stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<Event>> getAllEvents() async {
    try {
      final db = await _db.database;
      final maps = await db.query(_tableName);
      return maps.map(_fromMap).toList();
    } catch (e, stackTrace) {
      _logger.error('Error getting all events: $e\n$stackTrace');
      rethrow;
    }
  }

  @override
  Future<int> updateEventById(int id, Event event) async {
    try {
      final db = await _db.database;
      final count = await db.update(
        _tableName,
        _toMap(event),
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.logDatabase('Update', 'Updated event with ID: $id');
      return count;
    } catch (e, stackTrace) {
      _logger.error('Error updating event: $e\n$stackTrace');
      rethrow;
    }
  }

  @override
  Future<int> deleteEvent(int id) async {
    try {
      final db = await _db.database;
      final count = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      _logger.logDatabase('Delete', 'Deleted event with ID: $id');
      return count;
    } catch (e, stackTrace) {
      _logger.error('Error deleting event: $e\n$stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<Event>> getEventsByDate(DateTime date) async {
    try {
      final db = await _db.database;

      // Compare the date part only (assuming YYYY-MM-DD format prefix in ISO)
      final y = date.year.toString().padLeft(4, '0');
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString().padLeft(2, '0');
      final dateStr = '$y-$m-$d';

      final maps = await db.query(
        _tableName,
        where: 'date LIKE ?',
        whereArgs: ['$dateStr%'],
      );

      return maps.map(_fromMap).toList();
    } catch (e, stackTrace) {
      _logger.error('Error getting events by date: $e\n$stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<Event>> getEventsByDateRange(DateTime start, DateTime end) async {
    try {
      final db = await _db.database;

      final startStr = start.toIso8601String();
      final endStr = end.toIso8601String();

      final maps = await db.query(
        _tableName,
        where: 'date >= ? AND date <= ?',
        whereArgs: [startStr, endStr],
      );

      return maps.map(_fromMap).toList();
    } catch (e, stackTrace) {
      _logger.error('Error getting events by date range: $e\n$stackTrace');
      rethrow;
    }
  }
}
