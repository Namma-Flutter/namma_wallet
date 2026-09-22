import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/booking_reminder/booking_reminder_service.dart';
import 'package:namma_wallet/src/features/calendar/application/calendar_provider.dart';
import 'package:namma_wallet/src/features/events/presentation/event_card.dart';
import 'package:namma_wallet/src/features/travel/presentation/widgets/travel_ticket_card_widget.dart';

class CalendarList extends StatelessWidget {
  const CalendarList({
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
                  if (ticket.ticketId == null) return;

                  final result = await context.pushNamed<bool>(
                    AppRoute.ticketView.name,
                    pathParameters: {'id': ticket.ticketId!},
                  );
                  if (result ?? false) {
                    await provider.loadTickets();
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: _TicketCardWithBadge(ticket: ticket),
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

class _TicketCardWithBadge extends StatefulWidget {
  const _TicketCardWithBadge({required this.ticket});

  final Ticket ticket;

  @override
  State<_TicketCardWithBadge> createState() => _TicketCardWithBadgeState();
}

class _TicketCardWithBadgeState extends State<_TicketCardWithBadge> {
  bool _hasReminder = false;

  @override
  void initState() {
    super.initState();
    _checkReminder();
  }

  Future<void> _checkReminder() async {
    final ticketId = widget.ticket.ticketId;
    if (ticketId == null) return;

    final hasNormal = await getIt<BookingReminderService>().hasActiveReminder(
      ticketId,
    );
    final hasTatkal = await getIt<BookingReminderService>()
        .hasActiveTatkalReminder(ticketId);
    if (mounted) {
      setState(() => _hasReminder = hasNormal || hasTatkal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TravelTicketCardWidget(ticket: widget.ticket),
        if (_hasReminder)
          Positioned(
            top: 8,
            right: 8,
            child: Icon(
              Icons.notifications_active,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }
}
