import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:namma_wallet/src/features/calendar/data/event_model.dart';
import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart';
import 'package:namma_wallet/src/features/ticket/presentation/ticket_view.dart';
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
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Status bar area
            Container(
              height: MediaQuery.of(context).padding.top,
              color: Colors.grey[50],
            ),
            // Header with title and profile
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildHeader(),
            ),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Namma',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Wallet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '🎪',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green[200],
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile.png', // You may need to add this asset
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.green[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                );
              },
            ),
          ),
        ),
      ],
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
        // Calendar with gradient background - larger size
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xffE7FC57), // Lime yellow color from existing theme
                  Color(0xffD4E157), // Slightly darker green-yellow
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TableCalendar<Event>(
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: selectedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  onDaySelected: (day, focusedDay) {
                    provider.setSelectedDay(day);
                  },
                  calendarStyle: CalendarStyle(
                    // Remove default decorations
                    defaultDecoration: const BoxDecoration(),
                    weekendDecoration: const BoxDecoration(),
                    outsideDaysVisible: false,

                    // Selected day styling
                    selectedDecoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),

                    // Today styling
                    todayDecoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),

                    // Default text styling
                    defaultTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    weekendTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                      size: 28,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Colors.black,
                      size: 28,
                    ),
                    titleTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    weekendStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
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

        // Upcoming section
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upcoming',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: events.isEmpty
                    ? _buildNoEventsMessage()
                    : ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return _buildEventCard(event);
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoEventsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No event for today',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
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
          color: Colors.grey[800],
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
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d MMM yy').format(event.date),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              event.icon,
              color: Colors.white,
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
      ..color = Colors.grey[400]!
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
