import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:namma_wallet/src/common/database/ticket_dao_interface.dart';
import 'package:namma_wallet/src/common/di/locator.dart';
import 'package:namma_wallet/src/common/domain/models/extras_model.dart';
import 'package:namma_wallet/src/common/domain/models/ticket.dart';
import 'package:namma_wallet/src/common/enums/ticket_type.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_extension.dart';
import 'package:namma_wallet/src/common/services/haptic/haptic_service_interface.dart';
import 'package:namma_wallet/src/common/services/logger/logger_interface.dart';
import 'package:namma_wallet/src/common/services/ticket_change_notifier.dart';
import 'package:namma_wallet/src/common/services/widget/widget_service_interface.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/common/widgets/rounded_back_button.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/home/domain/ticket_extensions.dart';
import 'package:namma_wallet/src/features/travel/presentation/widgets/travel_row_widget.dart';
import 'package:namma_wallet/src/features/travel/presentation/widgets/travel_ticket_shape_line.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class TravelTicketView extends StatefulWidget {
  const TravelTicketView({
    required this.ticket,
    this.openedFromImport = false,
    super.key,
  });

  final Ticket ticket;
  final bool openedFromImport;

  @override
  State<TravelTicketView> createState() => _TravelTicketViewState();
}

class _TravelTicketViewState extends State<TravelTicketView> {
  bool _isDeleting = false;
  bool _isSharing = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _callConductor(String phoneNumber) async {
    final dialable = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (dialable.isEmpty) {
      showSnackbar(context, 'Invalid conductor phone number', isError: true);
      return;
    }

    final uri = Uri(scheme: 'tel', path: dialable);
    try {
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(uri);
        if (launched) return;
      }
    } on Exception catch (e, stackTrace) {
      getIt<ILogger>().error(
        '[TravelTicketView] Failed to launch dialer',
        e,
        stackTrace,
      );
    }

    if (!mounted) return;
    showSnackbar(context, 'Could not open dialer', isError: true);
  }

  Future<void> _pinToHomeScreen() async {
    const iOSWidgetName = 'TicketWidget';
    const androidWidgetName = 'TicketHomeWidget';
    const dataKey = 'ticket_data';

    try {
      if (Platform.isIOS) {
        await HomeWidget.saveWidgetData(dataKey, widget.ticket.toJson());
        await HomeWidget.updateWidget(
          androidName: androidWidgetName,
          iOSName: iOSWidgetName,
        );
      } else if (Platform.isAndroid) {
        await getIt<IWidgetService>().updateWidgetWithTicket(widget.ticket);
      } else {
        throw UnsupportedError('Unsupported platform');
      }

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
      getIt<IHapticService>().triggerHaptic(HapticType.selection);
      await _deleteTicket();
    }
  }

  Future<void> _deleteTicket() async {
    if (widget.ticket.ticketId == null) return;

    setState(() => _isDeleting = true);

    try {
      await getIt<ITicketDAO>().deleteTicket(widget.ticket.ticketId!);
      getIt<TicketChangeNotifier>().notifyTicketChanged();
      await _clearWidgetIfPinned();

      getIt<ILogger>().info(
        '[TravelTicketView] Successfully deleted ticket with '
        'ID: ${widget.ticket.ticketId}',
      );

      if (mounted) {
        final hapticService = getIt<IHapticService>();
        showSnackbar(context, 'Ticket deleted successfully');
        hapticService.triggerHaptic(HapticType.success);

        if (context.canPop()) {
          context.pop(true);
        } else {
          getIt<ILogger>().info(
            '[TravelTicketView] No navigation history after delete, '
            'navigating to home',
          );
          context.go('/');
        }
      }
    } on Object catch (e, stackTrace) {
      getIt<ILogger>().error(
        '[TravelTicketView] Failed to delete ticket',
        e,
        stackTrace,
      );

      if (mounted) {
        showSnackbar(context, 'Failed to delete ticket: $e', isError: true);
        getIt<IHapticService>().triggerHaptic(HapticType.error);
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _clearWidgetIfPinned() async {
    const dataKey = 'ticket_data';
    const iOSWidgetName = 'TicketWidget';
    const androidWidgetName = 'TicketHomeWidget';

    try {
      final pinnedData = await HomeWidget.getWidgetData<String>(dataKey);
      if (pinnedData == null) return;

      final ticketId = widget.ticket.ticketId;
      if (ticketId != null && pinnedData.contains('"ticket_id":"$ticketId"')) {
        await HomeWidget.saveWidgetData<String>(dataKey, null);
        await HomeWidget.updateWidget(
          androidName: androidWidgetName,
          iOSName: iOSWidgetName,
        );
        getIt<ILogger>().info(
          '[TravelTicketView] Cleared widget data for deleted ticket',
        );
      }
    } on Object catch (e, stackTrace) {
      getIt<ILogger>().error(
        '[TravelTicketView] Failed to clear widget data',
        e,
        stackTrace,
      );
    }
  }

  Future<void> _shareTicket() async {
    setState(() => _isSharing = true);

    try {
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final screenWidth = MediaQuery.of(context).size.width;
      final imageBytes = await _screenshotController.captureFromLongWidget(
        InheritedTheme.captureAll(
          context,
          MediaQuery(
            data: MediaQuery.of(context),
            child: Material(
              type: MaterialType.transparency,
              child: _TicketCardContent(
                ticket: widget.ticket,
                forScreenshot: true,
              ),
            ),
          ),
        ),
        pixelRatio: pixelRatio,
        context: context,
        constraints: BoxConstraints(maxWidth: screenWidth),
      );

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File(
        '${directory.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await imagePath.writeAsBytes(imageBytes);

      final title = widget.ticket.primaryText ?? 'My Ticket';
      final journeyDate = widget.ticket.startTime != null
          ? '${DateTimeConverter.instance.formatDate(widget.ticket.startTime!)} at ${DateTimeConverter.instance.formatTime(widget.ticket.startTime!)}'
          : null;

      final shareText = [
        '🎫 $title',
        if (journeyDate != null) '📅 $journeyDate',
        '',
        'Managed with Namma Wallet – your smart travel companion.',
        '📲 Android: https://play.google.com/store/apps/details?id=com.nammaflutter.nammawallet',
        '🍎 iOS: https://apps.apple.com/in/app/namma-wallet/id6757295408',
      ].join('\n');

      // shareXFiles is the correct API; suppressing the unrelated deprecation
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(imagePath.path)], text: shareText);
    } on Object catch (e, stackTrace) {
      getIt<ILogger>().error(
        '[TravelTicketView] Failed to share ticket',
        e,
        stackTrace,
      );
      if (mounted) {
        showSnackbar(context, 'Failed to share ticket: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
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
          if (_isSharing || _isDeleting)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                switch (value) {
                  case 'pin':
                    await _pinToHomeScreen();
                  case 'share':
                    await _shareTicket();
                  case 'delete':
                    await _showDeleteConfirmation();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'pin',
                  child: ListTile(
                    leading: Icon(Icons.push_pin_outlined),
                    title: Text('Pin to home screen'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share_outlined),
                    title: Text('Share ticket'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (widget.ticket.ticketId != null)
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(
                        Icons.delete,
                        color: Colors.red.shade400,
                      ),
                      title: Text(
                        'Delete ticket',
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: _TicketCardContent(
          ticket: widget.ticket,
          onCallConductor: _callConductor,
        ),
      ),
    );
  }
}

class _TicketCardContent extends StatelessWidget {
  const _TicketCardContent({
    required this.ticket,
    this.forScreenshot = false,
    this.onCallConductor,
  });

  final Ticket ticket;
  final bool forScreenshot;
  final void Function(String phoneNumber)? onCallConductor;

  String? get _conductorPhone {
    final value =
        ticket.getExtraByTitle('conductor contact') ??
        ticket.getExtraByTitle('conductor mobile no');
    if (value == null) return null;
    final cleaned = value.trim();
    if (cleaned.isEmpty || cleaned == '--') return null;
    return cleaned;
  }

  List<ExtrasModel> get _filteredExtras {
    if (ticket.extras == null) return [];
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

  @override
  Widget build(BuildContext context) {
    final conductorPhone = _conductorPhone;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                if (ticket.imagePath != null)
                  Builder(
                    builder: (context) {
                      final file = File(ticket.imagePath!);
                      if (!file.existsSync()) return const SizedBox.shrink();
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              file,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                getIt<ILogger>().error(
                                  '[TravelTicketView] Failed to load '
                                  'ticket image from path: '
                                  '${ticket.imagePath}',
                                  error,
                                  stackTrace,
                                );
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        ticket.type == TicketType.bus
                            ? Icons.airport_shuttle_outlined
                            : Icons.tram_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (ticket.secondaryText?.isNotEmpty ?? false)
                      Expanded(
                        child: Text(
                          ticket.secondaryText ?? '',
                          style: Paragraph03(
                            color: Theme.of(context).colorScheme.onSurface,
                          ).regular,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._buildRoute(context),
                const SizedBox(height: 12),
                TravelRowWidget(
                  title1: 'Journey Date',
                  title2: 'Time',
                  value1: ticket.startTime != null
                      ? DateTimeConverter.instance.formatDate(ticket.startTime!)
                      : 'Unknown',
                  value2: ticket.startTime != null
                      ? DateTimeConverter.instance.formatTime(ticket.startTime!)
                      : 'Unknown',
                ),
                const SizedBox(height: 16),
                if (!forScreenshot && ticket.directionsUrl != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          final uri = Uri.parse(ticket.directionsUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else if (context.mounted) {
                            showSnackbar(
                              context,
                              'Could not open map URL',
                              isError: true,
                            );
                          }
                        } on FormatException {
                          if (context.mounted) {
                            showSnackbar(
                              context,
                              'Invalid directional URL',
                              isError: true,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Get Directions'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ..._buildExtras(context),
              ],
            ),
          ),
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width * 0.95, 40),
            painter: TravelTicketShapeLine(
              backgroundColor: Theme.of(context).colorScheme.surface,
              dashedLineColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          if (ticket.hasPnrOrId)
            Container(
              margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
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
                  data: ticket.pnrOrId ?? 'xxx',
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
          if (!forScreenshot && conductorPhone != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => onCallConductor?.call(conductorPhone),
                  icon: const Icon(Icons.call),
                  label: const Text('Call Conductor'),
                  style: FilledButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),
          if (forScreenshot)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wallet,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'by Namma Wallet',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.4,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildRoute(BuildContext context) {
    final from = ticket.fromLocation;
    final to = ticket.toLocation;

    if (from != null && to != null) {
      return [
        _LocationChip(icon: Icons.trip_origin, location: from),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Icon(
              Icons.arrow_downward_rounded,
              size: 24,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
        ),
        _LocationChip(icon: Icons.location_on, location: to),
      ];
    }

    final primaryText = ticket.primaryText;
    if (primaryText == null || primaryText.isEmpty) return [];
    return [
      Text(
        primaryText,
        style: Paragraph01(
          color: Theme.of(context).colorScheme.onSurface,
        ).semiBold,
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
      ),
    ];
  }

  List<Widget> _buildExtras(BuildContext context) {
    final extras = _filteredExtras;
    if (extras.isEmpty) return [];

    return [
      const SizedBox(height: 12),
      for (var i = 0; i < extras.length; i += 2)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ExtraCell(extra: extras[i], align: TextAlign.start),
              ),
              if (i + 1 < extras.length)
                Expanded(
                  child: _ExtraCell(extra: extras[i + 1], align: TextAlign.end),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
    ];
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.icon, required this.location});

  final IconData icon;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              location,
              style: Paragraph02(
                color: Theme.of(context).colorScheme.onSurface,
              ).semiBold,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtraCell extends StatelessWidget {
  const _ExtraCell({required this.extra, required this.align});

  final ExtrasModel extra;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final isEnd = align == TextAlign.end;
    return Column(
      crossAxisAlignment: isEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          extra.title ?? '-',
          style: Paragraph03(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ).regular,
        ),
        const SizedBox(height: 4),
        Text(
          extra.value ?? '-',
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: align,
          style: Paragraph03(
            color: Theme.of(context).colorScheme.onSurface,
          ).semiBold,
        ),
      ],
    );
  }
}
