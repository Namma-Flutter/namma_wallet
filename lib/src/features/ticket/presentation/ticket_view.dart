import 'package:flutter/material.dart';
import 'package:namma_wallet/src/core/styles/styles.dart';
import 'package:namma_wallet/src/features/ticket/presentation/widgets/custom_ticket_shape_line.dart';
import 'package:namma_wallet/src/features/ticket/presentation/widgets/ticket_view_components.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketView extends StatefulWidget {
  const TicketView({required this.ticket, super.key});
  final TNSTCTicketModel ticket;

  @override
  State<TicketView> createState() => _TicketViewState();
}

class _TicketViewState extends State<TicketView> {
  // Helper method to handle empty values
  String getValueOrDefault(String? value) {
    return (value?.isEmpty ?? true) ? '--' : value!;
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
                TicketRowWidget(
                  title1: getValueOrDefault(widget.ticket.corporation),
                  title2: getValueOrDefault(widget.ticket.routeNo),
                ),
                const SizedBox(height: 16),
                TicketFromToRowWidget(
                  fromLocation: widget.ticket.displayFrom,
                  toLocation: widget.ticket.displayTo,
                ),
                const SizedBox(height: 16),
                TicketRowWidget(
                  title1: 'Journey Date',
                  title2: 'Service Time',
                  value1: widget.ticket.displayDate,
                  value2: getValueOrDefault(widget.ticket.serviceStartTime),
                ),
                const SizedBox(height: 16),
                TicketRowWidget(
                  title1: 'PNR No.',
                  title2: 'Trip Code',
                  value1: widget.ticket.displayPnr,
                  value2: getValueOrDefault(widget.ticket.tripCode),
                ),
                const SizedBox(height: 16),
                TicketLabelValueWidget(
                    label: 'Seat Numbers',
                    value: widget.ticket.seatNumbers.isEmpty
                        ? '--'
                        : widget.ticket.seatNumbers),
                const SizedBox(height: 16),
                TicketLabelValueWidget(
                    label: 'Class', value: widget.ticket.displayClass),
                const SizedBox(height: 16),
                TicketLabelValueWidget(
                    label: 'Boarding Point',
                    value: getValueOrDefault(widget.ticket.boardingPoint)),
                const SizedBox(height: 16),
                TicketRowWidget(
                  title1: 'Total Fare',
                  title2: 'Passengers',
                  value1: widget.ticket.displayFare,
                  value2: widget.ticket.numberOfSeats?.toString() ?? '1',
                ),
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
                data: widget.ticket.displayPnr,
                size: 200,
              ),
            ),
          )
        ],
      ),
    );
  }
}
