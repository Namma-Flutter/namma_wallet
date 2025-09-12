import 'package:dart_mappable/dart_mappable.dart';
import 'package:namma_wallet/src/features/home/data/model/extras_model.dart';
import 'package:namma_wallet/src/features/home/data/model/tag_model.dart';
import 'package:namma_wallet/src/features/home/data/model/tnstc_model.dart';

part 'generic_details_model.mapper.dart';

@MappableEnum()
enum EntryType { event, busTicket, trainTicket, none }

@MappableClass()
class GenericDetailsModel with GenericDetailsModelMappable {
  GenericDetailsModel({
    required this.primaryText,
    required this.secondaryText,
    required this.startTime,
    required this.location,
    this.type = EntryType.none,
    this.endTime,
    this.tags,
    this.extras,
  });

  GenericDetailsModel.fromTrainTicket(TNSTCModel ticket)
      : primaryText = ticket.pnrNo,
        secondaryText = '${ticket.from} → ${ticket.to}',
        startTime = DateTime.parse(ticket.journeyDate),
        endTime = DateTime.parse(ticket.journeyDate),
        location = ticket.boardingAt,
        type = EntryType.trainTicket,
        tags = [
          TagModel(value: ticket.tripCode, icon: 'confirmation_number'),
          TagModel(value: ticket.pnrNo, icon: 'train'),
          TagModel(value: ticket.time, icon: 'access_time'),
          TagModel(value: ticket.seatNumbers.join(', '), icon: 'event_seat'),
        ],
        extras = null;
  final String primaryText;
  final String secondaryText;
  final EntryType type;
  final DateTime startTime;
  final DateTime? endTime;
  final String location;
  final List<ExtrasModel>? extras;
  final List<TagModel>? tags;
}
