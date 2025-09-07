import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:namma_wallet/src/features/calendar/data/event_model.dart';
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
        appBar: AppBar(
          title: const Text('Event Calendar View'),
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
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
            borderRadius: BorderRadius.circular(8),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Week'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Month'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Date Range'),
              ),
            ],
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
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                leading: Icon(event.icon),
                title: Text(event.title),
                subtitle: Text(DateFormat.jm().format(event.date)),
              );
            },
          ),
        ),
      ],
    );
  }
}
