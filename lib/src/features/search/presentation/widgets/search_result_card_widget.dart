import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/features/home/domain/ticket_extensions.dart';

/// A compact search result card showing title and subtitle only.
///
/// Inspired by Swiggy/Zomato search result cards — clean and minimal,
/// displaying just enough info to identify the ticket.
class SearchResultCardWidget extends StatelessWidget {
  const SearchResultCardWidget({
    required this.ticket,
    required this.searchQuery,
    required this.onTap,
    super.key,
  });

  final Ticket ticket;
  final String searchQuery;
  final VoidCallback onTap;

  IconData _getTicketIcon() {
    return switch (ticket.type) {
      TicketType.bus => Icons.directions_bus_rounded,
      TicketType.train => Icons.train_rounded,
      TicketType.flight => Icons.flight_rounded,
      TicketType.metro => Icons.subway_rounded,
      TicketType.event => Icons.event_rounded,
      null => Icons.confirmation_number_outlined,
    };
  }

  String _getTitle() {
    // Show from → to if available, else primary text
    final from = ticket.fromLocation;
    final to = ticket.toLocation;

    if (from != null && from.isNotEmpty && to != null && to.isNotEmpty) {
      return '$from → $to';
    }

    return ticket.primaryText ?? 'Untitled Ticket';
  }

  String _getSubtitle() {
    final parts = <String>[];

    // Transport type
    if (ticket.type != null) {
      parts.add(
        ticket.type!.name[0].toUpperCase() + ticket.type!.name.substring(1),
      );
    }

    // Secondary text (train number, class, etc.)
    if (ticket.secondaryText != null && ticket.secondaryText!.isNotEmpty) {
      parts.add(ticket.secondaryText!);
    }

    return parts.isNotEmpty ? parts.join(' • ') : '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _getTitle();
    final subtitle = _getSubtitle();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getTicketIcon(),
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with highlighted search match
                    _HighlightedText(
                      text: title,
                      query: searchQuery,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      highlightColor: theme.colorScheme.primary.withValues(
                        alpha: 0.15,
                      ),
                      maxLines: 1,
                    ),

                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      _HighlightedText(
                        text: subtitle,
                        query: searchQuery,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.55,
                          ),
                        ),
                        highlightColor: theme.colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Arrow
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Highlights matching text portions within a string.
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    required this.highlightColor,
    this.maxLines,
  });

  final String text;
  final String query;
  final TextStyle style;
  final Color highlightColor;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    var start = 0;
    var index = lowerText.indexOf(lowerQuery, start);

    while (index != -1) {
      // Add non-matching text before the match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      // Add highlighted matching text
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: TextStyle(
            backgroundColor: highlightColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text after last match
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
