// Home page shows the tickets saved
// Top left has profile
import 'dart:developer' as developer;

import 'package:card_stack_widget/model/card_model.dart';
import 'package:card_stack_widget/model/card_orientation.dart';
import 'package:card_stack_widget/widget/card_stack_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/database_helper.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/common/domain/travel_ticket_model.dart';
import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/header_widget.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/ticket_card_widget.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/travel_ticket_card_widget.dart';
import 'package:namma_wallet/src/features/home/domain/extras_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  List<TravelTicketModel> _travelTickets = [];
  List<TravelTicketModel> _eventTickets = [];

  @override
  void initState() {
    super.initState();
    _loadTicketData();
  }

  Future<void> _loadTicketData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final ticketMaps = await DatabaseHelper.instance.fetchAllTravelTickets();

      if (!mounted) return;

      final tickets = ticketMaps
          .map((map) => TravelTicketModelMapper.fromMap(map))
          .toList();

      final travelTickets = <TravelTicketModel>[];
      final eventTickets = <TravelTicketModel>[];

      for (final ticket in tickets) {
        switch (ticket.ticketType) {
          case TicketType.bus:
          case TicketType.train:
          case TicketType.flight:
          case TicketType.metro:
            travelTickets.add(ticket);
          case TicketType.event:
            eventTickets.add(ticket);
        }
      }

      if (!mounted) return;
      setState(() {
        _travelTickets = travelTickets;
        _eventTickets = eventTickets;
        _isLoading = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      showSnackbar(context, 'Error loading ticket data: $e', isError: true);
      setState(() {
        _isLoading = false;
      });
    }
  }

  GenericDetailsModel _convertToGenericDetails(TravelTicketModel ticket) {
    // Parse journey date and combine with departure time
    DateTime startTime;
    try {
      DateTime baseDate;
      if (ticket.journeyDate != null) {
        // Handle both ISO format (2025-01-15) and display format (15/01/2025)
        final dateStr = ticket.journeyDate!;
        if (dateStr.contains('/')) {
          // Convert dd/mm/yyyy to yyyy-mm-dd for parsing
          final parts = dateStr.split('/');
          if (parts.length == 3) {
            final day = parts[0].padLeft(2, '0');
            final month = parts[1].padLeft(2, '0');
            final year = parts[2];
            baseDate = DateTime.parse('$year-$month-$day');
          } else {
            baseDate = DateTime.now();
          }
        } else {
          baseDate = DateTime.parse(dateStr);
        }
      } else {
        baseDate = DateTime.now();
      }

      // Add departure time if available
      if (ticket.departureTime?.isNotEmpty == true) {
        try {
          final timeParts = ticket.departureTime!.split(':');
          if (timeParts.length >= 2) {
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            startTime = DateTime(
              baseDate.year,
              baseDate.month,
              baseDate.day,
              hour,
              minute,
            );
          } else {
            startTime = baseDate;
          }
        } catch (e) {
          startTime = baseDate;
        }
      } else {
        startTime = baseDate;
      }
    } catch (e) {
      startTime = DateTime.now();
    }

    // Build extras list with ticket details
    final extras = <ExtrasModel>[];

    // Add departure time if available
    if (ticket.departureTime?.isNotEmpty ?? false) {
      extras.add(ExtrasModel(
        title: 'Departure Time',
        value: ticket.departureTime!,
      ));
    }

    // Add seat numbers if available
    if (ticket.seatNumbers?.isNotEmpty ?? false) {
      extras.add(ExtrasModel(
        title: 'Seat Numbers',
        value: ticket.seatNumbers!,
      ));
    }

    // Add class of service if available
    if (ticket.classOfService?.isNotEmpty ?? false) {
      extras.add(ExtrasModel(
        title: 'Class',
        value: ticket.classOfService!,
      ));
    }

    // Add PNR/booking reference if different from primary text
    final pnrOrBooking = ticket.pnrNumber ?? ticket.bookingReference;
    if (pnrOrBooking?.isNotEmpty ?? false) {
      extras.add(ExtrasModel(
        title: ticket.pnrNumber != null ? 'PNR Number' : 'Booking Reference',
        value: pnrOrBooking!,
      ));
    }

    // Add trip code if available
    if (ticket.tripCode?.isNotEmpty ?? false) {
      extras.add(ExtrasModel(
        title: 'Trip Code',
        value: ticket.tripCode!,
      ));
    }

    // Add coach number if available (for trains)
    if (ticket.coachNumber?.isNotEmpty ?? false) {
      extras.add(ExtrasModel(
        title: 'Coach',
        value: ticket.coachNumber!,
      ));
    }

    // Add boarding point if available
    if (ticket.boardingPoint?.isNotEmpty ?? false) {
      extras.add(ExtrasModel(
        title: 'Boarding Point',
        value: ticket.boardingPoint!,
      ));
    }

    // Add amount if available
    if (ticket.amount != null) {
      extras.add(ExtrasModel(
        title: 'Amount',
        value: '${ticket.currency} ${ticket.amount}',
      ));
    }

    // Create meaningful primary text with debug logging
    String primaryText;

    // Debug logging
    developer.log('Ticket fields for UI mapping:', name: 'UI_MAPPING');
    developer.log('sourceLocation: "${ticket.sourceLocation}"',
        name: 'UI_MAPPING');
    developer.log('destinationLocation: "${ticket.destinationLocation}"',
        name: 'UI_MAPPING');
    developer.log('pnrNumber: "${ticket.pnrNumber}"', name: 'UI_MAPPING');
    developer.log('providerName: "${ticket.providerName}"', name: 'UI_MAPPING');
    developer.log('displayName: "${ticket.displayName}"', name: 'UI_MAPPING');

    if ((ticket.sourceLocation?.isNotEmpty ?? false) &&
        (ticket.destinationLocation?.isNotEmpty ?? false)) {
      primaryText = '${ticket.sourceLocation!} → '
          '${ticket.destinationLocation!}';
      developer.log('Using route as primary text: "$primaryText"',
          name: 'UI_MAPPING');
    } else if (ticket.pnrNumber?.isNotEmpty ?? false) {
      primaryText = ticket.pnrNumber!;
      developer.log('Using PNR as primary text: "$primaryText"',
          name: 'UI_MAPPING');
    } else if (ticket.bookingReference?.isNotEmpty ?? false) {
      primaryText = ticket.bookingReference!;
      developer.log('Using booking ref as primary text: "$primaryText"',
          name: 'UI_MAPPING');
    } else {
      primaryText = ticket.displayName;
      developer.log('Using display name as primary text: "$primaryText"',
          name: 'UI_MAPPING');
    }

    // Create meaningful secondary text (provider name)
    String secondaryText;
    if (ticket.ticketType == TicketType.event) {
      secondaryText = ticket.eventName ?? 'Event Ticket';
    } else {
      secondaryText = '${ticket.providerName} - ${ticket.tripCode ?? 'Travel'}';
    }

    // Determine location for display
    String displayLocation;
    if (ticket.ticketType == TicketType.event) {
      displayLocation = ticket.venueName ?? ticket.sourceLocation ?? '';
    } else {
      displayLocation = ticket.boardingPoint ?? ticket.sourceLocation ?? '';
    }

    return GenericDetailsModel(
      primaryText: primaryText,
      secondaryText: secondaryText,
      startTime: startTime,
      location: displayLocation,
      type: ticket.ticketType == TicketType.event
          ? EntryType.event
          : ticket.ticketType == TicketType.bus
              ? EntryType.busTicket
              : EntryType.trainTicket,
      endTime: startTime, // For simplicity, same as start time
      extras: extras.isNotEmpty ? extras : null,
      ticketId: ticket.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardStackList = _travelTickets.map((ticket) {
      final genericTicket = _convertToGenericDetails(ticket);
      return CardModel(
        radius: const Radius.circular(30),
        shadowColor: Colors.transparent,
        child: InkWell(
            onTap: () async {
              final wasDeleted = await context.pushNamed<bool>(
                AppRoute.ticketView.name,
                extra: genericTicket,
              );

              if (wasDeleted == true && mounted) {
                await _loadTicketData();
              }
            },
            child: TravelTicketCardWidget(
              ticket: genericTicket,
              onTicketDeleted: _loadTicketData,
            )),
      );
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTicketData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const UserProfileWidget(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tickets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
                ),

                //* Top 3 card list
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  _travelTickets.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.airplane_ticket_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No travel tickets found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Paste travel SMS or add tickets manually',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            height: 500,
                            child: CardStackWidget(
                              cardList: cardStackList.take(3).toList(),
                              opacityChangeOnDrag: true,
                              swipeOrientation: CardOrientation.both,
                              cardDismissOrientation: CardOrientation.both,
                              positionFactor: 3,
                              scaleFactor: 2,
                              alignment: Alignment.center,
                              animateCardScale: true,
                              dismissedCardDuration:
                                  const Duration(milliseconds: 150),
                            ),
                          ),
                        ),

                //* Other Cards Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //* Event heading
                      const Text(
                        'Events',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      //* More cards list view
                      _eventTickets.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  'No event tickets found',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _eventTickets.length,
                              itemBuilder: (context, index) {
                                final eventTicket = _eventTickets[index];
                                final genericEvent =
                                    _convertToGenericDetails(eventTicket);
                                return InkWell(
                                  onTap: () async {
                                    final wasDeleted =
                                        await context.pushNamed<bool>(
                                      AppRoute.ticketView.name,
                                      extra: genericEvent,
                                    );

                                    if (wasDeleted == true && mounted) {
                                      await _loadTicketData();
                                    }
                                  },
                                  child: EventTicketCardWidget(
                                    ticket: genericEvent,
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
