import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:namma_wallet/src/common/database/wallet_database.dart';
import 'package:namma_wallet/src/common/helper/date_time_converter.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';
import 'package:namma_wallet/src/common/widgets/custom_back_button.dart';
import 'package:namma_wallet/src/common/widgets/snackbar_widget.dart';
import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/highlight_widget.dart';
import 'package:namma_wallet/src/features/travel/presentation/widgets/custom_ticket_shape_line.dart';
import 'package:namma_wallet/src/features/travel/presentation/widgets/ticket_view_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketView extends StatefulWidget {
  const TicketView({required this.ticket, super.key});

  final GenericDetailsModel ticket;

  @override
  State<TicketView> createState() => _TicketViewState();
}

class _TicketViewState extends State<TicketView> {
  bool _isDeleting = false;
  bool _isPinning = false;

  // Helper method to handle empty values
  String getValueOrDefault(String? value) {
    return (value?.isEmpty ?? true) ? '--' : value!;
  }

  bool hasPnrOrId(GenericDetailsModel ticket) {
    return getPnrOrId(ticket) != null;
  }

  String? getPnrOrId(GenericDetailsModel ticket) {
    for (final extra in ticket.extras ?? []) {
      if (extra.title?.toLowerCase() == 'pnr number') {
        return extra.value as String;
      }
    }

    for (final extra in ticket.extras ?? []) {
      if (extra.title?.toLowerCase() == 'booking id') {
        return extra.value as String;
      }
    }
    return null;
  }

  Future<void> _pinToHomeScreen() async {
    setState(() {
      _isPinning = true;
    });

    try {
      const iOSWidgetName = 'TicketHomeWidget';
      const androidWidgetName = 'TicketHomeWidget';
      const dataKey = 'ticket_data';

      // Convert ticket to JSON format for the widget
      final ticketData = widget.ticket.toJson();
      await HomeWidget.saveWidgetData(dataKey, jsonEncode(ticketData));

      await HomeWidget.updateWidget(
          androidName: androidWidgetName, iOSName: iOSWidgetName);

      if (mounted) {
        showSnackbar(context, '📌 Ticket pinned to home screen successfully!');
      }
    } on Object catch (e) {
      developer.log('Failed to pin ticket to home screen',
          name: 'TicketView', error: e);
      if (mounted) {
        showSnackbar(context, 'Failed to pin ticket: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPinning = false;
        });
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
      await _deleteTicket();
    }
  }

  Future<void> _deleteTicket() async {
    if (widget.ticket.ticketId == null) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await WalletDatabase.instance.deleteTravelTicket(widget.ticket.ticketId!);

      developer.log(
          'Successfully deleted ticket with ID: ${widget.ticket.ticketId}',
          name: 'TicketView');

      if (mounted) {
        showSnackbar(context, 'Ticket deleted successfully');
        context.pop(true); // Return true to indicate ticket was deleted
      }
    } on Object catch (e) {
      developer.log('Failed to delete ticket', name: 'TicketView', error: e);

      if (mounted) {
        showSnackbar(context, 'Failed to delete ticket: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _makePhoneCall() async {
    final mobile = widget.ticket.contactMobile;
    if (mobile == null || mobile.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: mobile);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        developer.log('Launched phone call to $mobile', name: 'TicketView');
      } else {
        if (mounted) {
          showSnackbar(context, 'Cannot make phone calls on this device',
              isError: true);
        }
      }
    } on Object catch (e) {
      developer.log('Failed to launch phone call',
          name: 'TicketView', error: e);
      if (mounted) {
        showSnackbar(context, 'Failed to make call: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const CustomBackButton(),
        title: const Text('Ticket View'),
        actions: [
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
                        icon: const Icon(Icons.delete,
                            size: 20, color: Colors.white),
                        tooltip: 'Delete ticket',
                      ),
              ),
            ),
          const SizedBox(width: 16)
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppColor.limeYellowColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //* Icon & Service
                        Row(
                          children: [
                            CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColor.whiteColor,
                                child: Icon(
                                    widget.ticket.type == EntryType.busTicket
                                        ? Icons.airport_shuttle_outlined
                                        : Icons.tram_outlined)),
                            const SizedBox(width: 16),
                            //* Description (Secondry text)
                            Expanded(
                              child: Text(widget.ticket.secondaryText,
                                  style: SubHeading(color: Shades.s100).regular,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        //* From to To (Primary text)
                        Text(widget.ticket.primaryText,
                            style: HeadingH2Small(color: Shades.s100).bold,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3),

                        const SizedBox(height: 16),

                        //* Date - Time
                        TicketRowWidget(
                          title1: 'Journey Date',
                          title2: 'Time',
                          value1: getValueOrDefault(
                              getTime(widget.ticket.startTime)),
                          value2: getValueOrDefault(
                              getDate(widget.ticket.startTime)),
                        ),

                        if (widget.ticket.tags != null &&
                            widget.ticket.tags!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ...widget.ticket.tags!
                                  .map((tag) => HighlightChipsWidget(
                                        bgColor: const Color(0xffCADC56),
                                        label: tag.icon ?? '',
                                        icon: Icons.star_border_rounded,
                                      ))
                            ],
                          ),
                        ],

                        if (widget.ticket.extras != null &&
                            widget.ticket.extras!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0;
                                  i < widget.ticket.extras!.length;
                                  i++) ...[
                                Row(
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: Text(
                                        '${widget.ticket.extras![i].title ?? 'xxx'}: ',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Paragraph02(color: Shades.s100)
                                            .regular,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        widget.ticket.extras![i].value,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Paragraph01(color: Shades.s100)
                                            .regular,
                                      ),
                                    ),
                                  ],
                                ),
                                if (i < widget.ticket.extras!.length - 1)
                                  const SizedBox(height: 5),
                              ]
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  CustomPaint(
                    size: Size(MediaQuery.of(context).size.width * 0.95, 40),
                    painter: CustomTicketShapeLine(),
                  ),
                  if (hasPnrOrId(widget.ticket))
                    Container(
                      margin: const EdgeInsets.only(
                          bottom: 16, left: 16, right: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColor.limeYellowColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: QrImageView(
                          data: getPnrOrId(widget.ticket) ?? 'xxx',
                          size: 200,
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          // Bottom section with action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: widget.ticket.contactMobile != null &&
                      widget.ticket.contactMobile!.isNotEmpty
                  ? Row(
                      spacing: 12,
                      children: [
                        // Call button (when mobile number is available)
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _makePhoneCall,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.phone, size: 20),
                              label: const Text(
                                'Call Conductor',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Pin button
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _isPinning ? null : _pinToHomeScreen,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: _isPinning
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black54,
                                      ),
                                    )
                                  : const Icon(Icons.push_pin, size: 20),
                              label: Text(
                                _isPinning ? 'Pinning...' : 'Pin',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isPinning ? null : _pinToHomeScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isPinning
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black54,
                                ),
                              )
                            : const Icon(Icons.push_pin, size: 20),
                        label: Text(
                          _isPinning ? 'Pinning...' : 'Pin to Home Screen',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
