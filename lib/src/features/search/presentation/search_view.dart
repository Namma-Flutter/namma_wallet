import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_extension.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/features/home/domain/ticket_extensions.dart';
import 'package:namma_wallet/src/features/search/presentation/widgets/search_result_card_widget.dart';

/// A full-screen search view inspired by Swiggy/Zomato search UX.
///
/// Navigated to from the home page search bar. Searches across ticket fields
/// including from/to locations, transport type, PNR, and secondary text.
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<Ticket> _allTickets = [];
  List<Ticket> _searchResults = [];
  bool _isLoading = true;
  bool _hasSearched = false;

  Timer? _debounce;

  late final IHapticService _hapticService;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _hapticService = getIt<IHapticService>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    unawaited(_loadTickets());

    // Auto-focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    try {
      final tickets = await getIt<ITicketDAO>().getAllTickets();

      if (!mounted) return;

      setState(() {
        _allTickets = tickets;
        _isLoading = false;
      });
    } on Object catch (e, stackTrace) {
      getIt<ILogger>().error('Failed to load tickets for search', e, stackTrace);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    final trimmedQuery = query.trim().toLowerCase();

    if (trimmedQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      _animationController.reverse();
      return;
    }

    final results = _allTickets.where((ticket) {
      // Search across multiple ticket fields
      final primaryText = ticket.primaryText?.toLowerCase() ?? '';
      final secondaryText = ticket.secondaryText?.toLowerCase() ?? '';
      final location = ticket.location?.toLowerCase() ?? '';
      final ticketId = ticket.ticketId?.toLowerCase() ?? '';
      final fromLocation = ticket.fromLocation?.toLowerCase() ?? '';
      final toLocation = ticket.toLocation?.toLowerCase() ?? '';
      final ticketType = ticket.type?.name.toLowerCase() ?? '';

      // Also search in extras (PNR, fare, provider, etc.)
      final extrasMatch = ticket.extras?.any(
            (extra) =>
                (extra.title?.toLowerCase().contains(trimmedQuery) ?? false) ||
                (extra.value?.toLowerCase().contains(trimmedQuery) ?? false),
          ) ??
          false;

      return primaryText.contains(trimmedQuery) ||
          secondaryText.contains(trimmedQuery) ||
          location.contains(trimmedQuery) ||
          ticketId.contains(trimmedQuery) ||
          fromLocation.contains(trimmedQuery) ||
          toLocation.contains(trimmedQuery) ||
          ticketType.contains(trimmedQuery) ||
          extrasMatch;
    }).toList();

    setState(() {
      _searchResults = results;
      _hasSearched = true;
    });

    _animationController.forward();
    _hapticService.triggerHaptic(HapticType.selection);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _hasSearched = false;
    });
    _animationController.reverse();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar header
            _buildSearchHeader(theme),

            // Content area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasSearched
                      ? _buildSearchResults(theme)
                      : _buildSearchSuggestions(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () {
              _hapticService.triggerHaptic(HapticType.selection);
              context.pop();
            },
            icon: const Icon(Icons.arrow_back_rounded),
            splashRadius: 24,
          ),

          const SizedBox(width: 4),

          // Search text field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? theme.colorScheme.primary.withValues(alpha: 0.4)
                      : theme.colorScheme.outline.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by from, to, transport...',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: _clearSearch,
                          icon: Icon(
                            Icons.close_rounded,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                            size: 20,
                          ),
                          splashRadius: 20,
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    if (_searchResults.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 72,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'No tickets found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '${_searchResults.length} '
              '${_searchResults.length == 1 ? 'result' : 'results'} found',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),

          // Results list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final ticket = _searchResults[index];
                return SearchResultCardWidget(
                  ticket: ticket,
                  searchQuery: _searchController.text.trim(),
                  onTap: () async {
                    _hapticService.triggerHaptic(HapticType.selection);
                    if (ticket.ticketId == null) return;

                    await context.pushNamed(
                      AppRoute.ticketView.name,
                      pathParameters: {'id': ticket.ticketId!},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions(ThemeData theme) {
    // Show quick category chips like Swiggy/Zomato
    final categories = <_SearchCategory>[
      _SearchCategory('Bus', Icons.directions_bus_rounded, 'bus'),
      _SearchCategory('Train', Icons.train_rounded, 'train'),
      _SearchCategory('Flight', Icons.flight_rounded, 'flight'),
      _SearchCategory('Metro', Icons.subway_rounded, 'metro'),
      _SearchCategory('Event', Icons.event_rounded, 'event'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Search by category',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),

          // Category chips grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories.map((category) {
              return _buildCategoryChip(theme, category);
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Recent/popular hint
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 48,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 12),
                Text(
                  'Search your tickets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Search by from, to, PNR, transport type...',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.25),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme, _SearchCategory category) {
    return InkWell(
      onTap: () {
        _hapticService.triggerHaptic(HapticType.selection);
        _searchController.text = category.query;
        _performSearch(category.query);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchCategory {
  _SearchCategory(this.label, this.icon, this.query);

  final String label;
  final IconData icon;
  final String query;
}
