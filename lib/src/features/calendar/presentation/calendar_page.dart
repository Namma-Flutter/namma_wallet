import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:namma_wallet/src/features/calendar/data/event_model.dart';
import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/header_widget.dart';
import 'package:namma_wallet/src/features/ticket/presentation/ticket_view.dart';
import 'package:namma_wallet/src/core/styles/styles.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarProvider extends ChangeNotifier {
  DateTime _selectedDay = DateTime.now();
  List<Event> _events = [];

  DateTime get selectedDay => _selectedDay;
  List<Event> get events => _events;

  void setSelectedDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  Future<void> loadEvents() async {
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
    notifyListeners();
  }

  List<Event> getEventsForDay(DateTime day) {
    return _events.where((event) => isSameDay(event.date, day)).toList();
  }
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarProvider()..loadEvents(),
      child: Scaffold(
        backgroundColor: AppColor.quaternaryColor,
        body: Column(
          children: [
            // Status bar area
            Container(
              height: MediaQuery.of(context).padding.top,
              color: AppColor.quaternaryColor,
            ),
            // Header with consistent design
            const UserProfileWidget(),
            // Calendar widget - full screen
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const CalendarView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildBottomNavigation() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.1),
  //           spreadRadius: 1,
  //           blurRadius: 10,
  //           offset: const Offset(0, -2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       children: [
  //         IconButton(
  //           onPressed: () {},
  //           icon: const Icon(Icons.home_outlined),
  //           color: Colors.grey[600],
  //         ),
  //         IconButton(
  //           onPressed: () {},
  //           icon: const Icon(Icons.star_outline),
  //           color: Colors.grey[600],
  //         ),
  //         Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  //           decoration: BoxDecoration(
  //             color: Colors.grey[800],
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           child: const Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Icon(
  //                 Icons.calendar_month,
  //                 color: Colors.white,
  //                 size: 20,
  //               ),
  //               SizedBox(width: 4),
  //               Text(
  //                 'Nov',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalendarProvider>(context);
    final selectedDay = provider.selectedDay;
    final events = provider.getEventsForDay(selectedDay);

    return Column(
      children: [
        // Calendar with gradient background - half page
        Expanded(
          flex: 1, // Exactly half the page
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.limeYellowColor,
                  AppColor.limeYellowThikColor,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(18), // Slightly increased padding
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: TableCalendar<Event>(
                      firstDay: DateTime.utc(2020),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: selectedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) =>
                          isSameDay(selectedDay, day),
                      onDaySelected: (day, focusedDay) {
                        provider.setSelectedDay(day);
                      },
                      // Optimized row height for half-page design
                      rowHeight: (constraints.maxHeight - 70) /
                          7, // Adjusted for half-page layout
                      calendarStyle: CalendarStyle(
                        // Remove default decorations
                        defaultDecoration: const BoxDecoration(),
                        weekendDecoration: const BoxDecoration(),
                        outsideDaysVisible: false,

                        // Selected day styling
                        selectedDecoration: BoxDecoration(
                          color: AppColor.whiteColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.blackColor.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        selectedTextStyle: const TextStyle(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.bold,
                        ),

                        // Today styling
                        todayDecoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w500,
                        ),

                        // Default text styling
                        defaultTextStyle: const TextStyle(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        weekendTextStyle: const TextStyle(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: AppColor.blackColor,
                          size: 24,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: AppColor.blackColor,
                          size: 24,
                        ),
                        titleTextStyle: TextStyle(
                          color: AppColor.blackColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        weekendStyle: TextStyle(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Dotted line separator
        Container(
          width: double.infinity,
          height: 1,
          child: CustomPaint(
            painter: DottedLinePainter(),
          ),
        ),

        const SizedBox(height: 20),

        // Upcoming section - other half of the page
        Expanded(
          flex: 1, // Exactly half the page to match calendar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upcoming',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColor.blackColor,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: events.isEmpty
                    ? const NoEventsMessageWidget()
                    : ListView.builder(
                        itemCount: events.length,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom +
                              80, // Account for nav bar
                        ),
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return EventCardWidget(event: event);
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NoEventsMessageWidget extends StatelessWidget {
  const NoEventsMessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 48,
            color: AppColor.blackColor.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No event for today',
            style: TextStyle(
              fontSize: 16,
              color: AppColor.blackColor.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class EventCardWidget extends StatelessWidget {
  const EventCardWidget({
    required this.event,
    super.key,
  });

  final Event event;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Convert Event to GenericDetailsModel
        final ticketData = GenericDetailsModel(
          primaryText: event.title,
          secondaryText: event.subtitle,
          startTime: event.date,
          location: 'Event Location', // Default location
          type: EntryType.event,
        );

        // Navigate to TicketView
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => TicketView(ticket: ticketData),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.secondaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: AppColor.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d MMM yy').format(event.date),
                    style: TextStyle(
                      color: AppColor.whiteColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.subtitle,
                    style: TextStyle(
                      color: AppColor.whiteColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              event.icon,
              color: AppColor.whiteColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.blackColor.withOpacity(0.4)
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
