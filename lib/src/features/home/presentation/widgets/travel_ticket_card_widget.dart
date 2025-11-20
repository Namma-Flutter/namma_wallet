// A dedicated, reusable widget for rendering the content of a wallet card.
import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/features/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/features/home/domain/extras_model.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/travel/presentation/widgets/ticket_view_widget.dart';

class TravelTicketCardWidget extends StatelessWidget {
  const TravelTicketCardWidget({
    required this.ticket,
    this.onTicketDeleted,
    super.key,
  });

  final Ticket ticket;
  final VoidCallback? onTicketDeleted;

  String? getFromLocation(Ticket ticket) {
    for (final extra in ticket.extras ?? <ExtrasModel>[]) {
      if (extra.title?.toLowerCase() == 'from') {
        return extra.value;
      }
    }
    return null;
  }

  String? getToLocation(Ticket ticket) {
    for (final extra in ticket.extras ?? <ExtrasModel>[]) {
      if (extra.title?.toLowerCase() == 'to') {
        return extra.value;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -3),
          ),
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(-3, 0),
          ),
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(3, 0),
          ),
        ],
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              //* Service profile
              Row(
                spacing: 10,
                children: [
                  //* Service icon
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      ticket.type == TicketType.bus
                          ? ticket.type == TicketType.bus
                                ? Icons.airport_shuttle_outlined
                                : Icons.badge_outlined
                          : Icons.tram_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  //* Secondary text
                  Flexible(
                    child: Text(
                      ticket.secondaryText.isNotEmpty
                          ? ticket.secondaryText
                          : 'xxx xxx',
                      style: Paragraph02(
                        color: Theme.of(context).colorScheme.onSurface,
                      ).regular,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),

              //* From to To
              ...() {
                final from = getFromLocation(ticket);
                final to = getToLocation(ticket);

                if (from != null && to != null) {
                  return <Widget>[
                    // Origin chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.05,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.trip_origin,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              from,
                              style: Paragraph02(
                                color: Theme.of(context).colorScheme.onSurface,
                              ).semiBold,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          size: 20,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),

                    // Destination chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.05,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              to,
                              style: Paragraph02(
                                color: Theme.of(context).colorScheme.onSurface,
                              ).semiBold,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                } else if (ticket.primaryText.isNotEmpty) {
                  return <Widget>[
                    Text(
                      ticket.primaryText,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ];
                }
                return <Widget>[];
              }(),

              //* Date - Time
              TicketRowWidget(
                title1: 'Journey Date',
                title2: 'Time',
                value1: formatDate(ticket.startTime),
                value2: formatTime(ticket.startTime),
              ),
            ],
          ),

          //* Boarding Point
          if (ticket.location.isNotEmpty)
            Row(
              spacing: 8,
              children: [
                const Icon(Icons.flag_outlined),
                Expanded(
                  child: Text(
                    ticket.location,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
