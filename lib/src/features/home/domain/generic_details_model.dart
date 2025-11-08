import 'package:dart_mappable/dart_mappable.dart';
import 'package:namma_wallet/src/features/common/domain/travel_ticket_model.dart';
import 'package:namma_wallet/src/features/home/domain/extras_model.dart';
import 'package:namma_wallet/src/features/home/domain/tag_model.dart';
import 'package:namma_wallet/src/features/tnstc/domain/tnstc_model.dart'
    as tnstc_domain;

part 'generic_details_model.mapper.dart';

@MappableClass()
class GenericDetailsModel with GenericDetailsModelMappable {
  GenericDetailsModel({
    required this.primaryText,
    required this.secondaryText,
    required this.startTime,
    required this.location,
    this.type = TicketType.bus,
    this.endTime,
    this.tags,
    this.extras,
    this.ticketId,
    this.contactMobile,
  });

  GenericDetailsModel.fromTNSTC(tnstc_domain.TNSTCTicketModel ticket)
    : primaryText = '${ticket.displayFrom} → ${ticket.displayTo}',
      secondaryText =
          '${ticket.corporation ?? 'TNSTC'} - ${ticket.routeNo ?? 'Bus'}',
      startTime = ticket.journeyDate ?? DateTime.now(),
      endTime = ticket.journeyDate ?? DateTime.now(),
      location =
          ticket.boardingPoint ?? ticket.passengerPickupPoint ?? 'Unknown',
      type = TicketType.bus,
      ticketId = null,
      contactMobile = ticket.conductorMobileNo,
      tags = [
        if (ticket.tripCode != null)
          TagModel(value: ticket.tripCode, icon: 'confirmation_number'),
        if (ticket.displayPnr.isNotEmpty)
          TagModel(value: ticket.displayPnr, icon: 'qr_code'),
        if (ticket.serviceStartTime != null)
          TagModel(value: ticket.serviceStartTime, icon: 'access_time'),
        if (ticket.seatNumbers.isNotEmpty)
          TagModel(value: ticket.seatNumbers, icon: 'event_seat'),
        if (ticket.displayFare.isNotEmpty)
          TagModel(value: ticket.displayFare, icon: 'attach_money'),
      ],
      extras = null;
  @MappableField(key: 'primary_text')
  final String primaryText;
  @MappableField(key: 'secondary_text')
  final String secondaryText;
  @MappableField(key: 'type')
  final TicketType type;
  @MappableField(key: 'start_time')
  final DateTime startTime;
  @MappableField(key: 'end_time')
  final DateTime? endTime;
  @MappableField(key: 'location')
  final String location;
  @MappableField(key: 'extras')
  final List<ExtrasModel>? extras;
  @MappableField(key: 'tags')
  final List<TagModel>? tags;
  @MappableField(key: 'ticket_id')
  final int? ticketId;
  final String? contactMobile;
}
