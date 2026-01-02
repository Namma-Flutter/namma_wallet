import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/calendar/application/calendar_notifier.dart';
import 'package:namma_wallet/src/features/calendar/presentation/widgets/themed_day_cell.dart';
import 'package:namma_wallet/src/features/events/domain/event_model.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({
    required this.calendarState,
    required this.calendarNotifier,
    required this.calendarFormat,
    required this.onDaySelected,
    super.key,
  });

  final CalendarState calendarState;
  final Calendar calendarNotifier;
  final CalendarFormat calendarFormat;
  final void Function(DateTime, DateTime) onDaySelected;

  @override
  Widget build(BuildContext context) {
    final selectedDay = calendarState.selectedDay;

    return TableCalendar<Event>(
      firstDay: DateTime.utc(2020),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: selectedDay,
      calendarFormat: calendarFormat,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      eventLoader: (day) {
        final events = calendarNotifier.getEventsForDay(day);
        final tickets = calendarNotifier.getTicketsForDay(day);
        return [
          ...events,
          ...tickets.map(
            (t) => Event(
              iconName: 'confirmation_number',
              title: t.primaryText,
              subtitle: t.secondaryText,
              date: day,
              price: '',
            ),
          ),
        ];
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (calendarNotifier.hasTicketsOnDay(day) ||
              calendarNotifier.getEventsForDay(day).isNotEmpty) {
            return ThemedDayCell(
              day: day,
              calendarNotifier: calendarNotifier,
            );
          }
          return null;
        },
        selectedBuilder: (context, day, focusedDay) {
          if (calendarNotifier.hasTicketsOnDay(day) ||
              calendarNotifier.getEventsForDay(day).isNotEmpty) {
            return ThemedDayCell(
              day: day,
              calendarNotifier: calendarNotifier,
              isSelected: true,
            );
          }
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
        todayBuilder: (context, day, focusedDay) {
          if (calendarNotifier.hasTicketsOnDay(day) ||
              calendarNotifier.getEventsForDay(day).isNotEmpty) {
            return ThemedDayCell(
              day: day,
              calendarNotifier: calendarNotifier,
              isToday: true,
            );
          }
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
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
