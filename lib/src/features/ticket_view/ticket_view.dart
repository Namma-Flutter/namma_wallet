import 'package:flutter/material.dart';
import 'package:namma_wallet/styles/styles.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/models.dart';
import 'components/components.dart';

class TicketView extends StatefulWidget {
  const TicketView({super.key, required this.ticket});
  final TicketModel ticket;

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
                _buildRow(
                  getValueOrDefault(widget.ticket.corporation),
                  getValueOrDefault(widget.ticket.service),
                ),
                const SizedBox(height: 16),
                _buildFromToRow(),
                const SizedBox(height: 16),
                _buildRow(
                  'Journey Date',
                  'Time',
                  getValueOrDefault(widget.ticket.journeyDate),
                  getValueOrDefault(widget.ticket.time),
                ),
                const SizedBox(height: 16),
                _buildRow(
                  'PNR No.',
                  'Trip Code',
                  getValueOrDefault(widget.ticket.pnrNo),
                  getValueOrDefault(widget.ticket.tripCode),
                ),
                const SizedBox(height: 16),
                _buildLabelValue(
                    'Seat Numbers',
                    widget.ticket.seatNumbers.isEmpty
                        ? "--"
                        : widget.ticket.seatNumbers.join(', ')),
                const SizedBox(height: 16),
                _buildLabelValue(
                    'Class', getValueOrDefault(widget.ticket.ticketClass)),
                const SizedBox(height: 16),
                _buildLabelValue(
                    'Boarding At', getValueOrDefault(widget.ticket.boardingAt)),
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

  Widget _buildFromToRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From', style: Paragraph02(color: Shades.s0).regular),
              Text(
                getValueOrDefault(widget.ticket.from),
                style: HeadingH6(color: Shades.s0).semiBold,
                textAlign: TextAlign.start,
                overflow: TextOverflow.clip,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('To', style: Paragraph02(color: Shades.s0).regular),
              Text(
                getValueOrDefault(widget.ticket.to),
                style: HeadingH6(color: Shades.s0).semiBold,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String title1, String title2,
      [String? value1, String? value2]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (value1 == null)
                Text(title1, style: HeadingH5(color: Shades.s0).bold)
              else
                _buildLabelValue(title1, value1, CrossAxisAlignment.start),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: value1 == null
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.end,
            children: [
              if (value2 == null)
                Text(title2, style: HeadingH5(color: Shades.s0).bold)
              else
                _buildLabelValue(title2, value2, CrossAxisAlignment.end),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabelValue(String label, String value,
      [CrossAxisAlignment alignment = CrossAxisAlignment.start]) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(label, style: Paragraph02(color: Shades.s0).regular),
        Text(value, style: HeadingH6(color: Shades.s0).semiBold),
      ],
    );
  }
}
