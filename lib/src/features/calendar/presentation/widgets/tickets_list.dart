import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/features/calendar/presentation/calendar_view.dart';
import 'package:namma_wallet/src/features/calendar/presentation/widgets/calendar_event_card.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/travel_ticket_card_widget.dart';

class TicketsList extends StatelessWidget {
  const TicketsList({
    required this.provider,
    super.key,
  });

  final CalendarProvider provider;

  @override
  Widget build(BuildContext context) {
    final selectedRange = provider.selectedRange;
    final selectedDay = provider.selectedDay;

    final events = selectedRange != null
        ? provider.getEventsForRange(selectedRange)
        : provider.getEventsForDay(selectedDay);

    final tickets = selectedRange != null
        ? provider.getTicketsForRange(selectedRange)
        : provider.getTicketsForDay(selectedDay);

    if (events.isEmpty && tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            selectedRange != null
                ? 'No events or tickets in this date range'
                : 'No events or tickets for this date',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tickets.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              selectedRange != null
                  ? 'Travel Tickets (${tickets.length})'
                  : 'Travel Tickets',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...tickets.map(
            (ticket) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () async {
                  final result = await context.pushNamed<bool>(
                    AppRoute.ticketView.name,
                    extra: ticket,
                  );
                  if (result == true) {
                    await provider.loadTickets();
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: TravelTicketCardWidget(ticket: ticket),
              ),
            ),
          ),
        ],
        if (events.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              selectedRange != null ? 'Events (${events.length})' : 'Events',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...events.map((event) => CalendarEventCard(event: event)),
        ],
      ],
    );
  }
}
