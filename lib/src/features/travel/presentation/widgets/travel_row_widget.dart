import 'package:flutter/material.dart';
import 'package:namma_wallet/src/features/travel/presentation/widgets/travel_label_value_widget.dart';

/// A widget that displays two label-value pairs side by side in a row.
///
/// Used in travel ticket views to show paired information like
/// "Departure | Arrival" or "Seat | Platform" in a consistent format.
class TravelRowWidget extends StatelessWidget {
  const TravelRowWidget({
    required this.title1,
    required this.title2,
    super.key,
    this.value1,
    this.value2,
  });

  /// The label for the left column
  final String title1;

  /// The label for the right column
  final String title2;

  /// The value for the left column (optional)
  final String? value1;

  /// The value for the right column (optional)
  final String? value2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TravelLabelValueWidget(
            label: title1,
            value: value1 ?? '',
          ),
        ),
        Expanded(
          child: TravelLabelValueWidget(
            label: title2,
            value: value2 ?? '',
            alignment: CrossAxisAlignment.end,
          ),
        ),
      ],
    );
  }
}
