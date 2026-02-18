import 'dart:async';

import 'package:card_stack_widget/model/card_model.dart';
import 'package:card_stack_widget/model/card_orientation.dart';
import 'package:card_stack_widget/widget/card_stack_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_extension.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/header_widget.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/ticket_card_widget.dart';
import 'package:namma_wallet/src/features/travel/presentation/widgets/travel_ticket_card_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  bool _isLoading = true;
  List<Ticket> _travelTickets = [];
  List<Ticket> _eventTickets = [];

  // Search feature variables
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late final IHapticService _hapticService;
  @override
  void initState() {
    super.initState();
    _hapticService = getIt<IHapticService>();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);
    unawaited(_loadTicketData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  List<Ticket> _filterTickets(List<Ticket> tickets) {
    if (_searchQuery.isEmpty) return tickets;

    final query = _searchQuery.toLowerCase();
    return tickets.where((ticket) {
      final pnr = ticket.ticketId?.toLowerCase() ?? '';
      final primary = ticket.primaryText?.toLowerCase() ?? '';
      final secondary = ticket.secondaryText?.toLowerCase() ?? '';
      final type = ticket.type?.name.toLowerCase() ?? '';

      final hasExtraMatch =
          ticket.extras?.any((extra) {
            final title = extra.title?.toLowerCase() ?? '';
            final value = extra.value?.toLowerCase() ?? '';
            return title.contains(query) || value.contains(query);
          }) ??
          false;

      return pnr.contains(query) ||
          primary.contains(query) ||
          secondary.contains(query) ||
          type.contains(query) ||
          hasExtraMatch;
    }).toList();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_loadTicketData());
    }
  }

  Future<void> _loadTicketData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final tickets = await getIt<ITicketDAO>().getAllTickets();

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
          case null:
            eventTickets.add(ticket);
        }
      }
      if (!mounted) return;
      setState(() {
        _travelTickets = travelTickets;
        _eventTickets = eventTickets;
        _isLoading = false;
      });

      if (mounted) {
        _hapticService.triggerHaptic(HapticType.selection);
      }
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
    final filteredTravelTickets = _filterTickets(_travelTickets);
    final filteredEventTickets = _filterTickets(_eventTickets);

    final cardStackList = filteredTravelTickets.map((ticket) {
      return CardModel(
        radius: const Radius.circular(30),
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: () async {
            _hapticService.triggerHaptic(HapticType.selection);
            if (ticket.ticketId == null) return;

            final wasDeleted = await context.pushNamed<bool>(
              AppRoute.ticketView.name,
              pathParameters: {'id': ticket.ticketId!},
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
                UserProfileWidget(),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search PNR, City, Transport...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,

                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),

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
                      if (filteredTravelTickets.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            await context.pushNamed(AppRoute.allTickets.name);
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
                  filteredTravelTickets.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.airplane_ticket_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No tickets match your search'
                                      : 'No travel tickets found',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_searchQuery.isEmpty)
                                  const Text(
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
                      if (filteredEventTickets.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? 'No events match your search'
                                  : 'No event tickets found',
                              style: const TextStyle(
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
                          itemCount: filteredEventTickets.length,
                          itemBuilder: (context, index) {
                            final eventTicket = filteredEventTickets[index];
                            return InkWell(
                              onTap: () async {
                                if (eventTicket.ticketId == null) return;

                                final wasDeleted = await context
                                    .pushNamed<bool>(
                                      AppRoute.ticketView.name,
                                      pathParameters: {
                                        'id': eventTicket.ticketId!,
                                      },
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
