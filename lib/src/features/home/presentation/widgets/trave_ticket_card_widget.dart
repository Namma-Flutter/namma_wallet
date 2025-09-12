// A dedicated, reusable widget for rendering the content of a wallet card.
import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/home/data/model/generic_details_model.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/hilight_widget.dart';
import 'package:namma_wallet/src/features/ticket_view/ticket_view.dart';

class TravelTicketCardWidget extends StatelessWidget {
  const TravelTicketCardWidget({required this.ticket, super.key});
  final GenericDetailsModel ticket;

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
          color: const Color(0xffE7FC57)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              //* Service profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      //* Service logo
                      CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey,
                          child: Icon(ticket.type == EntryType.busTicket
                              ? ticket.type == EntryType.busTicket
                                  ? Icons.airport_shuttle_outlined
                                  : Icons.badge_outlined
                              : Icons.tram_outlined)),

                      //* Serive name
                      // Text(
                      //   ticket.service,
                      //   style: const TextStyle(
                      //       fontSize: 20,
                      //       fontWeight: FontWeight.w500,
                      //       color: Colors.black45),
                      //   overflow: TextOverflow.ellipsis,
                      //   maxLines: 1,
                      // ),
                    ],
                  ),

                  //* Passanger count
                  // HighlightChipsWidget(
                  //   bgColor: const Color(0xffCADC56),
                  //   label: ticket.seatNumbers.length.toString(),
                  //   icon: Icons.people_outlined,
                  // ),
                ],
              ),

              //* From and To - Trip
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  //* From
                  Text(
                    ticket.primaryText,
                    style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),

                  // //* Arrow Icon
                  // const Icon(Icons.arrow_forward_outlined,
                  //     color: Colors.black54),

                  // //* To
                  // Text(
                  //   ticket.to,
                  //   style: const TextStyle(
                  //       fontSize: 25,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.black54),
                  // ),
                ],
              ),

              //* Secondary text
              Text(ticket.secondaryText),
              Text(ticket.startTime.toString()),
              if (ticket.endTime != null) Text(ticket.endTime.toString()),
              Text(ticket.location),

              //* Highlights
              if (ticket.tags != null && ticket.tags!.isNotEmpty)
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    ...ticket.tags!.map((tag) => HighlightChipsWidget(
                          bgColor: const Color(0xffCADC56),
                          label: tag.value ?? 'xxx',
                          icon: tag.iconData ?? Icons.star_border_rounded,
                        ))

                    // //* PNR no.
                    // HighlightChipsWidget(
                    //   bgColor: const Color(0xffCADC56),
                    //   label: ticket.pnrNo,
                    //   icon: Icons.train,
                    // ),

                    // //* Date
                    // HighlightChipsWidget(
                    //   bgColor: const Color(0xffCADC56),
                    //   label: ticket.journeyDate,
                    //   icon: Icons.calendar_month_outlined,
                    // ),

                    // //* Time
                    // HighlightChipsWidget(
                    //   bgColor: const Color(0xffCADC56),
                    //   label: ticket.time,
                    //   icon: Icons.access_time_outlined,
                    // ),
                  ],
                ),
            ],
          ),

          //*  See more action button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //* Status
              const Text(
                'Confirmed',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87),
              ),

              //* See more button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketView(ticket: ticket),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'See Details',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
