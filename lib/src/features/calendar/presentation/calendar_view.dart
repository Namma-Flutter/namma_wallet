import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:namma_wallet/src/common/database/i_ticket_dao.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/features/calendar/domain/event_model.dart';
import 'package:namma_wallet/src/features/calendar/presentation/widgets/calendar_toggle_buttons.dart';
import 'package:namma_wallet/src/features/calendar/presentation/widgets/calendar_widget.dart';
import 'package:namma_wallet/src/features/calendar/presentation/widgets/tickets_list.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarProvider extends ChangeNotifier {
  CalendarProvider({ILogger? logger}) : _logger = logger ?? getIt<ILogger>();
  final ILogger _logger;

  DateTime _selectedDay = DateTime.now();
  List<Event> _events = [];
  List<Ticket> _tickets = [];

  DateTime get selectedDay => _selectedDay;
  List<Event> get events => _events;
  List<Ticket> get tickets => _tickets;

  void setSelectedDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  Future<void> loadEvents() async {
    // Load events from JSON
    final response = await rootBundle.loadString(
      'assets/data/other_cards.json',
    );
    final data = json.decode(response) as List;
    _events = data.map((e) {
      final item = e as Map<String, dynamic>;
      final dateParts = (item['date'] as String).split(' ');
      final month = DateFormat.MMM().parse(dateParts[1]).month;
      final day = int.parse(dateParts[2]);
      final year = DateTime.now().year; // Assuming current year
      return Event(
        icon: Event.getIconData(item['icon'] as String),
        title: item['title'] as String,
        subtitle: item['subtitle'] as String,
        date: DateTime(year, month, day),
        price: item['price'] as String,
      );
    }).toList();

    // Load tickets from database
    await loadTickets();
    notifyListeners();
  }

  Future<void> loadTickets() async {
    try {
      final ticketDao = getIt<ITicketDao>();

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
}

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarProvider()..loadEvents(),
      child: Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text('Calendar'),
          ),
          centerTitle: false,
        ),
        body: const CalendarContent(),
      ),
    );
  }
}

class CalendarContent extends StatefulWidget {
  const CalendarContent({super.key});

  @override
  State<CalendarContent> createState() => _CalendarContentState();
}

class _CalendarContentState extends State<CalendarContent> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  int _selectedFilter = 1;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalendarProvider>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          CalendarToggleButtons(
            selectedFilter: _selectedFilter,
            onFilterChanged: (index) {
              setState(() {
                _selectedFilter = index;
                if (index == 0) {
                  _calendarFormat = CalendarFormat.week;
                } else if (index == 1) {
                  _calendarFormat = CalendarFormat.month;
                } else {
                  // Handle Date Range
                }
              });
            },
          ),
          CalendarWidget(
            provider: provider,
            calendarFormat: _calendarFormat,
            onDaySelected: (day, focusedDay) {
              provider.setSelectedDay(day);
            },
          ),
          const SizedBox(height: 8),
          TicketsList(provider: provider),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
