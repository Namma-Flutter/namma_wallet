import 'package:dart_mappable/dart_mappable.dart';

part 'ticket_update_info.mapper.dart';

/// Information about a ticket update (e.g., conductor details, vehicle number).
@MappableClass()
class TicketUpdateInfo with TicketUpdateInfoMappable {
  TicketUpdateInfo({
    required this.pnrNumber,
    required this.providerName,
    required this.updates,
  });

  final String pnrNumber;
  final String providerName;
  final Map<String, Object?> updates;
}
