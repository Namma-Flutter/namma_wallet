import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/features/calendar/presentation/calendar_view.dart';
import 'package:namma_wallet/src/features/calendar/presentation/widgets/calendar_utils.dart';

class CustomDayCell extends StatelessWidget {
  const CustomDayCell({
    required this.day, required this.provider, super.key,
    this.isSelected = false,
    this.isToday = false,
  });

  final DateTime day;
  final CalendarProvider provider;
  final bool isSelected;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final tickets = provider.getTicketsForDay(day);
    final events = provider.getEventsForDay(day);

    var primaryIcon = Icons.directions_bus;
    if (tickets.isNotEmpty) {
      primaryIcon = CalendarUtils.getTicketTypeIcon(tickets.first.ticketType);
    } else if (events.isNotEmpty) {
      primaryIcon = events.first.icon;
    }

    const backgroundColor = AppColor.limeYellowColor;
    var borderColor = Colors.transparent;

    if (isSelected) {
      borderColor = Colors.blue;
    } else if (isToday) {
      borderColor = Colors.blueAccent;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != Colors.transparent
            ? Border.all(color: borderColor, width: 2)
            : null,
      ),
      child: Stack(
        children: [
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
