import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart';

class TicketCardWidget extends StatelessWidget {
  const TicketCardWidget({
    required this.ticket,
    super.key,
  });

  final GenericDetailsModel ticket;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColor.secondaryColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //* ticket title
                    Text(
                      ticket.primaryText,
                      style: const TextStyle(color: AppColor.whiteColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),

                    //* Date & Time
                    Row(
                      children: [
                        Text(
                          // ticket.dateTime?.toString() ?? 'xxx xxx',
                          getTime(ticket.startTime),
                          style: const TextStyle(color: AppColor.whiteColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const Text(' - '),
                        Text(
                          // ticket.dateTime?.toString() ?? 'xxx xxx',
                          getDate(ticket.startTime),
                          style: const TextStyle(color: AppColor.whiteColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ],
                ),
                //* ticket icon
                const Icon(
                  // ticket.eventIcon,
                  Icons.star,
                  color: AppColor.whiteColor,
                ),
              ],
            ),
            //* Address
            Text(
              // ticket.venue ?? 'xxx xxx',
              ticket.location,
              style: const TextStyle(color: AppColor.whiteColor),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class EventTicketCardWidget extends StatelessWidget {
  const EventTicketCardWidget({
    required this.ticket,
    super.key,
  });

  final GenericDetailsModel ticket;

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
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, -3),
            ),
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(-3, 0),
            ),
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.04),
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
                      Row(
                        children: [
                          Text(
                            // ticket.dateTime?.toString() ?? 'xxx xxx',
                            getTime(ticket.startTime),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const Text(' - '),
                          Text(
                            // ticket.dateTime?.toString() ?? 'xxx xxx',
                            getDate(ticket.startTime),
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
                  // ticket.eventIcon,
                  Icons.star,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            //* Address
            Text(
              // ticket.venue ?? 'xxx xxx',
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
}
