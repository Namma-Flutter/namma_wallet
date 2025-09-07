import 'package:flutter/material.dart';

import '../../../../styles/styles.dart';

class TicketLabelValueWidget extends StatelessWidget {
  const TicketLabelValueWidget(
      {super.key,
      required this.label,
      required this.value,
      this.alignment = CrossAxisAlignment.start});

  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(label, style: Paragraph02(color: Shades.s0).regular),
        Text(value, style: HeadingH6(color: Shades.s0).semiBold),
      ],
    );
  }
}

class TicketRowWidget extends StatelessWidget {
  const TicketRowWidget(
      {super.key,
      required this.title1,
      required this.title2,
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
            alignment: CrossAxisAlignment.start,
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
  const TicketFromToRowWidget({super.key});

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
              Text('From', style: Paragraph02(color: Shades.s0).regular),
              Text(
                '--',
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
                '--',
                style: HeadingH6(color: Shades.s0).semiBold,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
