import 'package:dart_mappable/dart_mappable.dart';

part 'tnstc_model.mapper.dart';

@MappableClass()
class TNSTCModel with TNSTCModelMappable {
  @MappableField(key: 'corporation')
  final String corporation;

  @MappableField(key: 'service')
  final String service;

  @MappableField(key: 'pnr_no')
  final String pnrNo;

  @MappableField(key: 'from')
  final String from;

  @MappableField(key: 'to')
  final String to;

  @MappableField(key: 'trip_code')
  final String tripCode;

  @MappableField(key: 'journey_date')
  final String journeyDate;

  @MappableField(key: 'time')
  final String time;

  @MappableField(key: 'seat_numbers')
  final List<String> seatNumbers;

  @MappableField(key: 'class')
  final String ticketClass;

  @MappableField(key: 'boarding_at')
  final String boardingAt;

  const TNSTCModel({
    required this.corporation,
    required this.service,
    required this.pnrNo,
    required this.from,
    required this.to,
    required this.tripCode,
    required this.journeyDate,
    required this.time,
    required this.seatNumbers,
    required this.ticketClass,
    required this.boardingAt,
  });
  
}
