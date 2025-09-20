// A dedicated, reusable widget for rendering the content of a wallet card.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/hilight_widget.dart';
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
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
          color: ticket.type == EntryType.busTicket
              ? AppColor.limeYellowThikColor
              : AppColor.limeYellowColor),
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
                      radius: 20,
                      backgroundColor: AppColor.whiteColor,
                      child: Icon(ticket.type == EntryType.busTicket
                          ? ticket.type == EntryType.busTicket
                              ? Icons.airport_shuttle_outlined
                              : Icons.badge_outlined
                          : Icons.tram_outlined)),

                  //* Secondary text
                  Flexible(
                    child: Text(
                      ticket.secondaryText.isNotEmpty
                          ? ticket.secondaryText
                          : 'xxx xxx',
                      style: Paragraph02(color: Shades.s100).regular,
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
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54),
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
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    ...ticket.tags!.take(2).map((tag) => HighlightChipsWidget(
                          bgColor: const Color(0xffCADC56),
                          label: tag.value ?? 'xxx',
                          icon: tag.iconData ?? Icons.star_border_rounded,
                        ))
                  ],
                ),
            ],
          ),

          //*  See more action button
          Row(
            spacing: 15,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //* Location
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined),
                    Expanded(
                      child: Text(
                        ticket.location,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),

              //* See more button
              IconButton(
                onPressed: () async {
                  final wasDeleted = await context.pushNamed<bool>(
                    AppRoute.ticketView.name,
                    extra: ticket,
                  );

                  if (wasDeleted == true && onTicketDeleted != null) {
                    onTicketDeleted!();
                  }
                },
                icon: const Icon(Icons.info),
              )
            ],
          )
        ],
      ),
    );
  }
}
