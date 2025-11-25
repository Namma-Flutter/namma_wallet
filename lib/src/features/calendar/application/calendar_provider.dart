import 'dart:async';

import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/events/domain/event_model.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarProvider extends ChangeNotifier {
  CalendarProvider({ILogger? logger}) : _logger = logger ?? getIt<ILogger>();
  final ILogger _logger;

  DateTime _selectedDay = DateTime.now();
  List<Event> _events = [];
  List<Ticket> _tickets = [];
  DateTimeRange? _selectedRange;

  DateTime get selectedDay => _selectedDay;
  List<Event> get events => _events;
  List<Ticket> get tickets => _tickets;
  DateTimeRange? get selectedRange => _selectedRange;

  void setSelectedDay(DateTime day) {
    _selectedDay = day;
    _selectedRange = null; // Clear range when selecting a single day
    notifyListeners();
  }

  void setSelectedRange(DateTimeRange? range) {
    _selectedRange = range;
    if (range != null) {
      _selectedDay = range.start; // Set selected day to range start
    }
    notifyListeners();
  }

  Future<void> loadEvents() async {
    // Initialize empty events list (no mocked data)
    _events = [];

    // Load tickets from database
    await loadTickets();
    notifyListeners();
  }

  Future<void> loadTickets() async {
    try {
      final ticketDao = getIt<ITicketDAO>();

      _tickets = await ticketDao.getAllTickets();

      notifyListeners();
    } on Exception catch (e, st) {
      _logger.error('Error loading tickets: $e\n$st');
    }
  }

  List<Event> getEventsForDay(DateTime day) {
    return _events.where((event) => isSameDay(event.date, day)).toList();
  }

  List<Ticket> getTicketsForDay(DateTime day) {
    return _tickets.where((ticket) {
      try {
        return isSameDay(ticket.startTime, day);
      } on FormatException catch (e) {
        _logger.debug(
          'Invalid journeyDate format for ticket filtering: '
          '${ticket.startTime} - $e',
        );
        return false;
      } on Exception catch (e, st) {
        _logger.debug(
          'Error parsing journeyDate for ticket filtering: $e\n$st',
        );
        return false;
      }
    }).toList();
  }

  List<DateTime> getDatesWithTickets() {
    final dates = <DateTime>[];
    for (final ticket in _tickets) {
      try {
        if (!dates.any((d) => isSameDay(d, ticket.startTime))) {
          dates.add(ticket.startTime);
        }
      } on FormatException catch (e) {
        _logger.debug(
          'Invalid journeyDate format for date collection: '
          '${ticket.startTime} - $e',
        );
        // Skip invalid dates
      } on Exception catch (e, st) {
        _logger.debug(
          'Error parsing journeyDate for date collection: $e\n$st',
        );
      }
    }
    return dates;
  }

  bool hasTicketsOnDay(DateTime day) {
    return getTicketsForDay(day).isNotEmpty;
  }

  List<Ticket> getTicketsForRange(DateTimeRange range) {
    return _tickets.where((ticket) {
      try {
        final ticketDate = DateTime(
          ticket.startTime.year,
          ticket.startTime.month,
          ticket.startTime.day,
        );
        final rangeStart = DateTime(
          range.start.year,
          range.start.month,
          range.start.day,
        );
        final rangeEnd = DateTime(
          range.end.year,
          range.end.month,
          range.end.day,
        );
        return ticketDate.compareTo(rangeStart) >= 0 &&
            ticketDate.compareTo(rangeEnd) <= 0;
      } on Exception catch (e, st) {
        _logger.debug(
          'Error parsing journeyDate for range filtering: $e\n$st',
        );
        return false;
      }
    }).toList();
  }

  List<Event> getEventsForRange(DateTimeRange range) {
    return _events.where((event) {
      final eventDate = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      final rangeStart = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
      );
      final rangeEnd = DateTime(
        range.end.year,
        range.end.month,
        range.end.day,
      );
      return eventDate.compareTo(rangeStart) >= 0 &&
          eventDate.compareTo(rangeEnd) <= 0;
    }).toList();
  }
}
