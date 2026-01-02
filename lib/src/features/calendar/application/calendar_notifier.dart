/// Calendar state management with Riverpod code generation.
///
/// Uses @riverpod annotations for automatic provider generation.
/// Dependencies are injected via GetIt.
library;

import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/events/domain/event_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:table_calendar/table_calendar.dart';

part 'calendar_notifier.g.dart';

/// Immutable state class for calendar.
@immutable
class CalendarState {
  const CalendarState({
    required this.selectedDay,
    this.events = const [],
    this.tickets = const [],
    this.selectedRange,
    this.errorMessage,
    this.isLoading = false,
  });

  final DateTime selectedDay;
  final List<Event> events;
  final List<Ticket> tickets;
  final DateTimeRange? selectedRange;
  final String? errorMessage;
  final bool isLoading;

  CalendarState copyWith({
    DateTime? selectedDay,
    List<Event>? events,
    List<Ticket>? tickets,
    DateTimeRange? selectedRange,
    String? errorMessage,
    bool? isLoading,
    bool clearRange = false,
    bool clearError = false,
  }) {
    return CalendarState(
      selectedDay: selectedDay ?? this.selectedDay,
      events: events ?? this.events,
      tickets: tickets ?? this.tickets,
      selectedRange: clearRange ? null : (selectedRange ?? this.selectedRange),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Calendar notifier using Riverpod code generation.
/// Services are injected via GetIt.
@riverpod
class Calendar extends _$Calendar {
  static DateTime _todayAtMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  CalendarState build() {
    return CalendarState(selectedDay: _todayAtMidnight());
  }

  DateTime _normalizeToDateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  void setSelectedDay(DateTime day) {
    state = state.copyWith(selectedDay: day, clearRange: true);
  }

  void setSelectedRange(DateTimeRange? range) {
    if (range != null) {
      state = state.copyWith(selectedRange: range, selectedDay: range.start);
    } else {
      state = state.copyWith(clearRange: true);
    }
  }

  /// Load events and tickets
  Future<void> loadEvents() async {
    state = state.copyWith(events: []);
    await loadTickets();
  }

  Future<void> loadTickets() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Use GetIt for dependency injection
      final ticketDao = getIt<ITicketDAO>();
      final tickets = await ticketDao.getAllTickets();
      state = state.copyWith(tickets: tickets, isLoading: false);
    } on Exception catch (e, st) {
      // Use GetIt for dependency injection
      getIt<ILogger>().error('Error loading tickets: $e\n$st');
      state = state.copyWith(
        errorMessage: 'Failed to load tickets: $e',
        isLoading: false,
      );
    }
  }

  List<Event> getEventsForDay(DateTime day) {
    return state.events.where((event) => isSameDay(event.date, day)).toList();
  }

  List<Ticket> getTicketsForDay(DateTime day) {
    return state.tickets.where((ticket) {
      final startTime = ticket.startTime;
      return startTime != null && isSameDay(startTime, day);
    }).toList();
  }

  List<DateTime> getDatesWithTickets() {
    final dates = <DateTime>[];
    final seen = <DateTime>{};

    for (final ticket in state.tickets) {
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
    return state.tickets.where((ticket) {
      if (ticket.startTime == null) return false;
      final ticketDate = _normalizeToDateOnly(ticket.startTime!);
      final rangeStart = _normalizeToDateOnly(range.start);
      final rangeEnd = _normalizeToDateOnly(range.end);
      return ticketDate.compareTo(rangeStart) >= 0 &&
          ticketDate.compareTo(rangeEnd) <= 0;
    }).toList();
  }

  List<Event> getEventsForRange(DateTimeRange range) {
    return state.events.where((event) {
      final eventDate = _normalizeToDateOnly(event.date);
      final rangeStart = _normalizeToDateOnly(range.start);
      final rangeEnd = _normalizeToDateOnly(range.end);
      return eventDate.compareTo(rangeStart) >= 0 &&
          eventDate.compareTo(rangeEnd) <= 0;
    }).toList();
  }
}
