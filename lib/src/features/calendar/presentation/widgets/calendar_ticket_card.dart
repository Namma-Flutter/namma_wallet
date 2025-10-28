import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/features/common/domain/travel_ticket_model.dart';
import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart';
import 'package:namma_wallet/src/features/home/domain/tag_model.dart';

class CalendarTicketCard extends StatelessWidget {
  const CalendarTicketCard({
    required this.ticket,
    super.key,
  });

  final TravelTicketModel ticket;

  @override
  Widget build(BuildContext context) {
    final genericTicket = _convertToGenericModel(ticket);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _buildCalendarTicketCard(context, genericTicket),
    );
  }

  GenericDetailsModel _convertToGenericModel(TravelTicketModel ticket) {
    final entryType = switch (ticket.ticketType) {
      TicketType.bus => EntryType.busTicket,
      TicketType.train => EntryType.trainTicket,
      TicketType.flight => EntryType.none,
      TicketType.event => EntryType.none,
      TicketType.metro => EntryType.none,
    };

    final tags = <TagModel>[];
    if (ticket.seatNumbers != null && ticket.seatNumbers!.isNotEmpty) {
      tags.add(TagModel(value: ticket.seatNumbers, icon: 'event_seat'));
    }
    if (ticket.displayTime.isNotEmpty) {
      tags.add(TagModel(value: ticket.displayTime, icon: 'access_time'));
    }
    if (ticket.amount != null) {
      tags.add(TagModel(
          value: '₹${ticket.amount!.toStringAsFixed(0)}',
          icon: 'currency_rupee'));
    }

    late final DateTime startTime;
    try {
      if (ticket.journeyDate != null && ticket.journeyDate!.isNotEmpty) {
        startTime = DateTime.parse(ticket.journeyDate!);
      } else {
        startTime = DateTime.now();
      }
    } on FormatException {
      startTime = DateTime.now();
    }

    return GenericDetailsModel(
      primaryText: ticket.displayName,
      secondaryText: ticket.providerName,
      startTime: startTime,
      location: ticket.providerName,
      type: entryType,
      tags: tags.isNotEmpty ? tags : null,
      ticketId: ticket.id,
    );
  }

  Widget _buildCalendarTicketCard(
      BuildContext context, GenericDetailsModel ticket) {
    return Container(
      height: 350,
      width: double.infinity,
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
        color: AppColor.periwinkleBlue,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColor.whiteColor,
                    child: Icon(
                      ticket.type == EntryType.busTicket
                          ? Icons.airport_shuttle_outlined
                          : ticket.type == EntryType.trainTicket
                              ? Icons.train_outlined
                              : Icons.tram_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      ticket.secondaryText.isNotEmpty
                          ? ticket.secondaryText
                          : 'xxx xxx',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              if (ticket.primaryText.isNotEmpty)
                Text(
                  ticket.primaryText,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Journey Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(ticket.startTime),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(ticket.startTime),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              if (ticket.tags != null && ticket.tags!.isNotEmpty)
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    ...ticket.tags!.take(2).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                tag.iconData,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tag.value ?? 'xxx',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ))
                  ],
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ticket.location,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ticket details: ${ticket.primaryText}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.info,
                  color: Colors.white,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
