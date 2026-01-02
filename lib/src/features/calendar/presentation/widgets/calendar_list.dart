import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/features/calendar/application/calendar_notifier.dart';
import 'package:namma_wallet/src/features/events/presentation/event_card.dart';
import 'package:namma_wallet/src/features/travel/presentation/widgets/travel_ticket_card_widget.dart';

class CalendarList extends StatelessWidget {
  const CalendarList({
    required this.calendarState,
    required this.calendarNotifier,
    super.key,
  });

  final CalendarState calendarState;
  final Calendar calendarNotifier;

  @override
  Widget build(BuildContext context) {
    final selectedRange = calendarState.selectedRange;
    final selectedDay = calendarState.selectedDay;

    final events = selectedRange != null
        ? calendarNotifier.getEventsForRange(selectedRange)
        : calendarNotifier.getEventsForDay(selectedDay);

    final tickets = selectedRange != null
        ? calendarNotifier.getTicketsForRange(selectedRange)
        : calendarNotifier.getTicketsForDay(selectedDay);

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
                  if (result ?? false) {
                    await calendarNotifier.loadTickets();
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
          ...events.map((event) => EventCard(event: event)),
        ],
      ],
    );
  }
}
