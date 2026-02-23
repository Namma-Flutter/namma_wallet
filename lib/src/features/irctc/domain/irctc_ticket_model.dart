import 'package:dart_mappable/dart_mappable.dart';

part 'irctc_ticket_model.mapper.dart';

@MappableClass()
class IRCTCTicket with IRCTCTicketMappable {
  const IRCTCTicket({
    this.pnrNumber,
    this.passengerName,
    this.age,
    this.status,
    this.trainNumber,
    this.trainName,
    this.boardingStation,
    this.fromStation,
    this.toStation,
    this.ticketFare,
    this.irctcFee,
    this.transactionId,
    this.gender,
    this.quota,
    this.travelClass,
    this.scheduledDeparture,
    this.dateOfJourney,
    this.arrivalTime,
    this.distance,
    this.bookingDate,
    this.seatNumber,
  });

  final String? pnrNumber;
  final String? transactionId;
  final String? passengerName;
  final String? gender;
  final int? age;
  final String? status;
  final String? quota;
  final String? trainNumber;
  final String? trainName;
  final DateTime? scheduledDeparture;
  final DateTime? dateOfJourney;
  final String? arrivalTime;
  final int? distance;
  final DateTime? bookingDate;
  final String? seatNumber;
  final String? boardingStation;
  final String? travelClass;
  final String? fromStation;
  final String? toStation;
  final double? ticketFare;
  final double? irctcFee;

  String toReadableString() {
    final journeyDateStr = dateOfJourney != null
        ? '${dateOfJourney!.day.toString().padLeft(2, '0')}-'
              '${dateOfJourney!.month.toString().padLeft(2, '0')}-'
              '${dateOfJourney!.year}'
        : 'Unknown';

    final bookingDateStr = bookingDate != null
        ? '${bookingDate!.day.toString().padLeft(2, '0')}-'
              '${bookingDate!.month.toString().padLeft(2, '0')}-'
              '${bookingDate!.year}'
        : 'Unknown';

    return 'IRCTCTicket{\n'
        '  PNR: $pnrNumber\n'
        '  Passenger: $passengerName ($gender, $age)\n'
        '  Train: $trainNumber - $trainName\n'
        '  Journey: $fromStation → $toStation\n'
        '  Date: $journeyDateStr\n'
        '  Arrival: ${arrivalTime ?? 'Unknown'}\n'
        '  Distance: ${distance != null ? '$distance km' : 'Unknown'}\n'
        '  Booking Date: $bookingDateStr\n'
        '  Seat: ${seatNumber ?? 'Unknown'}\n'
        '  Class: $travelClass\n'
        '  Status: $status\n'
        '  Fare: ₹$ticketFare + ₹$irctcFee\n'
        '}';
  }
}
