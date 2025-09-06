import 'package:flutter/material.dart';
import 'package:namma_wallet/styles/styles.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/models.dart';
import 'components/components.dart';

class TicketView extends StatefulWidget {
  const TicketView({super.key, required this.ticket});
  final TNSTCModel ticket;

  @override
  State<TicketView> createState() => _TicketViewState();
}

class _TicketViewState extends State<TicketView> {
  // Helper method to handle empty values
  String getValueOrDefault(String? value) {
    return (value?.isEmpty ?? true) ? "--" : value!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.quaternaryColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.quaternaryColor,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColor.primaryColor,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.chevron_left, size: 28),
              ),
            ),
          ),
        ),
        title:
            Text('Ticket View', style: HeadingH6(color: Shades.s100).regular),
        actions: const [
          Center(
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColor.primaryColor,
              child: Icon(Icons.more_horiz, size: 28),
            ),
          ),
          SizedBox(width: 16)
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColor.periwinkleBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BuildRow(
                  title1: getValueOrDefault(widget.ticket.corporation),
                  title2: getValueOrDefault(widget.ticket.service),
                ),
                const SizedBox(height: 16),
                const BuildFromToRow(),
                const SizedBox(height: 16),
                BuildRow(
                  title1: 'Journey Date',
                  title2: 'Time',
                  value1: getValueOrDefault(widget.ticket.journeyDate),
                  value2: getValueOrDefault(widget.ticket.time),
                ),
                const SizedBox(height: 16),
                BuildRow(
                  title1: 'PNR No.',
                  title2: 'Trip Code',
                  value1: getValueOrDefault(widget.ticket.pnrNo),
                  value2: getValueOrDefault(widget.ticket.tripCode),
                ),
                const SizedBox(height: 16),
                BuildLabelValue(
                    label: 'Seat Numbers',
                    value: widget.ticket.seatNumbers.isEmpty
                        ? "--"
                        : widget.ticket.seatNumbers.join(', ')),
                const SizedBox(height: 16),
                BuildLabelValue(
                    label: 'Class',
                    value: getValueOrDefault(widget.ticket.ticketClass)),
                const SizedBox(height: 16),
                BuildLabelValue(
                    label: 'Boarding At',
                    value: getValueOrDefault(widget.ticket.boardingAt)),
              ],
            ),
          ),
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width * 0.95, 40),
            painter: CustomTicketShapeLine(),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColor.periwinkleBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: QrImageView(
                data: getValueOrDefault(widget.ticket.pnrNo),
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
