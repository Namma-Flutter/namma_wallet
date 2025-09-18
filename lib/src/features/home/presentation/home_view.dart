// Home page shows the tickets saved
// Top left has profile
import 'package:card_stack_widget/model/card_model.dart';
import 'package:card_stack_widget/model/card_orientation.dart';
import 'package:card_stack_widget/widget/card_stack_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/core/routing/app_routes.dart';
import 'package:namma_wallet/src/core/services/database_helper.dart';
import 'package:namma_wallet/src/core/widgets/snackbar_widget.dart';
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
    // Parse journey date or use current time
    DateTime startTime;
    try {
      startTime = ticket.journeyDate != null
          ? DateTime.parse(ticket.journeyDate!)
          : DateTime.now();
    } catch (e) {
      startTime = DateTime.now();
    }

    // Build extras list with ticket details
    final extras = <ExtrasModel>[];

    // Add seat numbers if available
    if (ticket.seatNumbers?.isNotEmpty == true) {
      extras.add(ExtrasModel(
        title: 'Seat Numbers',
        value: ticket.seatNumbers!,
      ));
    }

    // Add class of service if available
    if (ticket.classOfService?.isNotEmpty == true) {
      extras.add(ExtrasModel(
        title: 'Class',
        value: ticket.classOfService!,
      ));
    }

    // Add PNR/booking reference if different from primary text
    final pnrOrBooking = ticket.pnrNumber ?? ticket.bookingReference;
    if (pnrOrBooking?.isNotEmpty == true) {
      extras.add(ExtrasModel(
        title: ticket.pnrNumber != null ? 'PNR Number' : 'Booking Reference',
        value: pnrOrBooking!,
      ));
    }

    // Add trip code if available
    if (ticket.tripCode?.isNotEmpty == true) {
      extras.add(ExtrasModel(
        title: 'Trip Code',
        value: ticket.tripCode!,
      ));
    }

    // Add coach number if available (for trains)
    if (ticket.coachNumber?.isNotEmpty == true) {
      extras.add(ExtrasModel(
        title: 'Coach',
        value: ticket.coachNumber!,
      ));
    }

    // Add boarding point if available
    if (ticket.boardingPoint?.isNotEmpty == true) {
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

    return GenericDetailsModel(
      primaryText: ticket.pnrNumber ?? ticket.bookingReference ?? ticket.displayName,
      secondaryText: ticket.ticketType == TicketType.event
          ? ticket.eventName ?? 'Event Ticket'
          : '${ticket.sourceLocation ?? ''} → ${ticket.destinationLocation ?? ''}',
      startTime: startTime,
      location: ticket.ticketType == TicketType.event
          ? ticket.venueName ?? ticket.sourceLocation ?? ''
          : ticket.boardingPoint ?? ticket.sourceLocation ?? '',
      type: ticket.ticketType == TicketType.event ? EntryType.event
          : ticket.ticketType == TicketType.bus ? EntryType.busTicket
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
                              final genericEvent = _convertToGenericDetails(eventTicket);
                              return InkWell(
                                onTap: () async {
                                  final wasDeleted = await context.pushNamed<bool>(
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
