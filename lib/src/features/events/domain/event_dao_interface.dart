import 'package:namma_wallet/src/features/events/domain/event_model.dart';

/// Abstract interface for Event Data Access Object
abstract interface class IEventDAO {
  /// Insert an event into the database
  Future<int> insertEvent(Event event);

  /// Get Event by ID
  Future<Event?> getEventById(int id);

  /// Get all events
  Future<List<Event>> getAllEvents();

  /// Update by Event Id
  Future<int> updateEventById(int id, Event event);

  /// Delete an event
  Future<int> deleteEvent(int id);

  /// Get events by date
  Future<List<Event>> getEventsByDate(DateTime date);

  /// Get events by date range
  Future<List<Event>> getEventsByDateRange(DateTime start, DateTime end);
}
