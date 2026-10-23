import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/tag_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_extension.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/ticket_card_widget.dart';
import 'package:namma_wallet/src/features/travel/presentation/widgets/travel_ticket_card_widget.dart';

class TicketSearchView extends StatefulWidget {
  const TicketSearchView({super.key});

  @override
  State<TicketSearchView> createState() => _TicketSearchViewState();
}

class _TicketSearchViewState extends State<TicketSearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<Ticket> _tickets = [];
  String _searchQuery = '';
  bool _isLoading = true;
  late final IHapticService _hapticService;

  List<Ticket> get _matchingTickets {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return [];

    return _tickets.where((ticket) {
      return _searchableValues(ticket).any(
        (value) => value.toLowerCase().contains(query),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _hapticService = getIt<IHapticService>();
    unawaited(_loadTickets());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    try {
      final tickets = await getIt<ITicketDAO>().getActiveTickets();
      if (!mounted) return;
      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
    } on Object catch (error, stackTrace) {
      getIt<ILogger>().error(
        'Failed to load tickets for search',
        error,
        stackTrace,
      );
      if (!mounted) return;
      showSnackbar(
        context,
        'Unable to load tickets. Please try again.',
        isError: true,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Iterable<String> _searchableValues(Ticket ticket) sync* {
    yield* [
      ticket.primaryText,
      ticket.secondaryText,
      ticket.location,
      ticket.ticketId,
    ].whereType<String>();

    for (final extra in ticket.extras ?? <ExtrasModel>[]) {
      yield* _searchableExtraValues(extra);
    }

    for (final tag in ticket.tags ?? <TagModel>[]) {
      final value = tag.value;
      if (value != null) yield value;
    }
  }

  Iterable<String> _searchableExtraValues(ExtrasModel extra) sync* {
    final title = extra.title;
    final value = extra.value;
    if (title != null) yield title;
    if (value != null) yield value;

    for (final child in extra.child ?? <ExtrasModel>[]) {
      yield* _searchableExtraValues(child);
    }
  }

  Future<void> _openTicket(Ticket ticket) async {
    final ticketId = ticket.ticketId;
    if (ticketId == null) return;

    _hapticService.triggerHaptic(HapticType.selection);
    final wasDeleted = await context.pushNamed<bool>(
      AppRoute.ticketView.name,
      pathParameters: {'id': ticketId},
    );
    if (mounted && (wasDeleted ?? false)) {
      await _loadTickets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search tickets')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              key: const Key('ticketSearchInput'),
              autofocus: true,
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by route, location, or ticket ID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        key: const Key('clearTicketSearchInput'),
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchQuery.trim().isEmpty
                ? const Center(
                    child: Text('Start typing to search your tickets'),
                  )
                : _matchingTickets.isEmpty
                ? const Center(child: Text('No matching tickets'))
                : RefreshIndicator(
                    onRefresh: _loadTickets,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _matchingTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = _matchingTickets[index];
                        final isEvent = ticket.type == TicketType.event;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            key: ValueKey('searchResult-${ticket.ticketId}'),
                            onTap: () => _openTicket(ticket),
                            borderRadius: BorderRadius.circular(16),
                            child: isEvent
                                ? EventTicketCardWidget(ticket: ticket)
                                : TravelTicketCardWidget(ticket: ticket),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
