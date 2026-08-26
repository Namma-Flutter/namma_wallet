import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/routing/app_routes.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/features/receive/domain/shared_content_result.dart';

/// Success screen displayed when data is successfully shared to the application
class ShareSuccessView extends StatelessWidget {
  const ShareSuccessView({
    required this.result,
    super.key,
  });

  final TicketCreatedResult result;

  /// Determine if this is an update operation
  // TODO(KV): This `isUpdate` is only specified for TNSTC, need to work on this
  bool get isUpdate =>
      result.title == 'Ticket Updated' ||
      result.subtitle == 'Conductor Details';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? theme.scaffoldBackgroundColor
          : AppColor.specialColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isUpdate
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUpdate ? Icons.update : Icons.check_circle,
                  size: 80,
                  color: isUpdate
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                isUpdate
                    ? 'Ticket Updated Successfully!'
                    : 'Ticket Added Successfully!',
                style: HeadingH3(color: theme.colorScheme.onSurface).bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                isUpdate
                    ? 'Conductor details have been updated for your ticket'
                    : 'Your ticket has been saved to your wallet',
                style: Paragraph02(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ).regular,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              if (!isUpdate)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (result.ticketId != null) ...[
                        _DetailRow(
                          label: 'Ticket ID',
                          value: result.ticketId,
                          theme: theme,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _DetailRow(
                        label: _getTitleLabel(result.ticketType),
                        value: result.title,
                        theme: theme,
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        label: _getDateLabel(result.ticketType),
                        value: result.date,
                        theme: theme,
                      ),
                      if (result.subtitle != null) ...[
                        const SizedBox(height: 16),
                        _DetailRow(
                          label: _getSubtitleLabel(result.ticketType),
                          value: result.subtitle,
                          theme: theme,
                          isHighlighted: true,
                        ),
                      ],
                    ],
                  ),
                ),

              if (isUpdate)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        label: 'Ticket ID',
                        value: result.ticketId,
                        theme: theme,
                      ),
                      const SizedBox(height: 16),

                      _DetailRow(
                        label: 'Update Type',
                        value: result.subtitle,
                        theme: theme,
                      ),
                      const SizedBox(height: 16),

                      _DetailRow(
                        label: 'Updated',
                        value: result.date,
                        theme: theme,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Action Buttons
              Column(
                children: [
                  // View Ticket Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go(AppRoute.home.path);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isUpdate ? 'View Updated Ticket' : 'View My Tickets',
                        style: Paragraph01(color: Colors.white).semiBold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: () {
                        context.go(AppRoute.home.path);
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Done',
                        style: Paragraph01(
                          color: AppColor.primaryBlue,
                        ).semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitleLabel(TicketType? type) {
    if (type == TicketType.event) return 'Event';
    if (type == TicketType.flight) return 'Flight';
    return 'Route';
  }

  String _getDateLabel(TicketType? type) {
    if (type == TicketType.event) return 'Date';
    return 'Journey Date';
  }

  String _getSubtitleLabel(TicketType? type) {
    if (type == TicketType.event) return 'Venue / Details';
    if (type == TicketType.flight) return 'Class / Seats';
    return 'Bus / Train Info';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isHighlighted = false,
  });

  final String label;
  final String? value;
  final ThemeData theme;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Paragraph03(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ).regular,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value ?? 'Unknown',
            style: isHighlighted
                ? Paragraph02(color: AppColor.primaryBlue).semiBold
                : Paragraph02(color: theme.colorScheme.onSurface).semiBold,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
