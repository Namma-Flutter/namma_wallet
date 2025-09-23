import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:namma_wallet/src/features/calendar/domain/event_model.dart';
import 'package:namma_wallet/src/features/calendar/presentation/calendar_page.dart';
import 'package:namma_wallet/src/features/calendar/presentation/widgets/custom_day_cell.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({
    super.key,
    required this.provider,
    required this.calendarFormat,
    required this.onDaySelected,
  });

  final CalendarProvider provider;
  final CalendarFormat calendarFormat;
  final void Function(DateTime, DateTime) onDaySelected;

  @override
  Widget build(BuildContext context) {
    final selectedDay = provider.selectedDay;

    return TableCalendar<Event>(
      firstDay: DateTime.utc(2020),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: selectedDay,
      calendarFormat: calendarFormat,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      eventLoader: (day) {
        final events = provider.getEventsForDay(day);
        final tickets = provider.getTicketsForDay(day);
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
            return CustomDayCell(day: day, provider: provider);
          }
          return null;
        },
        selectedBuilder: (context, day, focusedDay) {
          if (provider.hasTicketsOnDay(day) ||
              provider.getEventsForDay(day).isNotEmpty) {
            return CustomDayCell(
              day: day,
              provider: provider,
              isSelected: true,
            );
          }
          return Container(
            margin: const EdgeInsets.all(4),
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
            return CustomDayCell(
              day: day,
              provider: provider,
              isToday: true,
            );
          }
          return Container(
            margin: const EdgeInsets.all(4),
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
        markersMaxCount: 0,
      ),
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),
    );
  }
}