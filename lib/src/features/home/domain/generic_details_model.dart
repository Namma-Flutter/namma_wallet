import 'package:dart_mappable/dart_mappable.dart';
import 'package:namma_wallet/src/features/common/domain/travel_ticket_model.dart';
import 'package:namma_wallet/src/features/home/domain/extras_model.dart';
import 'package:namma_wallet/src/features/home/domain/tag_model.dart';
import 'package:namma_wallet/src/features/home/domain/tnstc_model.dart';

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
  });

  GenericDetailsModel.fromTrainTicket(TNSTCModel ticket)
      : primaryText = ticket.pnrNo,
        secondaryText = '${ticket.from} → ${ticket.to}',
        startTime = DateTime.parse(ticket.journeyDate),
        endTime = DateTime.parse(ticket.journeyDate),
        location = ticket.boardingAt,
        type = TicketType.train,
        ticketId = null,
        tags = [
          TagModel(value: ticket.tripCode, icon: 'confirmation_number'),
          TagModel(value: ticket.pnrNo, icon: 'train'),
          TagModel(value: ticket.time, icon: 'access_time'),
          TagModel(value: ticket.seatNumbers.join(', '), icon: 'event_seat'),
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
}
