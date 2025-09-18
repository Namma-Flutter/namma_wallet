// Home page shows the tickets saved
// Top left has profile
import 'dart:convert';

import 'package:card_stack_widget/model/card_model.dart';
import 'package:card_stack_widget/model/card_orientation.dart';
import 'package:card_stack_widget/widget/card_stack_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namma_wallet/src/core/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/common/generated/assets.gen.dart';
import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/header_widget.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/ticket_card_widget.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/trave_ticket_card_widget.dart';
import 'package:namma_wallet/src/features/ticket/presentation/ticket_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  String extractedText = 'None';
  String? busTicket;
  List<GenericDetailsModel> _allTickets = [];
  final List<GenericDetailsModel> _travelTickets = [];
  final List<GenericDetailsModel> _eventTickets = [];
  final List<GenericDetailsModel> _otherTickets = [];

  @override
  void initState() {
    super.initState();
    _loadTicketData();
  }

  Future<void> _loadTicketData() async {
    try {
      final response =
          await rootBundle.loadString(Assets.data.ticketMockedData);
      final data = await json.decode(response) as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _allTickets = data
            .map((ticket) => GenericDetailsModelMapper.fromMap(
                ticket as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
      for (final ticket in _allTickets) {
        switch (ticket.type) {
          case EntryType.busTicket || EntryType.trainTicket:
            _travelTickets.add(ticket);
          case EntryType.event:
            _eventTickets.add(ticket);
          case EntryType.none:
            _otherTickets.add(ticket);
        }
      }
    } on Object catch (e) {
      if (!mounted) return;
      showSnackbar(context, 'Error loading card data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardStackList = _travelTickets.map((card) {
      return CardModel(
        radius: const Radius.circular(30),
        shadowColor: Colors.transparent,
        child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TicketView(ticket: card),
                ),
              );
            },
            child: TravelTicketCardWidget(ticket: card)),
      );
      // return const SizedBox.shrink();
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UserProfileWidget(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Tickets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              //* Top 3 card list
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                _travelTickets.isEmpty
                    ? const Center(child: Text('No cards found.'))
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _eventTickets.length,
                      itemBuilder: (context, index) {
                        final event = _eventTickets[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TicketView(ticket: _eventTickets[index]),
                              ),
                            );
                          },
                          child: EventTicketCardWidget(
                            ticket: event,
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
    );
  }
}
