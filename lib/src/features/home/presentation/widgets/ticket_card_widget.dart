import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';

class EventTicketCardWidget extends StatelessWidget {
  const EventTicketCardWidget({
    required this.ticket,
    super.key,
  });

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, -3),
            ),
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(-3, 0),
            ),
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(3, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //* ticket title
                      Text(
                        ticket.primaryText,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),

                      //* Date & Time
                      if (ticket.startTime != null)
                        Row(
                          children: [
                            Text(
                              DateTimeConverter.instance.formatDate(
                                ticket.startTime!,
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const Text(' - '),
                            Text(
                              DateTimeConverter.instance.formatTime(
                                ticket.startTime!,
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                //* ticket icon
                Icon(
                  _getTicketIcon(ticket.type),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            //* Address
            Text(
              ticket.location,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTicketIcon(TicketType type) {
    return switch (type) {
      TicketType.bus => Icons.airport_shuttle_outlined,
      TicketType.train => Icons.tram_outlined,
      TicketType.flight => Icons.flight_outlined,
      TicketType.metro => Icons.subway_outlined,
      TicketType.event => Icons.event_outlined,
    };
  }
}
