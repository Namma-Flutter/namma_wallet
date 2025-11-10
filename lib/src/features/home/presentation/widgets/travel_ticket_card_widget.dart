// A dedicated, reusable widget for rendering the content of a wallet card.
import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/features/common/domain/travel_ticket_model.dart';
import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/highlight_widget.dart';
import 'package:namma_wallet/src/features/travel/presentation/widgets/ticket_view_widget.dart';

class TravelTicketCardWidget extends StatelessWidget {
  const TravelTicketCardWidget({
    required this.ticket,
    this.onTicketDeleted,
    super.key,
  });
  final GenericDetailsModel ticket;
  final VoidCallback? onTicketDeleted;

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
              if (ticket.primaryText.isNotEmpty)
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

              //* Date - Time
              TicketRowWidget(
                title1: 'Journey Date',
                title2: 'Time',
                value1: getTime(ticket.startTime),
                value2: getDate(ticket.startTime),
              ),

              //* Highlights
              if (ticket.tags != null && ticket.tags!.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...ticket.tags!
                        .take(2)
                        .map(
                          (tag) => HighlightChipsWidget(
                            bgColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            label: tag.value ?? 'xxx',
                            icon: tag.iconData,
                          ),
                        ),
                  ],
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
