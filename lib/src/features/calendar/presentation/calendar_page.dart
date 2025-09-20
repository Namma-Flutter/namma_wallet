import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:namma_wallet/src/common/services/database_helper.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/features/calendar/data/event_model.dart';
import 'package:namma_wallet/src/features/common/domain/travel_ticket_model.dart';
import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart';
import 'package:namma_wallet/src/features/home/domain/tag_model.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarProvider extends ChangeNotifier {
  DateTime _selectedDay = DateTime.now();
  List<Event> _events = [];
  List<TravelTicketModel> _tickets = [];

  DateTime get selectedDay => _selectedDay;
  List<Event> get events => _events;
  List<TravelTicketModel> get tickets => _tickets;

  void setSelectedDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  Future<void> loadEvents() async {
    // Load events from JSON
    final response =
        await rootBundle.loadString('assets/data/other_cards.json');
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
      final dbHelper = DatabaseHelper.instance;
      final ticketMaps = await dbHelper.fetchAllTravelTickets();

      _tickets = ticketMaps
          .map((map) => TravelTicketModelMapper.fromMap(map))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error loading tickets: $e');
    }
  }

  List<Event> getEventsForDay(DateTime day) {
    return _events.where((event) => isSameDay(event.date, day)).toList();
  }

  List<TravelTicketModel> getTicketsForDay(DateTime day) {
    return _tickets.where((ticket) {
      if (ticket.journeyDate == null) return false;
      try {
        final ticketDate = DateTime.parse(ticket.journeyDate!);
        return isSameDay(ticketDate, day);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<DateTime> getDatesWithTickets() {
    final dates = <DateTime>[];
    for (final ticket in _tickets) {
      if (ticket.journeyDate != null) {
        try {
          final date = DateTime.parse(ticket.journeyDate!);
          if (!dates.any((d) => isSameDay(d, date))) {
            dates.add(date);
          }
        } catch (e) {
          // Skip invalid dates
        }
      }
    }
    return dates;
  }

  bool hasTicketsOnDay(DateTime day) {
    return getTicketsForDay(day).isNotEmpty;
  }
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarProvider()..loadEvents(),
      child: Scaffold(
        appBar: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              'Calendar',
              style: TextStyle(
                color: AppColor.blackColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          centerTitle: false,
        ),
        body: const CalendarView(),
      ),
    );
  }
}

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  int _selectedFilter = 1;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalendarProvider>(context);
    final selectedDay = provider.selectedDay;
    final events = provider.getEventsForDay(selectedDay);

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ToggleButtons(
                isSelected: [
                  _selectedFilter == 0,
                  _selectedFilter == 1,
                  _selectedFilter == 2
                ],
                onPressed: (index) {
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
                borderRadius: BorderRadius.circular(16),
                selectedBorderColor: AppColor.periwinkleBlue,
                selectedColor: Colors.white,
                borderWidth: 2,
                fillColor: AppColor.periwinkleBlue,
                color: Colors.grey[700],
                constraints: const BoxConstraints(minHeight: 40, minWidth: 80),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('Week',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('Month',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('Range',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ),
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: selectedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (day, focusedDay) {
              provider.setSelectedDay(day);
            },
            eventLoader: (day) {
              final events = provider.getEventsForDay(day);
              final tickets = provider.getTicketsForDay(day);
              // Return combined list for indicator dots
              return [
                ...events,
                ...tickets.map((t) => Event(
                      icon: Icons.confirmation_number,
                      title: t.displayName,
                      subtitle: t.providerName,
                      date: day,
                      price: t.amount?.toString() ?? '',
                    ))
              ];
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (provider.hasTicketsOnDay(day) ||
                    provider.getEventsForDay(day).isNotEmpty) {
                  return _buildCustomDayCell(day, provider);
                }
                return null;
              },
              selectedBuilder: (context, day, focusedDay) {
                if (provider.hasTicketsOnDay(day) ||
                    provider.getEventsForDay(day).isNotEmpty) {
                  return _buildCustomDayCell(day, provider, isSelected: true);
                }
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                if (provider.hasTicketsOnDay(day) ||
                    provider.getEventsForDay(day).isNotEmpty) {
                  return _buildCustomDayCell(day, provider, isToday: true);
                }
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            calendarStyle: const CalendarStyle(
              markersMaxCount:
                  0, // Disable default markers since we use custom builders
            ),
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
          ),
          const SizedBox(height: 8),
          _buildTicketsList(provider),
          // Add bottom padding to ensure content isn't hidden behind nav bar
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildTicketsList(CalendarProvider provider) {
    final selectedDay = provider.selectedDay;
    final events = provider.getEventsForDay(selectedDay);
    final tickets = provider.getTicketsForDay(selectedDay);

    if (events.isEmpty && tickets.isEmpty) {
      return const Center(
        child: Text(
          'No events or tickets for this date',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tickets.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Travel Tickets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...tickets.map((ticket) => _buildTicketCard(ticket)),
        ],
        if (events.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...events.map((event) => _buildEventCard(event)),
        ],
      ],
    );
  }

  GenericDetailsModel _convertToGenericModel(TravelTicketModel ticket) {
    // Convert TicketType to EntryType
    EntryType entryType;
    switch (ticket.ticketType) {
      case TicketType.bus:
        entryType = EntryType.busTicket;
        break;
      case TicketType.train:
        entryType = EntryType.trainTicket;
        break;
      default:
        entryType = EntryType.none;
    }

    // Create tags from ticket information
    List<TagModel> tags = [];
    if (ticket.seatNumbers != null && ticket.seatNumbers!.isNotEmpty) {
      tags.add(TagModel(value: ticket.seatNumbers!, icon: 'event_seat'));
    }
    if (ticket.displayTime.isNotEmpty) {
      tags.add(TagModel(value: ticket.displayTime, icon: 'access_time'));
    }
    if (ticket.amount != null) {
      tags.add(TagModel(
          value: '₹${ticket.amount!.toStringAsFixed(0)}',
          icon: 'currency_rupee'));
    }

    // Parse journey date string to DateTime
    DateTime startTime;
    try {
      if (ticket.journeyDate != null && ticket.journeyDate!.isNotEmpty) {
        startTime = DateTime.parse(ticket.journeyDate!);
      } else {
        startTime = DateTime.now();
      }
    } catch (e) {
      // Fallback to current date if parsing fails
      startTime = DateTime.now();
    }

    return GenericDetailsModel(
      primaryText: ticket.displayName,
      secondaryText: ticket.providerName,
      startTime: startTime,
      location: ticket.providerName, // Using provider as location fallback
      type: entryType,
      tags: tags.isNotEmpty ? tags : null,
      ticketId: ticket.id,
    );
  }

  Widget _buildTicketCard(TravelTicketModel ticket) {
    final genericTicket = _convertToGenericModel(ticket);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _buildCalendarTicketCard(genericTicket),
    );
  }

  Widget _buildCalendarTicketCard(GenericDetailsModel ticket) {
    return Container(
      height: 350,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
        color: AppColor.periwinkleBlue, // Using periwinkleBlue as accent color
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service profile
              Row(
                children: [
                  // Service icon
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColor.whiteColor,
                    child: Icon(
                      ticket.type == EntryType.busTicket
                          ? Icons.airport_shuttle_outlined
                          : ticket.type == EntryType.trainTicket
                              ? Icons.train_outlined
                              : Icons.tram_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Secondary text
                  Flexible(
                    child: Text(
                      ticket.secondaryText.isNotEmpty
                          ? ticket.secondaryText
                          : 'xxx xxx',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              // Primary text (ticket name/route)
              if (ticket.primaryText.isNotEmpty)
                Text(
                  ticket.primaryText,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              // Date - Time info
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Journey Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(ticket.startTime),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(ticket.startTime),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              // Tags/Highlights
              if (ticket.tags != null && ticket.tags!.isNotEmpty)
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    ...ticket.tags!.take(2).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                tag.iconData ?? Icons.star_border_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tag.value ?? 'xxx',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ))
                  ],
                ),
            ],
          ),
          // Location and action button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Location
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ticket.location,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              // Info button
              IconButton(
                onPressed: () {
                  // Handle ticket details view
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ticket details: ${ticket.primaryText}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.info,
                  color: Colors.white,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 350,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
        color: AppColor.ternaryColor, // Using ternaryColor as accent color for events
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              // Service profile
              Row(
                spacing: 10,
                children: [
                  // Event icon
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColor.whiteColor,
                    child: Icon(event.icon),
                  ),
                  // Secondary text
                  Flexible(
                    child: Text(
                      event.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Primary text (event title)
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 15),
              // Date - Time info
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Event Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(event.date),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Price',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          event.price.isNotEmpty ? event.price : 'Free',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Tags/Highlights
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Event',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.currency_rupee,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.price,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Location and action button
          Row(
            spacing: 15,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Location
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.subtitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              // Info button
              IconButton(
                onPressed: () {
                  // Handle event details view
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Event details: ${event.title}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.info,
                  color: Colors.white,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Color _getTicketTypeColor(TicketType type) {
    switch (type) {
      case TicketType.bus:
        return Colors.green;
      case TicketType.train:
        return Colors.blue;
      case TicketType.flight:
        return Colors.red;
      case TicketType.event:
        return Colors.purple;
      case TicketType.metro:
        return Colors.orange;
    }
  }

  IconData _getTicketTypeIcon(TicketType type) {
    switch (type) {
      case TicketType.bus:
        return Icons.directions_bus;
      case TicketType.train:
        return Icons.train;
      case TicketType.flight:
        return Icons.flight;
      case TicketType.event:
        return Icons.event;
      case TicketType.metro:
        return Icons.subway;
    }
  }

  Widget _buildCustomDayCell(DateTime day, CalendarProvider provider,
      {bool isSelected = false, bool isToday = false}) {
    final tickets = provider.getTicketsForDay(day);
    final events = provider.getEventsForDay(day);

    // Determine the primary icon to show
    IconData primaryIcon = Icons.directions_bus; // Default to bus icon
    if (tickets.isNotEmpty) {
      primaryIcon = _getTicketTypeIcon(tickets.first.ticketType);
    } else if (events.isNotEmpty) {
      primaryIcon = events.first.icon;
    }

    Color backgroundColor = AppColor.limeYellowColor;
    Color borderColor = Colors.transparent;

    if (isSelected) {
      borderColor = Colors.blue;
    } else if (isToday) {
      borderColor = Colors.blueAccent;
    }

    return Container(
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        border: borderColor != Colors.transparent
            ? Border.all(color: borderColor, width: 2.0)
            : null,
      ),
      child: Stack(
        children: [
          // Date number in top-left corner
          Positioned(
            top: 2,
            left: 4,
            child: Text(
              '${day.day}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // Icon in center
          Center(
            child: Icon(
              primaryIcon,
              size: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
