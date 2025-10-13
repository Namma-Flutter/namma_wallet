import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';

class TicketLabelValueWidget extends StatelessWidget {
  const TicketLabelValueWidget(
      {required this.label,
      required this.value,
      super.key,
      this.alignment = CrossAxisAlignment.start});

  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(label, style: Paragraph02(color: Shades.s100).regular),
        Text(value, style: HeadingH6(color: Shades.s100).semiBold),
      ],
    );
  }
}

class TicketRowWidget extends StatelessWidget {
  const TicketRowWidget(
      {required this.title1,
      required this.title2,
      super.key,
      this.value1,
      this.value2});

  final String title1;
  final String title2;
  final String? value1;
  final String? value2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TicketLabelValueWidget(
            label: title1,
            value: value1 ?? '',
          ),
        ),
        Expanded(
          child: TicketLabelValueWidget(
            label: title2,
            value: value2 ?? '',
            alignment: CrossAxisAlignment.end,
          ),
        ),
      ],
    );
  }
}

class TicketFromToRowWidget extends StatelessWidget {
  const TicketFromToRowWidget({
    required this.from,
    required this.to,
    super.key,
  });

  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From', style: Paragraph02(color: Shades.s100).regular),
              Text(
                from.isNotEmpty ? from : '--',
                style: HeadingH6(color: Shades.s100).semiBold,
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
              Text('To', style: Paragraph02(color: Shades.s100).regular),
              Text(
                to.isNotEmpty ? to : '--',
                style: HeadingH6(color: Shades.s100).semiBold,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
