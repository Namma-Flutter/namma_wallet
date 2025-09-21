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
                )
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
                      ticket.primaryText ?? 'xxx xxx',
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
                )
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
