import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/calendar/presentation/calendar_page.dart';
import 'package:namma_wallet/src/features/calendar/components/calendar_ticket_card.dart';
import 'package:namma_wallet/src/features/calendar/components/calendar_event_card.dart';

class TicketsList extends StatelessWidget {
  const TicketsList({
    super.key,
    required this.provider,
  });

  final CalendarProvider provider;

  @override
  Widget build(BuildContext context) {
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
            padding: EdgeInsets.all(16),
            child: Text(
              'Travel Tickets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...tickets.map((ticket) => CalendarTicketCard(ticket: ticket)),
        ],
        if (events.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...events.map((event) => CalendarEventCard(event: event)),
        ],
      ],
    );
  }
}