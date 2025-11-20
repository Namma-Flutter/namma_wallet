import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/logger_interface.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';
import 'package:namma_wallet/src/features/home/domain/ticket_extensions.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/ticket_card_widget.dart';

class AllTicketsView extends StatefulWidget {
  const AllTicketsView({super.key});

  @override
  State<AllTicketsView> createState() => _AllTicketsViewState();
}

class _AllTicketsViewState extends State<AllTicketsView> {
  bool _isLoading = true;
  List<Ticket> _allTickets = [];
  String _selectedFilter = 'All';

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

      final tickets = await getIt<ITicketDAO>().getAllTickets();

      if (!mounted) return;

      setState(() {
        _allTickets = tickets;
        _isLoading = false;
      });
    } on Object catch (e, stackTrace) {
      getIt<ILogger>().error('Failed to load tickets', e, stackTrace);

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

  List<Ticket> get _filteredTickets {
    if (_selectedFilter == 'All') {
      return _allTickets;
    }

    return _allTickets.where((ticket) {
      switch (_selectedFilter) {
        case 'Travel':
          return ticket.type == TicketType.bus ||
              ticket.type == TicketType.train ||
              ticket.type == TicketType.flight ||
              ticket.type == TicketType.metro;
        case 'Events':
          return ticket.type == TicketType.event;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tickets'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Travel'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Events'),
                ],
              ),
            ),
          ),

          // Ticket count
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filteredTickets.length} '
                  '${_filteredTickets.length == 1 ? 'ticket' : 'tickets'}'
                  '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Tickets list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.airplane_ticket_outlined,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tickets found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedFilter == 'All'
                              ? 'Add tickets to get started'
                              : 'No $_selectedFilter tickets available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTicketData,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _filteredTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = _filteredTickets[index];
                        final isEventTicket = ticket.type == TicketType.event;

                        return InkWell(
                          onTap: () async {
                            final wasDeleted = await context.pushNamed<bool>(
                              AppRoute.ticketView.name,
                              extra: ticket,
                            );

                            if (mounted && (wasDeleted ?? false)) {
                              await _loadTicketData();
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: isEventTicket
                              ? EventTicketCardWidget(ticket: ticket)
                              : TravelTicketListCardWidget(
                                  ticket: ticket,
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

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
      backgroundColor: isSelected
          ? null
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline,
        width: isSelected ? 2 : 1,
      ),
      elevation: isSelected ? 2 : 0,
    );
  }
}

// A compact card widget for travel tickets in list view
class TravelTicketListCardWidget extends StatelessWidget {
  const TravelTicketListCardWidget({
    required this.ticket,
    super.key,
  });

  final Ticket ticket;

  IconData _getTicketIcon() {
    return switch (ticket.type) {
      TicketType.bus => Icons.directions_bus_rounded,
      TicketType.train => Icons.train_rounded,
      TicketType.flight => Icons.flight_rounded,
      TicketType.metro => Icons.subway_rounded,
      TicketType.event => Icons.event_rounded,
    };
  }

  Color _getTicketColor(BuildContext context) {
    // Use consistent primary blue theme for all tickets
    return AppColor.primaryBlue;
  }

  String _getFromLocation() {
    // Use centralized ticket extension for consistent route parsing
    return ticket.fromLocation ?? ticket.primaryText.split('→')[0].trim();
  }

  String _getToLocation() {
    // Use centralized ticket extension for consistent route parsing
    final to = ticket.toLocation;
    if (to != null) return to;

    // Fallback: parse from primaryText if extension returns null
    final parts = ticket.primaryText.split('→');
    return parts.length > 1 ? parts[1].trim() : '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getTicketColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTicketIcon(),
              color: _getTicketColor(context),
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // Ticket details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // From location
                Row(
                  children: [
                    SizedBox(
                      width: 12,
                      child: Icon(
                        Icons.trip_origin,
                        size: 12,
                        color: _getTicketColor(context),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _getFromLocation(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1, bottom: 1),
                  child: SizedBox(
                    width: 12,
                    child: Icon(
                      Icons.more_vert,
                      size: 12,
                      color: _getTicketColor(context).withValues(alpha: 0.5),
                    ),
                  ),
                ),
                // To location
                Row(
                  children: [
                    SizedBox(
                      width: 12,
                      child: Icon(
                        Icons.location_on,
                        size: 12,
                        color: _getTicketColor(context),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _getToLocation(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Secondary info (train/bus number, etc.)
                Text(
                  ticket.secondaryText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Date and time
                Text(
                  '${formatDate(ticket.startTime)} • '
                  '${formatTime(ticket.startTime)}'
                  '',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Chevron icon
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
