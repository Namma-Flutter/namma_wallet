import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';

/// A widget that displays a label above a value in a column layout.
///
/// Used in travel ticket views to show information like departure time,
/// seat numbers, etc. in a consistent label-value format.
class TravelLabelValueWidget extends StatelessWidget {
  const TravelLabelValueWidget({
    required this.label,
    required this.value,
    super.key,
    this.alignment = CrossAxisAlignment.start,
  });

  /// The label text shown above the value
  final String label;

  /// The value text shown below the label
  final String value;

  /// How the label and value should be aligned horizontally
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: Paragraph03(
            color: Theme.of(context).colorScheme.onSurface,
          ).regular,
        ),
        Text(
          value,
          style: Paragraph02(
            color: Theme.of(context).colorScheme.onSurface,
          ).semiBold,
        ),
      ],
    );
  }
}
