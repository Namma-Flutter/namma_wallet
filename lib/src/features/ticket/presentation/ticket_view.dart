import 'package:flutter/material.dart';
<<<<<<< HEAD:lib/src/features/ticket_view/ticket_view.dart
import 'package:namma_wallet/src/core/helper/check_pnr_id.dart';
import 'package:namma_wallet/src/core/helper/date_time_converter.dart';
import 'package:namma_wallet/src/features/home/data/model/generic_details_model.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/hilight_widget.dart';
import 'package:namma_wallet/src/features/ticket_view/widgets/widget.dart';
import 'package:namma_wallet/styles/styles.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketView extends StatelessWidget {
  const TicketView({required this.ticket, super.key});
  final GenericDetailsModel ticket;

=======
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
>>>>>>> main:lib/src/features/ticket/presentation/ticket_view.dart
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
      body: SingleChildScrollView(
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
                          child: Icon(ticket.type == EntryType.busTicket
                              ? Icons.airport_shuttle_outlined
                              : Icons.tram_outlined)),
                      const SizedBox(width: 16),
                      //* Description (Secondry text)
                      Text(ticket.secondaryText,
                          style: SubHeading(color: Shades.s100).regular),
                    ],
                  ),

                  const SizedBox(height: 16),

                  //* From to To (Primary text)
                  Text(ticket.primaryText,
                      style: HeadingH2Small(color: Shades.s100).bold),

                  const SizedBox(height: 16),

                  //* Date - Time
                  TicketRowWidget(
                    title1: 'Journey Date',
                    title2: 'Time',
                    value1: getValueOrDefault(getTime(ticket.startTime)),
                    value2: getValueOrDefault(getDate(ticket.startTime)),
                  ),

                  if (ticket.tags != null && ticket.tags!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...ticket.tags!.map((tag) => HighlightChipsWidget(
                              bgColor: const Color(0xffCADC56),
                              label: tag.value ?? 'xxx',
                              icon: tag.iconData ?? Icons.star_border_rounded,
                            ))
                      ],
                    ),
                  ],

                  if (ticket.extras != null && ticket.extras!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < ticket.extras!.length; i++) ...[
                          Row(
                            children: [
                              Text(
                                '${ticket.extras![i].title ?? 'xxx'}: ',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Paragraph02(color: Shades.s100).regular,
                              ),
                              Expanded(
                                  child: Text(
                                ticket.extras![i].value ?? 'xxx',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: Paragraph01(color: Shades.s100).regular,
                              )),
                            ],
                          ),
                          if (i < ticket.extras!.length - 1)
                            const SizedBox(height: 5),
                        ]
                      ],
                    ),
                  ],
                ],
              ),
            ),
<<<<<<< HEAD:lib/src/features/ticket_view/ticket_view.dart
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width * 0.95, 40),
              painter: CustomTicketShapeLine(),
            ),
            if (hasPnrOrId(ticket))
              Container(
                margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
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
                    data: getPnrOrId(ticket) ?? 'xxx',
                    size: 200,
                  ),
                ),
              )
          ],
        ),
=======
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
>>>>>>> main:lib/src/features/ticket/presentation/ticket_view.dart
      ),
    );
  }
}
