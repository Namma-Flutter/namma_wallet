import 'package:dart_mappable/dart_mappable.dart';

part 'irctc_ticket_model.mapper.dart';

@MappableClass()
class IRCTCTicket with IRCTCTicketMappable {
  const IRCTCTicket({
    required this.pnrNumber,
    required this.transactionId,
    required this.passengerName,
    required this.gender,
    required this.age,
    required this.status,
    required this.quota,
    required this.trainNumber,
    required this.trainName,
    required this.scheduledDeparture,
    required this.dateOfJourney,
    required this.boardingStation,
    required this.travelClass,
    required this.fromStation,
    required this.toStation,
    required this.ticketFare,
    required this.irctcFee,
  });

  final String pnrNumber;
  final String transactionId;
  final String passengerName;
  final String gender;
  final int age;
  final String status;
  final String quota;
  final String trainNumber;
  final String trainName;
  final DateTime scheduledDeparture;
  final DateTime dateOfJourney;
  final String boardingStation;
  final String travelClass;
  final String fromStation;
  final String toStation;
  final double ticketFare;
  final double irctcFee;

  String toReadableString() {
    return 'IRCTCTicket{\n'
        '  PNR: $pnrNumber\n'
        '  Passenger: $passengerName ($gender, $age)\n'
        '  Train: $trainNumber - $trainName\n'
        '  Journey: $fromStation → $toStation\n'
        '  Date: ${dateOfJourney.day}-'
        '${dateOfJourney.month.toString().padLeft(2, '0')}-'
        '${dateOfJourney.year}\n'
        '  Class: $travelClass\n'
        '  Status: $status\n'
        '  Fare: ₹$ticketFare + ₹$irctcFee\n'
        '}';
  }
}
