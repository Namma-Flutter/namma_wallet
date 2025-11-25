import 'dart:async';

import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/events/domain/event_model.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarProvider extends ChangeNotifier {
  CalendarProvider({
    ILogger? logger,
    ITicketDAO? ticketDao,
    DateTime? initialSelectedDay,
  }) : _logger = logger ?? getIt<ILogger>(),
       _ticketDao = ticketDao ?? getIt<ITicketDAO>(),
       _selectedDay = initialSelectedDay ?? _todayAtMidnight();

  static DateTime _todayAtMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _normalizeToDateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  final ILogger _logger;
  final ITicketDAO _ticketDao;

  DateTime _selectedDay;
  List<Event> _events = [];
  List<Ticket> _tickets = [];
  DateTimeRange? _selectedRange;
  String? _errorMessage;

  DateTime get selectedDay => _selectedDay;
  List<Event> get events => _events;
  List<Ticket> get tickets => _tickets;
  DateTimeRange? get selectedRange => _selectedRange;
  String? get errorMessage => _errorMessage;

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

  // TODO(harish): Wire to IEventDAO when events feature is implemented
  Future<void> loadEvents() async {
    // Initialize empty events list (no mocked data)
    _events = [];

    // Load tickets from database
    await loadTickets();
  }

  Future<void> loadTickets() async {
    _errorMessage = null; // Clear any previous error
    try {
      _tickets = await _ticketDao.getAllTickets();
      notifyListeners();
    } on Exception catch (e, st) {
      _logger.error('Error loading tickets: $e\n$st');
      _errorMessage = 'Failed to load tickets: $e';
      notifyListeners();
    }
  }

  List<Event> getEventsForDay(DateTime day) {
    return _events.where((event) => isSameDay(event.date, day)).toList();
  }

  List<Ticket> getTicketsForDay(DateTime day) {
    return _tickets.where((ticket) {
      final startTime = ticket.startTime;
      return startTime != null && isSameDay(startTime, day);
    }).toList();
  }

  List<DateTime> getDatesWithTickets() {
    final dates = <DateTime>[];
    final seen = <DateTime>{};

    for (final ticket in _tickets) {
      if (ticket.startTime == null) continue;
      final dateOnly = _normalizeToDateOnly(ticket.startTime!);

      if (seen.add(dateOnly)) {
        dates.add(dateOnly);
      }
    }

    return dates;
  }

  bool hasTicketsOnDay(DateTime day) {
    return getTicketsForDay(day).isNotEmpty;
  }

  List<Ticket> getTicketsForRange(DateTimeRange range) {
    return _tickets.where((ticket) {
      if (ticket.startTime == null) return false;
      final ticketDate = _normalizeToDateOnly(ticket.startTime!);
      final rangeStart = _normalizeToDateOnly(range.start);
      final rangeEnd = _normalizeToDateOnly(range.end);
      return ticketDate.compareTo(rangeStart) >= 0 &&
          ticketDate.compareTo(rangeEnd) <= 0;
    }).toList();
  }

  List<Event> getEventsForRange(DateTimeRange range) {
    return _events.where((event) {
      final eventDate = _normalizeToDateOnly(event.date);
      final rangeStart = _normalizeToDateOnly(range.start);
      final rangeEnd = _normalizeToDateOnly(range.end);
      return eventDate.compareTo(rangeStart) >= 0 &&
          eventDate.compareTo(rangeEnd) <= 0;
    }).toList();
  }
}
