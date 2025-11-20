import 'package:namma_wallet/src/features/home/domain/extras_model.dart';
import 'package:namma_wallet/src/features/home/domain/ticket.dart';

/// Extension methods for [Ticket] to simplify common operations
/// on ticket extras data.
extension TicketExtrasExtension on Ticket {
  /// Gets the value of an extra field by its title, normalizing the title
  /// to lowercase for case-insensitive matching.
  ///
  /// Returns the matching extra's value, or `null` if no match is found.
  ///
  /// Example:
  /// ```dart
  /// final from = ticket.getExtraByTitle('from');
  /// final to = ticket.getExtraByTitle('to');
  /// final pnr = ticket.getExtraByTitle('pnr number');
  /// ```
  String? getExtraByTitle(String title) {
    final normalizedTitle = title.toLowerCase();
    for (final extra in extras ?? <ExtrasModel>[]) {
      if (extra.title?.toLowerCase() == normalizedTitle) {
        return extra.value;
      }
    }
    return null;
  }

  /// Gets the 'From' location from ticket extras.
  ///
  /// This is a convenience method that calls [getExtraByTitle] with 'from'.
  String? get fromLocation => getExtraByTitle('from');

  /// Gets the 'To' location from ticket extras.
  ///
  /// This is a convenience method that calls [getExtraByTitle] with 'to'.
  String? get toLocation => getExtraByTitle('to');

  /// Gets the PNR number from ticket extras.
  ///
  /// This checks for 'pnr number' first, then falls back to 'booking id'.
  String? get pnrOrId {
    return getExtraByTitle('pnr number') ?? getExtraByTitle('booking id');
  }

  /// Checks if the ticket has a PNR number or booking ID.
  bool get hasPnrOrId => pnrOrId != null;
}
