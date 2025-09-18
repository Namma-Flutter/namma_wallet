import 'package:flutter/material.dart';
import 'package:namma_wallet/src/core/helper/check_pnr_id.dart';
import 'package:namma_wallet/src/core/helper/date_time_converter.dart';
import 'package:namma_wallet/src/core/styles/styles.dart';
import 'package:namma_wallet/src/features/home/domain/generic_details_model.dart';
import 'package:namma_wallet/src/features/home/presentation/widgets/hilight_widget.dart';
import 'package:namma_wallet/src/features/ticket_view/widgets/widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketView extends StatelessWidget {
  const TicketView({required this.ticket, super.key});
  final GenericDetailsModel ticket;

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
                        ...ticket.tags!.map((tag) => const HighlightChipsWidget(
                              bgColor: Color(0xffCADC56),
                              label: 'xxx',
                              icon: Icons.star_border_rounded,
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
                                ticket.extras![i].value,
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
      ),
    );
  }
}
