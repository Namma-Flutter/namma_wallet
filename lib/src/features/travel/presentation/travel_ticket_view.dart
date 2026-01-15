import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/tag_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_extension.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/common/widgets/rounded_back_button.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/home/domain/ticket_extensions.dart';
import 'package:namma_wallet/src/features/travel/presentation/widgets/travel_row_widget.dart';
import 'package:namma_wallet/src/features/travel/presentation/widgets/travel_ticket_shape_line.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TravelTicketView extends StatefulWidget {
  const TravelTicketView({required this.ticket, super.key});

  final Ticket ticket;

  @override
  State<TravelTicketView> createState() => _TravelTicketViewState();
}

class _TravelTicketViewState extends State<TravelTicketView> {
  bool _isDeleting = false;

  // Helper method to handle empty values
  String getValueOrDefault(String? value) {
    return (value?.isEmpty ?? true) ? '--' : value!;
  }

  // Helper methods moved to TicketExtrasExtension in ticket_extensions.dart

  List<ExtrasModel> getFilteredExtras(Ticket ticket) {
    if (ticket.extras == null) return [];

    // Filter out From and To if both exist
    final from = ticket.fromLocation;
    final to = ticket.toLocation;

    if (from != null && to != null) {
      return ticket.extras!.where((extra) {
        final title = extra.title?.toLowerCase();
        return title != 'from' && title != 'to';
      }).toList();
    }

    return ticket.extras!;
  }

  List<TagModel> getFilteredTags(Ticket ticket) {
    if (ticket.tags == null) return [];
    return ticket.tags!;
  }

  Future<void> _pinToHomeScreen() async {
    try {
      const iOSWidgetName = 'TicketWidget';
      const androidWidgetName = 'TicketHomeWidget';
      const dataKey = 'ticket_data';

      // Convert ticket to JSON format for the widget
      // toJson() already returns a JSON string, no need to encode again
      final ticketData = widget.ticket.toJson();
      await HomeWidget.saveWidgetData(dataKey, ticketData);

      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
      );

      if (mounted) {
        showSnackbar(context, 'Ticket pinned to home screen successfully!');
      }
    } on Object catch (e, stackTrace) {
      getIt<ILogger>().error(
        '[TravelTicketView] Failed to pin ticket to home screen',
        e,
        stackTrace,
      );
      if (mounted) {
        showSnackbar(context, 'Failed to pin ticket: $e', isError: true);
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    if (widget.ticket.ticketId == null) {
      showSnackbar(context, 'Cannot delete this ticket', isError: true);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ticket'),
        content: const Text('Are you sure you want to delete this ticket?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (mounted && (confirmed ?? false)) {
      getIt<IHapticService>().triggerHaptic(
        HapticType.selection,
      );
      await _deleteTicket();
    }
  }

  Future<void> _deleteTicket() async {
    if (widget.ticket.ticketId == null) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await getIt<ITicketDAO>().deleteTicket(widget.ticket.ticketId!);

      getIt<ILogger>().info(
        '[TravelTicketView] Successfully deleted ticket with '
        'ID: ${widget.ticket.ticketId}',
      );

      if (mounted) {
        final hapticService = getIt<IHapticService>();

        showSnackbar(context, 'Ticket deleted successfully');
        hapticService.triggerHaptic(
          HapticType.success,
        );
        context.pop(true); // Return true to indicate ticket was deleted
      }
    } on Object catch (e, stackTrace) {
      getIt<ILogger>().error(
        '[TravelTicketView] Failed to delete ticket',
        e,
        stackTrace,
      );

      if (mounted) {
        final hapticService = getIt<IHapticService>();

        showSnackbar(context, 'Failed to delete ticket: $e', isError: true);

        hapticService.triggerHaptic(
          HapticType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const RoundedBackButton(),
        title: const Text('Ticket View'),
        actions: [
          Center(
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: IconButton(
                onPressed: _pinToHomeScreen,
                icon: const Icon(
                  Icons.push_pin_outlined,
                  size: 20,
                  color: Colors.white,
                ),
                tooltip: 'Pin to home screen',
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (widget.ticket.ticketId != null)
            Center(
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.red.shade400,
                child: _isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : IconButton(
                        onPressed: _isDeleting ? null : _showDeleteConfirmation,
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.white,
                        ),
                        tooltip: 'Delete ticket',
                      ),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //* Icon & Service
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(
                          widget.ticket.type == TicketType.bus
                              ? Icons.airport_shuttle_outlined
                              : Icons.tram_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      //* Description (Secondary text)
                      Expanded(
                        child: Text(
                          widget.ticket.secondaryText,
                          style: Paragraph03(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface,
                          ).regular,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  //* Route Display (From → To with chips)
                  ...() {
                    final from = widget.ticket.fromLocation;
                    final to = widget.ticket.toLocation;

                    if (from != null && to != null) {
                      return <Widget>[
                        // Origin chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.1),
                              width: 0.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: 0.05,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.trip_origin,
                                size: 20,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  from,
                                  style: Paragraph02(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ).semiBold,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Arrow
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            child: Icon(
                              Icons.arrow_downward_rounded,
                              size: 24,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(
                                    alpha: 0.6,
                                  ),
                            ),
                          ),
                        ),

                        // Destination chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.1),
                              width: 0.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: 0.05,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 20,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  to,
                                  style: Paragraph02(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ).semiBold,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    } else {
                      // Fallback to primaryText
                      return <Widget>[
                        Text(
                          widget.ticket.primaryText,
                          style: Paragraph01(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface,
                          ).semiBold,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ];
                    }
                  }(),

                  const SizedBox(height: 12),

                  //* Date - Time
                  TravelRowWidget(
                    title1: 'Journey Date',
                    title2: 'Time',
                    value1: widget.ticket.startTime != null
                        ? DateTimeConverter.instance.formatDate(
                            widget.ticket.startTime!,
                          )
                        : 'Unknown',
                    value2: widget.ticket.startTime != null
                        ? DateTimeConverter.instance.formatTime(
                            widget.ticket.startTime!,
                          )
                        : 'Unknown',
                  ),

                  const SizedBox(height: 16),

                  ...() {
                    final filteredExtras = getFilteredExtras(
                      widget.ticket,
                    );
                    if (filteredExtras.isEmpty) return <Widget>[];

                    return <Widget>[
                      const SizedBox(height: 12),
                      // 2-column grid layout
                      for (var i = 0; i < filteredExtras.length; i += 2)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left item
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      filteredExtras[i].title ?? '-',
                                      style: Paragraph03(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface.withValues(
                                              alpha: 0.7,
                                            ),
                                      ).regular,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      filteredExtras[i].value ?? '-',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: Paragraph03(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ).semiBold,
                                    ),
                                  ],
                                ),
                              ),
                              // Right item (if exists)
                              if (i + 1 < filteredExtras.length)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        filteredExtras[i + 1].title ?? '-',
                                        style: Paragraph03(
                                          color:
                                              Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface
                                                  .withValues(
                                                    alpha: 0.7,
                                                  ),
                                        ).regular,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        filteredExtras[i + 1].value ?? '-',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        textAlign: TextAlign.end,
                                        style: Paragraph03(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ).semiBold,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                const Expanded(child: SizedBox()),
                            ],
                          ),
                        ),
                    ];
                  }(),
                ],
              ),
            ),
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width * 0.95, 40),
              painter: TravelTicketShapeLine(
                backgroundColor: Theme.of(context).colorScheme.surface,
                dashedLineColor: Theme.of(context).colorScheme.onSurface
                    .withValues(
                      alpha: 0.3,
                    ),
              ),
            ),
            if (widget.ticket.hasPnrOrId)
              Container(
                margin: const EdgeInsets.only(
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: QrImageView(
                    data: widget.ticket.pnrOrId ?? 'xxx',
                    size: 200,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
