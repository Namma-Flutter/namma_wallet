import 'package:flutter/material.dart';
import 'package:namma_wallet/src/common/theme/styles.dart';

/// A widget that displays "From" and "To" locations in a row layout.
///
/// Used in travel ticket views to show the origin and destination
/// with proper styling and alignment.
class TravelFromToRowWidget extends StatelessWidget {
  const TravelFromToRowWidget({
    required this.from,
    required this.to,
    super.key,
  });

  /// The origin/departure location
  final String from;

  /// The destination/arrival location
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
              Text(
                'From',
                style: Paragraph03(
                  color: Theme.of(context).colorScheme.onSurface,
                ).regular,
              ),
              Text(
                from.isNotEmpty ? from : '--',
                style: Paragraph02(
                  color: Theme.of(context).colorScheme.onSurface,
                ).semiBold,
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
              Text(
                'To',
                style: Paragraph03(
                  color: Theme.of(context).colorScheme.onSurface,
                ).regular,
              ),
              Text(
                to.isNotEmpty ? to : '--',
                style: Paragraph02(
                  color: Theme.of(context).colorScheme.onSurface,
                ).semiBold,
                textAlign: TextAlign.end,
                overflow: TextOverflow.clip,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
