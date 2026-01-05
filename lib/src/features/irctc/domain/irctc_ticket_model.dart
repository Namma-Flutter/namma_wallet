import 'package:dart_mappable/dart_mappable.dart';

part 'irctc_ticket_model.mapper.dart';

@MappableClass()
class IRCTCTicket with IRCTCTicketMappable {
  const IRCTCTicket({
    required this.pnrNumber,
    required this.passengerName,
    required this.age,
    required this.status,
    required this.trainNumber,
    required this.trainName,
    required this.boardingStation,
    required this.fromStation,
    required this.toStation,
    this.ticketFare,
    this.irctcFee,
    this.transactionId,
    this.gender,
    this.quota,
    this.travelClass,
    this.scheduledDeparture,
    this.dateOfJourney,
  });

  final String pnrNumber;
  final String? transactionId;
  final String passengerName;
  final String? gender;
  final int age;
  final String status;
  final String? quota;
  final String trainNumber;
  final String trainName;
  final DateTime? scheduledDeparture;
  final DateTime? dateOfJourney;
  final String boardingStation;
  final String? travelClass;
  final String fromStation;
  final String toStation;
  final double? ticketFare;
  final double? irctcFee;

  String toReadableString() {
    final journeyDateStr = dateOfJourney != null
        ? '${dateOfJourney!.day.toString().padLeft(2, '0')}-'
              '${dateOfJourney!.month.toString().padLeft(2, '0')}-'
              '${dateOfJourney!.year}'
        : 'Unknown';

    return 'IRCTCTicket{\n'
        '  PNR: $pnrNumber\n'
        '  Passenger: $passengerName ($gender, $age)\n'
        '  Train: $trainNumber - $trainName\n'
        '  Journey: $fromStation → $toStation\n'
        '  Date: $journeyDateStr\n'
        '  Class: $travelClass\n'
        '  Status: $status\n'
        '  Fare: ₹$ticketFare + ₹$irctcFee\n'
        '}';
  }
}
