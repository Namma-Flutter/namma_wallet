import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
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
        final ticketDate = ticket.startTime;
        final rangeStart = range.start.subtract(const Duration(days: 1));
        final rangeEnd = range.end.add(const Duration(days: 1));
        return ticketDate.isAfter(rangeStart) && ticketDate.isBefore(rangeEnd);
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
      final rangeStart = range.start.subtract(const Duration(days: 1));
      final rangeEnd = range.end.add(const Duration(days: 1));
      return event.date.isAfter(rangeStart) && event.date.isBefore(rangeEnd);
    }).toList();
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

  Future<void> _showDateRangePicker(CalendarProvider provider) async {
    final initialRange =
        provider.selectedRange ??
        DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(days: 7)),
        );

    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
              // Change the color between selected dates from green to grey
              primaryContainer: Theme.of(
                context,
              ).colorScheme.surfaceContainerHigh,
              onPrimaryContainer: Theme.of(context).colorScheme.onSurface,
              // Override secondary colors that might be used for range
              secondary: Theme.of(context).colorScheme.surfaceContainerHigh,
              onSecondary: Theme.of(context).colorScheme.onSurface,
              secondaryContainer: Theme.of(
                context,
              ).colorScheme.surfaceContainerHigh,
              onSecondaryContainer: Theme.of(context).colorScheme.onSurface,
              // Override tertiary colors as fallback
              tertiary: Theme.of(context).colorScheme.surfaceContainerHigh,
              tertiaryContainer: Theme.of(
                context,
              ).colorScheme.surfaceContainerHigh,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      provider.setSelectedRange(pickedRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalendarProvider>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          CalendarToggleButtons(
            selectedFilter: _selectedFilter,
            onFilterChanged: (index) async {
              setState(() {
                _selectedFilter = index;
                if (index == 0) {
                  _calendarFormat = CalendarFormat.week;
                  provider.setSelectedRange(null);
                } else if (index == 1) {
                  _calendarFormat = CalendarFormat.month;
                  provider.setSelectedRange(null);
                }
              });

              if (index == 2) {
                // Handle Date Range
                await _showDateRangePicker(provider);
              }
            },
          ),
          if (provider.selectedRange != null)
            Builder(
              builder: (context) {
                final range = provider.selectedRange!;
                final formatter = DateFormat('MMM dd, yyyy');
                final startDate = formatter.format(range.start);
                final endDate = formatter.format(range.end);
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: InkWell(
                    onTap: () async {
                      await _showDateRangePicker(provider);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Selected: $startDate - $endDate',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              provider.setSelectedRange(null);
                              setState(() {
                                _selectedFilter = 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          if (provider.selectedRange == null)
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
