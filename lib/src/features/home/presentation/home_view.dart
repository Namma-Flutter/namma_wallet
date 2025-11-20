import 'package:card_stack_widget/model/card_model.dart';
import 'package:card_stack_widget/model/card_orientation.dart';
import 'package:card_stack_widget/widget/card_stack_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/database/i_ticket_dao.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/header_widget.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/ticket_card_widget.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/travel_ticket_card_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  bool _isLoading = true;
  List<Ticket> _travelTickets = [];
  List<Ticket> _eventTickets = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTicketData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTicketData();
    }
  }

  Future<void> _loadTicketData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final tickets = await getIt<ITicketDao>().getAllTickets();

      if (!mounted) return;

      final travelTickets = <Ticket>[];
      final eventTickets = <Ticket>[];

      for (final ticket in tickets) {
        switch (ticket.type) {
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

  @override
  Widget build(BuildContext context) {
    final cardStackList = _travelTickets.map((ticket) {
      return CardModel(
        radius: const Radius.circular(30),
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: () async {
            final wasDeleted = await context.pushNamed<bool>(
              AppRoute.ticketView.name,
              extra: ticket,
            );

            if (mounted && (wasDeleted ?? false)) {
              await _loadTicketData();
            }
          },
          child: TravelTicketCardWidget(
            ticket: ticket,
            onTicketDeleted: _loadTicketData,
          ),
        ),
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
                        ),
                      ),
                      if (_travelTickets.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            context.pushNamed(AppRoute.allTickets.name);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'View All',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        )
                      else
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
                              dismissedCardDuration: const Duration(
                                milliseconds: 150,
                              ),
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
                        ),
                      ),
                      const SizedBox(height: 16),
                      //* More cards list view
                      if (_eventTickets.isEmpty)
                        const Padding(
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
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _eventTickets.length,
                          itemBuilder: (context, index) {
                            final eventTicket = _eventTickets[index];
                            return InkWell(
                              onTap: () async {
                                final wasDeleted = await context
                                    .pushNamed<bool>(
                                      AppRoute.ticketView.name,
                                      extra: eventTicket,
                                    );

                                if (mounted && (wasDeleted ?? false)) {
                                  await _loadTicketData();
                                }
                              },
                              child: EventTicketCardWidget(
                                ticket: eventTicket,
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
